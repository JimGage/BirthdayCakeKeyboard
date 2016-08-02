// This is code that drives the Birthday Cake number pad board.  
// It's meant to drive ZealPC RGB LEDs.

// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated 
// documentation files( the "Software" ), to deal in the Software without restriction, including without 
// limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
// of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// 
// There's not a lot of code here so do whatever you want with it.  
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE 
// WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.IN NO EVENT SHALL THE AUTHORS OR 
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#include "usb_keyboard.h"

#include <string.h>

#include <util/delay.h>
#include <avr/wdt.h>
#include <avr/io.h>
#include <avr/interrupt.h>
#include <avr/power.h>
#include <util/twi.h>

//----------------------------------------------------------------------------

#define BOOTLOADER_START_ADDRESS						  0x3800

void bootloader(void)
{ 		
   ((void (*)(void))BOOTLOADER_START_ADDRESS)();
}

//----------------------------------------------------------------------------

static uint16_t const skKeyCodes[5][4] =
{
   { KEY_NUM_LOCK, KEYPAD_SLASH, KEYPAD_ASTERIX, KEYPAD_MINUS },
   { KEYPAD_7, KEYPAD_8, KEYPAD_9, KEYPAD_PLUS },
   { KEYPAD_4, KEYPAD_5, KEYPAD_6, 0 },
   { KEYPAD_1, KEYPAD_2, KEYPAD_3, KEYPAD_ENTER },
   { KEYPAD_0, 0, KEYPAD_PERIOD, 0 }
};


// structure to hold an RGB color
typedef struct 
{
   uint8_t mRed;
   uint8_t mGreen;
   uint8_t mBlue;
} SRGB;

#define GREEN { 0, 255, 0 }
#define RED { 255, 0, 0 }
#define ORANGE { 255, 255, 0 }
#define BLUE { 0, 0, 255 }
#define CYAN { 0, 255, 255 }
#define YELLOW { 255, 255, 0 }
#define PURPLE { 128, 0, 64 }
#define BLACK { 0, 0, 0 }

// Some colors to cycle through
SRGB const gColorChain[8] =
{ 
   GREEN, YELLOW, ORANGE, RED,   PURPLE, CYAN, BLUE, BLACK 
};

// bit mask to turn off all LEDs
static uint8_t const skAllOff = 0x7;

// global variables used by the animation code
uint16_t gColorChainIndex = 0;
uint16_t gTimeOutTime = 0;

// color buffer to be rendered
SRGB gColorBuffer[5][4] =
{
   0
};


//----------------------------------------------------------------------------

void SetupHardware( void )
{
   // Hardware Initialization 
   // 0 = INPUT
   // 1 = output

   DDRB = 0x80; // 7 is output
   PORTB = 0x71; // pull all the pins not in use high

   DDRC = 0xC0; // 6 & 7 are output

   DDRD = 0xFF; // all d pins are out
   PORTD = 0xFF; // set all of PORTF high

   DDRE = 0x40; // pin 6 is out
   PORTE = 0x40; // set all of PORTE high to turn off LEDs

   DDRF = 0x73;   // 0,1, 4, 5, and 6 are output
   PORTF = 0x73;  // set all of PORTF high to turn off LEDs
}

//----------------------------------------------------------------------------

// copy a color from one RGB element to another
void CopyColor(SRGB const * const source, SRGB * const dest)
{
   dest->mRed = source->mRed;
   dest->mGreen = source->mGreen;
   dest->mBlue = source->mBlue;
}

//----------------------------------------------------------------------------

void SlowFadeChannel(uint8_t const source, uint8_t * const dest)
{
   // need some room to prevent overflow
   uint16_t const higherPrecisionDest = *dest;

   *dest = (uint8_t)(( higherPrecisionDest * 7 + source ) >> 3);
}

//----------------------------------------------------------------------------

void SlowFade(SRGB const * const source, SRGB * const dest)
{
   SlowFadeChannel( source->mRed, &dest->mRed );
   SlowFadeChannel( source->mGreen, &dest->mGreen );
   SlowFadeChannel( source->mBlue, &dest->mBlue );
}

//----------------------------------------------------------------------------

// High is off, Low is on

// RGB 0 = PD2, PD3, PD4
// RGB 1 = PD5, PD6, PD7
// RGB 2 = PE6, PF0, PF1
// RGB 3 = PF4, PF5, PF6

//----------------------------------------------------------------------------
// set the first column of LEDs 
void RGB0(uint8_t const bitMask)
{
// red and blue
   PORTD = (PORTD & ~0x1C) | ( bitMask << 2 );
}

//----------------------------------------------------------------------------
// set the second column of LEDs 
void RGB1(uint8_t const bitMask)
{
   PORTD = (PORTD & ~0xE0) | (bitMask << 5);
}

//----------------------------------------------------------------------------
// set the third column of LEDs 
void RGB2(uint8_t const bitMask)
{
   PORTE = ( PORTE & ~0x40 ) | ( ( bitMask & 0x01 ) << 6 );
   PORTF = ( PORTF & ~0x03 ) | ( ( bitMask & 0x06 ) >> 1 );
}

//----------------------------------------------------------------------------
// set the fourth column of LEDs 
void RGB3(uint8_t const bitMask)
{
   PORTF = ( PORTF & ~0xF0 ) | ( bitMask << 4);
}

//----------------------------------------------------------------------------
// Set the bitmask for an LED column
void RGB(uint8_t const columnIndex, uint8_t const bitMask)
{
   switch (columnIndex)
   {
   case 0:
      RGB0( bitMask );
      break;
   case 1:
      RGB1( bitMask );
      break;
   case 2:
      RGB2( bitMask );
      break;
   case 3:
      RGB3( bitMask );
      break;
   default:
      break;
   }
}

//----------------------------------------------------------------------------
// Set the bitmask for all LED columns
void RGBAll(uint8_t const bitMask)
{
   RGB0(bitMask);
   RGB1(bitMask);
   RGB2(bitMask);
   RGB3(bitMask);
}

//----------------------------------------------------------------------------
// For a given color create an LED mask for where it should be shifted
uint8_t const MakeRGBMask(uint8_t const red, uint8_t const green, uint8_t const blue, uint8_t const shiftIndex)
{
   return
      ( ( ( red >> shiftIndex ) & 1 ) ^ 1 ) |
      ( ( ( ( green >> shiftIndex ) & 1 ) ^ 1 ) << 1 ) |
      ( ( ( ( blue >> shiftIndex ) & 1 ) ^ 1 ) << 2 );
}

//----------------------------------------------------------------------------

void UpdateLEDRow(uint8_t const row)
{
   uint8_t index = 0;
   uint8_t maskShift = 4;
   uint16_t delayTime = 16;


   // Different shades of colors are created by having an LED on for a certain period of time.
   // Rather than using a PWM signal an LED can be turned on and off multiple times for
   // a single cycle with increasing lengths based on which bits are set in the color.

   // unrolled loop 
   for (index = 0; index < 4; ++index)
   {
      RGB( index, MakeRGBMask( gColorBuffer[row][index].mRed,
                               gColorBuffer[row][index].mGreen,
                               gColorBuffer[row][index].mBlue, 
                               maskShift ) );
   }
   _delay_us(delayTime);
   delayTime = delayTime << 1;
   maskShift++;

   for (index = 0; index < 4; ++index)
   {
      RGB( index, MakeRGBMask( gColorBuffer[row][index].mRed,
                               gColorBuffer[row][index].mGreen,
                               gColorBuffer[row][index].mBlue, 
                               maskShift ) );
   }
   _delay_us(delayTime);
   delayTime = delayTime << 1;
   maskShift++;

   for (index = 0; index < 4; ++index)
   {
      RGB( index, MakeRGBMask( gColorBuffer[row][index].mRed,
                               gColorBuffer[row][index].mGreen,
                               gColorBuffer[row][index].mBlue, 
                               maskShift ) );
   }
   _delay_us(delayTime);
   delayTime = delayTime << 1;
   maskShift++;

   for (index = 0; index < 4; ++index)
   {
      RGB( index, MakeRGBMask( gColorBuffer[row][index].mRed,
                               gColorBuffer[row][index].mGreen,
                               gColorBuffer[row][index].mBlue, 
                               maskShift ) );
   }
   _delay_us(delayTime);

   // turn everything off
   RGBAll(skAllOff);
   _delay_us(50);

}

//----------------------------------------------------------------------------

// Simple animation to start a color at the bottom slowly fade up

void UpdateLEDAnimation()
{
   uint8_t row = 0;
   gColorChainIndex++;
   SlowFade(&gColorChain[(gColorChainIndex >> 8) & 7], &gColorBuffer[4][1]);
   SlowFade(&gColorChain[(gColorChainIndex >> 8) & 7], &gColorBuffer[4][2]);

   SlowFade(&gColorBuffer[4][1], &gColorBuffer[4][0]);
   SlowFade(&gColorBuffer[4][2], &gColorBuffer[4][3]);

   for (row = 4; row != 0; --row)
   {
      SlowFade(&gColorBuffer[row][0], &gColorBuffer[row - 1][0]);
      SlowFade(&gColorBuffer[row][1], &gColorBuffer[row - 1][1]);
      SlowFade(&gColorBuffer[row][2], &gColorBuffer[row - 1][2]);
      SlowFade(&gColorBuffer[row][3], &gColorBuffer[row - 1][3]);
   }
}

//----------------------------------------------------------------------------

void SetOutputPinsForRow( uint8_t const row )
{
   // ROW0 = PB7, ROW1 = PC6, ROW2 = PC7, ROW3 = PD0, ROW4 = PD1
   // COL0 = PB0, COL1 = PB4, COL2 = PB5, COL3 = PB6

   // Each row is held low to drive it and high to clear it

   PORTB |= 0x80;  // clear pb7
   PORTC |= (0x80 | 0x40); // clear pc6 and pc7
   PORTD |= (0x01 | 0x02);

   switch (row)
   {
   case 0:
      PORTB &= ~0x80;
      break;
   case 1:
      PORTC &= ~0x40;
      break;
   case 2:
      PORTC &= ~0x80;
      break;
   case 3:
      PORTD &= ~0x01;
      break;
   case 4:
      PORTD &= ~0x02;
      break;
   default:
      break;
   }
}

//----------------------------------------------------------------------------

void UpdateLEDs()
{
   uint8_t row = 0;

   if (gTimeOutTime >= (1 << (8+3)) )
   {
      RGBAll(skAllOff);
      _delay_us(50);
      return;
   }

   gTimeOutTime++;

   UpdateLEDAnimation();

   for (row = 0; row < 5; ++row)
   {
      SetOutputPinsForRow(row);

      // do the LEDs, this will give the switch a little bit of 
      // time to settle
      UpdateLEDRow(row);
   }

}

//----------------------------------------------------------------------------

void CreateKeyboardReport( )
{
   static int count = 0;
   uint8_t UsedKeyCodes = 0;

   uint8_t row = 0;
   uint8_t column = 0;
   uint8_t data = 0;
   uint8_t data_debounce = 0;

   memset(keyboard_keys, 0, sizeof(keyboard_keys));
   keyboard_modifier_keys = 0;

   for (row = 0; row < 5; ++row)
   {
      SetOutputPinsForRow(row);

      _delay_us(10);

      data_debounce = (PINB & 0x01) | ((PINB & 0x70) >> 3);

      _delay_us(50);

      // OR with the debounce since we looking for low values
      data = ( (PINB & 0x01) | ( ( PINB & 0x70 ) >> 3 ) ) | data_debounce;

      for (column = 0; column < 4; ++column)
      {
         if (((data >> column) & 1) == 0)
         {
            if (skKeyCodes[row][column] > 0x100)
            {
               keyboard_modifier_keys |= (skKeyCodes[row][column] & 0xff);
               gTimeOutTime = 0;
            }
            else
            {
               keyboard_keys[UsedKeyCodes++] = (uint8_t)(skKeyCodes[row][column]);
               gTimeOutTime = 0;
            }

            if (UsedKeyCodes >= 6)
            {
               return;
            }
         }
      }

   }

   usb_keyboard_send();
}

//----------------------------------------------------------------------------

int main(void)
{
   SetupHardware();

   usb_init();

   while (!usb_configured());

   for (;;)
   {
      UpdateLEDs();
      CreateKeyboardReport();
   }

   return 0;
}
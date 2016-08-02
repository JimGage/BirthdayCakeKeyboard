# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated 
# documentation files( the "Software" ), to deal in the Software without restriction, including without 
# limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
# of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# 
# There's not a lot of code here so do whatever you want with it.  
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE 
# WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.IN NO EVENT SHALL THE AUTHORS OR 
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
# OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

CCPP=avr-g++
CC=avr-gcc
ld=avr-gcc
OBJCOPY=avr-objcopy
TARGET=driver
TARGETELF=$(TARGET).elf
TARGETHEX=$(TARGET).hex
OBJS=main.o usb_keyboard.o
PROGRAMMER=usbtiny

CPU_SPEED=-DF_CPU=16000000UL
TARGETOPTIONS=-mmcu=atmega32u4
# -Wl,--verbose -v -save-temps
CFLAGS=$(TARGETOPTIONS) $(CPU_SPEED) -O3 


all: $(TARGET)


$(TARGET): $(OBJS)
	$(CC) $(TARGETOPTIONS) $(OBJS) -o $(TARGETELF)
	$(OBJCOPY) -j .text -j .data -O ihex $(TARGETELF) $(TARGETHEX)

.cpp.o:
	$(CCPP) $(CFLAGS) $(INCLUDES) -c $<  -o $@


Upload: $(TARGET)
	avrdude -C avrdude.conf -c $(PROGRAMMER) -p m32u4 -U flash:w:$(TARGETHEX)
	
clean:
	rm *.o
	rm $(TARGETELF)
	rm $(TARGETHEX)

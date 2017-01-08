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


// This the source file for my number pad case.  

//----------------------------------------------------------------------------

// set to use costar or cherry stabilizers
useCostarStabs = false;
useCherryStabs = true;

// Set to true to add ribs to the plate
addPlateSupports = false;
addBoxSupports = true;


// some constants
skSpaceBetweenSwitches = 19;
skTolerance = 0.2;

skPlateThickness = 1.5;

skScrewDiameter = 3;
skScrewHeadDiameter = 6;

// how tall the box is
skBoxDepth = 10;

skPlateOffset = 17;

// comment or uncomment to create a part
//Box();
Plate();
//rotate([180,0,0])TopBezel();
//CutOpen();
//Everything();


//----------------------------------------------------------------------------

// cut the box and plate open to see inside
module CutOpen()
{
    difference()
    {
        Everything();
        translate([0,15,0])cube([100,50,100],true);
        
        // inspect the screw holes from below
        //translate([0,0,-22])cube([100,150,50],true);
        
        // inspect the screw holes from the side
        translate([85,0,0])cube([100,150,100],true);

    }
}

//----------------------------------------------------------------------------

module Everything()
{
    union()
    {
        color([1,0.3,0.3]) Box();
        color([0.4,0.4,0.4])translate([0,0,skBoxDepth+2.1])rotate([2,0,0])Plate();
        color([1,0.4,0.4]) rotate([2,0,0])translate([0,.3,skBoxDepth+3]) TopBezel();
    }
}


//----------------------------------------------------------------------------

module OneUnitCutOut()
{
    cube([14+skTolerance,14+skTolerance,3], true );
    
    // horizontal clip cutouts
    translate([0,(5 + 3.5)/2,0]) cube([15.6+skTolerance,3.5+skTolerance,3], true );
    translate([0,-(5 + 3.5)/2,0]) cube([15.6+skTolerance,3.5+skTolerance,3], true );

}

//----------------------------------------------------------------------------

module LeftStabalizerCutout( halfWidth )
{

    if ( useCostarStabs )
    {
        translate([0.25,-0.5,0])cube([3.05, 14, 3], true );    
    }
    
    if ( useCherryStabs )
    {
        translate([-0.3,-0.5,0])translate([0.3,0,0])cube([6.4+skTolerance,12.46+skTolerance,3],true);
        translate([0,1,0])cube([8.4+skTolerance, 2.79+skTolerance, 3], true );    
        translate([0.25,-1.6,0])cube([3.05+skTolerance, 12+skTolerance, 3], true );    
        translate([halfWidth/2,-0.5,0])cube([halfWidth, 10.6, 3 ], true );
    }
}

//----------------------------------------------------------------------------

module RightStabalizerCutout( halfWidth )
{
    if ( useCostarStabs )
    {
        translate([-0.25,-0.5,0])cube([3.05+skTolerance, 14+skTolerance, 3], true );    
    }
    
    if ( useCherryStabs )
    {
        translate([-0.5,-0.5,0])translate([0.3,0,0])cube([6.4+skTolerance,12.46+skTolerance,3],true);
        translate([0,1,0])cube([8.4+skTolerance, 2.79+skTolerance, 3], true );    
        translate([-0.25,-1.6,0])cube([3.05+skTolerance, 12+skTolerance, 3], true );    
        translate([-halfWidth/2,-0.5,0])cube([halfWidth, 10.6+skTolerance, 3 ], true );
    }
}

//----------------------------------------------------------------------------

module StabalizerCutOut( width )
{
    translate([-width/2,0,0]) LeftStabalizerCutout( width/2);
    translate([width/2,0,0]) RightStabalizerCutout( width/2);
}

//----------------------------------------------------------------------------

module TwoUnitCutOut()
{
    OneUnitCutOut();
    
    StabalizerCutOut( 24.0 );
}

//----------------------------------------------------------------------------

module BlankPlate( thickness = skPlateThickness, tolerance = 0 )
{
    hull()
    {
        $fn = 20;
        translate([-35, 50, 0])  cylinder(thickness, r = 3 + tolerance, true );
        translate([-35, -50, 0])  cylinder(thickness, r = 3+ tolerance, true );
        translate([35, -50, 0])  cylinder(thickness, r = 3 + tolerance,true );
        translate([35, 50, 0])  cylinder(thickness, r = 3 + tolerance, true );
    }

}

//----------------------------------------------------------------------------

module BlankBox( thickness = skPlateThickness, tolerance = 0, skewHeight = 4, sideRotation = 0 )
{
    difference()
    {
        hull()
        {
            $fn = 100;
            translate([-34, 49, 0])  rotate([sideRotation,0,0])cylinder(thickness+skewHeight, r = 6, true );
            translate([-34, -49, 0])  rotate([sideRotation,0,0])cylinder(thickness, r = 6, true );
            translate([34, -49, 0])  rotate([sideRotation,0,0])cylinder(thickness, r = 6,true );
            translate([34, 49, 0])  rotate([sideRotation,0,0])cylinder(thickness+skewHeight, r = 6, true );
        }
        
        //translate([0,0,10+thickness-tolerance])cube([120,120,20],true);
    }
}

//----------------------------------------------------------------------------

module BezelCutOut( thickness = skPlateThickness, tolerance = 0 )
{
    hull()
    {
        
        $fn = 20;
        translate([-37, 46.5, 0])  rotate([-4,0,0])cylinder(thickness, r = 1 + tolerance, true );
        translate([-37, -46, 0])  rotate([4,0,0])cylinder(thickness, r = 1+ tolerance, true );
        translate([37, -46, 0])  rotate([4,0,0])cylinder(thickness, r = 1 + tolerance,true );
        translate([37, 46.5, 0])  rotate([-4,0,0])cylinder(thickness, r = 1 + tolerance, true );
    }

}

//----------------------------------------------------------------------------

module TopBezel()
{
    difference()
    {
        minkowski()
        {
            BlankBox( 3.2, .2, 0,  -2 );
            // put a rounded edge on the box
            sphere( r = 1, $fn=40 );
        }
        
        translate([0,0,-3]) BezelCutOut( 15 );
        translate([0,0,-2.5])cube([200,200,5], true );
        
        translate([0,0,-.3]) BlankPlate( 1, 0.4 );
        
        
        union()
        {
            $fn = 20;
            translate([-35, 50.3, -1])  rotate([-2,0,0])cylinder(4, d = skScrewDiameter, true );
            translate([-35, -49.7, -1])  rotate([-2,0,0])cylinder(4, d = skScrewDiameter, true );
            translate([35, -49.7, -1])  rotate([-2,0,0])cylinder(4, d = skScrewDiameter,true );
            translate([35, 50.3, -1])  rotate([-2,0,0])cylinder(4, d = skScrewDiameter, true );
        }
        
    }
}


//----------------------------------------------------------------------------

module corner( xOffset, yOffset, extraHeight = 0 )
{
    $fn = 30;
    translate([35 * xOffset, 50 * yOffset, 0])
    hull()
    {
        cylinder(14, d = 5, true );
        translate([xOffset * 3, 0, 0 ]) cylinder(14, d = 5, true );
        translate([0, yOffset * 3, 0 ]) cylinder(14, d = 5, true );
    }

    translate([35 * xOffset, 50 * yOffset, 0])
    hull()
    {
        cylinder(6+extraHeight, d = 7.5, true );
        cylinder(1, d = 8, true );
        translate([xOffset * 3, 0, 0 ]) cylinder(6+extraHeight, d = 5, true );
        translate([0, yOffset * 3, 0 ]) cylinder(6+extraHeight, d = 5, true );
    }
    
}

//----------------------------------------------------------------------------

module Box()
{
    difference()
    {
        minkowski()
        {
            
            BlankBox(skBoxDepth);
            // put a rounded edge on the box
            sphere( r = 1, $fn=40 );
        }
        
        // cut out the plate
        translate([0,0,2]) BlankPlate( skBoxDepth + 4, 0.4 );

        // usb access
        translate([0,55,6])
        hull()
        {
            translate([0,-2,0]) cube([12,1,6],true);
            translate([0,1,0]) cube([16,.1,10],true);
        }
        
        // access into the box for underside screws
        union()
        {
            $fn = 20;
            translate([-35, 50, -1.1])  cylinder(5, d = 6, true );
            translate([-35, -50, -1.1])  cylinder(5, d = 6, true );
            translate([35, -50, -1.1])  cylinder(5, d = 6,true );
            translate([35, 50, -1.1])  cylinder(5, d = 6, true );
        }

    }

    // all of the screw hole support stuff
    difference()
    {
        // support
        union()
        {
            corner( -1,  1, 3 );
            corner( -1, -1, 0 );
            corner(  1, -1, 0 );
            corner(  1,  1, 3 );
            
            if ( addBoxSupports )
            {
                $fn = 12;
                skBoxSupportDiameter = 5;
                translate([skSpaceBetweenSwitches *  1, skSpaceBetweenSwitches *  1.5, 1]) cylinder( skBoxDepth + 4, d = skBoxSupportDiameter );
                translate([skSpaceBetweenSwitches * -1, skSpaceBetweenSwitches *  1.5, 1]) cylinder( skBoxDepth + 4, d = skBoxSupportDiameter );
                translate([skSpaceBetweenSwitches * -1, skSpaceBetweenSwitches * -0.5, 1]) cylinder( skBoxDepth + 4, d = skBoxSupportDiameter );
                translate([skSpaceBetweenSwitches *  1, skSpaceBetweenSwitches * -0.5, 1]) cylinder( skBoxDepth + 4, d = skBoxSupportDiameter );
            }
            
        }
        
        // cut the top off at an angle
        translate([0,0,skPlateOffset])rotate([2,0,0])cube([100,150, 10], true );

        // box screw holes
        union()
        {
            $fn = 20;
            translate([-35, 50, 0])  cylinder(14, d = skScrewDiameter, true );
            translate([-35, -50, 0])  cylinder(14, d = skScrewDiameter, true );
            translate([35, -50, 0])  cylinder(14, d = skScrewDiameter,true );
            translate([35, 50, 0])  cylinder(14, d = skScrewDiameter, true );
        }
        
        // access underneath for screw heads
        union()
        {
            $fn = 20;
            translate([-35, 50, -1.1])  cylinder(8, d = skScrewHeadDiameter, true );
            translate([-35, -50, -1.1])  cylinder(5, d = skScrewHeadDiameter, true );
            translate([35, -50, -1.1])  cylinder(5, d = skScrewHeadDiameter,true );
            translate([35, 50, -1.1])  cylinder(8, d = skScrewHeadDiameter, true );
        }
    }
}

//----------------------------------------------------------------------------

module Plate()
{
    difference()
    {
        union()
        {
            BlankPlate();
            
            if ( addPlateSupports )
            {
                translate([-9.5,9.5,-0.4])cube([55,1,2],true);
                translate([0,9.5-19,-0.4])cube([75,1,2],true);
                translate([0,9.5+19,-0.4])cube([75,1,2],true);
                translate([-9.5,9.5-38,-0.4])cube([55,1,2],true);
                
                translate([0,0,-0.4])cube([2,100,2],true);
                translate([skSpaceBetweenSwitches*2-1,0,-0.9])cube([1,90,2],true);
                translate([-skSpaceBetweenSwitches,12,-0.9])cube([2,75,2],true);
                translate([-skSpaceBetweenSwitches*2+1,12,-0.9])cube([1,70,2],true);
            }
        }

        // add screw holes
        translate([0,0,-10])
        {
            $fn = 20;
            translate([-35, 50, 0])  cylinder(20, d = skScrewDiameter, true );
            translate([-35, -50, 0])  cylinder(20, d = skScrewDiameter, true );
            translate([35, -50, 0])  cylinder(20, d = skScrewDiameter,true );
            translate([35, 50, 0])  cylinder(20, d = skScrewDiameter, true );
        }

        // add the actual switch holes
        translate([-skSpaceBetweenSwitches/2,0,.1])
        {
            // top row
            translate([skSpaceBetweenSwitches *  2, skSpaceBetweenSwitches *  2, 0]) OneUnitCutOut();
            translate([skSpaceBetweenSwitches *  1, skSpaceBetweenSwitches *  2, 0]) OneUnitCutOut();
            translate([skSpaceBetweenSwitches *  0, skSpaceBetweenSwitches *  2, 0]) OneUnitCutOut();
            translate([skSpaceBetweenSwitches * -1, skSpaceBetweenSwitches *  2, 0]) OneUnitCutOut();

            // second row
            translate([skSpaceBetweenSwitches *  1, skSpaceBetweenSwitches *  1, 0]) OneUnitCutOut();
            translate([skSpaceBetweenSwitches *  0, skSpaceBetweenSwitches *  1, 0]) OneUnitCutOut();
            translate([skSpaceBetweenSwitches * -1, skSpaceBetweenSwitches *  1, 0]) OneUnitCutOut();


            // third row
            translate([skSpaceBetweenSwitches *  1, skSpaceBetweenSwitches *  0, 0]) OneUnitCutOut();
            translate([skSpaceBetweenSwitches *  0, skSpaceBetweenSwitches *  0, 0]) OneUnitCutOut();
            translate([skSpaceBetweenSwitches * -1, skSpaceBetweenSwitches *  0, 0]) OneUnitCutOut();

            // fourth row
            translate([skSpaceBetweenSwitches *  1, skSpaceBetweenSwitches * -1, 0]) OneUnitCutOut();
            translate([skSpaceBetweenSwitches *  0, skSpaceBetweenSwitches * -1, 0]) OneUnitCutOut();
            translate([skSpaceBetweenSwitches * -1, skSpaceBetweenSwitches * -1, 0]) OneUnitCutOut();

            // fifth row
            translate([skSpaceBetweenSwitches *  1, skSpaceBetweenSwitches * -2, 0]) OneUnitCutOut();

            translate([skSpaceBetweenSwitches *  -0.5, skSpaceBetweenSwitches * -2, 0]) TwoUnitCutOut();
            
            translate([skSpaceBetweenSwitches *  2, skSpaceBetweenSwitches * -1.5, 0]) rotate([0,0,-90])TwoUnitCutOut();
            translate([skSpaceBetweenSwitches *  2, skSpaceBetweenSwitches *  0.5, 0]) rotate([0,0,-90])TwoUnitCutOut();

        }
    }
}

//----------------------------------------------------------------------------

//translate([skSpaceBetweenSwitches *  1.5, skSpaceBetweenSwitches *  2, 15]) rotate([2,0,0])KeyCap();

module KeyCap()
{
    hull()
    {
        cube([18.5,18.5,.1],true);
        translate([0,0,12.3])cube([13.6,13.6,.1],true);
    }
}
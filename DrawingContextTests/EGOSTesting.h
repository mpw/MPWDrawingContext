//
//  EGOSTesting.h
//  EGOS
//
//  Created by Marcel Weiher on 1/2/13.
//
//

#import <MPWFoundation/DebugMacros.h>

@class CALayer,NSBitmapImageRep;

NSBitmapImageRep *bitmapForLayer( CALayer* layer );

BOOL imageCompare( NSBitmapImageRep* image1, NSBitmapImageRep *image2,NSString *name, BOOL shouldMatch);

#define IMAGEEXPECT( image1, image2, msg ) \
EXPECTTRUE( imageCompare( image1, image2, msg, YES) , msg@" look in /tmp " )

#define IMAGENOTEXPECT( image1, image2, msg ) \
EXPECTTRUE( imageCompare( image1, image2, msg, NO) , msg@" look in /tmp " )

#define BUNDLEIMAGE(name) [NSBitmapImageRep imageRepWithContentsOfFile:[[NSBundle bundleForClass:self] pathForImageResource:name]] 

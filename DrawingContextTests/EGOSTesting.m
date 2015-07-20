//
//  EGOSTesting.m
//  EGOS
//
//  Created by Marcel Weiher on 1/2/13.
//
//

#import "EGOSTesting.h"
#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import "MPWCGDrawingContext.h"


BOOL imageCompare( NSBitmapImageRep* image1, NSBitmapImageRep *image2,NSString *name, BOOL shouldMatch)
{
    NSData *png1=[image1 representationUsingType:NSPNGFileType properties:nil];
    NSData *png2=[image2 representationUsingType:NSPNGFileType properties:nil];
    BOOL areEqual = [png1 isEqualToData:png2];
    BOOL testOK = (areEqual && shouldMatch) || (!areEqual && !shouldMatch) ;
    if ( !testOK   ) {
        NSString *n1=[NSString stringWithFormat:@"/tmp/%@-failure-actual.png",name];
        NSString *n2=[NSString stringWithFormat:@"/tmp/%@-failure-expected.png",name];
        [png1 writeToFile:n1 atomically:YES];
        [png2 writeToFile:n2 atomically:YES];
        NSString* cmd = [NSString stringWithFormat:@"open %@ %@",png1 ?n1:@"",png2?n2:@""];
        
        system([cmd fileSystemRepresentation]);
    }
    return testOK;
}



NSBitmapImageRep *bitmapForLayer( CALayer* layer )
{
    CGRect r=[layer frame];
    NSRect layerRect=NSMakeRect(r.origin.x,r.origin.y,r.size.width,r.size.height);
    MPWCGBitmapContext *c=[MPWCGBitmapContext rgbBitmapContext:layerRect.size];
    [c drawImage:layer];
    
    return [c image];
}

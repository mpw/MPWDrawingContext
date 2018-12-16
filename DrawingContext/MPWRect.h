/* MPWRect.h Copyright (c) 1998-2017 by Marcel Weiher, All Rights Reserved.
*/


#import <Foundation/Foundation.h>
#import "PhoneGeometry.h"

@class MPWPoint;



@interface MPWRect : NSObject

@property NSRect rect;

+rectWithNSRect:(NSRect)aRect;
+rectWithNSString:(NSString*)string;
-initWithRect:(NSRect)aRect;
-origin;
-mpwSize;

-(double)x;
-(double)y;
-(double)width;
-(double)height;
-(NSRect)rectValue;



@end
@interface NSString(rectCreation)

-asRect;
-(NSRect)rectValue;

@end

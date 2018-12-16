/* MPWPoint.h Copyright (c) 1998-2017 by Marcel Weiher, All Rights Reserved.
*/


#import <Foundation/Foundation.h>
#import "PhoneGeometry.h"


@class MPWRect;


@interface MPWPoint : NSObject


@property () NSPoint point;

-(NSSize)asSize;
+pointWithNSPoint:(NSPoint)aPoint;
+pointWithNSSize:(NSSize)aSize;
+pointWithNSString:(NSString*)string;
+pointWithX:(float)x y:(float)y;
-(double)x;
-(double)y;
+zero;
-(MPWRect*)extent:otherPoint;
-(NSPoint)pointValue;

@end
@interface NSString(pointCreation)

-asPoint;
-(NSPoint)point;
-(NSSize)asSize;

@end

@interface NSNumber(pointCreation)

-pointWith:otherNumber;

@end

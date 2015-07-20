//
//  MPWCGPathCreationContext.h
//  EGOS
//
//  Created by Marcel Weiher on 5/17/13.
//
//

#import "MPWAbstractCGContext.h"
#import <QuartzCore/QuartzCore.h>

@interface MPWCGPathCreationContext : MPWAbstractCGContext
{
    CGMutablePathRef currentPath;
}


-path;
+context;

@end

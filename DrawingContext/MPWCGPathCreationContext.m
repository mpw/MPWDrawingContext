//
//  MPWCGPathCreationContext.m
//  EGOS
//
//  Created by Marcel Weiher on 5/17/13.
//
//

#import "MPWCGPathCreationContext.h"

@implementation MPWCGPathCreationContext

+(id)context
{
    return [[[self alloc] init] autorelease];
}

-(id)init
{
    self=[super init];
    currentPath=CGPathCreateMutable();
    return self;
}

-moveto:(float)x :(float)y
{
	CGPathMoveToPoint(currentPath, NULL,  x, y );
	return self;
}


-lineto:(float)x :(float)y
{
	CGPathAddLineToPoint(currentPath, NULL,  x, y );
	return self;
}

-curveto:(float)cp1x :(float)cp1y :(float)cp2x :(float)cp2y :(float)x :(float)y
{
    CGPathAddCurveToPoint(currentPath, NULL,  cp1x, cp1y, cp2x, cp2y, x,y );
    return self;
}


-arcWithCenter:(NSPoint)center radius:(float)radius startDegrees:(float)start endDegrees:(float)stop  clockwise:(BOOL)clockwise
{
	CGPathAddArc(currentPath, NULL,  center.x,center.y, radius , start * (M_PI/180), stop *(M_PI/180), clockwise);
	return self;
}

-arcFromPoint:(NSPoint)p1 toPoint:(NSPoint)p2 radius:(float)radius
{
    CGPathAddArcToPoint( currentPath, NULL , p1.x, p1.y,p2.x, p2.y,  radius);
    return self;
    
}

-closepath
{
	CGPathCloseSubpath(currentPath);
	return self;
}


-nsrect:(NSRect)r
{
	CGPathAddRect( currentPath, NULL , CGRectMake(r.origin.x, r.origin.y, r.size.width, r.size.height) );
	return self;
}

-ellipseInRect:(NSRect)r
{
    CGPathAddEllipseInRect( currentPath, NULL , CGRectMake(r.origin.x, r.origin.y, r.size.width, r.size.height));
    return self;
}

-path
{
    return (id)currentPath;
}

-(void)dealloc
{
    if ( currentPath) {
        CGPathRelease(currentPath);
    }
    [super dealloc];
}

@end

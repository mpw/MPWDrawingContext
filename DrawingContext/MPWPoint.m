/* MPWPoint.m Copyright (c) 1998-2017 by Marcel Weiher, All Rights Reserved.
*/


#import "MPWPoint.h"
#import "MPWRect.h"
#import "AccessorMacros.h"


@implementation MPWPoint
/*"
   An object level point abstraction, primarily for use of points with WebScript.
"*/


-(NSSize)asSize
{
    NSPoint p=self.point;
    NSSize size={p.x , p.y};
    return size;
}

-(NSPoint)pointValue
{
    return [self point];
}

-(const char*)objCType
{
    return @encode(NSPoint);
}

-(BOOL)isKindOfClass:(Class)aClass
{
    NSLog(@"%@ isKindOFClass: %@",[self class],aClass);
    return [super isKindOfClass:aClass];
}

-initWithPoint:(NSPoint)aPoint
{
    self = [super init];
    [self setPoint:aPoint];
    return self;
}


-(double)x
{
    return _point.x;
}

-(double)y
{
    return _point.y;
}

+zero
{
    return [self pointWithNSPoint:(NSPoint){0,0 }];
}

//CACHING_ALLOC( _mpwPoint, 20, NO )

+_mpwPoint
{
    return AUTORELEASE([[self alloc] init]);
}

+pointWithNSPoint:(NSPoint)aPoint
{
    id newPoint = [self _mpwPoint];
    [newPoint setPoint:aPoint];
    return newPoint;
}

+pointWithNSSize:(NSSize)size
{
    NSPoint p={
        size.width,size.height
    };
    return [self pointWithNSPoint:p];
}

+pointWithX:(float)x y:(float)y
{
    NSPoint p={
        x,y
    };
    return [self pointWithNSPoint:p];
}
#if ! TARGET_OS_IPHONE
+pointWithNSString:(NSString*)string
{
    return [self pointWithNSPoint:NSPointFromString(string)];
}

-(NSString*)description
{
    return NSStringFromPoint( [self point] );
}
#else
-(NSString*)description
{
    return [NSString stringWithFormat:@"<%@:%p: x=%g y=%g",[self class],self,_point.x,_point.y];
}
#endif
-asPoint
{
    return self;
}
-(MPWRect*)extent:otherPoint
{
	NSPoint origin=[self point];
	NSPoint extent=[otherPoint point];
    return AUTORELEASE([[MPWRect alloc] initWithRect:NSMakeRect(origin.x,origin.y,extent.x,extent.y)]);
}


#define pointArithmetic( methodName, operation )\
-methodName:aPoint\
{\
	NSPoint otherPoint=NSMakePoint(0,0);\
    if ( [aPoint respondsToSelector:@selector(point)] ) { otherPoint=[aPoint point]; } \
    else { otherPoint.x = [(NSNumber*)aPoint doubleValue]; otherPoint.y = otherPoint.x;  }  \
	return [[self class] pointWithX:otherPoint.x operation _point.x y:otherPoint.y operation _point.y];\
}

pointArithmetic( mulPoint, * )
pointArithmetic( reverseDivPoint, / )
pointArithmetic( addPoint, + )
pointArithmetic( reverseSubPoint, - )

-add:somethingElse
{
	return [somethingElse addPoint:self];
}

-mul:somethingElse
{
	return [somethingElse mulPoint:self];
}
-sub:somethingElse
{
	return [somethingElse reverseSubPoint:self];
}

-div:somethingElse
{
	return [somethingElse reverseDivPoint:self];
}

-(float)distance:(MPWPoint*)otherPoint
{
    double dx=[otherPoint x] - [self x];
    double dy=[otherPoint y] - [self y];
    return sqrt( dx*dx + dy*dy);
}

-(void)getReals:(float*)reals length:(int)len
{
    if (len>0) {
        reals[0]=_point.x;
        if ( len>1) {
            reals[1]=_point.y;
        }
    }
}

-(NSUInteger)count
{
    return 2;
}

@end


@implementation NSString(pointCreation)

-asPoint
{
    return [MPWPoint pointWithNSString:self];
}

-(NSPoint)point
{
    return [[self asPoint] point];
}

-(NSSize)asSize
{
    return [[self asPoint] asSize];
}

@end

@implementation NSNumber(pointCreationAndArithmetic)

-pointWith:otherNumber
{
    return AUTORELEASE([[MPWPoint alloc] initWithPoint:NSMakePoint([self floatValue],[otherNumber floatValue])]);
}

#define reversePointNumberArithmetic( op )\
-op:somethingElse {  return [[MPWPoint pointWithX:[self doubleValue] y:[self doubleValue]] op:somethingElse]; }\

reversePointNumberArithmetic( mulPoint )
reversePointNumberArithmetic( reverseDivPoint)
reversePointNumberArithmetic( addPoint )
reversePointNumberArithmetic( reverseSubPoint )



@end

#import "DebugMacros.h"


@implementation MPWPoint(testing)

+(void)testPointArithmetic
{
	MPWPoint* point1 = [self pointWithX:20 y:30];
	MPWPoint* point2 = [self pointWithX:4 y:3];
	id mulResult,addResult,subResult,divResult;
	
	mulResult = [point1 mul:point2];
	divResult = [point1 div:point2];
	addResult = [point1 add:point2];
	subResult = [point1 sub:point2];
	FLOATEXPECT([mulResult x], 80.0, @"multiply x");
	FLOATEXPECT([mulResult y], 90.0, @"multiply y");
	FLOATEXPECT([addResult x], 24.0, @"add x");
	FLOATEXPECT([addResult y], 33.0, @"add y");
	FLOATEXPECT([subResult x], 16.0, @"sub x");
	FLOATEXPECT([subResult y], 27.0, @"add y");
	FLOATEXPECT([divResult x], 5.0, @"divide x");
	FLOATEXPECT([divResult y], 10.0, @"divide y");
}

+(void)testPointNumberArithmetic
{
	MPWPoint* point1 = [self pointWithX:20 y:30];
    NSNumber* number = [NSNumber numberWithInt:2];
	MPWPoint* mulResult,addResult,subResult,divResult;
 
	mulResult = [point1 mul:number];
	divResult = [point1 div:number];
	addResult = [point1 add:number];
	subResult = [point1 sub:number];
	FLOATEXPECT([mulResult x], 40.0, @"multiply x");
	FLOATEXPECT([mulResult y], 60.0, @"multiply y");
	FLOATEXPECT([addResult x], 22.0, @"add x");
	FLOATEXPECT([addResult y], 32.0, @"add y");
	FLOATEXPECT([subResult x], 18.0, @"sub x");
	FLOATEXPECT([subResult y], 28.0, @"add y");
	FLOATEXPECT([divResult x], 10.0, @"divide x");
	FLOATEXPECT([divResult y], 15.0, @"divide y");
}

+(void)testDistance
{
	MPWPoint* point1 = [self pointWithX:20 y:30];
	MPWPoint* point2 = [self pointWithX:4 y:3];
    INTEXPECT((int)([point1 distance:point2]*10000), 313847, @"distance point1 <-> point2 * 1000");
    FLOATEXPECT([point1 distance:point1], 0.0, @"point1 point2")
}

+(void)testGetReals
{
	MPWPoint* point1 = [self pointWithX:20 y:30];
	MPWPoint* point2 = [self pointWithX:4 y:3];
    float reals[2];
    [point1  getReals:reals length:2];
    FLOATEXPECT(reals[0], 20.0, @"got x into real[0]");
    FLOATEXPECT(reals[1], 30.0, @"got y into real[1]");
    [point2  getReals:reals length:2];
    FLOATEXPECT(reals[0], 4.0, @"got x into real[0]");
    FLOATEXPECT(reals[1], 3.0, @"got y into real[1]");

}

+(void)testCount
{
	MPWPoint* point1 = [self pointWithX:20 y:30];
    INTEXPECT([point1 count], 2, @"always 2");
}

+(void)testPointValue
{
	MPWPoint* point1 = [self pointWithX:20 y:30];
    NSPoint theNSPoint=[point1 pointValue];
    FLOATEXPECTTOLERANCE(theNSPoint.x, 20, 0.001, @"x");
    FLOATEXPECTTOLERANCE(theNSPoint.y, 30, 0.001, @"y");
}


+testSelectors
{
	return [NSArray arrayWithObjects:
            @"testPointArithmetic",
            @"testPointNumberArithmetic",
            @"testDistance",
            @"testGetReals",
            @"testCount",
            @"testPointValue",
		nil];
}

@end


//
//  MPWCGDrawingStream.m
//  MusselWind
//
//  Created by Marcel Weiher on 8.12.09.
//  Copyright 2009-2010 Marcel Weiher. All rights reserved.
//

#import "MPWCGDrawingContext.h"
#import "MPWCGPathCreationContext.h"
#import "AccessorMacros.h"

#if TARGET_OS_IPHONE
#import <CoreText/CoreText.h>
#import <UIKit/UIKit.h>
#else
#import <ApplicationServices/ApplicationServices.h>
#import <Cocoa/Cocoa.h>
#endif

#if TARGET_OS_IPHONE   
#define IMAGECLASS  UIImage
#define FONTCLASS   UIFont
#define PATHCLASS   UIBezierPath
#else
#define IMAGECLASS  NSBitmapImageRep
#define FONTCLASS   NSFont
#define PATHCLASS   NSBezierPath
#endif

@protocol DrawingContextRealArray <NSObject>

-(void)getReals:(float*)reals length:(int)arrayLength;
-(float)realAtIndex:(int)anIndex;

@end

@interface NSObject(value)

-value:parameter;

@end

@protocol DrawingContextUshortArray <NSObject>

-(unsigned short*)ushorts;
-(NSUInteger)count;

@end
@implementation MPWCGDrawingContext

scalarAccessor( CGContextRef , context ,_setContext )
idAccessor(currentFont, setCurrentFont)
floatAccessor(fontSize, _setFontSize)
objectAccessor(NSMutableParagraphStyle, paragraphStyle, setParagraphStyle)

-(void)setContext:(CGContextRef)newVar
{
    if ( newVar ) {
        CGContextRetain(newVar);
    }
    if ( context ) {
        CGContextRelease(context);
    }
    [self _setContext:newVar];
}

+(CGContextRef)currentCGContext
{
#if TARGET_OS_IPHONE
	return UIGraphicsGetCurrentContext();
#else
	return [[NSGraphicsContext currentContext] graphicsPort];
#endif
}

+contextWithCGContext:(CGContextRef)c
{
    return [[[self alloc] initWithCGContext:c] autorelease];
}

+currentContext
{
	return [self contextWithCGContext:[self currentCGContext]];
}


-initWithCGContext:(CGContextRef)newContext;
{
	self=[super init];
	[self setContext:newContext];
    [self resetTextMatrix]; 
    [self setParagraphStyle:[[[NSMutableParagraphStyle alloc] init] autorelease]];
	return self;
}

-setLeading:(float)newLeading
{
    [[self paragraphStyle] setLineBreakMode:newLeading];
    return self;
}

-setParagraphSpacing:(float)newSpacing
{
    [[self paragraphStyle] setParagraphSpacing:newSpacing];
    return self;
}

-setParagraphSpacingBefore:(float)newSpacing
{
    [[self paragraphStyle] setParagraphSpacingBefore:newSpacing];
    return self;
}


-(void)dealloc
{
    if ( context ) {
        CGContextRelease(context);
    }
	[super dealloc];
}

-translate:(float)x :(float)y {
	CGContextTranslateCTM(context, x, y);
	return self;
}

-scale:(float)x :(float)y {
	CGContextScaleCTM(context, x, y);
	return self;
}

-rotate:(float)degrees {
	CGContextRotateCTM(context, degrees * (M_PI/180.0));
	return self;
}

-beginPath
{
    CGContextBeginPath( context );
    return self;
}

-_beginTransparencyLayer
{
    CGContextBeginTransparencyLayer( context, (CFDictionaryRef)[NSDictionary dictionary]);
    return self;
}


-_endTransparencyLayer
{
    CGContextEndTransparencyLayer( context );
    return self;
}

-_gsave
{
	CGContextSaveGState(context);
	return self;
}

-(id<MPWDrawingContext>)gsave
{
    return [self _gsave];
}

-_grestore
{
	CGContextRestoreGState(context);
    return self;
}

-grestore
{
//    NSLog(@"grestore: %@ %@",self,context);
    [self _grestore];   
    [self setCurrentFont:nil];
    [self setFontSize:0];
	return self;
}


-(BOOL)object:inArray toCGFLoats:(CGFloat*)cgArray maxCount:(int)maxCount
{
    int arrayLength = [(NSArray*)inArray count];
    arrayLength=MIN(arrayLength,maxCount);
    float floatArray[arrayLength];
    BOOL didConvert = [self object:inArray toFloats:(float *)floatArray maxCount:arrayLength];
    if ( didConvert ) {
        for (int i=0;i<arrayLength;i++) {
            cgArray[i]=floatArray[i];
        }
    }
    return didConvert;
}



-setdashpattern:inArray phase:(float)phase
{
    if ( inArray ) {
        int arrayLength = [(NSArray*)inArray count];
        CGFloat cgArray[ arrayLength ];
        [self object:inArray toCGFLoats:cgArray maxCount:arrayLength];
        CGContextSetLineDash(context, phase, cgArray, arrayLength);
    } else {
        CGContextSetLineDash(context, 0.0, NULL, 0);
    }
	return self;
}

-setlinewidth:(float)width
{
	CGContextSetLineWidth(context, width);
	return self;
}


-setlinecapRound
{
    CGContextSetLineCap(context, kCGLineCapRound);
    return self;
}

-setlinecapSquare
{
    CGContextSetLineCap(context, kCGLineCapSquare);
    return self;
}

-setlinecapButt
{
    CGContextSetLineCap(context, kCGLineCapButt );
    return self;
}

static inline CGColorRef asCGColorRef( id aColor ) {
    CGColorRef cgColor=(CGColorRef)aColor;
    if ( [aColor respondsToSelector:@selector(CGColor)])  {
        cgColor=[aColor CGColor];
    } else if ( [aColor respondsToSelector:@selector(rangeOfString:)]) {
        int r=0,g=0,b=0;
        char buffer[20];
        memset(buffer, 0, sizeof buffer);
//        NSLog(@"string color: '%@'",aColor);
        if ( [aColor hasPrefix:@"#"]) {
            aColor=[aColor substringFromIndex:1];
        }
        [aColor getCString:buffer maxLength:12 encoding:NSASCIIStringEncoding];
        sscanf(buffer, "%2x%2x%2x",&r,&g,&b);
#if TARGET_OS_IPHONE
        cgColor=[[UIColor colorWithRed:r / 255.0 green:g/255.0  blue: b/255.0 alpha:1.0] CGColor];
#else
        cgColor=[[NSColor colorWithRed:r / 255.0 green:g/255.0  blue: b/255.0 alpha:1.0] CGColor];
#endif
    }
    return cgColor;
}

static inline NSArray* asCGColorRefs( NSArray *colors ) {
    NSMutableArray *newColors=[NSMutableArray new];
    for ( id aColor in colors ) {
        [newColors addObject:(id)asCGColorRef(aColor)];
    }
    return newColors;
}

-setFillColor:aColor
{
    CGColorRef c = asCGColorRef(aColor);
    CGContextSetFillColorWithColor( context, c);
	return self;
}

-setStrokeColor:aColor 
{
    CGContextSetStrokeColorWithColor( context,  asCGColorRef(aColor) );
	return self;
}

-setFillColorGray:(float)gray alpha:(float)alpha
{
    return [self setFillColor:[self colorGray:gray alpha:alpha]];
}


-setAlpha:(float)alpha
{
    CGContextSetAlpha( context, alpha );
    return self;
}


-setAntialias:(BOOL)doAntialiasing
{
    CGContextSetShouldAntialias( context, doAntialiasing );
    return self;
}

-setShadowOffset:(NSSize)offset blur:(float)blur color:aColor
{
    CGContextSetShadowWithColor( context, CGSizeMake(offset.width,offset.height),blur, (CGColorRef)aColor);
    return self;
}

-clearShadow
{
    return [self setShadowOffset:NSMakeSize(0, 0) blur:0 color:nil];
}


-nsrect:(NSRect)r
{
	CGContextAddRect( context, CGRectMake(r.origin.x, r.origin.y, r.size.width, r.size.height) );
	return self;
}

#if TARGET_OS_IPHONE
-(PATHCLASS*)_rectpath:(NSRect)r rounded:(NSPoint)rounding
{
    CGSize s={rounding.x, rounding.y };
//    NSLog(@"UIBezierPath rounded rect: x=%g y=%g w=%g h=%g  round x=%g y=%g",
//          r.origin.x,r.origin.y,r.size.width,r.size.height,s.width,s.height);
    return [UIBezierPath bezierPathWithRoundedRect:r byRoundingCorners:UIRectCornerAllCorners cornerRadii: s];
}

#elif TARGET_OS_MAC
-(PATHCLASS*)_rectpath:(NSRect)r rounded:(NSPoint)rounding
{
    return [PATHCLASS bezierPathWithRoundedRect:r xRadius:rounding.x yRadius:rounding.y];
}
#else
-(PATHCLASS*)_rectpath:(NSRect)r rounded:(NSPoint)rounding
{
    return nil;
}
#endif
-nsrect:(NSRect)r rounded:(NSPoint)rounding
{
    PATHCLASS *rectpath=[self _rectpath:r rounded:rounding];
    if ( rectpath) {
        [self applyPath:rectpath];
    }
    return self;
}


-ellipseInRect:(NSRect)r
{
    CGContextAddEllipseInRect(context, CGRectMake(r.origin.x, r.origin.y, r.size.width, r.size.height));
    return self;
}

-path:pathBlock
{
    MPWCGPathCreationContext *c =[MPWCGPathCreationContext context];
    [pathBlock value:c];
    return [c path];
}

-(void)fill
{
	CGContextFillPath( context );
}

-(void)fillAndStroke
{
	CGContextDrawPath( context, kCGPathFillStroke );
}

-(void)eofillAndStroke
{
	CGContextDrawPath( context, kCGPathEOFillStroke );
}

-(void)eofill
{
    CGContextEOFillPath( context );
}

-(void)fillDarken
{
    [self _gsave];
    CGContextSetBlendMode(context, kCGBlendModeDarken);
    [self fill];
    [self _grestore];    
}

-(void)clip
{
	CGContextClip( context );
}

-(void)fillRect:(NSRect)r;
{
	CGContextFillRect(context, CGRectMake(r.origin.x, r.origin.y, r.size.width, r.size.height) );
}

-(void)stroke
{
	CGContextStrokePath( context );
}




-(NSRect)cliprect
{
    CGRect r=CGContextGetClipBoundingBox(context);
    return NSMakeRect(r.origin.x, r.origin.y, r.size.width, r.size.height);
}

-(CGGradientRef)_gradientWithColors:(NSArray*)colors offset:(NSArray*)offsets
{
    colors = asCGColorRefs(colors);
    CGColorRef firstColor = (CGColorRef)[colors objectAtIndex:0];
    
    CGColorSpaceRef colorSapce=CGColorGetColorSpace( firstColor);
    CGFloat locations[ [colors count] + 1 ];
    [self object:offsets toCGFLoats:locations maxCount:(int)[colors count]];
    CGGradientRef gradient = CGGradientCreateWithColors(colorSapce, colors, locations );
    [(id)gradient autorelease];
    return gradient;
}

-drawLinearGradientFrom:(NSPoint)startPoint to:(NSPoint)endPoint colors:(NSArray*)colors offsets:(NSArray*)offsets
{
    CGContextDrawLinearGradient(context,
                                [self _gradientWithColors:colors offset:offsets],
                                CGPointMake(startPoint.x, startPoint.y),
                                CGPointMake(endPoint.x, endPoint.y),0);
                                
    
    return self;
}

-drawRadialGradientFrom:(NSPoint)startPoint radius:(float)startRadius to:(NSPoint)endPoint radius:(float)endRadius colors:(NSArray*)colors offsets:(NSArray*)offsets
{
    CGContextDrawRadialGradient(context,
                                [self _gradientWithColors:colors offset:offsets],
                                CGPointMake(startPoint.x, startPoint.y),
                                startRadius,
                                CGPointMake(endPoint.x, endPoint.y),
                                endRadius,0);
    
    return self;
}


-moveto:(float)x :(float)y
{
	CGContextMoveToPoint(context, x, y );	
	return self;
}


-lineto:(float)x :(float)y
{
	CGContextAddLineToPoint(context, x, y );	
	return self;
}

-curveto:(float)cp1x :(float)cp1y :(float)cp2x :(float)cp2y :(float)x :(float)y
{
    CGContextAddCurveToPoint( context, cp1x, cp1y, cp2x, cp2y, x,y );
    return self;
}


-arcWithCenter:(NSPoint)center radius:(float)radius startDegrees:(float)start endDegrees:(float)stop  clockwise:(BOOL)clockwise
{
	CGContextAddArc(context, center.x,center.y, radius , start * (M_PI/180), stop *(M_PI/180), clockwise);
	return self;
}

-arcFromPoint:(NSPoint)p1 toPoint:(NSPoint)p2 radius:(float)radius
{
    CGContextAddArcToPoint( context , p1.x, p1.y,p2.x, p2.y,  radius);
    return self;

}

-closepath;
{
	CGContextClosePath(context);
	return self;
}

-setCharaterSpacing:(float)ax
{
    CGContextSetCharacterSpacing( context, ax );
    return self;
}


-fontWithName:(NSString*)name size:(float)size
{
    return [FONTCLASS fontWithName:name size:size];
}

-showTextString:str at:(NSPoint)position
{
    [self setTextPosition:position];
    [self show:str];
    return self;
}


-layoutText:(NSAttributedString*)someText inPath:aPath
{
    NSArray *lines=nil;
    if ( aPath ) {
        someText=[self attributedStringFromString:someText];
        CTFramesetterRef setter = CTFramesetterCreateWithAttributedString( (CFAttributedStringRef) someText );
        CTFrameRef frame=CTFramesetterCreateFrame(setter, CFRangeMake(0, [someText length]), (CGPathRef)aPath, (CFDictionaryRef)@{} );
        if ( frame) {
            lines=[(NSArray *)CTFrameGetLines( frame ) retain];
            
        } else {
            @throw [NSException exceptionWithName:@"nullpointer" reason:@"frame is null in -layoutText:inPath:" userInfo:nil];
        }
        [(id)frame release];
        [(id)setter release];
    } else {
        @throw [NSException exceptionWithName:@"nullpointer" reason:@"path is null in -layoutText:inPath:" userInfo:nil];
    }
    return [lines autorelease];
}


-drawText:(NSAttributedString*)someText inPath:aPath
{
    @autoreleasepool {
        NSArray *lines=[self layoutText:someText inPath:aPath];
        for (id line in lines ) {
            CTLineRef lineRef=(CTLineRef)line;
            CTLineDraw(lineRef, [self context]);
        }
    }
    return self;
}


-(int)numberOfLinesForText:(NSAttributedString*)someText inPath:aPath
{
    int numberOfLines=0;
    @autoreleasepool {
        numberOfLines=(int)[[self layoutText:someText inPath:aPath] count];
    }
    return numberOfLines;
}


-(NSRect)boundingRectForText:(NSAttributedString*)someText inPath:aPath
{
    CGRect totalBoundingRect=CGRectZero;
    @autoreleasepool {
        NSArray *lines=[self layoutText:someText inPath:aPath];
        for (id line in lines ) {
            CTLineRef lineRef=(CTLineRef)line;
            CGRect lineBounds = CTLineGetImageBounds ( lineRef, [self context] );
            NSLog(@"totalRect before: %@ line-rect : %@",NSStringFromRect(totalBoundingRect) ,NSStringFromRect(lineBounds));
            totalBoundingRect = CGRectUnion(totalBoundingRect, lineBounds );
        }
    }
    NSLog(@"totalRect: %@",NSStringFromRect(totalBoundingRect));
    return totalBoundingRect;
}


-(float)stringwidth:(NSAttributedString*)someText
{
    someText=[self attributedStringFromString:someText];
    CGRect r=[self boundingRectForText:someText inPath:[self path:^(id<MPWDrawingContext> c) {
        [c rect:@(10000000)];
    }]];
    return r.size.width;
}

-showGlyphBuffer:(unsigned short*)glyphs length:(int)len at:(NSPoint)position;
{
	CGContextShowGlyphsAtPoint( context, position.x,position.y, glyphs, len);
    return self;
}

-showGlyphs:(id <DrawingContextUshortArray> )glyphs at:(NSPoint)position;
{
	[self showGlyphBuffer:[glyphs ushorts] length:(int)[glyphs count] at:position];
    return self;
}

-showGlyphBuffer:(unsigned short *)glyphs length:(int)len atPositions:(NSPoint*)positonArray
{
    CGContextShowGlyphsAtPositions(context,(CGGlyph*)glyphs , (CGPoint*)positonArray, len);
    return self;
}

-showGlyphs:(id)glyphArray atPositions:positionArray
{
    return self;
}

-layerWithSize:(NSSize)size
{
    return [[[MPWCGLayerContext alloc] initWithCGContext:[self context] size:size] autorelease];
}


-setTextModeFill:(BOOL)fill stroke:(BOOL)stroke clip:(BOOL)clip
{
    CGTextDrawingMode modes[8]={
        kCGTextInvisible,
        kCGTextFill,
        kCGTextStroke,
        kCGTextFillStroke,
        kCGTextClip,
        kCGTextFillClip,
        kCGTextStrokeClip,
        kCGTextFillStrokeClip,
    };
    CGTextDrawingMode mode=modes[ (clip?4:0) + (stroke?2:0) + (fill?1:0)];
    CGContextSetTextDrawingMode(context, mode);
    return self;
}

-concat:(float)m11 :(float)m12  :(float)m21  :(float)m22  :(float)tx  :(float)ty
{
    CGContextConcatCTM(context, CGAffineTransformMake(m11,m12,m21,m22,tx,ty));
    return self;
}

-setTextMatrix:(float)m11 :(float)m12  :(float)m21  :(float)m22  :(float)tx  :(float)ty
{
    CGContextSetTextMatrix(context, CGAffineTransformMake(m11,m12,m21,m22,tx,ty));
    return self;
}

-setTextMatrix:someArray
{
    CGFloat a[6]={0};
    NSAssert2( [someArray count] == 6, @"concat %@ expects 6-element array, got %d",someArray,(int)[someArray count] );
    [self object:someArray toCGFLoats:a maxCount:6];
    [self setTextMatrix:a[0] :a[1] :a[2] :a[3] :a[4] :a[5]];
    return self;
}


-setFontSize:(float)newSize;
{
	CGContextSetFontSize( context, newSize );
    return  self;
}

-(id <MPWDrawingContext>)setFont:aFont
{
    [self setCurrentFont:aFont];
    if ( aFont ) {
        CFTypeID t=CFGetTypeID( (CFTypeRef)aFont);
        NSString *descr=(NSString*)CFCopyTypeIDDescription(t );
//        NSLog(@"obj: %@ type: %lx descr: %@",aFont,t,descr);
        if ( [descr isEqualToString:@"CTFont"] || t==0x10d) {
//            NSLog(@"converting font to CG font");
            aFont=(id)CTFontCopyGraphicsFont( (CTFontRef)aFont, nil);
            [aFont autorelease];
        }
        [descr release];
        CGContextSetFont(context, (CGFontRef)aFont);
    } else {
//        @throw @"nil font";
//        NSLog(@"setFont: nil font");
    }
   return self;
}

#if !TARGET_OS_IPHONE
-concatNSAffineTransform:(NSAffineTransform*)transform
{
    if ( transform ) {
        NSAffineTransformStruct s=[transform transformStruct];
        [self concat:s.m11 :s.m12 :s.m21  :s.m22  :s.tX  :s.tY];
    }
    return self; 
}
#endif

-(void)applyPath:aPath
{
    if ( [aPath respondsToSelector:@selector(drawOnContext:)]) {
        [aPath drawOnContext:self];
    } else if ( [aPath respondsToSelector:@selector(value:)]) {
        [aPath value:self];
    } else {
        CGPathRef cgPath=NULL;
        if ( [aPath respondsToSelector:@selector(CGPath)]) {
            cgPath=[aPath CGPath];
        } else {
            cgPath=(CGPathRef)aPath;
        }
        CGContextAddPath(context, cgPath);
    }
}

-(void)drawBitmapImage:anImage
{
    IMAGECLASS *image=(IMAGECLASS*)anImage;
    NSSize s=[image size];
    CGRect r={ CGPointZero, s.width, s.height };
    CGContextDrawImage(context, r, [anImage CGImage]);
}


-(void)resetTextMatrix
{
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
}

-(id <MPWDrawingContext>)setTextPosition:(NSPoint)p
{
    CGContextSetTextPosition(context, p.x,p.y);
    return self;
}

-(id <MPWDrawingContext>)drawTextLine:(CTLineRef)line
{
//    NSLog(@"draw text line: '%@'",(id)line);
    CTLineDraw(line, context);
    return self;
}

#if NS_BLOCKS_AVAILABLE

-layerWithSize:(NSSize)size content:(DrawingBlock)block
{
    MPWCGLayerContext *layerContext=[self layerWithSize:size];
    block( layerContext);
    return layerContext;
}

-bitmapWithSize:(NSSize)size content:(DrawingBlock)block
{
    MPWCGBitmapContext *bitmapContext=[MPWCGBitmapContext rgbBitmapContext:size];
    block( bitmapContext);
    return [bitmapContext image];
}

-maskedBy:aMaskImage draw:(DrawingBlock)drawingCommands
{
    [self ingsave:^(MPWCGDrawingContext* aContext) {
        @autoreleasepool {
            CGImageRef originalCG=[aMaskImage CGImage];
            CGImageRef theMask = CGImageMaskCreate(
                                           CGImageGetWidth(originalCG),
                                           CGImageGetHeight(originalCG),
                                           CGImageGetBitsPerComponent(originalCG),
                                           CGImageGetBitsPerPixel(originalCG),
                                           CGImageGetBytesPerRow(originalCG),
                                           CGImageGetDataProvider(originalCG),
                                           NULL, NO);
            if ( theMask != NULL) {
                CGRect r=CGRectMake(0, 0, CGImageGetWidth(theMask), CGImageGetHeight(theMask));
                CGContextClipToMask([aContext context], r, theMask);
                if (drawingCommands) {
                    drawingCommands(aContext);
                }
                CFRelease(theMask);
            }
        }
    }];
    return self;
}

#endif

@end

@implementation MPWCGLayerContext

-(id)initWithCGContext:(CGContextRef)baseContext size:(NSSize)s
{
    CGSize cgsize={s.width,s.height};
    CGLayerRef newlayer=CGLayerCreateWithContext(baseContext, cgsize,  NULL);
    CGContextRef layerContext=CGLayerGetContext(newlayer);
    if ( (self=[super initWithCGContext:layerContext])) {
        layer=newlayer;
    }
    return self;
}

-(void)drawOnContext:(MPWCGDrawingContext*)aContext
{
    CGContextDrawLayerAtPoint([aContext context],  CGPointMake(0, 0),layer);
}

-(void)dealloc
{
    if ( layer) {
        CGLayerRelease(layer);
    }
    [super dealloc];    
}

@end

@implementation MPWCGPDFContext

idAccessor(startPageBlock, setStartPageBlock)
idAccessor(endPageBlock, setEndPageBlock)
intAccessor(pageNo, setPageNo)

+pdfContextWithTarget:target mediaBox:(NSRect)bbox
{
    CGRect mediaBox={bbox.origin.x,bbox.origin.y,bbox.size.width,bbox.size.height};
    CGDataConsumerRef consumer=CGDataConsumerCreateWithCFData((CFMutableDataRef)target);
    CGContextRef newContext = CGPDFContextCreate(consumer, &mediaBox, NULL );
    CGDataConsumerRelease(consumer);
    CFAutorelease(newContext);
    return [self contextWithCGContext:newContext];
}

+pdfContextWithTarget:target size:(NSSize)pageSize
{
    return [self pdfContextWithTarget:target mediaBox:NSMakeRect(0, 0, pageSize.width, pageSize.height)];
}

+pdfContextWithTarget:target
{
    return [self pdfContextWithTarget:target size:NSMakeSize( 595, 842)];
}


-(void)beginPage:(NSDictionary*)parameters
{
    CGPDFContextBeginPage( context , (CFDictionaryRef)parameters);
    if ( startPageBlock ) {
        [self ingsave:startPageBlock];
    }
}

-(void)endPage
{
    CGPDFContextEndPage( context );
}

-(void)close
{
    CGPDFContextClose( context );
}


-page:(NSDictionary*)parameters content:(DrawingBlock)content
{
    @try {
        [self beginPage:parameters];
        [self ingsave:content];
    } @finally {
        [self endPage];
    }
    return self;
}


-laterWithSize:(NSSize)size content:(DrawingBlock)drawingCommands
{
    return [self layerWithSize:size content:drawingCommands];
}

-(void)dealloc
{
#if NS_BLOCKS_AVAILABLE
    [startPageBlock release];
    [endPageBlock release];
#endif
    [super dealloc];
    
}

@end


#if NS_BLOCKS_AVAILABLE

@implementation MPWDrawingCommands(patterns)


void ColoredPatternCallback(void *info, CGContextRef context)
{
    MPWDrawingCommands *command=(MPWDrawingCommands*)info;
    [command drawOnContext:[MPWCGDrawingContext contextWithCGContext:context]];
}

-(CGColorRef)CGColor
{
    CGPatternCallbacks coloredPatternCallbacks = {0, ColoredPatternCallback, NULL};
    CGPatternRef pattern=CGPatternCreate(self, CGRectMake(0, 0, size.width, size.height), CGAffineTransformIdentity, size.width, size.height, kCGPatternTilingNoDistortion, true , &coloredPatternCallbacks) ;
    CGColorSpaceRef coloredPatternColorSpace = CGColorSpaceCreatePattern(NULL);
    CGFloat alpha = 1.0;
    
    CGColorRef coloredPatternColor = CGColorCreateWithPattern(coloredPatternColorSpace, pattern, &alpha);
    CGPatternRelease(pattern);
    CGColorSpaceRelease(coloredPatternColorSpace);
    [(id)coloredPatternColor autorelease];
    return coloredPatternColor;
}

@end

#endif



@implementation MPWCGBitmapContext

-initBitmapContextWithSize:(NSSize)size colorSpace:(CGColorSpaceRef)colorspace scale:(float)scaleFactor
{
//    CGContextRef c=CGBitmapContextCreate(NULL, size.width, size.height, 8, 0, colorspace,
//                                         (CGColorSpaceGetNumberOfComponents(colorspace) == 4 ? kCGImageAlphaNone : kCGImageAlphaPremultipliedLast)  | kCGBitmapByteOrderDefault );
    CGContextRef c=CGBitmapContextCreate(NULL, size.width * scaleFactor, size.height*scaleFactor, 8, 0, colorspace,kCGImageAlphaNoneSkipFirst  | kCGBitmapByteOrderDefault );
    if ( !c ) {
        [self release];
        return nil;
    }
    id new = [self initWithCGContext:c];
    scale=scaleFactor;
    if (scale != 1) {
        [self scale:@(scaleFactor)];
    }
    CGContextRelease(c);
    return new;
    
}

-initBitmapContextWithSize:(NSSize)size colorSpace:(CGColorSpaceRef)colorspace
{
    return [self initBitmapContextWithSize:size colorSpace:colorspace scale:1];
}

+rgbBitmapContext:(NSSize)size scale:(float)scale
{
    return [[[self alloc] initBitmapContextWithSize:size colorSpace:CGColorSpaceCreateDeviceRGB() scale:scale] autorelease];
}


+rgbBitmapContext:(NSSize)size
{
    return [self rgbBitmapContext:size scale:1];
}



+cmykBitmapContext:(NSSize)size
{
    return [[[self alloc] initBitmapContextWithSize:size colorSpace:CGColorSpaceCreateDeviceCMYK()] autorelease];
}

-(CGImageRef)cgImage
{
    return CGBitmapContextCreateImage( context );
}



-(Class)imageClass
{
    return [IMAGECLASS class];
}

-image
{
    CGImageRef cgImage=[self cgImage];
#if TARGET_OS_IPHONE
    id image= [[[UIImage alloc]  initWithCGImage:cgImage scale:scale orientation:UIImageOrientationUp] autorelease];
#elif TARGET_OS_MAC
    id image = [[[NSBitmapImageRep alloc] initWithCGImage:cgImage] autorelease];
    NSSize s=[image size];
    s.width/=scale;
    s.height/=scale;
    [image setSize:s];
#endif
    CGImageRelease(cgImage);
    return image;
}



@end

#if TARGET_OS_IPHONE
@implementation UIImage(CGColor)

-(CGColorRef)CGColor
{
    return [[UIColor colorWithPatternImage:self] CGColor];
}
@end

#elif TARGET_OS_MAC

@implementation NSImage(CGColor)

-(CGColorRef)CGColor {   return [[NSColor colorWithPatternImage:self] CGColor]; };
@end

@implementation NSBitmapImageRep(CGColor)

-(CGColorRef)CGColor
{
    return [[[[NSImage alloc] initWithCGImage:[self CGImage] size:[self size]] autorelease] CGColor];
}
@end

@implementation NSColor(CGColor)

-(CGColorRef)CGColor
{
    CGColorRef color=NULL;
    if ( [self numberOfComponents] == 4) {
        CGFloat colorComponents[4]={[self redComponent],[self greenComponent],[self blueComponent],[self alphaComponent]};
        color=CGColorCreate( CGColorSpaceCreateDeviceRGB(), colorComponents);
    } else {
        NSLog(@"unknown number of components: %d",[self numberOfComponents]);
    }
    return color;
}
@end

@implementation NSBezierPath(drawing)

-(void)drawOnContext:(Drawable)context
{
    long elementCount=[self elementCount];
    for (long i=0; i<elementCount; i++) {
        NSPoint p[10];
        switch ( [self elementAtIndex:i associatedPoints:p]) {
            case NSMoveToBezierPathElement:
                [context moveto:p[0].x :p[0].y];
                break;
            case NSLineToBezierPathElement:
                [context lineto:p[0].x :p[0].y];
                break;
                
            case NSCurveToBezierPathElement:
                [context curveto:p[0].x :p[0].y :p[1].x :p[1].y :p[2].x :p[2].y];
                break;
                
            case NSClosePathBezierPathElement:
                [context closepath];
                break;
                
            default:
                NSLog(@"unknown path component");
        }
    }
}

@end
#endif



#if !TARGET_OS_IPHONE


#if 1
#import "EGOSTesting.h"


@implementation MPWCGBitmapContext(testing)



+(NSBitmapImageRep*)bitmapForImageNamed:(NSString*)name
{
    NSString *path=[[NSBundle bundleForClass:self] pathForImageResource:name];
    return [NSBitmapImageRep imageRepWithContentsOfFile:path];
}

+(void)testBasicShapesGetRendered
{
    MPWCGBitmapContext *c=[self rgbBitmapContext:NSMakeSize(400, 400)];
    SEL ops[3]={ @selector(fill),@selector(stroke),@selector(fillAndStroke)};
    
    [c setFillColor:[c colorRed:0 green:1 blue:0 alpha:1]];
    [c setStrokeColor:[c colorRed:1 green:0 blue:0 alpha:1]];
    [c setlinewidth:4];
    NSRect r=NSMakeRect(5, 5, 30, 20);

    for (int i=0;i<3;i++) {
        [c gsave];
        [c nsrect:r];
        [c performSelector:ops[i]];
        [c translate:35 :0];
        [c ellipseInRect:r];
        [c performSelector:ops[i]];
        [c grestore];
        [c translate:0 :40];
    }
    NSBitmapImageRep *referenceImage=BUNDLEIMAGE(@"basic-shape-rendering");
    NSBitmapImageRep *resultImage=[c image];
//    NSLog(@"referenceImage: %@",referenceImage);
//    NSLog(@"resultImage: %@",resultImage);
    IMAGEEXPECT( resultImage , referenceImage, @"basic-shape-rendering");
}


+(void)testSimpleColorCreation
{
    MPWCGBitmapContext *c=[self rgbBitmapContext:NSMakeSize(500,500)];
    struct color  {
        float r,g,b;
    } colors[] = {
        {1,0,0},
        {0,1,0},
        {0,0,1},
        {1,1,0},
        {1,0,1},
        {0,1,1},
        {1,1,1}
    };
    for (int i=0;i<7;i++) {
        id c1=[c colorRed:colors[i].r green:colors[i].g blue:colors[i].b alpha:1];
        [[[c setFillColor:c1] nsrect:NSMakeRect(0, 0, 10, 100)] fill ];
        [c translate:10 :0];
    }
    NSBitmapImageRep *referenceImage=BUNDLEIMAGE(@"simple-color-creation");
    NSBitmapImageRep *resultImage=[c image];
    IMAGEEXPECT( resultImage, referenceImage, @"simple-color-creation");
}

+(void)testStringWidth
{
    MPWCGBitmapContext *c=[self rgbBitmapContext:NSMakeSize(500,500)];
    FLOATEXPECTTOLERANCE([c stringwidth:@"Hello World!"],64.38, .003, @"string width of Hello World");
}

+testSelectors
{
    return @[
        @"testBasicShapesGetRendered",
        @"testSimpleColorCreation",
        @"testStringWidth",
    ];
}

@end

#endif

@implementation MPWCGPDFContext(testing)

+testSelectors {  return @[]; }

@end
#endif

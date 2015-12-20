//
//  MPWCGDrawingStream.h
//
//  Created by Marcel Weiher on 8.12.09.
//  Copyright 2009-2010 Marcel Weiher. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhoneGeometry.h"
#import "MPWAbstractCGContext.h"

@class NSMutableParagraphStyle;

@interface MPWCGDrawingContext: MPWAbstractCGContext <MPWDrawingContext>  {
	CGContextRef context;
    id currentFont;
    float fontSize;
    NSMutableParagraphStyle *paragraphStyle;
}

@property CGContextRef context;

-initWithCGContext:(CGContextRef)newContext;
+contextWithCGContext:(CGContextRef)c;
+currentContext;

-(void)resetTextMatrix;

-(NSRect)boundingRectForText:(NSAttributedString*)someText inPath:aPath;


#if !TARGET_OS_IPHONE
-concatNSAffineTransform:(NSAffineTransform*)transform;
#endif

@end

@interface MPWCGLayerContext : MPWCGDrawingContext 
{
    CGLayerRef layer;
}

-(id)initWithCGContext:(CGContextRef)baseContext size:(NSSize)s;

@end

@interface MPWCGPDFContext : MPWCGDrawingContext
{
    int pageNo;
    id startPageBlock;
    id endPageBlock;
}

+pdfContextWithTarget:target mediaBox:(NSRect)bbox;
+pdfContextWithTarget:target size:(NSSize)pageSize;
+pdfContextWithTarget:target;

-(void)beginPage:(NSDictionary*)parameters;
-(void)endPage;
#if NS_BLOCKS_AVAILABLE
-page:(NSDictionary*)parameters content:(DrawingBlock)drawingCommands;
#endif
-(void)close;

@end

@interface MPWCGBitmapContext : MPWCGDrawingContext
{
    float scale;
}

-initBitmapContextWithSize:(NSSize)size colorSpace:(CGColorSpaceRef)colorspace scale:(float)scale;
-initBitmapContextWithSize:(NSSize)size colorSpace:(CGColorSpaceRef)colorspace;


+rgbBitmapContext:(NSSize)size scale:(float)scale;
+rgbBitmapContext:(NSSize)size;
+cmykBitmapContext:(NSSize)size;

-image;


@end

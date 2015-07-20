//
//  MPWDrawingContext.h
//  MusselWind
//
//  Created by Marcel Weiher on 11/18/10.
//  Copyright 2010 Marcel Weiher. All rights reserved.
//

#import "PhoneGeometry.h"


@protocol MPWDrawingContext <NSObject>

@optional
-(instancetype)translate:(float)x :(float)y;
-(instancetype)scale:(float)x :(float)y;
-(instancetype)rotate:(float)degrees;

-(instancetype)gsave;
-(instancetype)grestore;
-(instancetype)setdashpattern:array phase:(float)phase;
-(instancetype)setlinewidth:(float)width;
-(instancetype)setlinecapRound;
-(instancetype)setlinecapSquare;
-(instancetype)setlinecapButt;


-(id)colorRed:(float)r green:(float)g blue:(float)b alpha:(float)alpha;
-(id)colorsRed:r green:g blue:b alpha:alpha;

-(id)colorCyan:(float)c magenta:(float)m yellow:(float)y black:(float)k alpha:(float)alpha;
-(id)colorsCyan:c magenta:m yellow:y black:k alpha:alpha;

-(id)colorGray:(float)gray alpha:(float)alpha;
-(id)colorsGray:gray alpha:alpha;

-(instancetype)setFillColor:(id)aColor;
-(instancetype)setStrokeColor:(id)aColor;

-(instancetype)setFillColorGray:(float)gray alpha:(float)alpha;


-(instancetype)setAlpha:(float)alpha;
-(instancetype)setAntialias:(BOOL)doAntialiasing;
-(instancetype)setShadowOffset:(NSSize)offset blur:(float)blur color:(id)aColor;
-(instancetype)clearShadow;


-(instancetype)concat:(float)m11 :(float)m12  :(float)m21  :(float)m22  :(float)tx  :(float)ty;
-(instancetype)concat:someArray;

-(instancetype)setTextMatrix:(float)m11 :(float)m12  :(float)m21  :(float)m22  :(float)tx  :(float)ty;
-(instancetype)setTextMatrix:someArray;

-(instancetype)setFontSize:(float)newSize;

-(instancetype)setTextModeFill:(BOOL)fill stroke:(BOOL)stroke clip:(BOOL)clip;
-(instancetype)setCharaterSpacing:(float)newSpacing;

-(id)fontWithName:(NSString*)name size:(float)size;
-(id)paragraphStyle;        // experimental

-(instancetype)showTextString:str at:(NSPoint)position;
-(instancetype)showGlyphBuffer:(unsigned short*)glyphs length:(int)len at:(NSPoint)position;
-(instancetype)showGlyphs:glyphArray at:(NSPoint)position;
-(instancetype)layoutText:someText inPath:aPath;


-(instancetype)drawLinearGradientFrom:(NSPoint)startPoint to:(NSPoint)endPoint colors:(NSArray*)colors offsets:(NSArray*)offsets;
-(instancetype)drawRadialGradientFrom:(NSPoint)startPoint radius:(float)startRadius to:(NSPoint)endPoint radius:(float)endRadius colors:(NSArray*)colors offsets:(NSArray*)offsets;


-(void)clip;
-(void)fill;
-(void)fill:aPath;
-(void)eofill;
-(void)eofillAndStroke;
-(void)fillAndStroke;
-(void)fillAndStroke:aPath;
-(void)stroke;
-(void)stroke:aPath;
-(void)fillRect:(NSRect)r;

-(void)fillDarken;          // not sure this should be here


-(NSRect)cliprect;

-(instancetype)beginPath;
-(instancetype)nsrect:(NSRect)r;
-(instancetype)moveto:(float)x :(float)y;
-(instancetype)lineto:(float)x :(float)y;
-(instancetype)curveto:(float)cp1x :(float)cp1y :(float)cp2x :(float)cp2y :(float)x :(float)y;
-(instancetype)closepath;
-(instancetype)arcWithCenter:(NSPoint)center radius:(float)radius startDegrees:(float)start endDegrees:(float)stop  clockwise:(BOOL)clockwise;
-(instancetype)arcFromPoint:(NSPoint)p1 toPoint:(NSPoint)p2 radius:(float)radius;
-(instancetype)ellipseInRect:(NSRect)r;

-(instancetype)drawImage:anImage;

-(instancetype)show:(id)someText;             // NS(Attributed)String
-(instancetype)setTextPosition:(NSPoint)p;
-(instancetype)setFont:aFont;

#if NS_BLOCKS_AVAILABLE
typedef void (^DrawingBlock)(id <MPWDrawingContext>);

-withShadowOffset:(NSSize)offset blur:(float)blur color:aColor draw:(DrawingBlock)commands;
-ingsave:(DrawingBlock)drawingCommands;
-(id)drawLater:(DrawingBlock)drawingCommands;
-layerWithSize:(NSSize)size content:(DrawingBlock)drawingCommands;
-laterWithSize:(NSSize)size content:(DrawingBlock)drawingCommands;
-page:(NSDictionary*)parameters content:(DrawingBlock)drawingCommands;
-path:(DrawingBlock)pathCreator;
#endif

-(instancetype)translate:(id)aPoint;
-(instancetype)scale:(id)aPointOrNumber;
-(instancetype)moveto:(id)aPoint;
-(instancetype)lineto:(id)aPoint;
-(instancetype)rect:(id)sizeOrRect;
-(instancetype)ellipse:(id)radiusSizeOrRect;


#if !TARGET_OS_IPHONE   // hack, don't use
-concatNSAffineTransform:(NSAffineTransform*)transform;
#endif

-(void)flush;
-(void)sync;
-(void)fillBackgroundWithColor:aColor;

@end

typedef id <MPWDrawingContext> Drawable;


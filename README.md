MPWDrawingContext, version 0.3
==============================

An Objective-C wrapper around the CoreGraphics CGContextRef.  It includes
the MPWDrawingContext protocol and the MPWCGDrawingContext class that 
implements that protocol by calling CoreGraphics CGContextRef functions.

The idea is for the context to be lightweight and straightforward enough
that including it is a no-brainer.

The MPWDrawingContext protocol itself has no dependencies on AppKit, 
UIKit or CoreGraphics.

Also includes is MPWView, a View class that subclasses UIView on iOS
and NSView on OSX and renders using an MPWDrawingContext.  The sample
applications for both OSX and iOS use the same view code.  MPWView
also allows drawing and event-handling code to be specified using
blocks, so trivial views don't require a subclass.

PhoneGeometry.h
provides NSPoint, NSSize and NSRect data-types on iOS by mapping them 
to their CoreGraphcis equivalents there.

The protocol aims to provide a "fluent" interface so that commands
can be chained.

ChangeLog
---------

Version 0.3
-----------

- object-based single argument convenience methods (moveto,lineto,etc.)
- shadows also block-based
- linecap
- drawOnContext: for blocks
- some unit tests

Version 0.2
-----------

- actually made separate subclasses for PDF and Bitmap contexts
- initial pattern support (only for colored patterns)
- blocks everywhere, especially for re-usable images
- use images or block-drawables directly as (pattern colors)


Version 0.1
-----------

- first release

Future Plans
------------

- expand text rendering to include most of CoreText (or equivalents)
- more context types, for example rendering to CALayers, SVG and Canvas or OpenGL textures
- image processing options, both stand-alone and as layered contexts

Creation
--------

Creation methods are not part of the MPWDrawingContext protocol, but left to specific context classes.

If you already have a CGContextRef or want to use the current one:

    +contextWithCGContext:(CGContextRef)c;
    -initWithCGContext:(CGContextRef)newContext;
    +currentContext;


Alternatively you can create a new bitmap context with a current size.

    +rgbBitmapContext:(NSSize)size;
    +cmykBitmapContext:(NSSize)size;

    -initBitmapContextWithSize:(NSSize)size colorSpace:(CGColorSpaceRef)colorspace;



Paths
-----

These are direct analogs to the corresponding CG functions.  Use like
this:   [[context nsrect:[self bounds]] fill];

Construction:

    -(id <MPWDrawingContext>)moveto:(float)x :(float)y;
    -(id <MPWDrawingContext>)lineto:(float)x :(float)y;
    -(id <MPWDrawingContext>)curveto:(float)cp1x :(float)cp1y :(float)cp2x :(float)cp2y :(float)x :(float)y;
    -(id <MPWDrawingContext>)closepath;
    -(id <MPWDrawingContext>)nsrect:(NSRect)r;
    -(id <MPWDrawingContext>)arcWithCenter:(NSPoint)center radius:(float)radius startDegrees:(float)start endDegrees:(float)stop  clockwise:(BOOL)clockwise;
    -(id <MPWDrawingContext>)arcFromPoint:(NSPoint)p1 toPoint:(NSPoint)p2 radius:(float)radius;
    -(id <MPWDrawingContext>)ellipseInRect:(NSRect)r;


Drawing:

    -(void)clip;
    -(void)fill;
    -(void)eofill;
    -(void)eofillAndStroke;
    -(void)fillAndStroke;
    -(void)stroke;

Gradients:


    -(id <MPWDrawingContext>)drawLinearGradientFrom:(NSPoint)startPoint to:(NSPoint)endPoint colors:(NSArray*)colors offsets:(NSArray*)offsets;
    -(id <MPWDrawingContext>)drawRadialGradientFrom:(NSPoint)startPoint radius:(float)startRadius to:(NSPoint)endPoint radius:(float)endRadius colors:(NSArray*)colors offsets:(NSArray*)offsets;



Images
------

There is currently just a single method:

    -(id <MPWDrawingContext>)drawImage:anImage;

The type of the image is purposely undefined.   MPWCGDrawingContext
expects that it either responds to (a) -CGImage to return a CGImageRef
(as both UIImage and NSBitmapImageRep do) or (b) can render itself 
using  -drawOnContext:(id <MPWDrawingContext>)aContext;

Images are rendered at their natural size (sent -size).


Text
----

    -(id <MPWDrawingContext>)show:(id)someText; 
    -(id <MPWDrawingContext>)setTextPosition:(NSPoint)p;
    -(id)fontWithName:(NSString*)name size:(float)size;
    -(id <MPWDrawingContext>)setFont:aFont;

Text support is currently very rudimentary, sporting only the
single -show: message.  It can be passed either an NSString
or an NSAttributedString.   In the former case, drawing 
parameters will be taken from the current graphics state,
in the latter they will be taken from the NSAttributedString
itself.

The -setFont: message takes as its argument a font returned
by -fontWithName:size:.   We purposely don't specify what
exact class the font will be.


Graphics State
--------------

Setting colors uses the same pattern as setting fonts: there are
two basic color-setting messages:

    -(id <MPWDrawingContext>)setFillColor:(id)aColor;
    -(id <MPWDrawingContext>)setStrokeColor:(id)aColor;

These are complemented by a number of messages returning color objects,
again we don't exactly say what class they will be, just that they are
compatible with the color-setting methods.

    -(id)colorRed:(float)r green:(float)g blue:(float)b alpha:(float)alpha;
    -(id)colorCyan:(float)c magenta:(float)m yellow:(float)y black:(float)k alpha:(float)alpha;
    -(id)colorGray:(float)gray alpha:(float)alpha;

So setting an RGB fill color works as follows:

    [context setFillColor:[context colorRed:1.0 green:0 blue:0 alpha:0]];

There are also plural versions of these methods:

    -(id)colorsRed:r green:g blue:b alpha:alpha;
    -(id)colorsCyan:c magenta:m yellow:y black:k alpha:alpha;
    -(id)colorsGray:gray alpha:alpha;

The key to these methods is that they allow array parameters and allow
array an non-array parameters to be mixed.  For example:

    [context colorRed:@[ 0.0 0.5 1.0 ] green:@0 blue:@0 alpha:@1];

will return 3 colors ranging from black to red.  This comes in
handy when specifying sets of related colors, for example
for gradients.

CTM transformations:

    -(id <MPWDrawingContext>)translate:(float)x :(float)y;
    -(id <MPWDrawingContext>)scale:(float)x :(float)y;
    -(id <MPWDrawingContext>)rotate:(float)degrees;

Saving and restoring:

    -(id <MPWDrawingContext>)gsave;
    -(id <MPWDrawingContext>)grestore;

Miscellaneous parameters:

    -(id <MPWDrawingContext>)setdashpattern:array phase:(float)phase;
    -(id <MPWDrawingContext>)setlinewidth:(float)width;
    -(id <MPWDrawingContext>)setlinecapRound;
    -(id <MPWDrawingContext>)setlinecapSquare;
    -(id <MPWDrawingContext>)setlinecapButt;


    -(id <MPWDrawingContext>)setAlpha:(float)alpha;
    -(id <MPWDrawingContext>)setAntialias:(BOOL)doAntialiasing;
    -(id <MPWDrawingContext>)setShadowOffset:(NSSize)offset blur:(float)blur color:(id)aColor;
    -(id <MPWDrawingContext>)clearShadow;

Block-based:


    -withShadowOffset:(NSSize)offset blur:(float)blur color:aColor draw:(DrawingBlock)commands;
    -ingsave:(DrawingBlock)drawingCommands;
    -(id)drawLater:(DrawingBlock)drawingCommands;
    -layerWithSize:(NSSize)size content:(DrawingBlock)drawingCommands;
    -laterWithSize:(NSSize)size content:(DrawingBlock)drawingCommands;
    -page:(NSDictionary*)parameters content:(DrawingBlock)drawingCommands;

Convenience:

    -(id <MPWDrawingContext>)translate:(id)aPoint;
    -(id <MPWDrawingContext>)scale:(id)aPointOrNumber;
    -(id <MPWDrawingContext>)moveto:(id)aPoint;
    -(id <MPWDrawingContext>)lineto:(id)aPoint;

Infrequently Asked Questions
----------------------------


**Why would anyone need an Objective-C drawing context?**

In short, while CoreGraphics is an awesome graphics subsystem, not having OO features makes CGContext closed to extension by anyone but Apple, and somewhat unpleasant to use, IMHO.

I explain a bit more about the motivation on my blog:   http://blog.metaobject.com/2012/06/pleasant-objective-c-drawing-context.html

**Who cares about possible future expansion when that means there's lots of code to integrate with nasty dependencies?**

It used to be just 1 Class,  1 Protocol, 3 extra include files to equalize some of the differences between iOS and OSX (could probably be reduced), but it's admittedly a little more now:  Classes for different context types, for storing drawing commands
and even (gasp!) an abstract class that captures some commonality between contexts.  Still totally worth it, though.

1 additional class (MPWView) is purely optional

In the [github project](https://github.com/mpw/MPWDrawingContext), the code
is actually integrated into an adapted version of Matt Gallagher's
[IconApp](http://www.cocoawithlove.com/2011/01/advanced-drawing-using-appkit.html) (with some inspiration from Marcus
Crafter's [iOS port](http://redartisan.com/2011/05/13/porting-iconapp-core-graphics) of same), so you have a working example right there.

**But Cocoa has some fine drawing functionality with NSBezierPath, NSAffineTransform and friends**

True, but MPWDrawingContext works identically on both iOS and Mac OS X.  In fact there's also an MPWView class that works on both iOS and OSX, which is used in the sample code mentioned above to create an iOS app using the same drawing code as the OS X app.

I also prefer my graphics context to not be a hidden global parameter that's implicitly used by a bunch of other objects.

**Who cares about OSX^H^H^H iOS?**

Based on my unscientific experiments, MPWDrawingContext reduces the code I have to write for even one of the two platforms by about 20-30%.  Your mileage will almost certainly vary.

**Who cares about less code?**

Well, it\s not just less code, it's more pleasant code as well:

	[[[[[context moveto:0 :0] lineto:100 :0] lineto:50 :50] closepath] stroke];

vs.

	CGContextMoveToPoint( context, 0, 0 );
	CGContextAddLineToPoint( context, 100, 0);
	CGContextAddLineToPoint( context, 50, 50 );
	CGContextClosePath( context );
	CGContextFillPath( context );

And

        bitmap = [context bitmapWithSize:NSMakeSize( 595, 842 ) commands:^(Drawable){  ... }];

vs.
	
	bitmapContext = CGBitmapContextCreate(NULL, size.width, size.height, 8, 0,
                           CGColorSpaceCreateDeviceRGB(),   
                           kCGImageAlphaPremultipliedLast)  | kCGBitmapByteOrderDefault );
	{ .... } 
        cgBitmap = CGBitmapContextCreateImage( bitmapContext );
	bitmap = [UIImage imageWithCGImage:cgBitmap];
	CGImageRelease(cgBitmap);
	CGContextRelease(bitmapContext);


**No it's not!**

OK :-)


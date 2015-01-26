//
//  NSImage+Resize.m
//  AppIcons
//
//  Created by B02923 on 2014/08/01.
//  Copyright (c) 2014年 B02923. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "NSImage+Resize.h"



@implementation NSImage (Resize)

/**
 * リサイズ.
 */
- (NSImage *)resizedImageToWidth:(float)width
                          height:(float)height
{
    return [self resizedImageToWidth:width height:height
                           maskImage:nil
                       filterEnabled:NO
                           intensity:0
                       sharpenRadius:0];
}

- (NSImage *)resizedImageToWidth:(float)width
                          height:(float)height
                       intensity:(float)intensity
                   sharpenRadius:(float)sharpenRadius
{
    return [self resizedImageToWidth:width height:height
                           maskImage:nil
                       filterEnabled:YES
                           intensity:intensity
                       sharpenRadius:sharpenRadius];
}


- (NSImage *)resizedImageToWidth:(float)width
                          height:(float)height
                     cornerRatio:(float)cornerRatio
                   filterEnabled:(BOOL)filterEnabled
                       intensity:(float)intensity
                   sharpenRadius:(float)sharpenRadius {
    
    return [self resizedImageToWidth:width
                              height:height
                           maskImage:[NSImage roundRectMaskWithSize:NSMakeSize(width, height) cornerRadiusRatio:cornerRatio]
                       filterEnabled:filterEnabled
                           intensity:intensity
                       sharpenRadius:sharpenRadius];
}

/**
 * 切り抜き用マスク指定してリサイズ.
 */
- (NSImage *)resizedImageToWidth:(float)width
                          height:(float)height
                       maskImage:(NSImage*)maskImage
                   filterEnabled:(BOOL)filterEnabled
                       intensity:(float)intensity
                   sharpenRadius:(float)sharpenRadius
{
    
    NSImage *resizedImage = [[NSImage alloc] initWithSize:NSMakeSize(width, height)];
    resizedImage.matchesOnMultipleResolution = NO;
    [resizedImage lockFocus];

//    NSImage* img = (filterEnabled) ? [self sharpenImageWithIntensity:intensity radius:sharpenRadius] : self;
    NSImage* img = self;
    
    [img drawInRect:NSMakeRect(0, 0, width, height)
           fromRect:NSMakeRect(0, 0, self.size.width, self.size.height)
          operation:NSCompositeSourceOver
           fraction:1.0
     respectFlipped:NO
              hints:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:NSImageInterpolationHigh]
                                                forKey:NSImageHintInterpolation]];

    if (maskImage) {
        [maskImage drawInRect:NSMakeRect(0, 0, width, height)
                     fromRect:NSMakeRect(0, 0, maskImage.size.width, maskImage.size.height)
                    operation:NSCompositeDestinationAtop
                     fraction:1.0
               respectFlipped:NO
                        hints:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:NSImageInterpolationHigh]
                                                          forKey:NSImageHintInterpolation]];
    }

    [resizedImage unlockFocus];
    NSImageRep* rep = [resizedImage.representations objectAtIndex:0];
    [rep setPixelsWide:self.size.width];
    [rep setPixelsHigh:self.size.height];
    
    return (filterEnabled)
        ? [resizedImage sharpenImageWithIntensity:intensity
                                           radius:sharpenRadius]
        : resizedImage;
}


- (NSImage*)sharpenImageWithIntensity:(CGFloat)intensity radius:(CGFloat)radius {

    CIImage* inputImage = [[CIImage alloc] initWithBitmapImageRep:[self unscaledBitmapImageRep]];
    CIFilter* filter = [CIFilter filterWithName:@"CIUnsharpMask"];
    [filter setDefaults];
    [filter setValue:inputImage forKey:@"inputImage"];
    [filter setValue:[NSNumber numberWithFloat:intensity] forKey:@"inputIntensity"];
    [filter setValue:[NSNumber numberWithFloat:radius*radius] forKey:@"inputRadius"];
    CIImage* outputImage = [filter valueForKey:@"outputImage"];
    
    NSRect outputImageRect = NSRectFromCGRect([outputImage extent]);
    NSImage* blurredImage = [[NSImage alloc]
                             initWithSize:outputImageRect.size];
    [blurredImage lockFocus];
    [outputImage drawAtPoint:NSZeroPoint fromRect:outputImageRect
                   operation:NSCompositeCopy fraction:1.0];
    [blurredImage unlockFocus];
    return blurredImage;
}



- (BOOL)writeToFileAsPNGFile:(NSString*)filename
{
    NSData *pngData = [[self unscaledBitmapImageRep] representationUsingType:NSPNGFileType properties:nil];
    return [pngData writeToFile:filename atomically:YES];
}


- (NSBitmapImageRep *)unscaledBitmapImageRep {
    NSBitmapImageRep *rep = [[NSBitmapImageRep alloc]
                             initWithBitmapDataPlanes:NULL
                             pixelsWide:self.size.width
                             pixelsHigh:self.size.height
                             bitsPerSample:8
                             samplesPerPixel:4
                             hasAlpha:YES
                             isPlanar:NO
                             colorSpaceName:NSDeviceRGBColorSpace
                             bytesPerRow:0
                             bitsPerPixel:0];
    rep.size = self.size;
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext:
     [NSGraphicsContext graphicsContextWithBitmapImageRep:rep]];
    
    [self drawAtPoint:NSMakePoint(0, 0)
             fromRect:NSZeroRect
            operation:NSCompositeSourceOver
             fraction:1.0];
    
    [NSGraphicsContext restoreGraphicsState];
    return rep;
}

+ (NSImage*)roundRectMaskWithSize:(NSSize)size cornerRadiusRatio:(CGFloat)radiusRatio {

    if (radiusRatio<0)radiusRatio=0.0f;
    if (radiusRatio>0.5)radiusRatio=0.5f;
    
    NSImage *image = [[NSImage alloc] initWithSize:size];
    [image lockFocus];
    [[NSColor whiteColor] set];
    
    if (radiusRatio>0) {
    [[NSBezierPath bezierPathWithRoundedRect:NSMakeRect(0, 0, size.width, size.height)
                                     xRadius:size.width*radiusRatio
                                     yRadius:size.height*radiusRatio] fill];
    }
    else {
        NSRectFill(NSMakeRect(0,0,size.width,size.height));
    }
    [image unlockFocus];
    return image;

}

@end

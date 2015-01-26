//
//  NSImage+Resize.h
//  AppIcons
//
//  Created by B02923 on 2014/08/01.
//  Copyright (c) 2014年 B02923. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSImage (Resize)

- (NSImage *)resizedImageToWidth:(float)width
                          height:(float)height;

- (NSImage *)resizedImageToWidth:(float)width
                          height:(float)height
                       intensity:(float)intensity
                   sharpenRadius:(float)sharpenRadius;

- (NSImage *)resizedImageToWidth:(float)width
                          height:(float)height
                     cornerRatio:(float)cornerRatio
                   filterEnabled:(BOOL)filterEnabled
                       intensity:(float)intensity
                   sharpenRadius:(float)sharpenRadius;

- (NSImage *)resizedImageToWidth:(float)width
                          height:(float)height
                       maskImage:(NSImage*)maskImage
                   filterEnabled:(BOOL)filterEnabled
                       intensity:(float)intensity
                   sharpenRadius:(float)sharpenRadius;

- (BOOL)writeToFileAsPNGFile:(NSString*)filename;

- (NSBitmapImageRep *)unscaledBitmapImageRep;

+ (NSImage*)roundRectMaskWithSize:(NSSize)size cornerRadiusRatio:(CGFloat)radiusRatio;

@end

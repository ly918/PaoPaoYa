//
//  NSImage+Compress.m
//  PaopaoYa
//
//  Created by Luca on 2018/7/4.
//  Copyright © 2018年 Luca. All rights reserved.
//

#import "NSImage+Compress.h"

@implementation NSImage (Compress)

/**
 类似UIImage contentMode 的AspectFit 的效果
 
 @param targetSize 目标限定区域
 @param transparent 带有透明背景 YES时 图片的size == targetsize 带有透明背景
 NO 时 图片的size不一定等于targetsize 不会带多余的透明背景
 @return 裁剪后的图片
 */
- (NSImage *)scaleAspectFitToSize:(CGSize)targetSize transparent:(BOOL)transparent{
    if ([self isValid]) {
        NSSize imageSize = [self size];
        float width  = imageSize.width;
        float height = imageSize.height;
        float targetWidth  = targetSize.width;
        float targetHeight = targetSize.height;
        float scaleFactor  = 0.0;
        float scaledWidth  = targetWidth;
        float scaledHeight = targetHeight;
        
        NSPoint thumbnailPoint = NSZeroPoint;
        
        if (!NSEqualSizes(imageSize, targetSize)){
            NSLog(@"IMGCOMPRESS:😂😂😂😂😂😂😂😂😂😂我被裁剪了");
            NSAssert(width > 0, @"IMGCOMPRESS:除数width为0!");
            NSAssert(height > 0, @"IMGCOMPRESS:除数height为0!");
            float widthFactor  = targetWidth / width;
            float heightFactor = targetHeight / height;
            
            if (widthFactor < heightFactor){
                scaleFactor = widthFactor;
            }
            else{
                scaleFactor = heightFactor;
            }
            
            scaledWidth  = width  * scaleFactor;
            scaledHeight = height * scaleFactor;
            
            if (widthFactor < heightFactor){
                thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
            }
            
            else if (widthFactor > heightFactor){
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
            
            
            // 等比缩放
            CGSize size = transparent ? targetSize : CGSizeMake(scaledWidth, scaledHeight);
            CGPoint point = transparent ? thumbnailPoint : CGPointZero;
            
            NSImage *newImage = [[NSImage alloc] initWithSize:size];
            
            [newImage lockFocus];
            
            NSRect thumbnailRect;
            thumbnailRect.origin = point;
            thumbnailRect.size.width = scaledWidth;
            thumbnailRect.size.height = scaledHeight;
            
            [self drawInRect:thumbnailRect
                    fromRect:NSZeroRect
                   operation:NSCompositeSourceOver
                    fraction:1.0];
            
            [newImage unlockFocus];
            return newImage;
        }
        return self;
    }
    return self;
}


/**
 类似UIImage contentMode 的AspectFill 的效果
 
 @param targetSize 目标限定区域
 @param clipsToBounds 返回的图片是否是裁剪过后的
 @return 裁剪后的图片
 */
- (NSImage *)scaleAspectFillToSize:(CGSize)targetSize clipsToBounds:(BOOL)clipsToBounds{
    if ([self isValid]) {
        NSSize imageSize = [self size];
        float width  = imageSize.width;
        float height = imageSize.height;
        float targetWidth  = targetSize.width;
        float targetHeight = targetSize.height;
        float scaleFactor  = 1.0;
        NSRect targetFrame = NSMakeRect(0, 0, targetSize.width, targetSize.height);
        
        if (!NSEqualSizes(imageSize, targetSize)){
            NSAssert(width > 0, @"IMGCOMPRESS:除数width为0!");
            NSAssert(height > 0, @"IMGCOMPRESS:除数height为0!");
            float widthFactor  = targetWidth / width;
            float heightFactor = targetHeight / height;
            
            if (!clipsToBounds) {
                if (widthFactor < heightFactor){
                    scaleFactor = heightFactor;
                }
                else{
                    scaleFactor = widthFactor;
                }
                CGSize scaleSize = CGSizeMake(width * scaleFactor, height * scaleFactor);
                return [self scaleAspectFitToSize:scaleSize transparent:NO];
            }
            
            NSRect cropRect = NSZeroRect;
            if (heightFactor >= widthFactor) {//放大过程中宽度先达到边界
                cropRect.size.width = floor (targetWidth / heightFactor);
                cropRect.size.height = height;
            } else {
                cropRect.size.width = width;
                cropRect.size.height = floor(targetHeight / widthFactor);
            }
            
            cropRect.origin.x = floor( (width - cropRect.size.width)/2 );
            cropRect.origin.y = floor( (height - cropRect.size.height)/2 );
            
            NSImage *targetImage = [[NSImage alloc] initWithSize:targetSize];
            
            [targetImage lockFocus];
            
            //从sourceImage上的fromRect位置处截取图片，绘制到targetFrame上
            [self drawInRect:targetFrame
                    fromRect:cropRect       //portion of source image to draw
                   operation:NSCompositeCopy  //compositing operation
                    fraction:1.0              //alpha (transparency) value
              respectFlipped:YES              //coordinate system
                       hints:@{NSImageHintInterpolation:
                                   [NSNumber numberWithInt:NSImageInterpolationLow]}];
            
            [targetImage unlockFocus];
            return targetImage;
        }
        return self;
    }
    return self;
}

- (NSData *)compressFactor:(CGFloat)aFactor{
    return [self compressFactor:aFactor outFileType:NSJPEGFileType];
}

- (NSData *)compressFactor:(CGFloat)aFactor outFileType:(NSBitmapImageFileType)fileType{
    NSBitmapImageRep *bitmapRep = nil;
    for (NSImageRep *imageRep in [self representations])
    {
        if ([imageRep isKindOfClass:[NSBitmapImageRep class]])
        {
            bitmapRep = (NSBitmapImageRep *)imageRep;
            break;
        }
    }
    if (!bitmapRep)
    {
        bitmapRep = [NSBitmapImageRep imageRepWithData:[self TIFFRepresentation]];
    }
    [bitmapRep setSize:self.size];
    NSDictionary *imgProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:aFactor] forKey:NSImageCompressionFactor];
    NSData *imgData = [bitmapRep representationUsingType:fileType properties:imgProps];
    return imgData;
}


- (NSData *)halfFuntionForMaxFileSize:(NSInteger)maxSize{
    //保存压缩系数
    static NSArray *arr = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableArray *compressionQualityArr = [NSMutableArray array];
        CGFloat avg   = 1.0/100;
        CGFloat value = avg;
        for (int i = 100; i >= 1; i--) {
            value = i*avg;
            [compressionQualityArr addObject:@(value)];
        }
        arr = [compressionQualityArr copy];
    });
    
    
    NSData *finallImageData = [self TIFFRepresentation];
    NSData *tempData = [NSData data];
    NSInteger start = 0;
    NSInteger end = arr.count - 1;
    
    while(end >= 0 && start <= end) {
        NSInteger index = start + (end - start)/2;
        NSLog(@"IMGCOMPRESS:开始位置:%tu,结束位置:%tu,index:%tu",start,end,index);
        NSAssert(index < arr.count, @"IMGCOMPRESS:🤭🤭🤭🤭🤭🤭🤭🤭🤭🤭index >= count");
        finallImageData = [self compressFactor:[arr[index] floatValue]];
        
        NSUInteger sizeOrigin = finallImageData.length;
        CGFloat sizeOriginMB = sizeOrigin / (1024. * 1024.);
        NSLog(@"IMGCOMPRESS:第%lu个位置的压缩,压缩系数为:%lf,压缩后的质量：%f", (unsigned long)index, [arr[index] floatValue],sizeOriginMB);
        if (sizeOriginMB > maxSize) {
            start = index + 1;
        } else if (sizeOriginMB < maxSize) {
            tempData = finallImageData;
            end = index - 1;
        } else {
            //刚好满足条件
            tempData = finallImageData;
            break;
        }
    }
    return tempData;
}

- (BOOL)writeToFile:(NSURL *)fileURL
{
    NSData *imageData = [self compressFactor:1 outFileType:[self fileTypeForFile:fileURL.path]];
    NSError *error;
    BOOL success = [imageData writeToURL:fileURL options:NSDataWritingAtomic error:&error];
    NSLog(@"Error %@ Path %@",error.localizedDescription,fileURL.path);
    return success;
}

- (NSBitmapImageFileType)fileTypeForFile:(NSString *)file{
    NSString *extension = [[file pathExtension] lowercaseString];
    if ([extension containsString:@"png"]){
        return NSPNGFileType;
    }
    else if ([extension containsString:@"gif"]){
        return NSGIFFileType;
    }
    else if ([extension containsString:@"jpg"] || [extension containsString:@"jpeg"]){
        return NSJPEGFileType;
    }
    return NSTIFFFileType;
}

@end

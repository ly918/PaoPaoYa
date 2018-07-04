//
//  NSImage+Compress.h
//  PaopaoYa
//
//  Created by Luca on 2018/7/4.
//  Copyright © 2018年 Luca. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSImage (Compress)


/**
 类似UIImage contentMode 的AspectFit 的效果
 
 @param targetSize 目标限定区域
 @param transparent 带有透明背景 YES时 图片的size == targetsize 带有透明背景
 NO 时 图片的size不一定等于targetsize 不会带多余的透明背景
 @return 裁剪后的图片
 */
- (NSImage *)scaleAspectFitToSize:(CGSize)targetSize transparent:(BOOL)transparent;

/**
 类似UIImage contentMode 的AspectFill 的效果
 
 @param targetSize 目标限定区域
 @param clipsToBounds 返回的图片是否是裁剪过后的
 @return 裁剪后的图片
 */
- (NSImage *)scaleAspectFillToSize:(CGSize)targetSize clipsToBounds:(BOOL)clipsToBounds;

/**
 图片压缩
 
 @param aFactor 压缩因子
 @return 压缩后的图片data
 */
- (NSData *)compressFactor:(CGFloat)aFactor;

- (NSData *)compressFactor:(CGFloat)aFactor outFileType:(NSBitmapImageFileType)fileType;

- (NSData *)halfFuntionForMaxFileSize:(NSInteger)maxSize;

- (BOOL)writeToFile:(NSURL *)fileURL;


@end

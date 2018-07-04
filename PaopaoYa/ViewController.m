//
//  ViewController.m
//  PaopaoYa
//
//  Created by Luca on 2018/7/3.
//  Copyright © 2018年 Luca. All rights reserved.
//

#import "ViewController.h"
#import "PPDragView.h"
#import "NSImage+Compress.h"
#import "JPNG.h"

@implementation ViewController
{
    PPDragView *gragView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    __weak typeof(self) wself = self;
    gragView = [[PPDragView alloc]initWithFrame:self.view.bounds];
    gragView.didGetFileListBlock = ^(NSArray *fileList) {
        [wself didGetFileList:fileList];
    };
    [self.view addSubview:gragView];
    // Do any additional setup after loading the view.
}

- (void)didGetFileList:(NSArray *)fileList{
    for (NSString *path in fileList) {
        if ([self pathValid:path]) {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self compressImageForPath:path];
            });
        }
    }
}

- (BOOL)pathValid:(NSString *)path{
    return [self fileType:path]?YES:NO;
}

- (NSString *)fileType:(NSString *)path{
    if ([path hasSuffix:@".jpg"]) {
        return @".jpg";
    }
    if ([path hasSuffix:@".jpeg"]) {
        return @".jpeg";
    }
    if ([path hasSuffix:@".png"]) {
        return @".png";
    }
    return nil;
}

- (NSBitmapImageFileType)bitFileType:(NSString *)path{
    if ([path hasSuffix:@".jpg"]||[path hasSuffix:@".jpeg"]) {
        return NSJPEGFileType;
    }
    if ([path hasSuffix:@".png"]) {
        return NSPNGFileType;
    }
    return NSJPEGFileType;
}

- (NSString *)getOutPath:(NSString *)inPath{
    NSString *fileType = [self fileType:inPath];
    return [inPath stringByReplacingOccurrencesOfString:fileType withString:[NSString stringWithFormat:@"_PPY%@",fileType]];
}

- (void)compressImageForPath:(NSString *)path{
    NSString *outPath = [self getOutPath:path];
    NSLog(@"Out %@",outPath);
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSLog(@"B %d KB",(int)data.length/1024);
    NSImage *image = [[NSImage alloc]initWithContentsOfFile:path];
    CGFloat scale = 0.5;
    NSData *compressData = nil;
    for (int i=100; i>=0; i--) {
        NSData *curData = NSImageJPNGRepresentation(image, (float)i/100.f);
        NSLog(@"curLength %d %d KB",i,(int)curData.length/1024);
        if ((float)curData.length/(float)data.length>scale) {
            if (i==0) {
                if (curData.length < data.length) {
                    compressData = curData;
                }
            }
            continue;
        } else {
            compressData = curData;
            break;
        }
    }
    compressData = compressData?:data;
    NSLog(@"A %d KB",(int)compressData.length/1024);
    NSError *error = nil;
    [compressData writeToFile:outPath options:NSDataWritingAtomic error:&error];
    NSLog(@"%@",error);
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end

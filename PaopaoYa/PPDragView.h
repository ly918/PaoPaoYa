//
//  PPDragView.h
//  PaopaoYa
//
//  Created by Luca on 2018/7/3.
//  Copyright © 2018年 Luca. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PPDragView : NSView
@property (nonatomic,copy)void (^didGetFileListBlock)(NSArray *fileList);
@end

//
//  PPDragView.m
//  PaopaoYa
//
//  Created by Luca on 2018/7/3.
//  Copyright © 2018年 Luca. All rights reserved.
//

#import "PPDragView.h"

@implementation PPDragView

- (instancetype)initWithFrame:(NSRect)frameRect{
    if (self = [super initWithFrame:frameRect]) {
        [self registerForDraggedTypes:@[NSFilenamesPboardType]];
    }
    return self;
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender{
    NSPasteboard *pb = [sender draggingPasteboard];
    if ([pb.types containsObject:NSFilenamesPboardType]) {
        return NSDragOperationCopy;
    }
    return NSDragOperationNone;
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender{
    NSPasteboard *pb = [sender draggingPasteboard];
    NSArray *list = [pb propertyListForType:NSFilenamesPboardType];
    if (_didGetFileListBlock) {
        _didGetFileListBlock(list);
    }
    return YES;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end

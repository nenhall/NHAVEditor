//
//  NHThread.m
//  NHAVEditorExamples
//
//  Created by XiuDan on 2019/8/14.
//  Copyright © 2019 XiuDan. All rights reserved.
//

#import "NHThread.h"


@interface NHThread ()
@property (nonatomic, strong) NSThread *rlThread;

@end
@implementation NHThread

- (instancetype)init
{
  self = [super init];
  if (self) {
    self.rlThread = [[NSThread alloc] initWithTarget:self selector:@selector(startRunLoop) object:nil];
    self.rlThread.name = @"com.nh.av.editor.thread";
  }
  return self;
}

- (void)startRunLoop {
  // create context
  CFRunLoopSourceContext content = {0};
  CFRunLoopSourceRef source = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &content);
  // 给 runloop 添加 sorces
  CFRunLoopAddSource(CFRunLoopGetCurrent(), source, kCFRunLoopDefaultMode);
  CFRelease(source);
  CFRunLoopRunInMode(kCFRunLoopDefaultMode, 1.0e10, false);
}

- (void)executeTask:(NHThreadTask)task {
  if (!self.rlThread || !task) {
    return;
  }
  if (!self.rlThread.isExecuting && !self.rlThread.isCancelled && !self.rlThread.finished) {
    [self.rlThread start];
  }
  
  [self performSelector:@selector(nh_executeTask:) onThread:self.rlThread withObject:task waitUntilDone:NO];
}

- (void)stop {
  if (!self.rlThread) {
    return;
  }
  
  [self performSelector:@selector(nh_stop) onThread:self.rlThread withObject:nil waitUntilDone:YES];
}

- (void)nh_stop {
  CFRunLoopStop(CFRunLoopGetCurrent());
  [_rlThread cancel];
  _rlThread = nil;
}

- (void)nh_executeTask:(NHThreadTask)task {
  task();
}

- (void)dealloc {
  [self stop];
}

@end

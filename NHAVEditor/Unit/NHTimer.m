//
//  NHTimer.m
//  NHAVEditorExamples
//
//  Created by XiuDan on 2019/8/14.
//  Copyright © 2019 XiuDan. All rights reserved.
//

#import "NHTimer.h"


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"


static NSMutableDictionary *timers_nh;
dispatch_semaphore_t semaphore_nh;


@implementation NHTimer

+ (void)initialize {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    timers_nh = [NSMutableDictionary dictionary];
    semaphore_nh = dispatch_semaphore_create(1);
  });
}

+ (NSString *)timerWithTimeInterval:(NSTimeInterval)interval
                              start:(NSTimeInterval)start
                            repeats:(BOOL)repeats
                              async:(BOOL)async
                           onlyFlag:(NSString *)onlyFlag
                      execTaskBlock:(void(^)(void))task {
  
  if ((repeats && interval <= 0) || !task || start < 0) {
    return nil;
  }
  
  if ([timers_nh objectForKey:onlyFlag]) {
    return onlyFlag;
  }
  
  dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
  if (!async) queue = dispatch_get_main_queue();
  
  dispatch_source_t source_t = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
  dispatch_source_set_timer(source_t,
                            dispatch_time(DISPATCH_TIME_NOW, (start * 1.0) * NSEC_PER_SEC),
                            (interval* 1.0) *NSEC_PER_SEC,
                            0);
  
  dispatch_semaphore_wait(semaphore_nh, DISPATCH_TIME_FOREVER);
  [timers_nh setObject:source_t forKey:onlyFlag];
  dispatch_semaphore_signal(semaphore_nh);
  
  dispatch_source_set_event_handler(source_t, ^{
    timer_safe_dispatch_main_q(^{
      task();
    });
    if (!repeats) [self cancelTask:onlyFlag];
  });
  dispatch_resume(source_t);
  
  return onlyFlag;
}


+ (NSString *)timerWithTimeInterval:(NSTimeInterval)interval
                              start:(NSTimeInterval)start
                             target:(id)target
                             action:(SEL)action
                            repeats:(BOOL)repeats
                              async:(BOOL)async
                           onlyFlag:(nonnull NSString *)onlyFlag{
  
  return [self timerWithTimeInterval:interval start:start repeats:repeats async:async onlyFlag:onlyFlag execTaskBlock:^{
    NSAssert([target respondsToSelector:action], @"定时器方法没有实现...");
    [target performSelector:action];
  }];
}

+ (void)cancelTask:(NSString *)name {
  
  if (!name) return;
  
  dispatch_semaphore_wait(semaphore_nh, DISPATCH_TIME_FOREVER);
  
  dispatch_source_t source_t = [timers_nh objectForKey:name];
  if (source_t) {
    dispatch_source_cancel(source_t);
    [timers_nh removeObjectForKey:name];
  }
  
  dispatch_semaphore_signal(semaphore_nh);
}

NS_INLINE void timer_safe_dispatch_main_q(dispatch_block_t block) {
  if (![[NSThread currentThread] isMainThread]) {
    dispatch_sync(dispatch_get_main_queue(), block);
  } else {
    dispatch_async(dispatch_get_main_queue(), block);
  }
}

@end

#pragma clang diagnostic pop

//
//  NHTimer.h
//  NHAVEditorExamples
//
//  Created by XiuDan on 2019/8/14.
//  Copyright © 2019 XiuDan. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NHTimer : NSObject

/**
 gcd定时器，回调的block内都会是主线程
 
 @param interval 间隙时间
 @param start 开始延迟
 @param repeats 是否重复
 @param async 同步？异步
 @param onlyFlag 唯一的标记
 @param task blockEvent
 @return 定时器标记，取消的时候需要用到
 */
+ (NSString *)timerWithTimeInterval:(NSTimeInterval)interval
                              start:(NSTimeInterval)start
                            repeats:(BOOL)repeats
                              async:(BOOL)async
                           onlyFlag:(nonnull NSString *)onlyFlag
                      execTaskBlock:(void(^)(void))task;

/**
 gcd定时器，回调的block内都会是主线程
 
 @param interval 间隙时间
 @param start 开始延迟
 @param target 执行对象
 @param action 事务
 @param repeats 是否重复
 @param async 同步？异步
 @return 定时器标记，取消的时候需要用到
 */
+ (NSString *)timerWithTimeInterval:(NSTimeInterval)interval
                              start:(NSTimeInterval)start
                             target:(nonnull id)target
                             action:(SEL)action
                            repeats:(BOOL)repeats
                              async:(BOOL)async
                           onlyFlag:(nonnull NSString *)onlyFlag
;


/**
 取消定时器
 
 @param name  定时器标记
 */
+ (void)cancelTask:(nonnull NSString *)name;

@end

NS_ASSUME_NONNULL_END

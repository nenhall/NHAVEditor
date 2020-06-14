//
//  NHThread.h
//  NHAVEditorExamples
//
//  Created by XiuDan on 2019/8/14.
//  Copyright © 2019 XiuDan. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^NHThreadTask)(void);

@interface NHThread : NSObject

/**
 在当前子线程执行一个任务
 */
- (void)executeTask:(NHThreadTask)task;

/**
 结束线程
 */
- (void)stop;

@end

NS_ASSUME_NONNULL_END

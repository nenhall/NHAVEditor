//
//  NSDate+NH.h
//  NHAVEditorExamples
//
//  Created by XiuDan on 2019/8/9.
//  Copyright © 2019 XiuDan. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (NH)

/**
 获取当前时间 （以毫秒为单位）

 @return 返回值格式:2019-04-19 10:33:35.886
 */
+ (NSString *)getNowTimeTimestamp;

@end

NS_ASSUME_NONNULL_END

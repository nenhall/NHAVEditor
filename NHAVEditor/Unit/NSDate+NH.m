//
//  NSDate+NH.m
//  NHAVEditorExamples
//
//  Created by XiuDan on 2019/8/9.
//  Copyright © 2019 XiuDan. All rights reserved.
//

#import "NSDate+NH.h"

@implementation NSDate (NH)

//获取当前时间 （以毫秒为单位）
//返回值格式:2019-04-19 10:33:35.886
+ (NSString *)getNowTimeTimestamp {
  NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setDateFormat:@"yyyyMMddHHmmssSS"];
  [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Beijing"]];
  NSString *dateString      = [formatter stringFromDate: datenow];
  return dateString;
}


@end

//
//  NSData+NH.m
//  NHAVEditorExamples
//
//  Created by XiuDan on 2019/8/13.
//  Copyright © 2019 XiuDan. All rights reserved.
//

#import "NSData+NH.h"

@implementation NSData (NH)

- (float)nh_size_m {
  return [self length] / 1024.0 / 1024.0;
}

@end

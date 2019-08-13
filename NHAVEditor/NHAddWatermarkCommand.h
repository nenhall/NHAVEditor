//
//  NHAddWatermarkCommand.h
//  NHAVEditorExamples
//
//  Created by XiuDan on 2019/8/9.
//  Copyright © 2019 XiuDan. All rights reserved.
//

#import "NHMediaCommand.h"

NS_ASSUME_NONNULL_BEGIN

@interface NHAddWatermarkCommand : NHMediaCommand
/**
 水印层
 */
@property (nonatomic, strong) CALayer *watermarkLayer;

/**
 自定义配置
 */
@property (nonatomic, strong) NHWatermarkConfig *config;

@end

NS_ASSUME_NONNULL_END

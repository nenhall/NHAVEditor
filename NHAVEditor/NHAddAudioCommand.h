//
//  NHAddAudioCommand.h
//  NHAVEditorExamples
//
//  Created by XiuDan on 2019/8/3.
//  Copyright © 2019 XiuDan. All rights reserved.
//

#import "NHMediaCommand.h"

NS_ASSUME_NONNULL_BEGIN

@interface NHAddAudioCommand : NHMediaCommand

/**
 自定义配置
 */
@property (nonatomic, strong) NHAudioConfig *config;

/**
 输入音频路径
 */
@property (nonatomic, copy) NSURL *inputAudioURL;


@end

NS_ASSUME_NONNULL_END

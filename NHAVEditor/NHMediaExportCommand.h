//
//  NHMediaExportCommand.h
//  NHAVEditorExamples
//
//  Created by XiuDan on 2019/8/9.
//  Copyright © 2019 XiuDan. All rights reserved.
//

#import "NHMediaCommand.h"

NS_ASSUME_NONNULL_BEGIN

@interface NHMediaExportCommand : NHMediaCommand

/**
 视频导出地址
 */
@property (nonatomic, copy  ) NSURL *outputURL;
@property (nonatomic, strong, readonly) AVAssetExportSession *exportSession;

/**
 自定义配置
 */
@property (nonatomic, strong) NHExporyConfig *config;

@end

NS_ASSUME_NONNULL_END

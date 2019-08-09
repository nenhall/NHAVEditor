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
@property (nonatomic, copy  ) NSURL *_Nullable outputURL;
@property (nonatomic, strong) AVAssetExportSession *exportSession;
@property (nonatomic, assign) NSString *exportPresetName;
@property (nonatomic, copy  ) AVFileType outputFileType;

@end

NS_ASSUME_NONNULL_END

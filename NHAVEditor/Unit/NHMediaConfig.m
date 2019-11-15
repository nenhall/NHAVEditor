//
//  NHMediaConfig.m
//  NHAVEditorExamples
//
//  Created by XiuDan on 2019/8/12.
//  Copyright © 2019 XiuDan. All rights reserved.
//

#import "NHMediaConfig.h"

@implementation NHAudioConfig

- (instancetype)init
{
  self = [super init];
  if (self) {
    _startVolume = 1.0;
    _endVolume = 1.0;
    _removeOriginalAudio = NO;
    _originalVolume = 1.0;
  }
  return self;
}

@end



/**
 ------------------------------- NHWatermarkConfig ------------------------------
 */
#pragma mark - NHWatermarkConfig
#pragma mark -

@implementation NHWatermarkConfig

- (instancetype)init
{
  self = [super init];
  if (self) {
    
  }
  return self;
}

@end



/**
 ------------------------------- NHExporyConfig ------------------------------
 */
#pragma mark - NHExporyConfig
#pragma mark -

@implementation NHExporyConfig

- (instancetype)init
{
  self = [super init];
  if (self) {
    _presetName = AVAssetExportPreset1280x720;
    _outputFileType = AVFileTypeQuickTimeMovie;
  }
  return self;
}

@end



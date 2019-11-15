//
//  NHAddAudioCommand.m
//  NHAVEditorExamples
//
//  Created by XiuDan on 2019/8/3.
//  Copyright © 2019 XiuDan. All rights reserved.
//

#import "NHAddAudioCommand.h"

@implementation NHAddAudioCommand

+ (instancetype)commandWithComposition:(AVMutableComposition *)composition
                      videoComposition:(AVMutableVideoComposition *)videoComposition
                              audioMix:(AVMutableAudioMix *)audioMix {
  NHAddAudioCommand *audio = [[NHAddAudioCommand alloc] initWithComposition:composition
                                                           videoComposition:videoComposition
                                                                   audioMix:audioMix];
  return audio;
}

- (void)performWithAsset:(AVAsset *)asset {
  
  // Check video and audio tracks
  AVAssetTrack *assetVideoTrack = nil;
  AVAssetTrack *assetAudioTrack = nil;
  
  // 视频
  NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
  if ([tracks count]) {
    assetVideoTrack = tracks.firstObject;
  }
  
  // 音频
  tracks = [asset tracksWithMediaType:AVMediaTypeAudio];
  if ([tracks count]) {
    assetAudioTrack = tracks.firstObject;
  }
  
  NSError *error = nil;
  
  // 获取被添加的音乐轨道
  AVAsset *audioAsset = [[AVURLAsset alloc] initWithURL:self.inputAudioURL options:nil];
  NSArray *audioTracks = [audioAsset tracksWithMediaType:AVMediaTypeAudio];
  AVAssetTrack *newAudioTrack = nil;
  if ([audioTracks count]) {
    newAudioTrack = audioTracks.firstObject;
  }
  
  // 是否保留视频原有的音频
  AVMutableCompositionTrack *ori_mcAudioTrack = nil;
  BOOL isAddOriginalAudio = assetAudioTrack && (self.config && !self.config.removeOriginalAudio);

  if (!self.mComposition) {
    self.mComposition = [AVMutableComposition composition];
    CMTimeRange iTimeRange = CMTimeRangeMake(kCMTimeZero, [asset duration]);

    // ** 视频 **
    if (assetVideoTrack) {
      AVMutableCompositionTrack *mcVideoTrack = [self.mComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
      [mcVideoTrack insertTimeRange:iTimeRange ofTrack:assetVideoTrack atTime:kCMTimeZero error:&error];
    }
    
    // ** 建立音轨 **
    if (assetAudioTrack) {
      ori_mcAudioTrack = [self.mComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
      
      if (isAddOriginalAudio) {
        [ori_mcAudioTrack insertTimeRange:iTimeRange ofTrack:assetAudioTrack atTime:kCMTimeZero error:&error];
      }
    }
  }
  
  // 原有的音轨
  AVMutableAudioMixInputParameters *oriMixParameters = nil;
  if (ori_mcAudioTrack) {
    oriMixParameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:ori_mcAudioTrack];
    if (self.config) {
      [oriMixParameters setVolumeRampFromStartVolume:self.config.originalVolume
                                         toEndVolume:self.config.originalVolume
                                           timeRange:CMTimeRangeMake(kCMTimeZero, asset.duration)];
      [oriMixParameters setTrackID:ori_mcAudioTrack.trackID];
    }
  }
  
  
  // 新的音频轨道
  AVMutableCompositionTrack *new_mcAudioTrack = nil;
  AVMutableAudioMixInputParameters *newMixParameters = nil;
  if (newAudioTrack) {
    new_mcAudioTrack = [self.mComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    CMTimeRange mi_timeRange = self.config.insertTimeRange;
    if (CMTIMERANGE_IS_INVALID(mi_timeRange)) {
      mi_timeRange = CMTimeRangeMake(kCMTimeZero, [self.mComposition duration]);
    }
    
    CMTime startTime = self.config.startTime;
    if (CMTIME_IS_INVALID(startTime)) {
      startTime = kCMTimeZero;
    }
    
    // 新音轨的插入范围、起点
    [new_mcAudioTrack insertTimeRange:mi_timeRange ofTrack:newAudioTrack atTime:startTime  error:&error];

    // 新的音频轨道
    // 把新的音轨一并合入
    newMixParameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:newAudioTrack];
    CMTimeRange volumeTimeRange = self.config.volumeTimeRange;
    if (CMTIMERANGE_IS_INVALID(volumeTimeRange)) {
      volumeTimeRange = CMTimeRangeMake(kCMTimeZero, [self.mComposition duration]);
    }
    if (self.config) {
      [newMixParameters setVolumeRampFromStartVolume:self.config.startVolume
                                         toEndVolume:self.config.endVolume
                                           timeRange:volumeTimeRange];
    } else {
      [newMixParameters setVolumeRampFromStartVolume:1.0
                                         toEndVolume:1.0
                                           timeRange:volumeTimeRange];
    }
    [newMixParameters setTrackID:new_mcAudioTrack.trackID];
  }
  
  // 所有音轨
  self.mAudioMix = [AVMutableAudioMix audioMix];
  if (isAddOriginalAudio) {
    self.mAudioMix.inputParameters = [NSArray arrayWithObjects:oriMixParameters, newMixParameters, nil];
  } else {
    self.mAudioMix.inputParameters = [NSArray arrayWithObjects:newMixParameters, nil];
  }

  if (self.delegate && [self.delegate respondsToSelector:@selector(mediaCompositioned:error:)]) {
    [self.delegate mediaCompositioned:self error:error];
  }
  
}

- (NHAVEditorType)type {
  return NHAVEditorTypeAudio;
}

@end

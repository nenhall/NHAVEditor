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
  
  if (!self.mComposition) {
    self.mComposition = [AVMutableComposition composition];
    CMTimeRange iTimeRange = CMTimeRangeMake(kCMTimeZero, [asset duration]);

    // 视频
    if (assetVideoTrack) {
      AVMutableCompositionTrack *cVideoTrack = [self.mComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
      [cVideoTrack insertTimeRange:iTimeRange ofTrack:assetVideoTrack atTime:kCMTimeZero error:&error];
    }
    
    // 音频
    BOOL isAddOrgAudio = assetAudioTrack && (self.config && !self.config.removeOriginalAudio);
    if (isAddOrgAudio) {
      AVMutableCompositionTrack *cAudioTrack = [self.mComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
      [cAudioTrack insertTimeRange:iTimeRange ofTrack:assetAudioTrack atTime:kCMTimeZero error:&error];
    }
  }
  
  // 新的音频轨道
  AVMutableCompositionTrack *nmAudioTrack = [self.mComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
  
  CMTimeRange mi_timeRange = self.config.insertTimeRange;
  if (CMTIMERANGE_IS_INVALID(mi_timeRange)) {
    mi_timeRange = CMTimeRangeMake(kCMTimeZero, [self.mComposition duration]);
  }
  
  CMTime startTime = self.config.startTime;
  if (CMTIME_IS_INVALID(startTime)) {
    startTime = kCMTimeZero;
  }

  // 插入范围、起点
  [nmAudioTrack insertTimeRange:mi_timeRange ofTrack:newAudioTrack atTime:startTime  error:&error];
  
  // 把新的音轨一并合入
  AVMutableAudioMixInputParameters *mixParameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:nmAudioTrack];
  CMTimeRange volumeTimeRange = self.config.volumeTimeRange;
  if (CMTIMERANGE_IS_INVALID(volumeTimeRange)) {
    volumeTimeRange = CMTimeRangeMake(kCMTimeZero, [self.mComposition duration]);
  }
  if (self.config) {
    [mixParameters setVolumeRampFromStartVolume:self.config.startVolume
                                    toEndVolume:self.config.endVolume
                                      timeRange:volumeTimeRange];
  } else {
    [mixParameters setVolumeRampFromStartVolume:1.0
                                    toEndVolume:1.0
                                      timeRange:volumeTimeRange];
  }
  
  
  self.mAudioMix = [AVMutableAudioMix audioMix];
  self.mAudioMix.inputParameters = @[ mixParameters ];
  
  if (self.delegate && [self.delegate respondsToSelector:@selector(mediaCompositioned:error:)]) {
    [self.delegate mediaCompositioned:self error:error];
  }
  
}



@end

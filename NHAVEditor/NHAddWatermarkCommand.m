//
//  NHAddWatermarkCommand.m
//  NHAVEditorExamples
//
//  Created by XiuDan on 2019/8/9.
//  Copyright © 2019 XiuDan. All rights reserved.
//

#import "NHAddWatermarkCommand.h"

@implementation NHAddWatermarkCommand
+ (instancetype)commandWithComposition:(AVMutableComposition *)composition
                      videoComposition:(AVMutableVideoComposition *)videoComposition
                              audioMix:(AVMutableAudioMix *)audioMix {
  NHAddWatermarkCommand *audio = [[NHAddWatermarkCommand alloc] initWithComposition:composition
                                                                   videoComposition:videoComposition
                                                                           audioMix:audioMix];
  return audio;
}

- (void)performWithAsset:(AVAsset *)asset {
  
  AVAssetTrack *assetVideoTrack = nil;
  AVAssetTrack *assetAudioTrack = nil;
  
  // Check video and audio tracks
  NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
  if ([tracks count]) {
    assetVideoTrack = tracks.firstObject;
  }
  
  tracks = [asset tracksWithMediaType:AVMediaTypeAudio];
  if ([tracks count]) {
    assetAudioTrack = tracks.firstObject;
  }
  
  CMTime insetionPoint = kCMTimeZero;
  NSError *error = nil;
  
  
  if (!self.mComposition) {
    self.mComposition = [AVMutableComposition composition];
    CMTimeRange iTimeRange = CMTimeRangeMake(kCMTimeZero, [asset duration]);

    if (assetVideoTrack != nil) {
      AVMutableCompositionTrack *cVideoTrack = [self.mComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
      [cVideoTrack insertTimeRange:iTimeRange ofTrack:assetVideoTrack atTime:insetionPoint error:&error];
    }
    
    if (assetAudioTrack != nil) {
      AVMutableCompositionTrack *cAudioTrack = [self.mComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
      [cAudioTrack insertTimeRange:iTimeRange ofTrack:assetAudioTrack atTime:insetionPoint error:&error];
    }
  }
  
  if ([[self.mComposition tracksWithMediaType:AVMediaTypeVideo] count] != 0) {
    if (!self.mVideoComposition) {
      self.mVideoComposition = [AVMutableVideoComposition videoComposition];
      self.mVideoComposition.frameDuration = CMTimeMake(1, 30);
      self.mVideoComposition.renderSize = assetVideoTrack.naturalSize;
      
      AVMutableVideoCompositionInstruction *vcInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
      vcInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, [self.mComposition duration]);
      
      AVAssetTrack *videoTrack = [self.mComposition tracksWithMediaType:AVMediaTypeVideo].firstObject;
      AVMutableVideoCompositionLayerInstruction *vcLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
      vcInstruction.layerInstructions = @[ vcLayerInstruction ];
      self.mVideoComposition.instructions = @[ vcLayerInstruction ];
    }
  }
  
  if (self.delegate && [self.delegate respondsToSelector:@selector(mediaCompositioned:outputURL:error:)]) {
    [self.delegate mediaCompositioned:self outputURL:nil error:error];
  }
  
}

@end

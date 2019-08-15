//
//  NHAddWatermarkCommand.m
//  NHAVEditorExamples
//
//  Created by XiuDan on 2019/8/9.
//  Copyright © 2019 XiuDan. All rights reserved.
//

#import "NHAddWatermarkCommand.h"
#import <CoreImage/CoreImage.h>
#import <UIKit/UIKit.h>

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
  
  // Step 1
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
  
  // Step 2
  if ([[self.mComposition tracksWithMediaType:AVMediaTypeVideo] count] != 0) {
    if (!self.mVideoComposition) {
      self.mVideoComposition = [AVMutableVideoComposition videoComposition];
      
//      CIFilter *watermarkFilter = [CIFilter filterWithName:@"CISourceOverCompositing"];
//      self.mVideoComposition = [AVMutableVideoComposition videoCompositionWithAsset:asset applyingCIFiltersWithHandler:^(AVAsynchronousCIImageFilteringRequest * _Nonnull request) {
//        CIImage *watermarkImage = [[CIImage alloc] initWithCGImage:[UIImage imageNamed:@"logo"].CGImage];
//        CIImage *source = request.sourceImage;
//        [watermarkFilter setValue:source forKey:kCIInputBackgroundImageKey];
//        [watermarkFilter setValue:[watermarkImage imageByApplyingTransform:CGAffineTransformMakeScale(source.extent.size.width/watermarkImage.extent.size.width, source.extent.size.height/watermarkImage.extent.size.height)] forKey:kCIInputImageKey];
//        [request finishWithImage:watermarkFilter.outputImage context:nil];
//      }];
      
      self.mVideoComposition.frameDuration = CMTimeMake(1, 25); //fps
      self.mVideoComposition.renderSize = assetVideoTrack.naturalSize;
      
      AVAssetTrack *videoTrack = [self.mComposition tracksWithMediaType:AVMediaTypeVideo].firstObject;
      
      // 一个视频轨道，包含了这个轨道上的所有视频素材
      AVMutableVideoCompositionLayerInstruction *vcLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
      //      [vcLayerInstruction setOpacity:0.0 atTime:[self.mComposition duration]];
      
      if (!CMTIMERANGE_IS_INVALID(self.config.transformTimeRange)) {
        [vcLayerInstruction setTransformRampFromStartTransform:self.config.startTransform
                                                toEndTransform:self.config.endTransform
                                                     timeRange:self.config.transformTimeRange];
      }
      
      if (!CMTIMERANGE_IS_INVALID(self.config.opacityTimeRange)) {
        [vcLayerInstruction setOpacityRampFromStartOpacity:self.config.startOpacity
                                              toEndOpacity:self.config.endOpacity
                                                 timeRange:self.config.opacityTimeRange];
      }

      // 管理所有视频轨道，水印添加在这
      AVMutableVideoCompositionInstruction *vcInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
      vcInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, [self.mComposition duration]);
      vcInstruction.layerInstructions = @[ vcLayerInstruction ];
      self.mVideoComposition.instructions = @[ vcInstruction ];
    }
  }
  
  // Step 3
  if (self.delegate && [self.delegate respondsToSelector:@selector(mediaCompositioned:error:)]) {
    [self.delegate mediaCompositioned:self error:error];
  }
  
}

@end

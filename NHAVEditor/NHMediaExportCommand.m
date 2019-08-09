//
//  NHMediaExportCommand.m
//  NHAVEditorExamples
//
//  Created by XiuDan on 2019/8/9.
//  Copyright © 2019 XiuDan. All rights reserved.
//

#import "NHMediaExportCommand.h"
#import "NSDate+NH.h"
#import "NHAVEditorHeader.h"

@implementation NHMediaExportCommand

+ (instancetype)commandWithComposition:(AVMutableComposition *)composition
                      videoComposition:(AVMutableVideoComposition *)videoComposition
                              audioMix:(AVMutableAudioMix *)audioMix {
  NHMediaExportCommand *export = [[NHMediaExportCommand alloc] initWithComposition:composition
                                                                  videoComposition:videoComposition
                                                                          audioMix:audioMix];
  return export;
}

- (void)setOutputURL:(NSURL *_Nullable)outputURL {
  if (outputURL) {
    _outputURL = outputURL;
  } else {
    NSString *name = [NSString stringWithFormat:@"%@.mp4",[NSDate getNowTimeTimestamp]];
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:name];
    NSURL *url = [NSURL fileURLWithPath:path];
    _outputURL = url;
  }
  [[NSFileManager defaultManager] removeItemAtURL:outputURL error:nil];
}


- (void)performWithAsset:(AVAsset *)asset {
  
  if (!self.exportPresetName) {
    self.exportPresetName = AVAssetExportPreset1280x720;
  }
  
  self.exportSession = [[AVAssetExportSession alloc] initWithAsset:[self.mComposition copy] presetName:self.exportPresetName];
  self.exportSession.audioMix = self.mAudioMix;
  self.exportSession.outputURL = self.outputURL;
  self.exportSession.outputFileType = self.outputFileType ?: AVFileTypeQuickTimeMovie;
  
  __weak __typeof(self)ws = self;
  [self.exportSession exportAsynchronouslyWithCompletionHandler:^{
    
    switch (ws.exportSession.status) {
      case AVAssetExportSessionStatusExporting:
        if (self.delegate && [self.delegate respondsToSelector:@selector(mediaCompositioning:progress:)]) {
          [self.delegate mediaCompositioning:ws progress:self.exportSession.progress];
        }
        break;
        
      case AVAssetExportSessionStatusCompleted:
        NHLog(@"导出完成");
        if (ws.delegate && [ws.delegate respondsToSelector:@selector(mediaCompositioned:outputURL:error:)]) {
          [ws.delegate mediaCompositioned:ws outputURL:ws.outputURL error:ws.exportSession.error];
        }
        break;
        
      case AVAssetExportSessionStatusFailed:
        NHLog(@"导出失败：%@",ws.exportSession.error.localizedDescription);
        if (ws.delegate && [ws.delegate respondsToSelector:@selector(mediaCompositioned:outputURL:error:)]) {
          [ws.delegate mediaCompositioned:ws outputURL:ws.outputURL error:ws.exportSession.error];
        }
        break;
        
      case AVAssetExportSessionStatusUnknown:
        NHLog(@"导出失败：%@",ws.exportSession.error.localizedDescription);
        if (ws.delegate && [ws.delegate respondsToSelector:@selector(mediaCompositioned:outputURL:error:)]) {
          [ws.delegate mediaCompositioned:ws outputURL:ws.outputURL error:ws.exportSession.error];
        }
        break;
        
      case AVAssetExportSessionStatusWaiting:
        NHLog(@"等待导出：%f",ws.exportSession.progress);
        if (ws.delegate && [ws.delegate respondsToSelector:@selector(mediaCompositioned:outputURL:error:)]) {
          [ws.delegate mediaCompositioned:ws outputURL:ws.outputURL error:ws.exportSession.error];
        }
        break;
        
      case AVAssetExportSessionStatusCancelled:
        NHLog(@"导出取消：%@",ws.exportSession.error.localizedDescription);
        if (ws.delegate && [ws.delegate respondsToSelector:@selector(mediaCompositioned:outputURL:error:)]) {
          [ws.delegate mediaCompositioned:ws outputURL:ws.outputURL error:ws.exportSession.error];
        }
        break;
    }
  }];
  
}


@end

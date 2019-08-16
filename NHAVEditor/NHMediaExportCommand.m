//
//  NHMediaExportCommand.m
//  NHAVEditorExamples
//
//  Created by XiuDan on 2019/8/9.
//  Copyright © 2019 XiuDan. All rights reserved.
//

#import "NHMediaExportCommand.h"
#import "NHAVEditorDefine.h"


@implementation NHMediaExportCommand {
  AVAssetExportSession *_exportSession;
}
@synthesize exportSession = _exportSession;

+ (instancetype)commandWithComposition:(AVMutableComposition *)composition
                      videoComposition:(AVMutableVideoComposition *)videoComposition
                              audioMix:(AVMutableAudioMix *)audioMix {
  NHMediaExportCommand *export = [[NHMediaExportCommand alloc] initWithComposition:composition
                                                                  videoComposition:videoComposition
                                                                          audioMix:audioMix];
  return export;
}


- (void)performWithAsset:(AVAsset *)asset {
  // check outputURL
  if (![self outputURL]) {
    if (self.delegate && [self.delegate respondsToSelector:@selector(mediaCompositioned:error:)]) {
      NSError *error = NH_ERROR(400, ERR_INFO(@"导出地址不能为空", nil, nil));
      [self.delegate mediaCompositioned:self error:error];
    }
    return;
  }
  
  // create AVAssetExportSession
  NSString *presetName = self.config.presetName;
  if (!presetName) {
    presetName = AVAssetExportPresetPassthrough;
  }
  _exportSession = [[AVAssetExportSession alloc] initWithAsset:[self.mComposition copy] presetName:presetName];
  _exportSession.audioMix = self.mAudioMix;
  _exportSession.outputURL = self.outputURL;
  _exportSession.videoComposition = self.mVideoComposition;
  _exportSession.shouldOptimizeForNetworkUse = YES;
  _exportSession.outputFileType = self.config.outputFileType ?: AVFileTypeMPEG4;
  
  __weak __typeof(self)ws = self;
  [self.exportSession exportAsynchronouslyWithCompletionHandler:^{
    switch (ws.exportSession.status) {
      case AVAssetExportSessionStatusExporting:
        NHLog(@"导出中：%f",ws.exportSession.progress);
        if (ws.delegate && [ws.delegate respondsToSelector:@selector(mediaCompositioning:progress:)]) {
          [ws.delegate mediaCompositioning:ws progress:ws.exportSession.progress];
        }
        break;
        
      case AVAssetExportSessionStatusUnknown:
        NHLog(@"导出状态未知：(AVAssetExportSessionStatusUnknown) - %@",ws.exportSession.error.localizedDescription);
        if (ws.delegate && [ws.delegate respondsToSelector:@selector(mediaCompositioning:progress:)]) {
          [ws.delegate mediaCompositioning:ws progress:ws.exportSession.progress];
        }
        break;
        
      case AVAssetExportSessionStatusWaiting:
        NHLog(@"等待导出：%f",ws.exportSession.progress);
        if (ws.delegate && [ws.delegate respondsToSelector:@selector(mediaCompositioning:progress:)]) {
          [ws.delegate mediaCompositioning:ws progress:ws.exportSession.progress];
        }
        break;
        
      case AVAssetExportSessionStatusCompleted:
        NHLog(@"导出完成");
        if (ws.delegate && [ws.delegate respondsToSelector:@selector(mediaExportCompleted:outputURL:error:)]) {
          [ws.delegate mediaExportCompleted:ws outputURL:ws.outputURL error:ws.exportSession.error];
        }
        break;
        
      case AVAssetExportSessionStatusFailed:
        NHLog(@"导出失败：(AVAssetExportSessionStatusFailed)%@",ws.exportSession.error.localizedDescription);
        if (ws.delegate && [ws.delegate respondsToSelector:@selector(mediaExportCompleted:outputURL:error:)]) {
          [ws.delegate mediaExportCompleted:ws outputURL:ws.outputURL error:ws.exportSession.error];
        }
        break;
        
      case AVAssetExportSessionStatusCancelled:
        NHLog(@"导出取消：%@",ws.exportSession.error.localizedDescription);
        if (ws.delegate && [ws.delegate respondsToSelector:@selector(mediaExportCompleted:outputURL:error:)]) {
          [ws.delegate mediaExportCompleted:ws outputURL:ws.outputURL error:ws.exportSession.error];
        }
        break;
    }
  }];
}

- (NHAVEditorType)type {
  return NHAVEditorTypeExport;
}

@end

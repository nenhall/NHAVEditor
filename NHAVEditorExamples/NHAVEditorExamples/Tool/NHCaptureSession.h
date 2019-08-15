//
//  NHCaptureSession.h
//  NHAVEditorExamples
//
//  Created by XiuDan on 2019/8/15.
//  Copyright © 2019 XiuDan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "NHCaptureSessionProtocol.h"


NS_ASSUME_NONNULL_BEGIN

@interface NHCaptureSession : NSObject<NHCaptureSessionProtocol>
{
  NSString *_inputPath;
  NSString *_outputPath;
  AVCaptureVideoOrientation _videoOrientation;
  BOOL     _isRecording;
  __weak UIView *_preview;
  CGFloat _distanceNormalizationFactor;
}
@property (nonatomic, weak) id<NHCaptureSessionProtocol> delegate;
@property (nonatomic, copy) NSString *inputPath;
@property (nonatomic, copy) NSString *outputPath;
@property (nonatomic, weak  ) UIView *preview;


/** 开始捕捉(预览) */
- (void)startCapture;

/** 停止捕捉(预览) */
- (void)stopCapture;

@end

NS_ASSUME_NONNULL_END

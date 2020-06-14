//
//  NHCaptureViewController.h
//  NHAVEditorExamples
//
//  Created by XiuDan on 2019/8/15.
//  Copyright © 2019 XiuDan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NHCaptureViewController : UIViewController

@property (nonatomic, copy) void(^didOutputBuffer)(CMSampleBufferRef bufferRef);
@property (nonatomic, copy) void(^didStopCapture)(BOOL stop);

@end

NS_ASSUME_NONNULL_END

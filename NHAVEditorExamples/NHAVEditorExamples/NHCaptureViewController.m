//
//  NHCaptureViewController.m
//  NHAVEditorExamples
//
//  Created by XiuDan on 2019/8/15.
//  Copyright © 2019 XiuDan. All rights reserved.
//

#import "NHCaptureViewController.h"
#import "NHCaptureSession.h"

@interface NHCaptureViewController ()<NHCaptureSessionProtocol>
@property (nonatomic, strong) NHCaptureSession *captureSession;
@property (nonatomic, assign) BOOL capture;
@end

@implementation NHCaptureViewController

- (void)viewDidLoad {
    [super viewDidLoad];

  
#if !TARGET_IPHONE_SIMULATOR
  _captureSession = [[NHCaptureSession alloc] init];
  _captureSession.delegate = self;
  [_captureSession setPreview:self.view];
  [_captureSession startCapture];
#endif

}
- (IBAction)backController:(id)sender {
  if (self.didStopCapture) {
    self.didStopCapture(YES);
  }
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)beginCapture:(UIButton *)sender {
  sender.selected = !sender.selected;
  if (self.didStopCapture) {
    self.didStopCapture(!sender.selected);
  }
  [self setCapture:sender.selected];
}


- (void)captureDidOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer {
  if (_capture) {
    if (_didOutputBuffer) {
      _didOutputBuffer(sampleBuffer);
    }
  }
}



@end

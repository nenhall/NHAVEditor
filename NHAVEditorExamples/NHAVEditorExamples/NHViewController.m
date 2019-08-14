//
//  NHViewController.m
//  NHAVEditorExamples
//
//  Created by XiuDan on 2019/8/3.
//  Copyright © 2019 XiuDan. All rights reserved.
//

#import "NHViewController.h"
#import "NHDisplayView.h"
#import <MBProgressHUD+NHAdd.h>
#import "NHAVEditor.h"
#import "NHAVEditorHeader.h"
#import <CoreImage/CoreImage.h>


#define kMp3Path [[NSBundle mainBundle] pathForResource:@"黑龙-38度6" ofType:@"mp3"]
#define kMp4Path [[NSBundle mainBundle] pathForResource:@"Бамбинтон-Зая" ofType:@"mp4"]


@interface NHViewController ()<NHAVEditorProtocol>
@property (weak, nonatomic  ) IBOutlet NHDisplayView *displayView;
@property (weak, nonatomic  ) IBOutlet UIButton *exportButton;
@property (nonatomic, strong) NHAVEditor *mediaEditor;
@property (nonatomic, strong) CALayer *watermarkLayer;
@property (nonatomic, assign) BOOL isOpenAnimation;

@end

@implementation NHViewController

- (void)viewDidLoad {
    [super viewDidLoad];

  [_displayView setPlayUrl:[NSURL fileURLWithPath:kMp4Path]];
  
}

#pragma mark - edit command
#pragma mark -
- (IBAction)addWatermarkAction:(UIButton *)sender {
  [self.mediaEditor addWatermarkWithLayer:self.watermarkLayer customConfig:nil completedBlock:^(NSURL * _Nullable outputURL, NSError * _Nullable error) {
    NHLog(@"合成完成:%@", outputURL);
  }];
}

- (IBAction)addMusicAction:(UIButton *)sender {
  [self.mediaEditor addAudioWithAudioURL:[NSURL fileURLWithPath:kMp3Path] customConfig:^(NHAudioConfig * _Nonnull config) {
    config.startVolume = -1.0;
    config.endVolume = 1.0;
  } completedBlock:^(NSURL * _Nullable outputURL, NSError * _Nullable error) {
    NHLog(@"合成完成:%@", outputURL);
  }];
}

- (IBAction)exportAction:(UIButton *)sender {
  [MBProgressHUD showDownToView:self.view progressStyle:NHHUDProgressDeterminateHorizontalBar title:@"正在导出..." progress:nil];
  __weak __typeof(self)ws = self;
  [self.mediaEditor exportMediaWithOutputURL:nil customConfig:^(NHExporyConfig * _Nonnull config) {
    config.presetName = AVAssetExportPreset1280x720;
    config.outputFileType = AVFileTypeQuickTimeMovie;
  } completedBlock:^(NSURL * _Nullable outputURL, NSError * _Nullable error) {
    NSLog(@"合成完成:%@", outputURL);
    dispatch_async(dispatch_get_main_queue(), ^{
      [MBProgressHUD hideHUDForView:ws.view];
    });
  }];
}

- (IBAction)watermarkSwitch:(UISwitch *)sender {
  _isOpenAnimation = sender.on;
}

#pragma mark - NHAVEditorProtocol
#pragma mark -
- (void)editorCompositioning:(NHAVEditor *)editor progress:(CGFloat)progress {
  NHLog(@"合成进度:%.02f",progress);
  [MBProgressHUD HUDForView:self.view].progress = progress;
}

- (void)editorCompositioned:(NHAVEditor *)editor outputURL:(NSURL *)outputURL error:(NSError *)error {
  NHLog(@"合成完成:%@", outputURL);
}

- (void)editorExportCompleted:(NHAVEditor *)editor outputURL:(NSURL *)outputURL error:(NSError *)error {
  NHLog(@"导出完成:%@", outputURL);
  [_displayView setPlayUrl:outputURL];

}


#pragma mark - private method
#pragma mark -
- (UIImage *)logoImage {
  return [UIImage imageNamed:@"logo"];
}

- (CALayer *)watermarkLayer {
  _watermarkLayer = [CALayer layer];
  CGFloat x = _displayView.videoSize.width - [self logoImage].size.width;
  CGFloat y = _displayView.videoSize.height - [self logoImage].size.height;
  _watermarkLayer.frame = CGRectMake(x, 0, [self logoImage].size.width, [self logoImage].size.height);
 
  CALayer *imageLayer = [CALayer layer];
  imageLayer.frame = CGRectMake(0, 0, [self logoImage].size.width, [self logoImage].size.height);
  imageLayer.contents = (__bridge id)[self logoImage].CGImage;
  [_watermarkLayer addSublayer:imageLayer];
  
  CATextLayer *titleLayer = [CATextLayer layer];
  titleLayer.frame = CGRectMake(0, 0, 100, 100);
  titleLayer.string = @"秀蛋科技";
  titleLayer.fontSize = 20.0;
  titleLayer.font = (__bridge CFTypeRef)@"PingFangSC-Regular";
  titleLayer.foregroundColor = [UIColor orangeColor].CGColor;
  titleLayer.shadowOpacity = 0.8;
  titleLayer.shadowColor = [UIColor blackColor].CGColor;
  titleLayer.shadowOffset = CGSizeMake(2.0, 2.0);
  titleLayer.alignmentMode = kCAAlignmentCenter;
  [_watermarkLayer addSublayer:titleLayer];

  if (_isOpenAnimation) {
    CABasicAnimation *keyAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    keyAnimation.duration = 2.0;
    keyAnimation.repeatCount = MAXFLOAT;
    keyAnimation.toValue = @(M_PI * 2.0);
    
    /**
     把动画加到视频，一定要设两面个属性: `beginTime 、removedOnCompletion`
     beginTime: 开始时间
     removedOnCompletion: 动画完成后是否从之删除
     */
    keyAnimation.beginTime = AVCoreAnimationBeginTimeAtZero;
    keyAnimation.removedOnCompletion = NO;
    [_watermarkLayer addAnimation:keyAnimation forKey:@"transform.rotation.z"];
  }
  
  return _watermarkLayer;
}

- (NHAVEditor *)mediaEditor {
  if (!_mediaEditor) {
    _mediaEditor = [[NHAVEditor alloc] initWithVideoURL:[NSURL fileURLWithPath:kMp4Path]];
    _mediaEditor.delegate = self;
  }
  return _mediaEditor;
}


@end

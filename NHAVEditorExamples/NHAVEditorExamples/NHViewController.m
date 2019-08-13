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


#define kMp3Path [[NSBundle mainBundle] pathForResource:@"黑龙-38度6" ofType:@"mp3"]
#define kMp4Path [[NSBundle mainBundle] pathForResource:@"Бамбинтон-Зая" ofType:@"mp4"]


@interface NHViewController ()<NHAVEditorProtocol>
@property (weak, nonatomic  ) IBOutlet NHDisplayView *displayView;
@property (weak, nonatomic  ) IBOutlet UIButton *exportButton;
@property (nonatomic, strong) NHAVEditor *mediaEditor;
@property (nonatomic, strong) CALayer *watermarkLayer;

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
  [MBProgressHUD showLoadToView:self.view title:@"正在导出..."];
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

#pragma mark - NHAVEditorProtocol
#pragma mark -
- (void)editorCompositioning:(NHAVEditor *)editor progress:(CGFloat)progress {
  NHLog(@"合成进度:%.02f",progress);
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
  _watermarkLayer.frame = CGRectMake(0, 0, [self logoImage].size.width, [self logoImage].size.height);
 
  CALayer *imageLayer = [CALayer layer];
  imageLayer.frame = CGRectMake(0, 0, [self logoImage].size.width, [self logoImage].size.height);
  imageLayer.contents = (__bridge id)[self logoImage].CGImage;
  [_watermarkLayer addSublayer:imageLayer];
  
  CATextLayer *titleLayer = [CATextLayer layer];
  titleLayer.string = @"38度6-黑龙";
  titleLayer.fontSize = 18.0;
  titleLayer.font = (__bridge CFTypeRef)@"PingFangSC-Regular";
  titleLayer.foregroundColor = [UIColor whiteColor].CGColor;
  titleLayer.shadowOpacity = 0.5;
  titleLayer.alignmentMode = kCAAlignmentCenter;
  titleLayer.frame = CGRectMake(0, 0, 100, 100);
  [_watermarkLayer addSublayer:titleLayer];

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

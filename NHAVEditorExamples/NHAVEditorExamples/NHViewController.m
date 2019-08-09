//
//  NHViewController.m
//  NHAVEditorExamples
//
//  Created by XiuDan on 2019/8/3.
//  Copyright © 2019 XiuDan. All rights reserved.
//

#import "NHViewController.h"
#import "NHAVEditorExamples-Swift.h"
#import "NHDisplayView.h"
#import <MBProgressHUD+NHAdd.h>
#import "NHAVEditor.h"

#define kMp3Path [[NSBundle mainBundle] pathForResource:@"黑龙-38度6" ofType:@"mp3"]
#define kMp4Path [[NSBundle mainBundle] pathForResource:@"Бамбинтон-Зая" ofType:@"mp4"]


@interface NHViewController ()<NHAVEditorProtocol>
@property (weak, nonatomic) IBOutlet NHDisplayView *displayView;
@property (weak, nonatomic) IBOutlet UIButton *exportButton;
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
  [self.mediaEditor addWatermarkWithLayer:self.watermarkLayer completedBlock:^(NSURL * _Nullable mediaUrl, NSError * _Nullable error) {
    
  }];
  
}

- (IBAction)addMusicAction:(UIButton *)sender {
  [self.mediaEditor addAudioWithAudioURL:[NSURL fileURLWithPath:kMp3Path] completedBlock:^(NSURL * _Nullable mediaUrl, NSError * _Nullable error) {
    
  }];
  
}

- (IBAction)exportAction:(UIButton *)sender {
  [self.mediaEditor exportMediaWithOutputURL:nil
                                  presetName:AVAssetExportPreset1280x720
                              outputFileType:AVFileTypeQuickTimeMovie
                              completedBlock:^(NSURL * _Nullable mediaUrl, NSError * _Nullable error) {
    
  }];
}

#pragma mark - NHAVEditorProtocol
#pragma mark -
- (void)editorCompositioning:(NHAVEditor *)editor progress:(CGFloat)progress {
  NSLog(@"合成进度:%.02f",progress);
}

- (void)editorCompositioned:(NHAVEditor *)editor outputUrl:(NSURL *)outputUrl error:(NSError *)error {
  NSLog(@"合成完成:%@", outputUrl);
}

- (void)editorExportCompleted:(NHAVEditor *)editor outputUrl:(NSURL *)outputUrl error:(NSError *)error {
  NSLog(@"导出完成:%@", outputUrl);
}


#pragma mark - private method
#pragma mark -
- (UIImage *)logoImage {
  return [UIImage imageNamed:@"logo"];
}

- (CALayer *)watermarkLayer {
  
  _watermarkLayer = [CALayer layer];
  _watermarkLayer.bounds = CGRectMake(0, 0, _displayView.videoSize.width, _displayView.videoSize.height);
  
  CALayer *imageLayer = [CALayer layer];
  imageLayer.frame = CGRectMake(0, 0, [self logoImage].size.width, [self logoImage].size.height);
  imageLayer.contents = [self logoImage];
  [_watermarkLayer addSublayer:imageLayer];
  
  CATextLayer *titleLayer = [CATextLayer layer];
  titleLayer.string = @"38度6-黑龙";
  titleLayer.foregroundColor = [UIColor whiteColor].CGColor;
  titleLayer.shadowOpacity = 0.5;
  titleLayer.alignmentMode = kCAAlignmentCenter;
  titleLayer.bounds = CGRectMake(0, 0, 100, 100);
  [_watermarkLayer addSublayer:titleLayer];
  [self.view.layer addSublayer:_watermarkLayer];
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

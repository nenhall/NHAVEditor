//
//  NHViewController.m
//  NHAVEditorExamples
//
//  Created by XiuDan on 2019/8/3.
//  Copyright © 2019 XiuDan. All rights reserved.
//

#import "NHViewController.h"
#import "NHDisplayView.h"
#import <CoreImage/CoreImage.h>
#import <MBProgressHUD+NHAdd.h>
#import "NHAVEditorDefine.h"
#import "NHCaptureViewController.h"
//#import <NHAVEditor.h>
#import "NHAVEditor.h"


#define kMp3Path [[NSBundle mainBundle] pathForResource:@"黑龙-38度6" ofType:@"mp3"]
#define kMp3Path2 [[NSBundle mainBundle] pathForResource:@"一生有你-赵海洋" ofType:@"mp3"]
#define kMp4Path [[NSBundle mainBundle] pathForResource:@"Бамбинтон-Зая" ofType:@"mp4"]


@interface NHViewController ()<NHAVEditorProtocol>
@property (weak, nonatomic  ) IBOutlet NHDisplayView *displayView;
@property (weak, nonatomic  ) IBOutlet UIButton *exportButton;
@property (nonatomic, strong) NHAVEditor *mediaEditor;
@property (nonatomic, strong) CALayer *watermarkLayer;
@property (nonatomic, assign) BOOL isOpenAnimation;
@property (nonatomic, strong) NHGifWriter *gifWriter;
@property (nonatomic, strong) NHMediaWriter *mediaWriter;

@end

@implementation NHViewController

- (void)viewDidLoad {
    [super viewDidLoad];

  [_displayView setPlayUrl:[NSURL fileURLWithPath:kMp4Path]];
  
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [self recordMove];
}


#pragma mark - edit command
#pragma mark -
- (IBAction)addWatermarkAction:(UIButton *)sender {
  [_displayView pause];
  [MBProgressHUD showLoadToView:self.view title:@"正在添加水印..."];
  [self.mediaEditor addWatermarkWithLayer:self.watermarkLayer customConfig:nil completedBlock:nil];
}

- (IBAction)addMusicAction:(UIButton *)sender {
  [_displayView pause];
  [MBProgressHUD showLoadToView:self.view title:@"正在添加音乐..."];
  
  static int index = 0;
  NSURL *url = [NSURL fileURLWithPath:kMp3Path];
  if (index == 1) {
    url = [NSURL fileURLWithPath:kMp3Path2];
  }
  index +=1;
  
  [self.mediaEditor addAudioWithAudioURL:url customConfig:^(NHAudioConfig * _Nonnull config) {
    //开始的音量大小，结束的时音量大小，从开始到结束这段时间的一个音量线性变化
    config.startVolume = 0.0;
    config.endVolume = 1.0;
    // 是否关闭视频原声，默认false
    //  config.removeOriginalAudio = true;
    config.originalVolume = 0.1;
  } completedBlock:nil];
}

- (IBAction)exportAction:(UIButton *)sender {
  [_displayView pause];

  [MBProgressHUD showDownToView:self.view progressStyle:NHHUDProgressDeterminateHorizontalBar title:@"正在导出..." progress:nil];

  [self.mediaEditor exportMediaWithOutputURL:nil customConfig:^(NHExporyConfig * _Nonnull config) {
    config.presetName = AVAssetExportPreset1280x720;
    config.outputFileType = AVFileTypeQuickTimeMovie;
  } completedBlock:^(NSURL * _Nullable outputURL, NSError * _Nullable error) {
    // do someing sth ...
    
  }];
}

- (IBAction)watermarkSwitch:(UISwitch *)sender {
  _isOpenAnimation = sender.on;
}

- (IBAction)resetAVEditor:(UIButton *)sender {
  [_mediaEditor resetAllCompositionBeforeRestarting];
}


/**
 从摄像头获取数据，并写成mp4 、acc文件，再进行处理
 */
- (void)recordMove {
  // 这部份代码未做整理，参考其使用方法就可以
  NHCaptureViewController *capture = (NHCaptureViewController *)[self presentedViewController];
  if ([capture isKindOfClass:[NHCaptureViewController class]]) {
    __weak __typeof(self)ws = self;
    [capture setDidStopCapture:^(BOOL stop) {
      if (stop) {
        // 完成写入
        [ws.mediaWriter finishWriteWithCompletionHandler:^(NSURL * _Nonnull fileUrl) {
          NHLog(@"%@",fileUrl);
          if (fileUrl) {
            [ws.displayView setPlayUrl:fileUrl];
            [ws.mediaEditor resetAllCompositionBeforeRestarting];
            [ws.mediaEditor setInputVideoURL:fileUrl];
          }
        }];
      } else {
        // 准备写入，保存的文件格式，请与当`fileType`对应
        [ws.mediaWriter prepareBuildMediaWithOutpurUrl:[ws OutUrl:@"mov"]];
        // [ws.mediaWriter beginBuildMediaWithOutpurUrl:[ws OutUrl:@"acc"]];
      }
    }];
    
    [capture setDidOutputBuffer:^(CMSampleBufferRef  _Nonnull bufferRef) {
      CMFormatDescriptionRef des = CMSampleBufferGetFormatDescription(bufferRef);
      CMMediaType mediaType = CMFormatDescriptionGetMediaType(des);
      // 写入音/视频数据，暂不支持同时写入
      if (mediaType == kCMMediaType_Audio) {
        //        [ws.mediaWriter appendAudioSampleBuffer:bufferRef];
      } else {
        [ws.mediaWriter appendVideoSampleBuffer:bufferRef];
      }
    }];
  }
}


#pragma mark - NHAVEditorProtocol
#pragma mark -
- (void)editorCompositioning:(NHAVEditor *)editor progress:(CGFloat)progress type:(NHAVEditorType)type {
  NHLog(@"合成进度:%.02f",progress);
  [MBProgressHUD HUDForView:self.view].progress = progress;
}

- (void)editorCompositioned:(NHAVEditor *)editor type:(NHAVEditorType)type error:(NSError * _Nullable)error {
  NHLog(@"合成完成，Error:%@",error.localizedDescription);
  [[MBProgressHUD HUDForView:self.view] hideAnimated:YES afterDelay:1.0];
}

- (void)editorExporting:(NHAVEditor *)editor progress:(CGFloat)progress type:(NHAVEditorType)type {
  NHLog(@"导出进度:%.02f",progress);
  [MBProgressHUD HUDForView:self.view].progress = progress;
}

- (void)editorExported:(NHAVEditor *)editor outputURL:(NSURL *)outputURL type:(NHAVEditorType)type error:(NSError *)error {
  NHLog(@"导出完成:%@", outputURL);
  [_displayView setPlayUrl:outputURL];
  
  dispatch_async(dispatch_get_main_queue(), ^{
    [MBProgressHUD hideHUDForView:self.view];
  });
  
  // 保存视频到相册
  [NHPicture saveVideoGifToPhotoWithURL:outputURL completionHandler:^(BOOL success, NSError * _Nullable error) {
    NHLog(@"视频保存相册, error:%@", error.localizedDescription);
  }];
  
  // 生成 Gif 图
  [self.gifWriter buildGifFromVideo:outputURL timeInterval:@(600) completion:^(NSURL * _Nullable url, NSError * _Nullable error) {
    NHLog(@"GIF生成完成:%@", url);
    [NHPicture saveVideoGifToPhotoWithURL:url completionHandler:^(BOOL success, NSError * _Nullable error) {
      NHLog(@"保存相册, error:%@", error.localizedDescription);
    }];
  }];
}


#pragma mark - private method
#pragma mark -
- (UIImage *)logoImage {
  return [UIImage imageNamed:@"logo"];
}

- (CALayer *)watermarkLayer {
  _watermarkLayer = [CALayer layer];
  _watermarkLayer.position = CGPointMake(_displayView.videoSize.width * 0.5, _displayView.videoSize.height * 0.5);
  _watermarkLayer.bounds = CGRectMake(0, 0, [self logoImage].size.width, [self logoImage].size.height);
//   _watermarkLayer.backgroundColor = [UIColor redColor].CGColor;
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

- (NSURL *)OutUrl:(NSString *)ext {
  NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setDateFormat:@"yyyyMMddHHmmssSS"];
  [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Beijing"]];
  NSString *dateString = [formatter stringFromDate: datenow];
  NSString *name = [NSString stringWithFormat:@"%@.%@",dateString,ext];
  NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:name];
  NSURL *url = [NSURL fileURLWithPath:path];
  [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
  return url;
}

- (NHAVEditor *)mediaEditor {
  if (!_mediaEditor) {
    _mediaEditor = [[NHAVEditor alloc] initWithVideoURL:[NSURL fileURLWithPath:kMp4Path]];
    _mediaEditor.delegate = self;
  }
  return _mediaEditor;
}

- (NHGifWriter *)gifWriter {
  if (!_gifWriter) {
    _gifWriter = [[NHGifWriter alloc] initWithOutputURL:nil];
    _gifWriter.loopCount = 0;
    _gifWriter.delayTime = 0.1;
  }
  return _gifWriter;
}

- (NHMediaWriter *)mediaWriter {
  if (!_mediaWriter) {
    _mediaWriter = [NHMediaWriter mediaWithVideoSize:_displayView.videoSize fileType:AVFileTypeQuickTimeMovie];
  }
  return _mediaWriter;
}

@end

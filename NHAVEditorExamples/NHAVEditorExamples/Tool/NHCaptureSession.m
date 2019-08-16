//
//  NHCaptureSession.m
//  NHAVEditorExamples
//
//  Created by XiuDan on 2019/8/15.
//  Copyright © 2019 XiuDan. All rights reserved.
//

#import "NHCaptureSession.h"
#import "NHVideoConfiguration.h"
#import "NHAVEditorHeader.h"

@interface NHCaptureSession ()<
AVCaptureVideoDataOutputSampleBufferDelegate,
AVCaptureAudioDataOutputSampleBufferDelegate,
AVCaptureFileOutputRecordingDelegate,
AVCaptureMetadataOutputObjectsDelegate
>

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureDeviceInput *videoDeviceInput;
@property (nonatomic, strong) AVCaptureDeviceInput *audioDeviceInput;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
@property (nonatomic, strong) AVCaptureAudioDataOutput *audioDataOutput;
@property (nonatomic, strong) AVCaptureMovieFileOutput *moveFileOutput;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) UITapGestureRecognizer *focusGesture;
@property (nonatomic, weak  ) AVCaptureConnection *videoCaptureConnection;
@property (nonatomic, weak  ) AVCaptureConnection *audioCaptureConnection;

@end

@implementation NHCaptureSession  {
  dispatch_queue_t     _encodeQueue;
  NHVideoConfiguration *_videoConfiguration;
  CGSize               _captureVideoSize;
  BOOL                 _isVideoPortrait;
}

- (instancetype)init
{
  self = [super init];
  if (self) {
    [self initializeCaptureSession];
  }
  return self;
}

#pragma mark - AVCaptureSession init
#pragma mark -
- (void)initializeCaptureSession {
  
  _encodeQueue = dispatch_queue_create("avcaptureSession", DISPATCH_QUEUE_SERIAL);
  
#pragma mark -- set capture settings
  _isVideoPortrait = YES;
  _videoOrientation = AVCaptureVideoOrientationPortrait;
  AVCaptureSessionPreset preset = AVCaptureSessionPreset1280x720;
  _captureVideoSize = [self getVideoSize:AVCaptureSessionPreset1280x720 isVideoPortrait:_isVideoPortrait];
  
  
  // 初始化会话管理对象
  _captureSession = [[AVCaptureSession alloc] init];
  //指定输出质量
  _captureSession.sessionPreset = preset;
  
  // 视频输入
  AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
  NSError *capLockError;
  BOOL lock = [videoDevice lockForConfiguration:&capLockError];
  if (lock) {
    AVCaptureDeviceFormat *format = videoDevice.formats.firstObject;
    NHLog(@"formats.count:%zd\nvideoSupportedFrameRateRanges:%@",videoDevice.formats.count,format.videoSupportedFrameRateRanges);
    //设置视频帧率
    videoDevice.activeVideoMaxFrameDuration = CMTimeMake(1, 10);
    [videoDevice unlockForConfiguration];
  }
  NSError *videoInputError;
  _videoDeviceInput =  [[AVCaptureDeviceInput alloc] initWithDevice:[self cameraWithPosition:AVCaptureDevicePositionFront] error:&videoInputError];
  if ([_captureSession canAddInput:_videoDeviceInput]) {
    [_captureSession addInput:_videoDeviceInput];
  } else {
    NHLog(@"captureSession add video input error");
    return;
  }
  
  
  // 视频输出
  _videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
  _videoDataOutput.alwaysDiscardsLateVideoFrames = YES;
  // nv12
  /**
   kCVPixelBufferPixelFormatTypeKey 指定解码后的图像格式
   kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange  : YUV420 用于标清视频[420v]
   kCVPixelFormatType_420YpCbCr8BiPlanarFullRange   : YUV422 用于高清视频[420f]
   kCVPixelFormatType_32BGRA : 输出的是BGRA的格式，适用于OpenGL和CoreImage
   */
  //    NSString *typekey = (__bridge NSString *)kCVPixelBufferPixelFormatTypeKey;
  NSDictionary *settings = [[NSDictionary alloc] initWithObjectsAndKeys:
                            [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA],
                            kCVPixelBufferPixelFormatTypeKey,
                            nil];
  _videoDataOutput.videoSettings = settings;
  dispatch_queue_t videoQueue = dispatch_queue_create("videoOutputQueue", DISPATCH_QUEUE_CONCURRENT);
  [_videoDataOutput setSampleBufferDelegate:self queue:videoQueue];
  if ([_captureSession canAddOutput:_videoDataOutput]) {
    [_captureSession addOutput:_videoDataOutput];
  } else {
    NHLog(@"captureSession add video output error");
    return;
  }
  // 保存Connection，用于在SampleBufferDelegate中判断数据来源（是Video/Audio？）
  _videoCaptureConnection = [_videoDataOutput connectionWithMediaType:AVMediaTypeVideo];
  _videoCaptureConnection.videoOrientation = _videoOrientation;
  // 设置镜像效果镜像
  if ([_videoCaptureConnection isVideoMirroringSupported]) {
    _videoCaptureConnection.videoMirrored = YES;
  }
  
  //视频稳定设置
  if ([_videoCaptureConnection isVideoStabilizationSupported]) {
    _videoCaptureConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
  }
  //视频旋转方向的设置
  //    _videoCaptureConnection.videoScaleAndCropFactor = _videoCaptureConnection.videoMaxScaleAndCropFactor;
  
    // 音频输入
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    NSError *audioInputError;
    _audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&audioInputError];
    if ([_captureSession canAddInput:_audioDeviceInput]) {
      [_captureSession addInput:_audioDeviceInput];
    } else {
      NHLog(@"captureSession add audio input error");
      return;
    }
  
  
    // 音频输出
    dispatch_queue_t audioQueue = dispatch_queue_create("audioOutputQueue", DISPATCH_QUEUE_CONCURRENT);
    _audioDataOutput = [[AVCaptureAudioDataOutput alloc] init];
    [_audioDataOutput setSampleBufferDelegate:self queue:audioQueue];
    if ([_captureSession canAddOutput:_audioDataOutput]) {
      [_captureSession addOutput:_audioDataOutput];
    } else {
      NHLog(@"captureSession add audio output error");
      return;
    }
    _audioCaptureConnection = [_audioDataOutput connectionWithMediaType:AVMediaTypeAudio];
  
  
  // 预览层
  _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
  [_previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
  [_previewLayer setFrame:CGRectMake(0, 0, _preview.bounds.size.width, _preview.bounds.size.height)];
  [_preview.layer addSublayer:_previewLayer];
  //    _previewLayer.connection.videoOrientation = [_videoOutput connectionWithMediaType:AVMediaTypeVideo].videoOrientation;
  
  //  [self setupFaceSessionOutput:_captureSession];
  //  [self addFocusGestureTouchEvent];
}

- (void)setPreview:(UIView *)preview {
  [_previewLayer removeFromSuperlayer];
  _preview = preview;
  [preview.layer addSublayer:_previewLayer];
  _previewLayer.frame = preview.bounds;
  //  [self addFocusGestureTouchEvent];
}

- (void)startCapture {
  if (![_captureSession isRunning]) {
    [_captureSession startRunning];
  }
}

- (void)stopCapture {
  if ([_captureSession isRunning]) {
    [_captureSession stopRunning];
  }
}


#pragma mark - Handle Video Orientation
- (AVCaptureVideoOrientation)currentVideoOrientation {
  UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
  if (deviceOrientation == UIDeviceOrientationLandscapeLeft) {
    return AVCaptureVideoOrientationLandscapeRight;
  } else {
    return AVCaptureVideoOrientationLandscapeLeft;
  }
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position {
  NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
  for (AVCaptureDevice *device in devices) {
    if ([device position] == position) {
      return device;
    }
  }
  return nil;
}

/** 获取视频尺寸 */
- (CGSize)getVideoSize:(NSString *)sessionPreset isVideoPortrait:(BOOL)isVideoPortrait {
  CGSize size = CGSizeZero;
  if ([sessionPreset isEqualToString:AVCaptureSessionPresetMedium]) {
    if (isVideoPortrait)
      size = CGSizeMake(360, 480);
    else
      size = CGSizeMake(480, 360);
  } else if ([sessionPreset isEqualToString:AVCaptureSessionPreset1920x1080]) {
    if (isVideoPortrait)
      size = CGSizeMake(1080, 1920);
    else
      size = CGSizeMake(1920, 1080);
  } else if ([sessionPreset isEqualToString:AVCaptureSessionPreset1280x720]) {
    if (isVideoPortrait)
      size = CGSizeMake(720, 1280);
    else
      size = CGSizeMake(1280, 720);
  } else if ([sessionPreset isEqualToString:AVCaptureSessionPreset640x480]) {
    if (isVideoPortrait)
      size = CGSizeMake(480, 640);
    else
      size = CGSizeMake(640, 480);
  }
  
  return size;
}

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
  
  if (self.delegate && [self.delegate respondsToSelector:@selector(captureDidOutputSampleBuffer:)]) {
    [self.delegate captureDidOutputSampleBuffer:sampleBuffer];
  }
  
}


@end

//
//  NHMediaWriter.m
//  NHAVEditorExamples
//
//  Created by XiuDan on 2019/8/14.
//  Copyright © 2019 XiuDan. All rights reserved.
//

#import "NHMediaWriter.h"
#import "NHAVEditorHeader.h"
#import "NSDate+NH.h"

@interface NHMediaWriter ()
@property (nonatomic, strong) AVAssetWriter *writer;
@property (nonatomic, strong) AVAssetWriterInput *assetWriterVideoInput;
@property (nonatomic, strong) AVAssetWriterInput *assetWriterAudioInput;
@property (nonatomic, strong) AVAssetWriterInputPixelBufferAdaptor *assetWritePiexlBufferInput;
@property (nonatomic, assign) CMTime startTime;
@property (nonatomic, copy  ) NSURL *outUrl;
@property (nonatomic, strong) dispatch_queue_t mediaWiterQueue;
@property (nonatomic, assign) BOOL isRecording;
@property (nonatomic, assign) BOOL needRecord;
@property (nonatomic, copy  ) NSDictionary *audioOutputSetting;
@property (nonatomic, copy  ) NSDictionary *videoOutputSetting;

@end


@implementation NHMediaWriter {
  NSDictionary *_audioOutputSetting;
  NSDictionary *_videoOutputSetting;
}
@synthesize audioOutputSetting = _audioOutputSetting;
@synthesize videoOutputSetting = _videoOutputSetting;


- (instancetype)init {
  if (self = [super init]) {
    _expectsMediaDataInRealTime = YES;
    _mediaWiterQueue = dispatch_queue_create("com.nh.mediaWriter.queue", DISPATCH_QUEUE_SERIAL);

  }
  return self;
}

+ (instancetype)mediaWithVideoSize:(CGSize)videoSize fileType:(NSString *)fileType {
  NHMediaWriter *mediaWriter = [[NHMediaWriter alloc] init];
  mediaWriter.videoSize = videoSize;
  mediaWriter.fileType = fileType ?: AVFileTypeQuickTimeMovie;
  return mediaWriter;
}

- (void)configWriter:(NSURL *)outputUrl {
  _isRecording = NO;
  _startTime = kCMTimeInvalid;
  
  [self setOutUrl:outputUrl];
  [self buildAssetWriteWithUrl:self.outUrl];
  [self buildVideoWriter];
  [self buildAudioWriter];
}

- (void)prepareBuildMediaWithOutpurUrl:(NSURL *)outputUrl {
  _needRecord = YES;
  [self configWriter:outputUrl];
}

#pragma mark - AVAsserWriter初始化
- (void)buildAssetWriteWithUrl:(NSURL *)url {
  if (!url) {
    NHLog(@"Asset Write URL is Null");
    return;
  }
  
  NSError *error;
  self.writer = [AVAssetWriter assetWriterWithURL:url fileType:_fileType error:&error];
  
  if(error) {
    NHLog(@"%@",error.description);
    return;
  }
  self.writer.movieFragmentInterval = CMTimeMakeWithSeconds(1.0, 1000);
}


- (void)buildVideoWriter {
  self.assetWriterVideoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:[self videoOutputSetting]];
  
  self.assetWriterVideoInput.expectsMediaDataInRealTime = _expectsMediaDataInRealTime;
  
  NSDictionary *attributeDic = @{
                                 (id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA),
                                 (id)kCVPixelBufferWidthKey : @(self.videoSize.width),
                                 (id)kCVPixelBufferHeightKey : @(self.videoSize.height)
                                 };
  self.assetWritePiexlBufferInput = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:self.assetWriterVideoInput sourcePixelBufferAttributes:attributeDic];
  
  if([self.writer canAddInput:self.assetWriterVideoInput]) {
    [self.writer addInput:self.assetWriterVideoInput];
  }
}


- (void)buildAudioWriter {
  self.assetWriterAudioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio
                                                                  outputSettings:[self audioOutputSetting]];
  self.assetWriterAudioInput.expectsMediaDataInRealTime = _expectsMediaDataInRealTime;
  
  if ([self.writer canAddInput:self.assetWriterAudioInput]) {
    [self.writer addInput:self.assetWriterAudioInput];
  }
}

- (BOOL)appendVideoPixelBuffer:(CVPixelBufferRef)videoBuffer {
  
  if (!_needRecord) return NO;
  self.isRecording = YES;
  
  if (!videoBuffer) {
    NHLog(@"videoBuffer为NULL");
    return NO;
  }
  
  BOOL success = NO;

  CVPixelBufferLockBaseAddress(videoBuffer, 0);

  CFRetain(videoBuffer);
  CMTime currentSampleTime = CMClockGetTime(CMClockGetHostTimeClock());
  
  if(CMTIME_IS_INVALID(self.startTime)) {
    if(self.writer.status != AVAssetWriterStatusWriting) {
      [self.writer startWriting];
      NHLog(@"开始写入视频");
    }
    [self.writer startSessionAtSourceTime:currentSampleTime];
    self.startTime = currentSampleTime;
  }
  //一个布尔值，指示输入准备接受更多媒体数据
  if(self.assetWriterVideoInput.readyForMoreMediaData) {
    if (self.writer.status == AVAssetWriterStatusWriting) {
      if ([self.assetWritePiexlBufferInput appendPixelBuffer:videoBuffer withPresentationTime:currentSampleTime]) {
        CVPixelBufferUnlockBaseAddress(videoBuffer, 0);
        success = YES;
      }
    }
  }
  if (self.writer.status != AVAssetWriterStatusCompleted) {
    NHLog(@"拼接视频失败:%f",CMTimeGetSeconds(currentSampleTime));
  }
  return success;
}

- (BOOL)appendVideoSampleBuffer:(CMSampleBufferRef)videoBuffer {
  
  if ([self isCanBeginWriter:videoBuffer] == NO) {
    return NO;
  }
  
  BOOL success = NO;

  CFRetain(videoBuffer);
  CMTime currentSampleTime = CMSampleBufferGetPresentationTimeStamp(videoBuffer);
  
  CMFormatDescriptionRef des = CMSampleBufferGetFormatDescription(videoBuffer);
  CMMediaType mediaType = CMFormatDescriptionGetMediaType(des);
  if (mediaType == kCMMediaType_Audio) {
    [self appendAudioSampleBuffer:videoBuffer];
    return NO;
  }
  
  if(CMTIME_IS_INVALID(self.startTime)) {
    if(self.writer.status != AVAssetWriterStatusWriting) {
      [self.writer startWriting];
      NHLog(@"开始写入视频");
    }
    [self.writer startSessionAtSourceTime:currentSampleTime];
    self.startTime = currentSampleTime;
  }
  
  if(self.assetWriterVideoInput.readyForMoreMediaData) {
    if (self.writer.status == AVAssetWriterStatusWriting) {
      CVImageBufferRef cvImageRef = CMSampleBufferGetImageBuffer(videoBuffer);
      if ([self.assetWritePiexlBufferInput appendPixelBuffer:cvImageRef withPresentationTime:currentSampleTime]) {
        success = YES;
      }
    }
  }
  CFRelease(videoBuffer);
  NHLog(@"拼接视频失败:%f",CMTimeGetSeconds(currentSampleTime));
  return success;
}


- (BOOL)appendAudioSampleBuffer:(CMSampleBufferRef)audioBuffer {
  
  if ([self isCanBeginWriter:audioBuffer] == NO) {
    return NO;
  }
  
  BOOL success = NO;
  
  CFRetain(audioBuffer);
  CMTime currentSampleTime = CMSampleBufferGetPresentationTimeStamp(audioBuffer);
  
  if(CMTIME_IS_INVALID(self.startTime)) {
    if(self.writer.status != AVAssetWriterStatusWriting) {
      [self.writer startWriting];
      NSLog(@"开始写入音频");
    }
    [self.writer startSessionAtSourceTime:currentSampleTime];
    self.startTime = currentSampleTime;
  }
  
  if(self.assetWriterAudioInput.readyForMoreMediaData) {
    if (self.writer.status == AVAssetWriterStatusWriting){
      if ([self.assetWriterAudioInput appendSampleBuffer:audioBuffer]) {
        success = YES;
      }
    }
  }
  CFRelease(audioBuffer);
  NHLog(@"拼接音频失败:%f",CMTimeGetSeconds(currentSampleTime));
  return success;
}

- (BOOL)appendVideoAndAudioSampleBuffer:(CMSampleBufferRef)bufferRef {
  
  if ([self isCanBeginWriter:bufferRef] == NO) {
    return NO;
  }
  
  BOOL success = NO;
  
  CFRetain(bufferRef);
  CMTime currentSampleTime = CMSampleBufferGetPresentationTimeStamp(bufferRef);
  CMFormatDescriptionRef des = CMSampleBufferGetFormatDescription(bufferRef);
  CMMediaType mediaType = CMFormatDescriptionGetMediaType(des);
  
  if(CMTIME_IS_INVALID(self.startTime)) {
    if(self.writer.status != AVAssetWriterStatusWriting) {
      [self.writer startWriting];
      NHLog(@"开始写入音视频");
    }
    [self.writer startSessionAtSourceTime:currentSampleTime];
    self.startTime = currentSampleTime;
  }
  
  if (mediaType == kCMMediaType_Audio) {
    if(self.assetWriterAudioInput.readyForMoreMediaData) {
      if (self.writer.status == AVAssetWriterStatusWriting){
        if ([self.assetWriterAudioInput appendSampleBuffer:bufferRef]) {
          success = YES;
        }
      }
    }
  } else {
    if(self.assetWriterVideoInput.readyForMoreMediaData) {
      if (self.writer.status == AVAssetWriterStatusWriting) {
        CVImageBufferRef cvImageRef = CMSampleBufferGetImageBuffer(bufferRef);
        if ([self.assetWritePiexlBufferInput appendPixelBuffer:cvImageRef withPresentationTime:currentSampleTime]) {
          success = YES;
        }
      }
    }
  }
  CFRelease(bufferRef);
  return success;
}

- (BOOL)isCanBeginWriter:(CMSampleBufferRef)bufferRef {
  if (!_needRecord) return NO;
  _isRecording = YES;
  
  if (!CMSampleBufferIsValid(bufferRef)) {
    NHLog(@"videoBuffer为NULL");
    return NO;
  }
  return YES;
}

- (void)finishWriteWithCompletionHandler:(void (^)(NSURL *))handler {
  
  if (self.writer.status == AVAssetWriterStatusCompleted ||
      self.writer.status == AVAssetWriterStatusCancelled ||
      self.writer.status == AVAssetWriterStatusUnknown) {
    _isRecording = NO;
    _needRecord = NO;
    return ;
  }
  
  if(self.writer.status == AVAssetWriterStatusWriting) {
    [self.assetWriterVideoInput markAsFinished];
    [self.assetWriterAudioInput markAsFinished];
  }
  
  __weak __typeof(self)weakself = self;
  [self.writer finishWritingWithCompletionHandler:^{
    weakself.isRecording = NO;
    weakself.needRecord = NO;
    NSLog(@"完成写入");
    if (![[NSThread currentThread] isMainThread]) {
      dispatch_sync(dispatch_get_main_queue(), ^{
        if (handler) {
          handler(weakself.outUrl);
        }
      });
    } else {
      dispatch_async(dispatch_get_main_queue(), ^{
        if (handler) {
          handler(weakself.outUrl);
        }
      });
    }
  }];
}


#pragma mark - private method
- (void)setVideoSize:(CGSize)videoSize {
  _videoSize = videoSize;
  if (!_isRecording) {
    [self buildVideoWriter];
  }
}

- (void)setFileType:(NSString *)fileType {
  _fileType = fileType;
  if (!_isRecording) {
    [self configWriter:self.outUrl];
  }
}

- (void)setExpectsMediaDataInRealTime:(BOOL)expectsMediaDataInRealTime {
  _expectsMediaDataInRealTime = expectsMediaDataInRealTime;
  if (!_isRecording) {
    [self buildAudioWriter];
    [self buildVideoWriter];
  }
}

- (void)setAudioOutputSetting:(NSDictionary *)audioOutputSetting {
  _audioOutputSetting = audioOutputSetting;
  if (!_isRecording) {
    [self buildAudioWriter];
  }
}

- (void)setVideoOutputSetting:(NSDictionary *)videoOutputSetting {
  _videoOutputSetting = videoOutputSetting;
  if (!_isRecording) {
    [self buildVideoWriter];
  }
}

- (NSDictionary *)audioOutputSetting {
  if (!_audioOutputSetting) {
    _audioOutputSetting = @{
                            AVFormatIDKey: @(kAudioFormatMPEG4AAC),
                            AVNumberOfChannelsKey : @(2),
                            AVSampleRateKey : @(44100),
//                            AVEncoderAudioQualityKey : @(AVAudioQualityHigh),
                            AVEncoderBitRateKey : @(128000),
                            };
  }
  return _audioOutputSetting;
}

- (NSDictionary *)videoOutputSetting {
  if (!_videoOutputSetting) {
      NSDictionary *compressionProperties = @{
                                              AVVideoExpectedSourceFrameRateKey : @(25), /**< 帧速率以每秒帧数来衡量 */
                                              AVVideoProfileLevelKey : AVVideoProfileLevelH264BaselineAutoLevel
                                              };
    _videoOutputSetting = @{
                            AVVideoCodecKey : AVVideoCodecH264,
                            AVVideoWidthKey : @(self.videoSize.width),
                            AVVideoHeightKey : @(self.videoSize.height),
                            AVVideoScalingModeKey : AVVideoScalingModeResizeAspect,
                            AVVideoCompressionPropertiesKey : compressionProperties
                            };
  }
  return _videoOutputSetting;
}

- (void)setOutUrl:(NSURL *)outUrl {
  if (outUrl) {
    _outUrl = outUrl;
  } else {
    NSString *name = [NSString stringWithFormat:@"%@.mov",[NSDate getNowTimeTimestamp]];
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:name];
    NSURL *url = [NSURL fileURLWithPath:path];
    _outUrl = url;
  }
  [[NSFileManager defaultManager] removeItemAtURL:_outUrl error:nil];
}


@end

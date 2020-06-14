//
//  NHMediaWriter.h
//  NHAVEditorExamples
//
//  AVFormatIDKey: @(kAudioFormatMPEG4AAC),/**< 声音格式 */
//  AVNumberOfChannelsKey : @(2),/**< 声道数 */
//  AVSampleRateKey : @(44100),/**< 采样率 单位是HZ */
//  AVEncoderAudioQualityKey: @(AVAudioQualityHigh),/**< 声音质量 */
//  AVEncoderBitRateKey : @(128000),/**< BPS传输速率 */
//  格式ID为'aac'时，不允许使用以下键
//  AVLinearPCMBitDepthKey : @(16)/**< 比特率 */
//  AVLinearPCMIsFloatKey : @(NO) /**< 是否使用浮点数采样 */
//  AVVideoCodecKey : AVVideoCodecH264, /**< 编码格式 */
//  AVVideoWidthKey : @(self.videoSize.width),
//  AVVideoHeightKey : @(self.videoSize.height),
//  AVVideoScalingModeKey : AVVideoScalingModeResizeAspect, /**< 填充模式 */
//  AVVideoCompressionPropertiesKey : compressionProperties
//
//  AVVideoAverageBitRateKey : @(8*1024.0*1024), /**< 视频尺寸*比率，数值越大，显示越精细 */
//  AVCaptureSessionPreset1280x720:8*1024.0*1024
//  AVVideoExpectedSourceFrameRateKey : @(25), /**< 帧速率以每秒帧数来衡量 */
//  AVVideoMaxKeyFrameIntervalKey : @(35), /**< 关键帧最大间隔，1为每个都是关键帧，数值越大压缩率越高 */
//  AVVideoProfileLevelKey : AVVideoProfileLevelH264BaselineAutoLevel /**< 画质 */
//
//  Created by XiuDan on 2019/8/14.
//  Copyright © 2019 XiuDan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NHMediaWriter : NSObject
/**
 是否正在录制中
 */
@property (nonatomic, assign, readonly) BOOL isRecording;

/**
 视频保存的格式
 通过 `+mediaWithVideoSize:fileType:`初始后，不需另设，除非确定需要变更时，构建中重设无效
 */
@property (nonatomic, copy  ) NSString *fileType;

/**
 视频保存的尺寸
 通过 `+mediaWithVideoSize:fileType:`初始后，不需另设，除非确定需要变更时，构建中重设无效
 */
@property (nonatomic, assign) CGSize videoSize;

/**
 如果数据源是实时采集的，需要设置该属性为 true，default: true，构建中重设无效
 */
@property (nonatomic, assign) BOOL expectsMediaDataInRealTime;


/**
 初始化方法
 
 @param videoSize 视频尺寸
 @param fileType 视频保存的格式, default: AVFileTypeQuickTimeMovie
 */
+ (instancetype)mediaWithVideoSize:(CGSize)videoSize fileType:(NSString *_Nullable)fileType;

/**
 准备构建，每次录制前都需要调用此方法

 @param outputUrl 文件写入地址
 */
- (void)prepareBuildMediaWithOutpurUrl:(NSURL *)outputUrl;

/**
 append Video

 @param videoBuffer CMSampleBufferRef
 @return return true:success false:fail
 */
- (BOOL)appendVideoSampleBuffer:(CMSampleBufferRef)videoBuffer;

/**
 append Video

 @param videoBuffer CVPixelBufferRef
 @return return true:success false:fail
 */
- (BOOL)appendVideoPixelBuffer:(CVPixelBufferRef)videoBuffer;

/**
 append Audio

 @param audioBuffer CMSampleBufferRef
 @return return true:success false:fail
 */
- (BOOL)appendAudioSampleBuffer:(CMSampleBufferRef)audioBuffer;

/**
 待完善

 @param bufferRef bufferRef description
 @return return true:success false:fail
 */
- (BOOL)appendVideoAndAudioSampleBuffer:(CMSampleBufferRef)bufferRef;


/**
 完成（结束）写入

 @param handler handler.fileUrl:写入完成的文件路径，如果为空，说明失败。
 */
- (void)finishWriteWithCompletionHandler:(nullable void (^)(NSURL *fileUrl))handler;

/**
 音频构建输出设置
 @default 构建中重设无效
 AVFormatIDKey: @(kAudioFormatMPEG4AAC),
 AVNumberOfChannelsKey : @(2),
 AVSampleRateKey : @(44100HZ),4
 AVEncoderAudioQualityKey: @(AVAudioQualityHigh),
 AVEncoderBitRateKey : @(128000bps)
 */
- (void)setAudioOutputSetting:(NSDictionary *)audioOutputSetting;

/**
 视频构建输出设置
 @default 构建中重设无效
 AVVideoExpectedSourceFrameRateKey : @(25),
 AVVideoProfileLevelKey : AVVideoProfileLevelH264BaselineAutoLevel
 AVVideoCodecKey : AVVideoCodecH264,
 AVVideoWidthKey : @(self.videoSize.width),
 AVVideoHeightKey : @(self.videoSize.height),
 AVVideoScalingModeKey : AVVideoScalingModeResizeAspect,
 */
- (void)setVideoOutputSetting:(NSDictionary *)videoOutputSetting;

@end

NS_ASSUME_NONNULL_END

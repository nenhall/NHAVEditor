//
//  NHMediaConfig.h
//  NHAVEditorExamples
//
//  Created by XiuDan on 2019/8/12.
//  Copyright © 2019 XiuDan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>



NS_ASSUME_NONNULL_BEGIN


/**
 ________________________________________________________________________________
 
 -------------------------------- NHAudioConfig ---------------------------------
 ________________________________________________________________________________
 */

@interface NHAudioConfig : NSObject

/**
 截取插入音乐的范围，eg.: 从 0 秒到 90 秒
 
 @abstract default:整段音乐
 1. 如果音频比视频时间长，则从0秒开始，视频的时长结束，超出视频长度部份丢弃
 2. 如果音频比视频时间短，则从0秒开始，音频的有多少时长就插入多少时长，不够部份将保持视频原状态
 */
@property (nonatomic, assign) CMTimeRange insertTimeRange;

/**
 从视频的那个时间点开始插入新的音乐
 @abstract default: 0秒开始
 */
@property (nonatomic, assign) CMTime startTime;

/**
 设置在指定的timeRange期间的音量坡度：开始音量，只针对新添加的音乐
 @abstract 自定义开始音量，range: 0.0 ~ 1.0, default: 1.0
 */
@property (nonatomic, assign) float startVolume;

/**
 设置在指定的timeRange期间的音量坡度：结束音量，只针对新添加的音乐
 @abstract 自定义结束音量，range: 0.0 ~ 1.0, default: 1.0
 */
@property (nonatomic, assign) float endVolume;

/**
 设置在指定的timeRange期间的音量坡度
 @abstract 自定义音量的范围, default: 视频的起始位置
 */
@property (nonatomic, assign) CMTimeRange volumeTimeRange;

/**
 是否去除视频原声音，default: false
 */
@property (nonatomic, assign) BOOL removeOriginalAudio;

/**
 视频原声的音量大小，range: 0.0 ~ 1.0, default: 视频原声大小
 */
@property (nonatomic, assign) float originalVolume;

@end



/**
 ________________________________________________________________________________
 
 ----------------------------- NHWatermarkConfig --------------------------------
 ________________________________________________________________________________
 */

@interface NHWatermarkConfig : NSObject

/** 在`opacityTimeRange`时间范围内的不透明度 0.0 - 1.0
 @abstract 在时间范围之前为1.0,在时间范围之后，按`endOpacity`值保持
  The value must be between 0.0 and 1.0.
 */
@property (nonatomic, assign) float startOpacity;
@property (nonatomic, assign) float endOpacity;
@property (nonatomic, assign) CMTimeRange opacityTimeRange;

/** 在`transformTimeRange`时间范围内的动画
 @abstract 在时间范围之前为空,在时间范围之后，按`endTransform`值保持
 */
@property (nonatomic, assign) CGAffineTransform startTransform;
@property (nonatomic, assign) CGAffineTransform endTransform;
@property (nonatomic, assign) CMTimeRange transformTimeRange;
@end



/**
 ________________________________________________________________________________
 
 ------------------------------- NHExporyConfig ---------------------------------
 ________________________________________________________________________________
 */

@interface NHExporyConfig : NSObject
/**
 导出视频分辨率，默认: AVAssetExportPreset1280x720 默认
 */
@property (nonatomic, copy) NSString *presetName;

/**
 视频导出的文件类型 default：AVFileTypeQuickTimeMovie
 */
@property (nonatomic, copy) AVFileType outputFileType;
@end




NS_ASSUME_NONNULL_END

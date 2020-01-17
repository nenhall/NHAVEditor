//
//  MediaConfig.swift
//  NHAVEditor
//
//  Created by nenhall on 2019/12/6.
//

import UIKit
import AVFoundation

public protocol MediaConfigProtocol {
    
}

public struct NHTime {
    var start: Float
    var end: Float
    var timescale: Int32 = 600
    init(start: Float, end: Float) {
        self.start = start
        self.end = end
    }
    init(start: Float, end: Float, timescale: Int32) {
        self.start = start
        self.end = end
        self.timescale = timescale
    }
}

var kNHTimeOriginalValue :Float {
    get {
        -1.0
    }
}

public struct NHVolume {
    var start: Float
    var end: Float
}


/// 音频配置
public struct AudioConfig: MediaConfigProtocol {
    
    /// 截取插入音乐的范围，eg.: 从 0 秒到 90 秒
    ///
    /// default:整段音乐
    /// 1. 如果音频比视频时间长，则从0秒开始，视频的时长结束，超出视频长度部份丢弃
    /// 2. 如果音频比视频时间短，则从0秒开始，音频的有多少时长就插入多少时长，不够部份将保持视频原状态
    var insertTimeRange: CMTimeRange?
    
    /// 从视频的那个时间点开始插入新的音乐 default: 0秒开始
    var startTime = CMTime.zero

    /// 开始音量：在指定的`timeRange`期间的开始音量坡度
    ///
    /// range: 0.0 ~ 1.0, default: 1.0，只针对新添加的音乐（之前存在的音轨不变化）
    var startVolume: Float = 1.0

    /// 结束音量：在指定的`timeRange`期间的结束音量坡度
    ///
    /// range: 0.0 ~ 1.0
    /// default: 1.0
    /// 只针对新添加的音乐（之前存在的音轨不变化）
    var endVolume: Float = 1.0

    /// 设置在指定的`timeRange`期间的音量坡度
    ///
    /// 自定义音量的范围, default: 视频的起始位置
    var volumeTimeRange: CMTimeRange?
    
    /// 视频原声的音量大小，range: 0.0 ~ 1.0, default: 视频原声大小
    var originalVolume: Float = 1.0;
 
    /// 是否去除视频原声音，default: false
    var removeOriginalAudio = false
    
    
    /// 现插入的音频的截取范围
    var insertAudioCutRange: NHTime
    var insertAudioFromVideoTime: NHTime
    var insertAudioVolume: NHVolume
    var insertAudioVolumeRange: CMTimeRange
    var originalAudioVolume: NHVolume
    
}

/// 水印配置
public struct WatermarkConfig: MediaConfigProtocol {
    
    /// 在`opacityTimeRange`时间范围内的不透明度 0.0 - 1.0
    ///
    /// 1. 在时间范围之前为1.0,在时间范围之后，按`endOpacity`值保持
    /// 2. The value must be between 0.0 and 1.0.
    var startOpacity = 1.0
    
    /// 在`opacityTimeRange`时间范围内的不透明度 0.0 - 1.0
    ///
    /// 1. 在时间范围之前为1.0,在时间范围之后，按`endOpacity`值保持
    /// 2. The value must be between 0.0 and 1.0.
    var endOpacity = 1.0
    var opacityTimeRange = CMTimeRange()
    
    /// 在`transformTimeRange`时间范围内的动画效果
    ///
    /// 1. 在时间范围之前为空,在时间范围之后，按`endTransform`值保持
    /// 2. The value must be between 0.0 and 1.0.
    var startTransform = CGAffineTransform()
    
    /// 在`transformTimeRange`时间范围内的动画效果
    ///
    /// 1. 在时间范围之前为空,在时间范围之后，按`endTransform`值保持
    /// 2. The value must be between 0.0 and 1.0.
    var endTransform = CGAffineTransform()
    var transformTimeRange = CMTimeRange()
    
}


/// 视频导出配置
public struct ExporyConfig: MediaConfigProtocol {
    
    /// 导出视频分辨率，默认: AVAssetExportPreset1280x720 默认
    var presetName: String = AVAssetExportPreset1280x720
    
    /// 视频导出的文件类型 default：AVFileType.mov.rawValue
    var outputFileType: String = AVFileType.mov.rawValue
}



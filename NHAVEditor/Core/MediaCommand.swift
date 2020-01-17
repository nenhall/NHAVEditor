//
//  MediaCommand.swift
//  Pods-NHAVEditorExamples
//
//  Created by nenhall on 2019/12/6.
//

import UIKit
import AVFoundation

/// 编辑的类型
public enum NHAVEditorType {
    /// 未知
    case Unknown
    /// 添加水印
    case Watermark
    /// 添加音频
    case Audio
    /// 导出
    case Export
}

// MARK: - MediaCommandProtocol
protocol MediaCommandProtocol: NSObjectProtocol {
    
    /// 完成合成
    /// - Parameters:
    ///   - cmd: MediaCommand Object
    ///   - error: error description
    func mediaCompostioned(cmd: MediaCommand, error: NHAVEditorError?)
    
    /// 导出中
    /// - Parameters:
    ///   - cmd: ExportCommand Object
    ///   - progress: 导出进度
    func mediaExporting(cmd: ExportCommand, progress: Float)
    
    /// 完成导出
    /// - Parameters:
    ///   - cmd: ExportCommand Object
    ///   - error: error description
    func mediaExported(cmd: ExportCommand, error: NHAVEditorError?)
}
extension MediaCommandProtocol {
    func mediaCompostioned(cmd: MediaCommand, error: NHAVEditorError?) {}
    func mediaExporting(cmd: ExportCommand, progress: Float) {}
    func mediaExported(cmd: ExportCommand, error: NHAVEditorError?) {}
}

// MARK: - MediaCommand Object
public class MediaCommand: NSObject {
    var mComposition: AVMutableComposition?
    var mVideoComposition: AVMutableVideoComposition?
    var mAudioMix = AVMutableAudioMix()
    public var type: NHAVEditorType {
        get{ .Unknown }
    }
    weak var delegate: MediaCommandProtocol?
    public var config: MediaConfigProtocol? {
        set {
            if newValue is AudioConfig {
                audioConfig = newValue as? AudioConfig
            }
            else if newValue is WatermarkConfig {
                watermarkConfig = newValue as? WatermarkConfig
            }
            else if newValue is ExporyConfig {
                exportConfig = newValue as? ExporyConfig
            }
        }
        get {
            if self is AudioCommand {
                return audioConfig
            }
            else if self is WatermarkCommand {
                return watermarkConfig
            } else if self is ExportCommand {
                return exportConfig
            } else {
                return nil
            }
        }
    }

    var audioConfig: AudioConfig?
    var watermarkConfig :WatermarkConfig?
    var exportConfig :ExporyConfig?
    public var inputURL: URL?
    
    
    public func initCommand(composition: AVMutableComposition?, videoComposition: AVMutableVideoComposition?, audioMix: AVMutableAudioMix?) -> Self {
        
        mComposition = composition
        mVideoComposition = videoComposition
        mAudioMix = audioMix ?? AVMutableAudioMix()
        
        return self
    }

    public func performAsset(_ asset: AVAsset) {
        
    }
    
}


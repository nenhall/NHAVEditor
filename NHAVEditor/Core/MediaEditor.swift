//
//  MediaEditor.swift
//  NHAVEditor
//
//  Created by nenhall on 2019/12/6.
//

import UIKit
import AVFoundation


public protocol MediaEditorProtocol : NSObjectProtocol{
    
    /// 编辑完成
    /// - Parameters:
    ///   - tyep: 编辑类型
    ///   - error: error description
    func editorCompositioned(type: NHAVEditorType, error: NHAVEditorError?)
    
    /// 导出中
    /// - Parameters:
    ///   - progress: 导出进度
    func editorExporting(progress: Float)
    
    /// 完成导出
    /// - Parameters:
    ///   - outputURL: 输出地址
    ///   - error: error description
    func editorExported(outputURL: URL?, error: NHAVEditorError?)
}
extension MediaEditorProtocol {
    func editorCompositioned(type: NHAVEditorType, error: NHAVEditorError?){}
    func editorExporting(progress: Float){}
    func editorExported(outputURL: URL?, error: NHAVEditorError?){}
}

public typealias EditorCompleted = ((Error?) -> Void)
public typealias ExportCompleting = ((Float) ->Void)
public typealias ExportCompleted = ((URL?, NHAVEditorError?) ->Void)
public typealias EditorConfig<MediaConfigProtocol> = ((inout MediaConfigProtocol) ->Void)

open class MediaEditor: NSObject {
    
    weak public var delegate: MediaEditorProtocol?
    public var editorCompletedBlock: EditorCompleted?
    public var exportCompletedBlock: ExportCompleted?
    public var exportCompleteingBlock: ExportCompleting?
    
    /// 是否正在合成
    public var isCompositioning = false
    public var isCancelComposition = false
    /// 当前合成进度
    public var currentProgress: Float = 0.0
    var audioURL: URL?
    var watermLayer: CALayer?
    var exportProgress: Float = 0.0
    var timer: Timer = Timer.init()
    
    var _inputVideoURL: URL?
    var inAsset: AVAsset?
    /// 视频源的地址，只支持本地视频
    public var inputVideoURL: URL? {
        set {
            if let url = newValue {
                _inputVideoURL = url
                inAsset = AVAsset.init(url: url)
            } else {
                inAsset = nil
                _inputVideoURL = nil
            }
        }
        get {
            return _inputVideoURL
        }
    }
    
    var mComposition: AVMutableComposition?
    var mVideoComposition: AVMutableVideoComposition?
    var mAudioMix:AVMutableAudioMix?
    lazy var audioCMD: AudioCommand = {
        [unowned self] in
        let audioCMD = AudioCommand().initCommand(composition: self.mComposition, videoComposition: self.mVideoComposition, audioMix: self.mAudioMix)
        return audioCMD
    }()
    
    lazy var watermCMD: WatermarkCommand = {
        [unowned self] in
        let watermCMD = WatermarkCommand().initCommand(composition: self.mComposition, videoComposition: self.mVideoComposition, audioMix: self.mAudioMix)
        return watermCMD
    }()

    lazy var exportCMD: ExportCommand = {
        [unowned self] in
        let exportCMD = ExportCommand().initCommand(composition: self.mComposition, videoComposition: self.mVideoComposition, audioMix: self.mAudioMix)
        return exportCMD
    }()
    
    let compositionQueue = DispatchQueue(label: "com.nh.av.editor.queue", qos: .default, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
    /// 初始化实例
    /// - Parameter inputURL: 输入视频的视频地址
    func initVideoURL(inputURL: URL) -> MediaEditor {
        inputVideoURL = inputURL
        
        
        
        return self
    }
    
    /// 初始化
    /// - Parameter inputURL: 输入视频的视频地址
    public static func initVideoURL(inputURL: URL) -> MediaEditor {
        return MediaEditor().initVideoURL(inputURL: inputURL)
    }
    
    func checkIputAsset(cmd: MediaCommand) -> AVAsset? {
        if let asset = inAsset {
            return asset
        }
        
        if let isDelegate = delegate {
            isDelegate.editorCompositioned(type: cmd.type, error: nil)
        }
        return nil
    }
    
    /// 添加背景音乐
    /// - Parameters:
    ///   - audioURL: 音乐地址
    ///   - customConfig:  自定义插入音频的配置，传空则使用默认配置，详情参考：`MediaConfig.swift`
    ///     - config: 已初始化的配置实例，如果需要直接设置它的成员变量
    ///   - completed: 完成回调
    ///     - error: 失败时的错误详情，成功：error 为 nil
    public func addAudio(url: URL, customConfig: EditorConfig<AudioConfig>? = nil, completed: EditorCompleted? = nil){
        
        var cg: AudioConfig?
        if let config = customConfig {
            cg = AudioConfig()
            config(&cg!)
        }
        
        if url.isFileURL {
            audioURL = url
        }
        
        editorCompletedBlock = completed
        if let asset = checkIputAsset(cmd: audioCMD) {
            beginCompositionAsync(cmd: audioCMD, config: cg, asset: asset, inputURL:audioURL)
//            compositionQueue.async {
//                self.isCompositioning = true
//                self.isCancelComposition = false
//                self.audioCMD.delegate = self
//                self.audioCMD.audioConfig = cg
//                self.audioCMD.inputURL = self.inputVideoURL
//                self.audioCMD.performAsset(asset)
//            }
        }
    }
    
    
    /// 添加水印
    /// - Parameters:
    ///   - layer: 一个处理好的 CALayer，如果需要动画，需要把动加在这个`layer`上
    ///   - customConfig: 传空则使用默认配置，详情参考：NHWatermarkConfig.h
    ///     - config: 已初始化的配置实例，如果需要直接设置它的成员变量
    ///   - completed: 完成回调
    ///     - error: 失败时的错误详情，成功：error 为 nil
    public func addWatermark(layer: CALayer, customConfig: EditorConfig<WatermarkConfig>? = nil, completed: EditorCompleted? = nil){
        
        watermLayer = layer
        var cg: WatermarkConfig?
        if let config = customConfig {
            cg = WatermarkConfig.init()
            config(&cg!)
        }
        
        editorCompletedBlock = completed
        if let asset = checkIputAsset(cmd: watermCMD) {
            beginCompositionAsync(cmd: watermCMD, config: cg, asset: asset, inputURL: _inputVideoURL)

//            compositionQueue.async {
//                self.isCompositioning = true
//                self.isCancelComposition = false
//                self.watermCMD.delegate = self
//                self.watermCMD.watermarkConfig = cg
//                self.watermCMD.inputURL = self.inputVideoURL
//                self.watermCMD.performAsset(asset)
//            }
        }
        
    }
    
    
    /// 导出视频
    /// - Parameters:
    ///   - outputURL: 一个处理好的 CALayer，如果需要动画，需要把动加在这个`layer`上
    ///   - customConfig: 传空则使用默认配置，详情参考：NHWatermarkConfig.h
    ///     - config: 已初始化的配置实例，如果需要直接设置它的成员变量
    ///   - progress: 导出进度
    ///   - completed: 完成回调
    ///      - outputURL: 输出地址
    ///      - error: 失败时的错误详情，成功：error 为 nil
    public func exportMedia(outputURL: URL = getOutputURL(), customConfig: EditorConfig<ExporyConfig>? = nil, progress: ExportCompleting? = nil, completed: ExportCompleted? = nil){
        
        exportWillBegin()
        
        var cg: ExporyConfig?
        if let config = customConfig {
            cg = ExporyConfig.init()
            config(&cg!)
        }
        
        exportCompletedBlock = completed
        exportCompleteingBlock = progress
        if let asset = checkIputAsset(cmd: exportCMD) {
            beginCompositionAsync(cmd: exportCMD, config: cg, asset: asset, inputURL: _inputVideoURL)

//            compositionQueue.async {
//                self.isCompositioning = true
//                self.isCancelComposition = false
//                self.exportCMD.delegate = self
//                self.exportCMD.exportConfig = cg
//                self.exportCMD.outputURL = outputURL
//                self.exportCMD.performAsset(asset)
//            }
        }
    }
    
    func exportWillBegin() {
        if let wm_layer = watermLayer {
            let videoLayer = CALayer.init()
            let animationLayer = CALayer.init()
            let width = mVideoComposition?.renderSize.width ?? (inAsset?.videoSize().width ?? 0.0)
            let height = mVideoComposition?.renderSize.height ?? (inAsset?.videoSize().height ?? 0.0)
            let frame = CGRect(x: 0, y: 0, width:width , height: height)
            animationLayer.frame = frame
            videoLayer.frame = frame
            animationLayer.addSublayer(videoLayer)
            animationLayer.addSublayer(wm_layer)
            
            if mVideoComposition != nil {
                mVideoComposition!.animationTool = AVVideoCompositionCoreAnimationTool.init(postProcessingAsVideoLayer: videoLayer, in: animationLayer)
            }
            
            exportProgress = 0.0
            timer = Timer.init(timeInterval: 1.0, target: self, selector: Selector.init(("updateExportProgress")), userInfo: nil, repeats: true)
        }
    }
    
    func updateExportProgress() {
        let progress = exportCMD.exportSession?.progress
        exportProgress = progress ?? 0.0
        if progress == 1.0 {
            timer.invalidate()
        }
        
        if let delegate_ = delegate {
            delegate_.editorExporting(progress: exportProgress)
        }
        
        debugPrint("updateExportProgress:", exportProgress)
    }
    
    func beginCompositionAsync(cmd: MediaCommand, config: MediaConfigProtocol?, asset: AVAsset, inputURL: URL?) {
        compositionQueue.async {
            self.isCompositioning = true
            self.isCancelComposition = false
            cmd.delegate = self
            cmd.config = config
            cmd.inputURL = inputURL
            cmd.performAsset(asset)
        }
    }
    
    /// 每重新合成新视频前，都需要调用下此方法，用于清空历史的水印、音频信息，正在合成时调用无效
    public func resetAllCompositionAtBeforeRestart() {
        
    }
    
    /// 取消合成
    public func cancelComposition() {
        
    }
    
    static public func getOutputURL() -> URL {
        URL.init(fileURLWithPath: NSTemporaryDirectory().appending("\(Date.getCurrentTimestamp())\(".mov")"))
    }
}

// MARK: - MediaCommandProtocol
extension MediaEditor: MediaCommandProtocol {
    
    func mediaCompostioned(cmd: MediaCommand, error: NHAVEditorError?) {
        mAudioMix         = cmd.mAudioMix
        mComposition      = cmd.mComposition
        mVideoComposition = cmd.mVideoComposition
        
        DispatchQueue.main.async {
            self.delegate?.editorCompositioned(type: cmd.type, error: error)
            if let compostionedBlock = self.editorCompletedBlock {
                compostionedBlock(error)
            }
        }

    }
    
    func mediaExporting(cmd: ExportCommand, progress: Float) {
        
        DispatchQueue.main.async {
            self.delegate?.editorExporting(progress: progress)
            if let exportingBlock = self.exportCompleteingBlock {
                exportingBlock(progress)
            }
        }
    }
    
    func mediaExported(cmd: ExportCommand, error: NHAVEditorError?) {
        
        DispatchQueue.main.async {
            self.delegate?.editorExported(outputURL: cmd.outputURL, error: error)
            if let exportedBlock = self.exportCompletedBlock {
                exportedBlock(cmd.outputURL, error)
            }
        }
    }
    
}



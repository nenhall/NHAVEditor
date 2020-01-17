//
//  ViewController.swift
//  NHAVEditorExamples
//
//  Created by nenhall on 2019/12/6.
//  Copyright © 2019 nenhall. All rights reserved.
//

import UIKit
//import NHAVEditor
import AVFoundation

@IBDesignable

class ViewController: UIViewController {

    @IBOutlet weak var previewButton: UIButton!
    @IBOutlet weak var playView: UIImageView!
    @IBOutlet weak var scrollerView: UIScrollView!
    @IBOutlet weak var oriVolume: UISlider!
    @IBOutlet weak var beginVol: UISlider!
    @IBOutlet weak var endVol: UISlider!
    @IBOutlet weak var poBeginTextField: UITextField!
    @IBOutlet weak var poEndTextField: UITextField!
    @IBOutlet weak var cutBeginTextField: UITextField!
    @IBOutlet weak var cutEndTextField: UITextField!
    @IBOutlet weak var otherVolume: UISlider!
    @IBOutlet weak var oriVolumeSwitch: UISwitch!
    @IBOutlet weak var insertBeginTextField: UITextField!
    
    
    var _playLayer: AVPlayerLayer?
    
    let mp4URLString = Bundle.main.path(forResource: "Бамбинтон-Зая", ofType: "mp4")
    let mp3URLString = Bundle.main.path(forResource: "黑龙-38度6", ofType: "mp3")
    lazy var audioURL: URL = {
        [unowned self] in
        return URL.init(fileURLWithPath: self.mp3URLString!)
        }()
    lazy var inputMp4URL = {
        [unowned self] in
        URL.init(fileURLWithPath: self.mp4URLString!)
    }()
    let outpurURL = URL.init(fileURLWithPath: NSTemporaryDirectory().appending("\(Date.getCurrentTimestamp())\(".mp4")"))
    var  player: AVPlayer?
    lazy var mediaEditor: MediaEditor = {
        [unowned self] in
        let mediaEditor = MediaEditor.initVideoURL(inputURL: URL.init(fileURLWithPath: "/tmp"))
        mediaEditor.delegate = self
        return mediaEditor
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollerView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 54, right: 0)

        initializePlayer()
        mediaEditor.inputVideoURL = inputMp4URL
        print("outpurURL:", outpurURL)
  
        
    }
    
     @IBAction func addAudio(_ sender: UIButton) {
        sender.isEnabled = false
        mediaEditor.addAudio(url: audioURL, customConfig: { [weak self] (config)  in
            if let self_ = self {                
                let mp4Time = AVAsset.getDuration(url: URL.init(fileURLWithPath: (self?.mp4URLString!) ?? ""));
                config.removeOriginalAudio = !self_.oriVolumeSwitch.isOn
                config.originalVolume = 0.0
                config.startVolume = self_.beginVol.value
                config.endVolume = self_.endVol.value
                if let text = self?.insertBeginTextField.text {
                    config.startTime = CMTimeMake(value: Int64.init(text) ?? 0, timescale: 600)
                }
                
                if let beginT = self?.cutBeginTextField.text , let endT = self?.cutEndTextField.text{
                    let time = CMTimeMake(value: Int64.init(beginT) ?? 600, timescale: 600)
                    let dTime = CMTimeMake(value: Int64.init(endT) ?? Int64(mp4Time.value), timescale: 600)
                    config.insertTimeRange = CMTimeRangeMake(start: time, duration: dTime)
                }
                
                if let beginT = self?.poBeginTextField.text , let endT = self?.poEndTextField.text{
                    let timeB = CMTimeMake(value: Int64.init(beginT) ?? 0, timescale: mp4Time.timescale)
                    let timeE = CMTimeMake(value: Int64.init(endT) ?? Int64(mp4Time.value), timescale: mp4Time.timescale)
                    config.volumeTimeRange = CMTimeRangeMake(start: timeB, duration: timeE)
                }
                
            }
            
        }) { (error) in
            sender.isEnabled = true
            debugPrint("Add Audio Compeleted1:","NHAVEditorExamples.NHAVEditorType.Audio", error?.localizedDescription ?? "")
        }
    }
    
     @IBAction func addWatermark(_ sender: UIButton) {
        mediaEditor.addWatermark(layer: CALayer.init(), customConfig: {  [weak self] (config) in
            if let self_ = self {
                
            }
        }) { (error) in
            
        }
    }
    
    @IBAction func addAnimation(_ sender: UIButton) {

    }
    
     @IBAction func exportVideo(_ sender: UIButton) {
        mediaEditor.exportMedia(outputURL: outpurURL, customConfig: { [weak self] (config) in
             if let self_ = self {
                 
             }
         }, progress: { (progress) in
             debugPrint("export progress:", progress)
         }) { (outputURL, error) in
             debugPrint("导出完成", outputURL ?? "", error?.localizedDescription ?? "")
         }
    }
    
    @IBAction func previewVideo(_ sender: UIButton) {
        if sender.isSelected {
            player?.pause()
        } else {
            if let composition = mediaEditor.mComposition {
                let playItem = AVPlayerItem.init(asset: composition)
                player?.replaceCurrentItem(with: playItem)
                player?.play()
            } else {
                player?.play()
            }
        }
        sender.isSelected = !sender.isSelected
    }
    
    
    @IBAction func originalVolumeSwitch(_ sender: UISwitch) {
        
    }
    
    @IBAction func originalVolume(_ sender: UISlider) {
        
    }
    
    @IBAction func beginInputAudioVolume(_ sender: UISlider) {
        
    }
    
    @IBAction func endInputAudioVolume(_ sender: UISlider) {
        
    }
    
    @IBAction func changePoBeginVolume(_ sender: UIStepper) {
        if let text = poBeginTextField.text {
            let num = Double(text) ?? 0.0
            let newNum = sender.value > num ? num + 1.0 : num - 1.0
            sender.value = newNum
            poBeginTextField.text = String(newNum)
        }
    }

    @IBAction func changePoEndVolume(_ sender: UIStepper) {
        if let text = poEndTextField.text {
            let num = Double(text) ?? 0.0
            let newNum = sender.value > num ? num + 1.0 : num - 1.0
            sender.value = newNum
            poEndTextField.text = String(newNum)
        }
    }
    
    @IBAction func changeCutBeginVolume(_ sender: UIStepper) {
        if let text = cutBeginTextField.text {
            let num = Double(text) ?? 0.0
            let newNum = sender.value > num ? num + 1.0 : num - 1.0
            sender.value = newNum
            cutBeginTextField.text = String(newNum)
        }
    }
    
    @IBAction func changeCutEndVolume(_ sender: UIStepper) {
        if let text = cutEndTextField.text {
            let num = Double(text) ?? 0.0
            let newNum = sender.value > num ? num + 1.0 : num - 1.0
            sender.value = newNum
            cutEndTextField.text = String(newNum)
        }
    }
    
    @IBAction func insertBeginFromVideo(_ sender: UIStepper) {
        if let text = insertBeginTextField.text {
            let num = Double(text) ?? 0.0
            let newNum = sender.value > num ? num + 1.0 : num - 1.0
            sender.value = newNum
            insertBeginTextField.text = String(newNum)
        }
    }
    
    @IBAction func otherVolume(_ sender: UISlider) {
        
    }
    
    
    func initializePlayer() {
        let asset = AVAsset.init(url: inputMp4URL)
        let playItem = AVPlayerItem.init(asset: asset)
        player = AVPlayer.init(playerItem: playItem)
        let playLayer = AVPlayerLayer.init(player: player)
        playLayer.frame = playView.bounds
        _playLayer = playLayer
        playView.layer.addSublayer(playLayer)
        player?.play()
    }

}

extension ViewController: MediaEditorProtocol {
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        _playLayer?.frame = playView.bounds;
        if UIDevice.current.orientation != UIDeviceOrientation.portrait {
            if #available(iOS 11.0, *) {
//                vLeftMargin.constant = self.view.safeAreaInsets.left
            }
        }
        
    }
    
    func editorCompositioned(type: NHAVEditorType, error: Error?) {
        debugPrint("Add Audio Compeleted2:", type, error?.localizedDescription ?? "")
        DispatchQueue.main.async {
//            self.previewButton.isEnabled = (self.mediaEditor.mComposition != nil)
        }
    }
    
    func editorExporting(progress: Float) {
        debugPrint("export progress:", progress)

    }
    
    func editorExported(outputURL: URL?, error: Error?) {
        debugPrint("导出完成", outputURL ?? "", error?.localizedDescription ?? "")

    }
}


//
//  AudioCommand.swift
//  Pods-NHAVEditorExamples
//
//  Created by nenhall on 2019/12/6.
//

import UIKit
import AVFoundation


public class AudioCommand: MediaCommand {
    
    override public var type: NHAVEditorType {
        get{
            return .Audio
        }
    }
    override public func performAsset(_ asset: AVAsset) {
        var oriVideoTrack: AVAssetTrack?
        var oriAudioTrack: AVAssetTrack?
        
        // video
        let vTracks = asset.tracks(withMediaType: AVMediaType.video)
        if vTracks.count > 0 {
            oriVideoTrack = vTracks.first
        }
        
        // audio
        let aTracks = asset.tracks(withMediaType: AVMediaType.audio)
        if aTracks.count > 0 {
            oriAudioTrack = aTracks.first
        }
        
        
        // is keep original audio tracks
        var oriAudioCTrack: AVMutableCompositionTrack?
        var mComposition = AVMutableComposition()
        let removeOriginalAudio = self.audioConfig != nil ? self.audioConfig!.removeOriginalAudio : false
        let isAddOriginalAudio = (oriAudioTrack != nil) && !removeOriginalAudio
        let iTimeRange = CMTimeRangeMake(start: CMTime.zero, duration: asset.duration)

        if self.mComposition == nil {
            self.mComposition = mComposition
            // create video track
            if let videoTrack_ = oriVideoTrack {
                let mcVideoTrack = mComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: videoTrack_.trackID)
                do {
                    try mcVideoTrack?.insertTimeRange(iTimeRange, of: videoTrack_, at: CMTime.zero)
                }
                catch let error {
                    if self.delegate != nil {
                        delegate?.mediaCompostioned(cmd: self, error: NHAVEditorError(line: #line, column: #column, kind: .parameter, description: "mcVideoTrack insterTimerRange failed!"+error.localizedDescription, error: error))
                    }
                    debugPrint("mcVideoTrack insterTimerRange failed!")
                    return
                }
            }
            // create audio track
            if let audioTrack_ = oriAudioTrack {
                oriAudioCTrack = mComposition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: audioTrack_.trackID)
                if isAddOriginalAudio {
                    do {
                        try oriAudioCTrack?.insertTimeRange(iTimeRange, of: audioTrack_, at: CMTime.zero)
                    } catch let error {
                        if self.delegate != nil {
                            delegate?.mediaCompostioned(cmd: self, error: NHAVEditorError(line: #line, column: #column, kind: .objectIsNull, description: "original audio insert failed!"+error.localizedDescription, error: error))
                        }
                        debugPrint("original audio insert failed!")
                        return
                    }
                }
            }
        } else {
            mComposition = self.mComposition!
            let audioTracks = mComposition.tracks(withMediaType: AVMediaType.audio)
            oriAudioCTrack = audioTracks.first
            debugPrint(audioTracks)
        }
        
        // original audio mix
        var originalMixInPar: AVMutableAudioMixInputParameters?
        if let oriAudioCTrack_ = oriAudioCTrack {
            originalMixInPar = AVMutableAudioMixInputParameters.init(track: oriAudioCTrack_)
            if let audioConfig = self.audioConfig {
                originalMixInPar?.trackID = oriAudioCTrack_.trackID
                originalMixInPar?.setVolume(audioConfig.originalVolume, at: CMTime.zero)
//                originalMixInPar?.setVolumeRamp(fromStartVolume: audioConfig.originalVolume, toEndVolume: audioConfig.originalVolume, timeRange: oriAudioCTrack_.timeRange)
            }
        }
        
        var newCAudioTrack: AVMutableCompositionTrack?
        var newMixInPar: AVMutableAudioMixInputParameters?
        let defaultTimeRange = CMTimeRangeMake(start: CMTime.zero, duration: mComposition.duration)
        
        // new audio track
        if let audioInputURL = self.inputURL {
            let newAudioAsset = AVURLAsset.init(url: audioInputURL)
            
            // get audio track in the new audio file
            let naTracks = newAudioAsset.tracks(withMediaType: AVMediaType.audio)
            var newAudioTrack: AVAssetTrack?
            if naTracks.count > 0 {
                newAudioTrack = naTracks.first
            }
            
            if let newAudioTrack_ = newAudioTrack {
                newCAudioTrack = mComposition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: newAudioTrack_.trackID)
                
                var insertTime = iTimeRange
                var startTime = CMTime.zero
                if let audioFig = self.audioConfig {
                    insertTime = audioFig.insertTimeRange ?? defaultTimeRange
                    startTime = audioFig.startTime
                }
                
                do {
                    // new audio track the range and start time
                    try newCAudioTrack?.insertTimeRange(insertTime, of: newAudioTrack_, at: startTime)
                } catch let error {
                    debugPrint("new audio track insert failed! ", error)
                    if self.delegate != nil {
                        delegate?.mediaCompostioned(cmd: self, error: NHAVEditorError(line: #line, column: #column, kind: .parameter, description: "new audio track insert failed!"+error.localizedDescription, error: error))
                    }
                    return
                }
                
                // composition new audio track
                newMixInPar = AVMutableAudioMixInputParameters.init(track: newAudioTrack_)
                
                var volumeTimeRange = defaultTimeRange
                if self.audioConfig?.volumeTimeRange != nil {
                    volumeTimeRange = self.audioConfig!.volumeTimeRange!
                }
                
                if let audioConfig = self.audioConfig {
                    newMixInPar?.setVolumeRamp(fromStartVolume: audioConfig.startVolume, toEndVolume: audioConfig.endVolume, timeRange: volumeTimeRange)
                } else {
                    newMixInPar?.setVolumeRamp(fromStartVolume: 1.0, toEndVolume: 1.0, timeRange: volumeTimeRange)
                }
                if let newCAudioTrack_ = newCAudioTrack {
                    newMixInPar?.trackID = newCAudioTrack_.trackID
                }
            }
        }
        
        // all audio track
        self.mAudioMix = AVMutableAudioMix()
        if isAddOriginalAudio {
            self.mAudioMix.inputParameters = [ originalMixInPar ?? AVMutableAudioMixInputParameters(), newMixInPar ?? AVMutableAudioMixInputParameters()]
        }
        
        if self.delegate != nil {
            delegate?.mediaCompostioned(cmd: self, error: nil)
        }
    }
    
    
}

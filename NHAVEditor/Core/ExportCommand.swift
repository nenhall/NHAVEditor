//
//  ExportCommand.swift
//  Pods-NHAVEditorExamples
//
//  Created by nenhall on 2019/12/6.
//

import UIKit
import AVFoundation

public class ExportCommand: MediaCommand {

    var outputURL: URL?
    var exportSession: AVAssetExportSession?
    override public var type: NHAVEditorType {
        get{
            return .Export
        }
    }
    public override func performAsset(_ asset: AVAsset) {
        
    }
    
}

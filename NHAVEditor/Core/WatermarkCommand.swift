//
//  WatermarkCommand.swift
//  Pods-NHAVEditorExamples
//
//  Created by nenhall on 2019/12/6.
//

import UIKit

public class WatermarkCommand: MediaCommand {
    override public var type: NHAVEditorType {
        get{
            return .Watermark
        }
    }
}

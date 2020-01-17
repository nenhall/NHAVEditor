//
//  AVEditorExtend.swift
//  NHAVEditor
//
//  Created by nenhall on 2019/12/6.
//

import Foundation
import AVFoundation

public extension Data {
    
    /// 计算文件大小
    func fileSize() -> Float {
    Float.init(self.count) / 1024.0 / 1024.0
    }
    
    
}

public extension Date {
    
    /// 获取当前时间 （以毫秒为单位）返回值格式:2019-04-19 10:33:35.886
    static func getCurrentTimestamp() -> String {
        let dateNow = Date.init()
        let dateFmt = DateFormatter.init()
        dateFmt.dateFormat = "yyyyMMddHHmmssSS"
        dateFmt.timeZone = TimeZone.init(identifier: "Asia/Beijing")
        let timestamp = dateFmt.string(from: dateNow)
        return timestamp;
    }
}


public func NHPrint( _ object: @autoclosure() -> Any?,
                     _ file: String = #file,
                     _ function: String = #function,
                     _ line: Int = #line) {
    #if DEBUG
    guard let value = object() else {
        return
    }
    var stringRepresentation: String?
    
    if let value = value as? CustomDebugStringConvertible {
        stringRepresentation = value.debugDescription
    }
    else if let value = value as? CustomStringConvertible {
        stringRepresentation = value.description
    }
    else {
        fatalError("gLog only works for values that conform to CustomDebugStringConvertible or CustomStringConvertible")
    }
    
    let gFormatter = DateFormatter()
    gFormatter.dateFormat = "HH:mm:ss:SSS"
    let timestamp = gFormatter.string(from: Date())
    let queue = Thread.isMainThread ? "UI" : "BG"
    let fileURL = NSURL(string: file)?.lastPathComponent ?? "Unknown file"
    
    if let string = stringRepresentation {
        print("✅ \(timestamp) {\(queue)} \(fileURL) > \(function)[\(line)]: \(string)")
    } else {
        print("✅ \(timestamp) {\(queue)} \(fileURL) > \(function)[\(line)]: \(value)")
    }
    #endif
}

extension AVAsset {
    
    /// get video size
    func videoSize() -> CGSize {
        let videoTracks = self.tracks(withMediaType: AVMediaType.video)
        if videoTracks.count > 0 {
            let videoTrack = videoTracks.first
            let naturalSize = __CGSizeApplyAffineTransform(videoTrack?.naturalSize ?? CGSize.zero, videoTrack?.preferredTransform ?? CGAffineTransform.init())
            return  CGSize(width: naturalSize.width, height: naturalSize.height)
        }
        return CGSize.zero
    }

    static func getDuration(url: URL) -> CMTime {
        return AVAsset.init(url: url).duration
    }
    
}


public struct NHAVEditorError: Error {
    enum ErrorKind {
        case unknown
        case parameter
        case objectIsNull
    }
    
    let line: Int?
    let column: Int?
    let kind: ErrorKind
    let description: String?
    let error: Error
}

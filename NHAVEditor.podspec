Pod::Spec.new do |spec|
  
  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  spec.name         = "NHAVEditor"
  spec.version      = "0.0.1"
  spec.summary      = "基于 AVFoundation 框架封装的 iOS视频编辑工具 Swift 版"
  spec.description  = <<-DESC
  基于 AVFoundation 框架封装的 iOS视频编辑工具，支持给视频添加水印、特效、音乐、导出视频、视频转gif
  DESC
  
  spec.homepage     = "https://github.com/nenhall/NHAVEditor"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "nenhall" => "nenhall@126.com" }
  spec.platform     = :ios, "8.0"
  spec.ios.deployment_target = "8.0"
  spec.swift_versions = ['5.0', '5.1']
  spec.source       = { :git => "https://github.com/nenhall/NHAVEditor.git", :tag => "#{spec.version}" }
  # spec.exclude_files = "Classes/Exclude"
  # spec.public_header_files = "Classes/**/*.h"
#  spec.source_files = "NHAVEditor/*.swift"
  spec.frameworks  = ["AVFoundation", "ImageIO", "CoreServices", "UIKit", "AssetsLibrary", "Photos"]
  spec.default_subspec = ['Core', 'Accessory', 'Unit']
  
  
  spec.subspec 'Core' do |core|
    core.source_files = "NHAVEditor/Core/*.swift"
#    core.public_header_files = "NHAVEditor/Core/*.swift"
    
  end
  
  spec.subspec 'Accessory' do |acc|
    acc.source_files = "NHAVEditor/Accessory/*.swift"
#    acc.public_header_files = "NHAVEditor/Accessory/*.swift"

    
  end
  
  spec.subspec 'Unit' do |unit|
    unit.source_files = "NHAVEditor/Unit/*.swift"
#    unit.public_header_files = "NHAVEditor/Unit/*.swift"

    
  end
  
end

#
#  Be sure to run `pod spec lint NHAVEditor.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  spec.name         = "NHAVEditor"
  spec.version      = "0.0.2"
  spec.summary      = "基于 AVFoundation 框架封装的 iOS视频编辑工具"
  spec.description  = <<-DESC
  基于 AVFoundation 框架封装的 iOS视频编辑工具，支持给视频添加水印、特效、音乐、导出视频、视频转gif
                   DESC

  spec.homepage     = "https://github.com/nenhall/NHAVEditor"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "nenhall" => "nenhall@126.com" }
  spec.platform     = :ios, "9.0"
  spec.ios.deployment_target = "9.0"
  spec.source       = { :git => "https://github.com/nenhall/NHAVEditor.git", :tag => "#{spec.version}" }
  spec.source_files = "NHAVEditor/*.{h,m}", "NHAVEditor/Unit/*.{h,m}"
  # spec.exclude_files = "Classes/Exclude"
  # spec.public_header_files = "Classes/**/*.h"
   spec.frameworks  = ["AVFoundation", "ImageIO", "CoreServices", "UIKit", "AssetsLibrary", "Photos"]


end

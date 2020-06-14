## NHAVEditor


> 基于 AVFoundation 框架封装的 iOS视频编辑工具，支持给视频添加水印、特效、音乐、导出视频、视频转gif、去除原声

iOS: >= 8.0

**Swift**：https://github.com/nenhall/NHAVEditor2 (功能还未完善，开发中)

**Objective-C**：https://github.com/nenhall/NHAVEditor

![预览图](https://github.com/nenhall/NHAVEditor/blob/master/preview.gif)

### 使用方法：

`    pod 'NHAVEditor', '~> 0.0.2'`

1. 导入头文件：

   ```objective-c
   #import "NHAVEditor.h"
   ```
   
2. 初始化

   ```objective-c
   - (NHAVEditor *)mediaEditor {
     if (!_mediaEditor) {
       _mediaEditor = [[NHAVEditor alloc] initWithVideoURL:[NSURL fileURLWithPath:kMp4Path]];
       _mediaEditor.delegate = self;
     }
     return _mediaEditor;
   }
   
   - (NHGifWriter *)gifWriter {
     if (!_gifWriter) {
       _gifWriter = [[NHGifWriter alloc] initWithOutputURL:nil];
       _gifWriter.loopCount = 0;
       _gifWriter.delayTime = 0.1;
     }
     return _gifWriter;
   }
   
   - (NHMediaWriter *)mediaWriter {
     if (!_mediaWriter) {
       _mediaWriter = [NHMediaWriter mediaWithVideoSize:_displayView.videoSize fileType:AVFileTypeQuickTimeMovie];
     }
     return _mediaWriter;
   }
   ```

3. 添加背景音乐

   ```objective-c
     [self.mediaEditor addAudioWithAudioURL:url customConfig:^(NHAudioConfig * _Nonnull config) {
        // 开始的音量大小，结束的时音量大小，从开始到结束这段时间的一个音量线性变化
        config.startVolume = 0.0;
        config.endVolume = 1.0;
        // 是否关闭视频原声，默认false
        //  config.removeOriginalAudio = true;
        config.originalVolume = 0.1;
     } completedBlock:nil];
   ```

4. 添加水印

   ```objective-c
   // 先创建一个水印或者动效 layer 层
     _watermarkLayer = [CALayer layer];
    CGFloat x = _displayView.videoSize.width - [self logoImage].size.width;
   //  CGFloat y = _displayView.videoSize.height - [self logoImage].size.height;
     _watermarkLayer.frame = CGRectMake(x, 0, [self logoImage].size.width, [self logoImage].size.height);
      if (_isOpenAnimation) {
       CABasicAnimation *keyAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
       keyAnimation.duration = 2.0;
       keyAnimation.repeatCount = MAXFLOAT;
       keyAnimation.toValue = @(M_PI * 2.0);
       keyAnimation.beginTime = AVCoreAnimationBeginTimeAtZero;
       keyAnimation.removedOnCompletion = NO;
       [_watermarkLayer addAnimation:keyAnimation forKey:@"transform.rotation.z"];
     }
     
     // 执行添加水印操作
       [self.mediaEditor addWatermarkWithLayer:self.watermarkLayer customConfig:nil completedBlock:nil];
   
   ```

5. 导出视频

   ```objective-c
       [self.mediaEditor exportMediaWithOutputURL:nil customConfig:^(NHExporyConfig * _Nonnull config) {
       config.presetName = AVAssetExportPreset1280x720;
       config.outputFileType = AVFileTypeQuickTimeMovie;
     } completedBlock:^(NSURL * _Nullable outputURL, NSError * _Nullable error) {
       // do ...
     }];
   ```

6. 视频转 GIF

   ```objective-c
     [self.gifWriter buildGifFromVideo:outputURL timeInterval:@(600) completion:^(NSURL * _Nullable url, NSError * _Nullable error) {
       NHLog(@"GIF生成完成:%@", url);
     }];
   ```

7. CMSampleBufferRef / CVPixelBufferRef 写成音/视频文件

   ```objective-c
   // 1. 准备工作
   [ws.mediaWriter prepareBuildMediaWithOutpurUrl:[ws OutUrl:@"mov"]];
   
   // 2. 写入
   [ws.mediaWriter appendVideoSampleBuffer:bufferRef];
   
   // 3. 完成写入
   [ws.mediaWriter finishWriteWithCompletionHandler:^(NSURL * _Nonnull fileUrl) {
    NHLog(@"%@",fileUrl);
    if (fileUrl) {
    }
   }];
   ```

8. 更多操作，请查看工程内的 `NHAVEditorExamples.xcodeproj`


音视频开发技术交流群：纯做此项技术，如做推广、营销人员匆扰

![音视频开发技术交流](https://upload-images.jianshu.io/upload_images/2443108-a7493c9f2f56cec8.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/620)

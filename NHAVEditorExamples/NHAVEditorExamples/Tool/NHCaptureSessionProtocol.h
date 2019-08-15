//
//  NHCaptureSessionProtocol.h
//  NHCaptureFramework
//
//  Created by nenhall on 2019/3/18.
//  Copyright © 2019 nenhall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIkit.h>
#import <AVFoundation/AVFoundation.h>


@class XDExportConfig;

NS_ASSUME_NONNULL_BEGIN
/** 推流工具选择 */
typedef enum : NSUInteger {
    XDPushStreamOptionalFFmpeg, //deflaut
    XDPushStreamOptionalAVCapture,
} XDPushStreamOptional;


/** 推流状态 */
typedef enum : NSUInteger {
    XDPushStreamStatusUnknown,
    XDPushStreamStatusPushing,/**< 推流中 */
    XDPushStreamStatusEnd,/**< 推流结束 */
} XDPushStreamStatus;


@protocol NHCaptureSessionProtocol <NSObject>

@optional
- (void)captureDidOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer;
- (void)captureDidOutputAfterProcessSampleBuffer:(CVPixelBufferRef)sampleBuffer;

- (void)captureOutputDidStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnection:(NSArray<AVCaptureConnection *> *)connections;


- (void)captureOutputDidFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections error:(NSError *)error;


//- (void)exportVidelWithUrl:(NSURL *)url
//              exportConfig:(NHExportConfig *)config
//                  progress:(void (^)(CGFloat value))progress
//                 completed:(void (^)(NSURL *exportURL, NSError *error))completed
//          savedPhotosAlbum:(BOOL)save;

/**
 获取视频当前图片(截屏)

 @param newImage 返回新的图片
 @param save 是否同时保存到相册
 */
- (void)captureStillImage:(void (^)(UIImage *image))newImage savedPhotosAlbum:(BOOL)save;

@end

NS_ASSUME_NONNULL_END

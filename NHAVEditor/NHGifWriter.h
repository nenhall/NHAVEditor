//
//  NHGifWriter.h
//  NHAVEditorExamples
//
//  Created by XiuDan on 2019/8/14.
//  Copyright © 2019 XiuDan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

typedef void(^NHCompletionBlock)(NSURL *_Nullable url, NSError *_Nullable error);

@interface NHGifWriter : NSObject

/**
 输出URL
 */
@property (nonatomic, copy) NSURL *outputURL;

/**
 帧间隙时间 默认0.21fs
 */
@property (nonatomic, assign) float delayTime;

/**
 播放次数 default:0 即无限循环
 */
@property (nonatomic, assign) int loopCount;

/**
 需要生成的总帧数
 */
@property (nonatomic, assign, readonly) NSInteger frameCount;

/**
 构建状态：true 构建中
 */
@property (nonatomic, assign, readonly) BOOL building;


/**
 初始化

 @param url 输出地址
 @return return value description
 */
- (instancetype)initWithOutputURL:(NSURL *__nullable)url;

/**
 准备构建gif图，设置需要构建的帧数 （每次构建gif图前需要调用）
 @abstract 实际在构建中，不管是何种方式，都需要保证传入资源数量与这里设置的值一致，否则失败
 @param frameCount 总帧数
 */
- (void)prepareBuildGifSetFrameCount:(NSInteger)frameCount;

/**
 通过`UIImage`资源构建 GIF

 @param image image 对象
 */
- (void)buildGifWithImage:(UIImage *)image;

/**
 通过`CGImageRef`资源构建 GIF
 
 @param imageRef CGImageRef 对象
 */
- (void)buildGifWithCGImageRef:(CGImageRef)imageRef;

/**
 通过`CVPixelBufferRef`资源构建 GIF
 
 @param bufferRef bufferRef description
 @param clipCenter 竖向是否取 buffer 的中间部份内容，主要针对 buffer 的宽高不等或上下边的内容不需要时
 true: 则以宽为基准，x:0点开始，y:取中间部份，裁取的高度就是width尺寸
 false: x/y 都从 bufferRef 的 0,0 点开始，取整个 buffer 尺寸
 */
- (void)buildGifWithBufferRef:(CVPixelBufferRef)bufferRef clipCenter:(BOOL)clipCenter;

/**
 通过`UIImage`资源组构建 GIF

 @param images 图片数组
 @param handler 完成的操作
 */
- (void)buildGifWithImages:(NSArray *)images completionHandler:(void (^)(BOOL ,NSURL *))handler;

/**
 通过本地视频资源构建 GIF (Convert the video at the given URL to a GIF)
 
 @param videoURL 视频的路径URL
 @param timeInterval default:600
 @param completionBlock return the GIF's URL if it was created
 */
- (void)buildGifFromVideo:(NSURL*)videoURL
             timeInterval:(NSNumber *)timeInterval
               completion:(NHCompletionBlock)completionBlock;

/**
 完成/结束构建 GIF
 
 @param handler 成功 success:yes, url never nonull
 */
- (void)finalizeGifWithCompletionHandler:(void (^)(BOOL success, NSURL *url))handler;

@end

NS_ASSUME_NONNULL_END

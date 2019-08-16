//
//  NHPicture.h
//  NHAVEditor
//
//  Created by XiuDan on 2019/8/16.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


NS_ASSUME_NONNULL_BEGIN
/** 相册保存位置 */
typedef enum : NSUInteger {
  NHPictureSavePhoto = 1 << 0, /**< 保存到相册 */
  NHPictureSaveDocument = 1 << 1, /**< 保存到 沙盒 Document 目录 */
} NHPictureSaveArea;

typedef void (^_Nullable NHPictureCompletedBlock)(NHPictureSaveArea area, NSURL *_Nullable fileUrl, NSError *_Nullable error);


@interface NHPicture : NSObject

/**
 buffer 生成图片
 
 @param pixelBuffer pixelBuffer description
 @param isCrop 是否以中间部份进行裁切
 @param completed completed description
 */
+ (void)makeImageFromPixelBuffer:(CVPixelBufferRef)pixelBuffer isCrop:(BOOL)isCrop completed:(nullable void(^)(UIImage *image))completed;
- (void)makeImageFromPixelBuffer:(CVPixelBufferRef)pixelBuffer isCrop:(BOOL)isCrop completed:(nullable void(^)(UIImage *image))completed;

+ (void)saveImage:(UIImage *)image name:(NSString *__nullable)name saveArea:(NHPictureSaveArea)saveArea completionHandler:(NHPictureCompletedBlock)completionHandler;

- (void)saveImage:(UIImage *)image name:(NSString *__nullable)name directory:(NSString *__nullable)directory toPath:(NSString *__nullable)path saveArea:(NHPictureSaveArea)saveArea completionHandler:(NHPictureCompletedBlock)completionHandler;

+ (void)saveImage:(UIImage *)image name:(NSString *__nullable)name directory:(NSString *__nullable)directory toPath:(NSString *__nullable)path saveArea:(NHPictureSaveArea)saveArea completionHandler:(NHPictureCompletedBlock)completionHandler;
+ (void)saveFileToPhotoWithURL:(NSURL *)url completionHandler:(nullable void(^)(BOOL success, NSError *__nullable error))completionHandler;

+ (UIImage *)addWaterMarkWithImage:(UIImage *)image waterImage:(UIImage *)waterImage imgScale:(CGFloat)scale;
+ (UIImage *)makeImageWithView:(UIView *)view withSize:(CGSize)size scale:(CGFloat)scale;


/**
 通过抽样缓存数据创建一个UIImage对象
 
 @param bufferRef bufferRef description
 @param isCrop 是否以中间部份进行裁切
 @return return value description
 */
+ (UIImage *)imageFromPixelBuffer:(CVPixelBufferRef)bufferRef isCrop:(BOOL)isCrop;
- (UIImage *)imageFromPixelBuffer:(CVPixelBufferRef)bufferRef isCrop:(BOOL)isCrop;
+ (CGImageRef)imageRefFromBufferRef:(CVPixelBufferRef)bufferRef;
- (CGImageRef)imageRefFromBufferRef:(CVPixelBufferRef)bufferRef;

+ (void)renderImageFromCVPixelBuffer:(CVPixelBufferRef)buffer toBuffer:(CVPixelBufferRef)toBuffer image:(UIImage *)image;

/**
 * 调整尺寸
 */
+ (UIImage *)scaleImage:(UIImage *)image scale:(CGFloat)scale;


@end

NS_ASSUME_NONNULL_END

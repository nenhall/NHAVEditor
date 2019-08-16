//
//  NHPicture.m
//  NHAVEditor
//
//  Created by XiuDan on 2019/8/16.
//

#import "NHPicture.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreServices/CoreServices.h>


@implementation NHPicture {
  dispatch_queue_t _takePhotoQ;
  CVPixelBufferReleaseBytesCallback _myPixelBufferReleaseCallback;
}

- (instancetype)init
{
  self = [super init];
  if (self) {
    _takePhotoQ = dispatch_queue_create("com.xd.takePhoto", DISPATCH_QUEUE_CONCURRENT);
  }
  return self;
}

+ (void)saveImage:(UIImage *)image name:(NSString *)name saveArea:(NHPictureSaveArea)saveArea completionHandler:(NHPictureCompletedBlock)completionHandler {
  [[[NHPicture alloc] init] saveImage:image name:name directory:nil toPath:nil saveArea:saveArea completionHandler:completionHandler];
}

+ (void)saveImage:(UIImage *)image name:(NSString *)name directory:(NSString *)directory toPath:(NSString *)path saveArea:(NHPictureSaveArea)saveArea isToDoucment:(BOOL)isToDoucment completionHandler:(NHPictureCompletedBlock)completionHandler {
  [[[NHPicture alloc] init] saveImage:image name:name directory:directory toPath:path saveArea:saveArea completionHandler:completionHandler];
}

+ (void)saveFileToPhotoWithURL:(NSURL *)url completionHandler:(nullable void(^)(BOOL success, NSError *__nullable error))completionHandler {
  
  NSData *imageData = [NSData dataWithContentsOfURL:url];
  
  ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
  NSDictionary *metadata = @{@"UTI" : (__bridge NSString *)kUTTypeGIF};
  
  [library writeImageDataToSavedPhotosAlbum:imageData metadata:metadata completionBlock:^(NSURL *assetURL, NSError *error) {
    BOOL suc = YES;
    if (error || !assetURL) {
      suc = NO;
    }
    if (completionHandler) {
      completionHandler(suc, error);
    }
  }];
}

+ (void)saveImage:(UIImage *)image name:(NSString *)name directory:(NSString *)directory toPath:(NSString *)path saveArea:(NHPictureSaveArea)saveArea completionHandler:(NHPictureCompletedBlock)completionHandler {
  [[[NHPicture alloc] init] saveImage:image
                                 name:name
                            directory:directory
                               toPath:path
                             saveArea:saveArea
                    completionHandler:completionHandler];
}
- (void)saveImage:(UIImage *)image name:(NSString *)name directory:(NSString *)directory toPath:(NSString *)path saveArea:(NHPictureSaveArea)saveArea completionHandler:(NHPictureCompletedBlock)completionHandler {
  
  if (!image) {
    return;
  }
  
  dispatch_async(_takePhotoQ, ^{
    
    NSString *fullPath = path;
    
    if (saveArea & NHPictureSavePhoto) {
      [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        
        [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        
      } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (completionHandler) {
          completionHandler(NHPictureSavePhoto , nil, error);
        }
      }];
    }
    
    if (saveArea & NHPictureSaveDocument) {
      NSError *error;
      
      if (!path) {
        
        NSString *doucmentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        
        NSString *sDir = directory ?: @"";
        
        NSString *subDirectory = [NSString stringWithFormat:@"photos/%@",sDir];
        
        NSString *pngDir = [doucmentPath stringByAppendingPathComponent:subDirectory];
        
        BOOL isExecutable = [[NSFileManager defaultManager] isExecutableFileAtPath:pngDir];
        
        if (!isExecutable) {
          //        NSDictionary *attributes = @{NSFileAppendOnly : @(1), NSFilePosixPermissions : @(777) };
          BOOL createResult = [[NSFileManager defaultManager] createDirectoryAtPath:pngDir withIntermediateDirectories:YES attributes:nil error:&error];
          if (!createResult) {
            NSLog(@"create file failed");
          }
        }
        
        NSString *fileName = [NSString stringWithFormat:@"%@_%@",sDir,name];
        
        if (!fileName) {
          fileName = [NSString stringWithFormat:@"%@_%f.png", sDir,[[[NSDate alloc] init] timeIntervalSince1970]];
        }
        
        
        fullPath = [pngDir stringByAppendingPathComponent:fileName];
      }
      
      NSData *imageData = UIImagePNGRepresentation(image);
      
      BOOL writerResult = [imageData writeToFile:fullPath atomically:YES];
      if (completionHandler) {
        NSURL *outputURL;
        if (fullPath) {
          outputURL = [NSURL fileURLWithPath:fullPath];
        }
        completionHandler(NHPictureSaveDocument, writerResult ? outputURL : nil, error);
      }
    }
  });
}

+ (UIImage *)addWaterMarkWithImage:(UIImage *)image waterImage:(UIImage *)waterImage imgScale:(CGFloat)scale {
  
  UIGraphicsBeginImageContextWithOptions(image.size, NO, scale);
  
  [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
  
  [waterImage drawInRect:CGRectMake(0, 0, waterImage.size.width, waterImage.size.height)];
  
  UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
  
  UIGraphicsEndImageContext();
  
  return newImage;
}

+ (UIImage *)makeImageWithView:(UIView *)view withSize:(CGSize)size scale:(CGFloat)scale
{
  UIGraphicsBeginImageContextWithOptions(size, NO, scale);
  [view.layer renderInContext:UIGraphicsGetCurrentContext()];
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return image;
}

// 通过抽样缓存数据创建一个UIImage对象
+ (void)makeImageFromPixelBuffer:(CVPixelBufferRef)pixelBuffer isCrop:(BOOL)isCrop completed:(void (^)(UIImage * _Nonnull))completed {
  //  dispatch_sync(dispatch_queue_create("com.xd.takePhoto", 0), ^{
  UIImage *image = [NHPicture imageFromPixelBuffer:pixelBuffer isCrop:isCrop];
  // 释放Quartz image对象
  if (completed) {
    completed(image);
  }
  //  });
}
- (void)makeImageFromPixelBuffer:(CVPixelBufferRef)pixelBuffer isCrop:(BOOL)isCrop completed:(void (^)(UIImage * _Nonnull))completed {
  
  dispatch_sync(dispatch_queue_create("com.xd.takePhoto", 0), ^{
    //    CGImageRef quartzImage = [NHPicture imageRefFromBufferRef:pixelBuffer];
    //    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    //    CGImageRelease(quartzImage);
    UIImage *image = [NHPicture imageFromPixelBuffer:pixelBuffer isCrop:isCrop];
    // 释放Quartz image对象
    if (completed) {
      completed(image);
    }
  });
}

+ (UIImage *)imageFromPixelBuffer:(CVPixelBufferRef)pixelBufferRef isCrop:(BOOL)isCrop {
  return [[[NHPicture alloc] init] imageFromPixelBuffer:pixelBufferRef isCrop:isCrop];
}

- (UIImage *)imageFromPixelBuffer:(CVPixelBufferRef)pixelBufferRef isCrop:(BOOL)isCrop {
  CVPixelBufferLockBaseAddress(pixelBufferRef, 0);
  
  float width = CVPixelBufferGetWidth(pixelBufferRef);
  float height = CVPixelBufferGetHeight(pixelBufferRef);
  
  CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pixelBufferRef];
  
  CIContext *temporaryContext = [CIContext contextWithOptions:nil];
  CGRect rect = CGRectMake(0, 0, width, height);
  if (isCrop) {
    // //取中间部份
    rect = CGRectMake(0, (height - width) *0.5, width, width);
  }
  CGImageRef videoImage = [temporaryContext
                           createCGImage:ciImage
                           fromRect:rect];
  
  UIImage *image = [UIImage imageWithCGImage:videoImage];
  CGImageRelease(videoImage);
  CVPixelBufferUnlockBaseAddress(pixelBufferRef, 0);
  return image;
}

+ (CGImageRef)imageRefFromBufferRef:(CVPixelBufferRef)pixelBufferRef {
  return [[[NHPicture alloc] init] imageRefFromBufferRef:pixelBufferRef];
}
- (CGImageRef)imageRefFromBufferRef:(CVPixelBufferRef)bufferRef {
  // 为媒体数据设置一个CMSampleBuffer的Core Video图像缓存对象
  //  CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
  CVImageBufferRef imageBuffer = bufferRef;
  
  // 锁定pixel buffer的基地址
  CVPixelBufferLockBaseAddress(imageBuffer, 0);
  // 得到pixel buffer的基地址
  void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
  // 得到pixel buffer的行字节数
  size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
  // 得到pixel buffer的宽和高
  size_t width = CVPixelBufferGetWidth(imageBuffer);
  size_t height = CVPixelBufferGetHeight(imageBuffer);
  
  if (width == 0) {
    NSLog(@"图片生成为空");
    return nil;
  }
  
  // 创建一个依赖于设备的RGB颜色空间
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  
  // kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast
  // kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst
  CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst;
  
  // 用抽样缓存的数据创建一个位图格式的图形上下文（graphics context）对象
  CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,bytesPerRow, colorSpace, bitmapInfo);
  // 根据这个位图context中的像素数据创建一个Quartz image对象
  CGImageRef quartzImage = CGBitmapContextCreateImage(context);
  
  // 解锁pixel buffer
  CVPixelBufferUnlockBaseAddress(imageBuffer,0);
  // 释放context和颜色空间
  CGContextRelease(context);
  CGColorSpaceRelease(colorSpace);
  
  return (quartzImage);
}

+ (void)renderImageFromCVPixelBuffer:(CVPixelBufferRef)buffer toBuffer:(CVPixelBufferRef)toBuffer image:(UIImage *)image {
  CIImage *renderImage = [[CIImage alloc] initWithCVPixelBuffer:buffer];
  renderImage = [renderImage imageByCompositingOverImage:[[CIImage alloc] initWithImage:image]];
  CIContext *context = [CIContext contextWithOptions:nil];
  [context render:renderImage toCVPixelBuffer:toBuffer];
}


- (CVPixelBufferRef)modifyImage:(CVPixelBufferRef)sampleBuffer ratio:(float)ratio {
  //  @synchronized (self) {
  CVImageBufferRef imageBuffer = sampleBuffer;
  // Lock the image buffer
  CVPixelBufferLockBaseAddress(imageBuffer,0);
  
  // Get information about the image
  uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
  size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
  size_t width = CVPixelBufferGetWidth(imageBuffer);
  size_t height = CVPixelBufferGetHeight(imageBuffer);
  
  CVPixelBufferRef pxbuffer;
  NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                           [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                           [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                           [NSNumber numberWithInt:720], kCVPixelBufferWidthKey,
                           [NSNumber numberWithInt:1280], kCVPixelBufferHeightKey,
                           nil];
  NSInteger tempWidth = (NSInteger) (width / ratio);
  NSInteger tempHeight = (NSInteger) (height / ratio);
  
  NSInteger baseAddressStart = 100 + 100 * bytesPerRow;
  CVReturn status = CVPixelBufferCreateWithBytes(kCFAllocatorDefault, tempWidth, tempHeight, kCVPixelFormatType_32BGRA, &baseAddress[baseAddressStart], bytesPerRow, _myPixelBufferReleaseCallback, NULL, (__bridge CFDictionaryRef)options, &pxbuffer);
  
  if (status != 0) {
    //      CKLog(@"%d", status);
    return NULL;
  }
  
  CVPixelBufferUnlockBaseAddress(imageBuffer,0);
  
  return pxbuffer;
  //  }
}

/**
 * 调整尺寸
 */
+ (UIImage *)scaleImage:(UIImage *)image scale:(CGFloat)scale
{
  CGSize newSize = CGSizeMake(480, 480);
  UIGraphicsBeginImageContextWithOptions(newSize, NO, scale);
  
  [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
  
  UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
  
  UIGraphicsEndImageContext();
  
  return newImage;
}

@end

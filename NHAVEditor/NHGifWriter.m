//
//  NHGifWriter.m
//  NHAVEditorExamples
//
//  Created by XiuDan on 2019/8/14.
//  Copyright © 2019 XiuDan. All rights reserved.
//

#import "NHGifWriter.h"
#import <ImageIO/ImageIO.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreServices/CoreServices.h>
#import "NSDate+NH.h"
#import "NHAVEditorDefine.h"


typedef NS_ENUM(NSInteger, NHGIFQuality) {
  NHGIFQualityVeryLow  = 2,
  NHGIFQualityLow      = 3,
  NHGIFQualityMedium   = 5,
  NHGIFQualityHigh     = 7,
  NHGIFQualityOriginal = 10
};

@interface NHGifWriter ()
@property (nonatomic, copy  ) NHCompletionBlock interceptBlock;
@property (nonatomic, copy  ) NHCompletionBlock completeBlock;
@property (nonatomic, assign) NHGIFQuality gifQuality;
@property (nonatomic, assign) BOOL building;
@property (nonatomic, strong) dispatch_queue_t createGifQ;
@property (nonatomic, assign) CGImageDestinationRef destination;
@property (nonatomic, copy  ) NSDictionary *fileProperties;
@property (nonatomic, copy  ) NSDictionary *frameProperties;
@property (nonatomic, assign) NSInteger frameCount;
@property (nonatomic, assign) NSInteger currentIndex;
@end

@implementation NHGifWriter
static int nh_timeInterval = 600;


- (instancetype)initWithOutputURL:(NSURL *)url {
  self = [super init];
  if (self) {
    _createGifQ = dispatch_queue_create("com.xd.gif.queue", DISPATCH_QUEUE_SERIAL);
    _currentIndex = 0;
    [self setOutputURL:url];
    [self setLoopCount:0];
    [self setDelayTime:0.21];
  }
  return self;
}

- (void)prepareBuildGifSetFrameCount:(NSInteger)frameCount {
  _building = YES;
  _frameCount = frameCount;
  _destination = nil;
  _currentIndex = 0;
  NHLog(@"GIF合成开始,%ld帧",frameCount);
}

- (void)buildGifWithImages:(NSArray *)images completionHandler:(void (^)(BOOL ,NSURL *))handler {
  [self prepareBuildGifSetFrameCount:images.count];
  for (UIImage *image in images) {
    CGImageDestinationAddImage(self.destination, image.CGImage, (CFDictionaryRef)self.frameProperties);
  }
  [self finalizeGifWithCompletionHandler:handler];
}

- (void)buildGifWithImage:(UIImage *)image {
  if (_building) {
    //    NHLog(@"GIF 正在合成的帧数：%ld   %ld",self.currentIndex,self.frameCount);
    //    dispatch_async(_createGifQ, ^{
    if (self.currentIndex < self.frameCount) {
      CGImageDestinationAddImage(self.destination, image.CGImage, (CFDictionaryRef)self.frameProperties);
      self.currentIndex++;
    }
    //    });
  } else {
    NHLog(@"在构建gif 图前，请先调用：`beginBuildGifSetFrameCount:` 方法");
  }
}

- (void)buildGifWithCGImageRef:(CGImageRef)imageRef {
  if (_building) {
    //    NHLog(@"GIF 正在合成的帧数：%ld   %ld",self.currentIndex,self.frameCount);
    if (self.currentIndex > self.frameCount) {
      NHLog(@"GIF帧数已满,%ld帧",self.currentIndex);
    } else {
      //      dispatch_async(_createGifQ, ^{
      float width = CGImageGetWidth(imageRef);
      float height = CGImageGetHeight(imageRef);
      CGImageRetain(imageRef);
      CIImage *ciImage = [CIImage imageWithCGImage:imageRef];
      CIContext *temporaryContext = [CIContext contextWithOptions:nil];
      CGImageRef videoImage = [temporaryContext
                               createCGImage:ciImage
                               fromRect:CGRectMake(0, 0, width, height)];
      
      CGImageRef newVideoImage = createImageWithScale(videoImage, (NHGIFQualityOriginal / 10.0));
      CGImageDestinationAddImage(self.destination, newVideoImage, (CFDictionaryRef)self.frameProperties);
      self.currentIndex++;
      CGImageRelease(imageRef);
      CGImageRelease(videoImage);
      CGImageRelease(newVideoImage);
      //      });
    }
  } else {
    NHLog(@"在构建gif 图前，请先调用：`beginBuildGifSetFrameCount:` 方法");
  }
}

- (void)buildGifWithBufferRef:(CVPixelBufferRef)bufferRef clipCenter:(BOOL)clipCenter {
  if (_building) {
    NHLog(@"GIF 正在合成的帧数：%ld   %ld",self.currentIndex,self.frameCount);
    dispatch_async(_createGifQ, ^{
      CVPixelBufferLockBaseAddress(bufferRef, 0);
      float width = CVPixelBufferGetWidth(bufferRef);
      float height = CVPixelBufferGetHeight(bufferRef);
      CIImage *ciImage = [CIImage imageWithCVPixelBuffer:bufferRef];
      CIContext *temporaryContext = [CIContext contextWithOptions:nil];
      CGRect fromRect = CGRectMake(0, 0, width, width);
      if (clipCenter) {
        //取中间部份
        fromRect = CGRectMake(0, (height - width) *0.5, width, width);
      }
      CGImageRef videoImage = [temporaryContext
                               createCGImage:ciImage
                               fromRect:fromRect];
      
      CVPixelBufferUnlockBaseAddress(bufferRef, 0);
      CGImageRef newVideoImage = createImageWithScale(videoImage, (NHGIFQualityMedium / 10.0));
      if (self.currentIndex <= self.frameCount) {
        CGImageDestinationAddImage(self.destination, newVideoImage, (CFDictionaryRef)self.frameProperties);
        self.currentIndex++;
      }
      CGImageRelease(newVideoImage);
    });
  } else {
    NHLog(@"在构建gif 图前，请先调用：`beginBuildGifSetFrameCount:` 方法");
  }
}

- (void)buildGifFromVideo:(NSURL*)videoURL
             timeInterval:(NSNumber *)timeInterval
               completion:(NHCompletionBlock)completionBlock {
  
  int tempTime = timeInterval ? [timeInterval intValue] : nh_timeInterval;
  
  AVURLAsset *asset = [AVURLAsset assetWithURL:videoURL];
  
  float videoWidth = [[[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] naturalSize].width;
  float videoHeight = [[[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] naturalSize].height;
  
  NHGIFQuality optimalSize = NHGIFQualityMedium;
  if (videoWidth >= 1200 || videoHeight >= 1200)
    optimalSize = NHGIFQualityVeryLow;
  else if (videoWidth >= 800 || videoHeight >= 800)
    optimalSize = NHGIFQualityLow;
  else if (videoWidth >= 400 || videoHeight >= 400)
    optimalSize = NHGIFQualityMedium;
  else if (videoWidth < 400|| videoHeight < 400)
    optimalSize = NHGIFQualityHigh;
  
  // Get the length of the video in seconds
  float videoLength = (float)asset.duration.value/asset.duration.timescale;
  int framesPerSecond = 4;
  int frameCount = videoLength * framesPerSecond;
  
  // How far along the video track we want to move, in seconds.
  float increment = (float)videoLength / frameCount;
  
  // Add frames to the buffer
  NSMutableArray *timePoints = [NSMutableArray array];
  for (int currentFrame = 0; currentFrame < frameCount; ++currentFrame) {
    float seconds = (float)increment * currentFrame;
    CMTime time = CMTimeMakeWithSeconds(seconds, tempTime);
    [timePoints addObject:[NSValue valueWithCMTime:time]];
  }
  
  // Prepare group for firing completion block
  dispatch_group_t gifQueue = dispatch_group_create();
  dispatch_group_enter(gifQueue);
  
  __block NSURL *gifURL;
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    gifURL = [self createGIFforTimePoints:timePoints
                                  fromURL:videoURL
                               frameCount:frameCount
                             timeInterval:tempTime
                               gifQuality:optimalSize];
    dispatch_group_leave(gifQueue);
  });
  
  dispatch_group_notify(gifQueue, dispatch_get_main_queue(), ^{
    // Return GIF URL
    completionBlock(gifURL, nil);
  });
}

- (void)finalizeGifWithCompletionHandler:(void (^)(BOOL ,NSURL *))handler {
  _building = NO;
  //  dispatch_async(_createGifQ, ^{
  BOOL result = CGImageDestinationFinalize(self.destination);
  __block __typeof(self)weakself = self;
  if (![[NSThread currentThread] isMainThread]) {
    dispatch_async(dispatch_get_main_queue(), ^{
      if (handler) {
        handler(result, weakself.outputURL);
      }
    });
  } else {
    if (handler) {
      handler(result, weakself.outputURL);
    }
  }
  //  });
}

#pragma mark - Base methods
- (NSURL *)createGIFforTimePoints:(NSArray *)timePoints
                          fromURL:(NSURL *)url
                       frameCount:(int)frameCount
                     timeInterval:(int)timeInterval
                       gifQuality:(NHGIFQuality)gifQuality {
  
  // Create properties dictionaries
  NSDictionary *fileProperties = [NHGifWriter filePropertiesWithLoopCount:_loopCount];
  NSDictionary *frameProperties = [NHGifWriter framePropertiesWithDelayTime:_delayTime];
  
  NSString *fileName = [[url.path stringByDeletingPathExtension] stringByAppendingString:@".gif"];
  
  NSURL *fileURL = [NSURL fileURLWithPath:fileName];
  if (fileURL == nil)
    return nil;
  
  CGImageDestinationRef destination = CGImageDestinationCreateWithURL((__bridge CFURLRef)fileURL, kUTTypeGIF , frameCount, NULL);
  CGImageDestinationSetProperties(destination, (CFDictionaryRef)fileProperties);
  
  AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
  AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
  generator.appliesPreferredTrackTransform = YES;
  
  CMTime tol = CMTimeMakeWithSeconds(_delayTime, timeInterval);
  generator.requestedTimeToleranceBefore = tol;
  generator.requestedTimeToleranceAfter = tol;
  
  NSError *error = nil;
  CGImageRef previousImageRefCopy = nil;
  for (NSValue *time in timePoints) {
    CGImageRef imageRef;
    
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
    float size = gifQuality / 10.0;
    if (size != 1.0) {
      imageRef = createImageWithScale([generator copyCGImageAtTime:[time CMTimeValue] actualTime:nil error:&error], size);
    } else {
      imageRef = [generator copyCGImageAtTime:[time CMTimeValue] actualTime:nil error:&error];
    }
#elif TARGET_OS_MAC
    imageRef = [generator copyCGImageAtTime:[time CMTimeValue] actualTime:nil error:&error];
#endif
    
    if (error) {
      NSLog(@"Error copying image: %@", error);
    }
    if (imageRef) {
      CGImageRelease(previousImageRefCopy);
      previousImageRefCopy = CGImageCreateCopy(imageRef);
    } else if (previousImageRefCopy) {
      imageRef = CGImageCreateCopy(previousImageRefCopy);
    } else {
      NSLog(@"Error copying image and no previous frames to duplicate");
      return nil;
    }
    CGImageDestinationAddImage(destination, imageRef, (CFDictionaryRef)frameProperties);
    CGImageRelease(imageRef);
  }
  CGImageRelease(previousImageRefCopy);
  
  // Finalize the GIF
  if (!CGImageDestinationFinalize(destination)) {
    NSLog(@"Failed to finalize GIF destination: %@", error);
    if (destination != nil) {
      CFRelease(destination);
    }
    return nil;
  }
  CFRelease(destination);
  
  return fileURL;
}

#pragma mark - Helpers

CGImageRef createImageWithScale(CGImageRef imageRef, float scale) {
  
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
  
  CGSize newSize = CGSizeMake(CGImageGetWidth(imageRef)*scale, CGImageGetHeight(imageRef)*scale);
  CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
  
  UIGraphicsBeginImageContextWithOptions(newSize, NO, 1);
  CGContextRef context = UIGraphicsGetCurrentContext();
  if (!context) {
    return nil;
  }
  
  // Set the quality level to use when rescaling
  CGContextSetInterpolationQuality(context, kCGInterpolationLow);
  CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, newSize.height);
  
  CGContextConcatCTM(context, flipVertical);
  // Draw into the context; this scales the image
  CGContextDrawImage(context, newRect, imageRef);
  
  //Release old image
  CFRelease(imageRef);
  // Get the resized image from the context and a UIImage
  imageRef = CGBitmapContextCreateImage(context);
  
  UIGraphicsEndImageContext();
#endif
  
  return imageRef;
}


#pragma mark - private method
- (void)setDelayTime:(float)delayTime {
  _delayTime = delayTime;
  _frameProperties = [NHGifWriter framePropertiesWithDelayTime:self.delayTime];
}

- (void)setLoopCount:(int)loopCount {
  _loopCount = loopCount;
  _fileProperties = [NHGifWriter filePropertiesWithLoopCount:self.loopCount];
}

- (CGImageDestinationRef)destination {
  if (!_destination) {
    _destination = CGImageDestinationCreateWithURL((__bridge CFURLRef)self.outputURL,
                                                   kUTTypeGIF,
                                                   self.frameCount,
                                                   NULL);
    CGImageDestinationSetProperties(_destination, (CFDictionaryRef)self.fileProperties);
  }
  return _destination;
}

- (void)setOutputURL:(NSURL *)outputURL {
  if (!outputURL) {
    NSString *timeEncodedFileName = [NSString stringWithFormat:@"%@.gif", [NSDate getNowTimeTimestamp]];
    NSString *temporaryFile = [NSTemporaryDirectory() stringByAppendingString:timeEncodedFileName];
    NSURL *fileURL = [NSURL fileURLWithPath:temporaryFile];
    _outputURL = fileURL;
  } else {
    _outputURL = outputURL;
  }
}

+ (NSDictionary *)filePropertiesWithLoopCount:(int)loopCount {
  return @{(NSString *)kCGImagePropertyGIFDictionary:
             @{(NSString *)kCGImagePropertyGIFLoopCount: @(loopCount)}
           };
}

+ (NSDictionary *)framePropertiesWithDelayTime:(float)delayTime {
  
  return @{(NSString *)kCGImagePropertyGIFDictionary:
             @{(NSString *)kCGImagePropertyGIFDelayTime: @(delayTime)},
           (NSString *)kCGImagePropertyColorModel:(NSString *)kCGImagePropertyColorModelRGB
           };
}


@end

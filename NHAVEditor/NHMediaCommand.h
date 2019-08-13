//
//  NHMediaCommand.h
//  NHAVEditor
//
//  Created by XiuDan on 2019/8/3.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "NHMediaCommandProtocol.h"
#import "NHMediaConfig.h"


NS_ASSUME_NONNULL_BEGIN

@interface NHMediaCommand : NSObject
@property (nonatomic, strong) AVMutableComposition *mComposition;
@property (nonatomic, strong) AVMutableVideoComposition *mVideoComposition;
@property (nonatomic, strong) AVMutableAudioMix *mAudioMix;
@property (nonatomic, weak) id<NHMediaCommandProtocol> delegate;

/**
 初始化

 @param composition composition description
 @param videoComposition videoComposition description
 @param audioMix audioMix description
 @return instance NHMediaCommand
 */
+ (instancetype)commandWithComposition:(AVMutableComposition*)composition
                      videoComposition:(AVMutableVideoComposition*)videoComposition
                              audioMix:(AVMutableAudioMix*)audioMix;

- (instancetype)initWithComposition:(AVMutableComposition*)composition
                   videoComposition:(AVMutableVideoComposition*)videoComposition
                           audioMix:(AVMutableAudioMix*)audioMix;


/**
 执行合成操作

 @param asset asset description
 */
- (void)performWithAsset:(AVAsset*)asset;

@end

NS_ASSUME_NONNULL_END

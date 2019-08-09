//
//  NHMediaCommand.m
//  NHAVEditor
//
//  Created by XiuDan on 2019/8/3.
//

#import "NHMediaCommand.h"
#import "NSDate+NH.h"

@implementation NHMediaCommand

- (instancetype)initWithComposition:(AVMutableComposition *)composition
                   videoComposition:(AVMutableVideoComposition *)videoComposition
                           audioMix:(AVMutableAudioMix *)audioMix {
  self = [super init];
  if(self != nil) {
    self.mComposition = composition;
    self.mVideoComposition = videoComposition;
    self.mAudioMix = audioMix;
    [self setOutputURL:nil];
  }
  return self;
}

+ (instancetype)commandWithComposition:(AVMutableComposition *)composition
                      videoComposition:(AVMutableVideoComposition *)videoComposition
                              audioMix:(AVMutableAudioMix *)audioMix {
  return [[NHMediaCommand alloc] initWithComposition:composition
                                    videoComposition:videoComposition
                                            audioMix:audioMix];
}

- (void)setOutputURL:(NSURL *)outputURL {
  
}

- (void)performWithAsset:(AVAsset *)asset {
  
}

@end

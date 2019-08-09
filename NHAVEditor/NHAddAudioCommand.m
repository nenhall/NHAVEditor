//
//  NHAddAudioCommand.m
//  NHAVEditorExamples
//
//  Created by XiuDan on 2019/8/3.
//  Copyright © 2019 XiuDan. All rights reserved.
//

#import "NHAddAudioCommand.h"

@implementation NHAddAudioCommand

+ (instancetype)commandWithComposition:(AVMutableComposition *)composition
                      videoComposition:(AVMutableVideoComposition *)videoComposition
                              audioMix:(AVMutableAudioMix *)audioMix {
  NHAddAudioCommand *audio = [[NHAddAudioCommand alloc] initWithComposition:composition
                                                           videoComposition:videoComposition
                                                                   audioMix:audioMix];
  return audio;
}





@end

//
//  NHVideoConfiguration.m
//  NHPushStreamSDK
//
//  Created by nenhall on 2019/2/18.
//  Copyright © 2019 neghao. All rights reserved.
//

#import "NHVideoConfiguration.h"


@implementation NHVideoConfiguration

+ (instancetype)defaultConfiguration {
    
    NHVideoConfiguration *videoConfiguration = [[NHVideoConfiguration alloc] init];
    videoConfiguration.videoSize = CGSizeMake(720, 1280);
    videoConfiguration.frameRate = 30;
    videoConfiguration.maxKeyframeInterval = 60;
    videoConfiguration.bitrate = 1536*1000;
    videoConfiguration.profileLevel = @"";
                                                
    return videoConfiguration;
}

@end

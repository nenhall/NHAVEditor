//
//  NHVideoConfiguration.h
//  NHPushStreamSDK
//
//  Created by nenhall on 2019/2/18.
//  Copyright © 2019 neghao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NHVideoConfiguration : NSObject
@property (assign, nonatomic) CGSize videoSize;
@property (assign, nonatomic) CGFloat frameRate; /**< 视频码率 */
@property (assign, nonatomic) CGFloat maxKeyframeInterval; /**< 最大帧率 */
@property (assign, nonatomic) CGFloat bitrate; /**< 视频码率 */
@property (copy,   nonatomic) NSString *profileLevel;



/**
 默认配置
 videoSize = CGSizeMake(720, 1280);
 frameRate = 30;
 maxKeyframeInterval = 60;
 bitrate = 1536*1000;
 profileLevel = @"";
 */
 + (instancetype)defaultConfiguration;



@end

NS_ASSUME_NONNULL_END

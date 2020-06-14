//
//  NHDisplayView.h
//  NHAVEditorExamples
//
//  Created by XiuDan on 2019/8/3.
//  Copyright © 2019 XiuDan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NHDisplayView : UIView
@property (nonatomic, copy) NSURL *playUrl;
@property (nonatomic, assign, readonly) CGSize videoSize;

- (void)play;

- (void)pause;

- (void)stop;

@end

NS_ASSUME_NONNULL_END

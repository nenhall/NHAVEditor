//
//  NHDisplayView.m
//  NHAVEditorExamples
//
//  Created by XiuDan on 2019/8/3.
//  Copyright © 2019 XiuDan. All rights reserved.
//

#import "NHDisplayView.h"
#import <AVFoundation/AVFoundation.h>

@interface NHDisplayView ()
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVAsset *asset;
@property (nonatomic, strong) AVPlayerItem *currentPlayItem;
@property (nonatomic, weak) AVPlayerLayer *playerLayer;
@property (nonatomic, weak) IBOutlet UIButton *playButton;
@property (nonatomic, assign) CGSize videoSize;

@end

@implementation NHDisplayView


- (instancetype)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    
  }
  return self;
}

- (void)awakeFromNib {
  [super awakeFromNib];
  
  self.playButton.layer.zPosition = 1;
}

- (void)setPlayUrl:(NSURL *)playUrl {
  _playUrl = playUrl;
  [self resetPlayer];
}

- (void)resetPlayer {
  [_player pause];
  
  _asset = [AVAsset assetWithURL:_playUrl];
  NSArray *assetKeys = @[@"playable", @"hasProtectedContent"];
  NSArray *loadkeys = @[@"duration", @"tracks", @"commonMetadata"];
  
  __weak __typeof(self)ws = self;
  [_asset loadValuesAsynchronouslyForKeys:loadkeys completionHandler:^{
    dispatch_sync(dispatch_get_main_queue(), ^{
      AVPlayerItem *newPlayItem = [[AVPlayerItem alloc] initWithAsset:ws.asset automaticallyLoadedAssetKeys:assetKeys];
      ws.currentPlayItem = newPlayItem;
      if (!ws.player) {
        ws.player = [[AVPlayer alloc] initWithPlayerItem:ws.currentPlayItem];
        AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:ws.player];
        playerLayer.frame = ws.bounds;
        ws.playerLayer = playerLayer;
        [ws.layer addSublayer:playerLayer];
      } else {
        [ws.player replaceCurrentItemWithPlayerItem:newPlayItem];
      }
      if (@available(iOS 10.0, *)) {
        [ws.player reasonForWaitingToPlay];
      }
    });

    for (AVAssetTrack *track in ws.asset.tracks) {
      if ([track.mediaType isEqualToString:AVMediaTypeVideo]) {
        ws.videoSize = track.naturalSize;
      }
    }
  }];
}

- (IBAction)playButtonAction:(UIButton *)sender {
  sender.selected = !sender.selected;

  if (sender.selected) {
    [self play];
  } else {
    [self pause];
  }
  sender.hidden = YES;
}

- (void)play {
  [_player play];
}

- (void)pause {
  [_player pause];
}

- (void)stop {
  [_player pause];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
  self.playButton.hidden = !self.playButton.hidden;
  
}

- (void)layoutSubviews {
  [super layoutSubviews];
  
  _playerLayer.frame = self.bounds;

}

@end

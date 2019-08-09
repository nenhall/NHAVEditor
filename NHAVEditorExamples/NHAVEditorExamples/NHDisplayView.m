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
  [_playerLayer removeFromSuperlayer];
  
  _asset = [AVAsset assetWithURL:_playUrl];
  NSArray *assetKeys = @[@"playable",
                         @"hasProtectedContent"];
  _currentPlayItem = [[AVPlayerItem alloc] initWithAsset:_asset automaticallyLoadedAssetKeys:assetKeys];
  
  
  if (!_player) {
    _player = [[AVPlayer alloc] initWithPlayerItem:_currentPlayItem];
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    playerLayer.frame = self.bounds;
    [self.layer addSublayer:playerLayer];
    _playerLayer = playerLayer;
    
  } else {
    [_player replaceCurrentItemWithPlayerItem:_currentPlayItem];
  }
  
  for (AVAssetTrack *track in _asset.tracks) {
    if ([track.mediaType isEqualToString:AVMediaTypeVideo]) {
      _videoSize = track.naturalSize;
    }
  }
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

@end

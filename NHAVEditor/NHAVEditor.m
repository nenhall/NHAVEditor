//
//  NHAVEditor.m
//  MBProgressHUD
//
//  Created by XiuDan on 2019/8/3.
//

#import "NHAVEditor.h"
#import "NHMediaCommandProtocol.h"
#import "NHAddAudioCommand.h"
#import "NHAddWatermarkCommand.h"
#import "NHMediaExportCommand.h"


@interface NHAVEditor ()<NHMediaCommandProtocol>
@property (nonatomic, copy  ) NSURL *audioUrl;
@property (nonatomic, strong) CALayer *waterMLayer;
@property (nonatomic, copy  ) NSURL *_Nullable outputURL;

/**
 合成中状态
 */
@property (nonatomic, assign) BOOL isCompositioning;

/**
 是否取消了合成
 */
@property (nonatomic, assign) BOOL isCancelComposition;
@property (nonatomic, strong) dispatch_queue_t compositionQueue;
@property (nonatomic, strong) AVAsset *vInputAsset;
@property (nonatomic, strong) AVMutableComposition *composition;
@property (nonatomic, strong) AVMutableVideoComposition *videoComposition;
@property (nonatomic, strong) AVMutableAudioMix *audioMix;
@property (nonatomic, strong) NHAddAudioCommand *audioCommand;
@property (nonatomic, strong) NHAddWatermarkCommand *watermarkCommand;
@property (nonatomic, strong) NHMediaExportCommand *exportCommand;
@property (nonatomic, copy  ) NHEditCompletedBlock mediaCommandCompletedBlock;

@end

@implementation NHAVEditor

- (instancetype)init {
  self = [super init];
  if (self) {
    [self initAvEditorConfig];
  }
  return self;
}

- (instancetype)initWithVideoURL:(NSURL *)videoURL {
  self = [super init];
  if (self) {
    [self setInputVideoURL:videoURL];
    [self initAvEditorConfig];
  }
  return self;
}

+ (instancetype)editorVideoURL:(NSURL *)videoURL {
  NHAVEditor *avEditor = [[NHAVEditor alloc] initWithVideoURL:videoURL];
  return avEditor;
}

#pragma mark - private method
#pragma mark -
- (void)initAvEditorConfig {
  _compositionQueue = dispatch_queue_create("com.nh.aveditor.composition", DISPATCH_QUEUE_SERIAL);

  
}

- (void)setInputVideoURL:(NSURL *)inputVideoURL {
  if (inputVideoURL) {
    _vInputAsset = [AVAsset assetWithURL:inputVideoURL];
  } else {
    _vInputAsset = nil;
  }
}


#pragma mark - media command
#pragma mark -
- (void)addWatermarkWithLayer:(CALayer *)layer completedBlock:(NHEditCompletedBlock)completedBlock {
  if (completedBlock) {
    self.mediaCommandCompletedBlock = completedBlock;
  }
  _waterMLayer = layer;
  [self addWatermark];
}

- (void)addAudioWithAudioURL:(NSURL *)audioURL completedBlock:(NHEditCompletedBlock)completedBlock {
  if (completedBlock) {
    self.mediaCommandCompletedBlock = completedBlock;
  }
  _audioUrl = audioURL;
  [self addAudio];
}

- (void)exportMediaWithOutputURL:(NSURL *_Nullable)outputURL
                      presetName:(NSString *)presetName
                  completedBlock:(NHEditCompletedBlock)completedBlock {
  _outputURL = outputURL;
  if (completedBlock) {
    self.mediaCommandCompletedBlock = completedBlock;
  }
  [self exportMedia:outputURL];
}

- (void)addAudio {
  _isCancelComposition = NO;
  _audioCommand = [NHAddAudioCommand commandWithComposition:_composition
                                           videoComposition:_videoComposition
                                                   audioMix:_audioMix];
  _audioCommand.audioURL = _audioUrl;
  [_audioCommand performWithAsset:_vInputAsset];
}

- (void)addWatermark {
  _isCancelComposition = NO;
  _watermarkCommand = [NHAddWatermarkCommand commandWithComposition:_composition
                                                   videoComposition:_videoComposition
                                                           audioMix:_audioMix];
  _watermarkCommand.watermarkLayer = _waterMLayer;
  
}

- (void)exportMedia:(NSURL *)outputURL {
  if (_isCancelComposition) {
    _isCompositioning = NO;
    _isCancelComposition = NO;
    return;
  }
  _exportCommand = [NHMediaExportCommand commandWithComposition:_composition
                                               videoComposition:_videoComposition
                                                       audioMix:_audioMix];
  _exportCommand.outputURL = outputURL;
}

- (void)cancelComposition {
  _isCancelComposition = YES;
}


#pragma mark - NHMediaCommandProtocol
#pragma mark -
- (void)mediaCompositioning:(NHMediaCommand *)editor progress:(CGFloat)progress {
  self.audioMix = editor.mAudioMix;
  self.composition = editor.mComposition;
  self.videoComposition = editor.mVideoComposition;
  self.currentProgress = progress;
  if (self.delegate && [self.delegate respondsToSelector:@selector(editorCompositioning:progress:)]) {
    [self.delegate editorCompositioning:self progress:progress];
  }
}

- (void)mediaCompositioned:(NHMediaCommand *)editor outputURL:(NSURL *)outputURL error:(NSError *)error {
  self.audioMix = editor.mAudioMix;
  self.composition = editor.mComposition;
  self.videoComposition = editor.mVideoComposition;
  
  if (_mediaCommandCompletedBlock) {
    _mediaCommandCompletedBlock(outputURL, error);
  }
  if (self.delegate && [self.delegate respondsToSelector:@selector(editorCompositioned:outputURL:error:)]) {
    [self.delegate editorCompositioned:self outputURL:outputURL error:error];
  }
}

- (void)mediaExportCompleted:(NHMediaCommand *)editor outputURL:(NSURL *)outputURL error:(NSError *)error {
  self.audioMix = editor.mAudioMix;
  self.composition = editor.mComposition;
  self.videoComposition = editor.mVideoComposition;
  
  if (_mediaCommandCompletedBlock) {
    _mediaCommandCompletedBlock(outputURL, error);
  }
  if (self.delegate && [self.delegate respondsToSelector:@selector(editorExportCompleted:outputURL:error:)]) {
    [self.delegate editorExportCompleted:self outputURL:outputURL error:error];
  }
}




@end

//
//  NHAVEditor.h
//  MBProgressHUD
//
//  Created by XiuDan on 2019/8/3.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NHAVEditorProtocol.h"
#import <AVFoundation/AVFoundation.h>


NS_ASSUME_NONNULL_BEGIN

typedef void(^_Nullable NHEditCompletedBlock)(NSURL *_Nullable mediaUrl, NSError *_Nullable error);

@interface NHAVEditor : NSObject
@property (nonatomic, weak) id<NHAVEditorProtocol> delegate;
/** 是否正在合成 */
@property (nonatomic, assign, readonly) BOOL isCompositioning;
/** 当前合成进度 */
@property (nonatomic, assign) CGFloat currentProgress;
/** 视频源的地址，只支持本地视频 */
@property (nonatomic, copy) NSURL *inputVideoURL;

/**
 初始化

 @param videoURL 视频源的地址，只支持本地视频
 @return return NHAVEditor instance description
 */
- (instancetype)initWithVideoURL:(NSURL *)videoURL;
+ (instancetype)editorVideoURL:(NSURL *)videoURL;


/**
 添加背景音乐
 property:`currentProgress`获取当前进度
 
 @param audioURL audioURL description
 @param completedBlock completedBlock description
 */
- (void)addAudioWithAudioURL:(NSURL *)audioURL completedBlock:(NHEditCompletedBlock)completedBlock;

/**
 添加水印
 property:`currentProgress`获取当前进度
 
 @param layer 一个画好的 CALayer
 @param completedBlock completedBlock description
 */
- (void)addWatermarkWithLayer:(CALayer *)layer completedBlock:(NHEditCompletedBlock)completedBlock;

/**
 导出视频
 property:`currentProgress`获取当前进度

 @param outputURL 导出地址，不设：默认导出到 `tmp` 目录下，以当前时间戳为文件名
 @param presetName 导出视频分辨率，eg. : AVAssetExportPreset1280x720 默认为视频的原尺寸
 @param completedBlock completedBlock description
 */
- (void)exportMediaWithOutputURL:(NSURL *_Nullable)outputURL
                      presetName:(NSString *_Nullable)presetName
                  outputFileType:(AVFileType)outputFileType
                  completedBlock:(NHEditCompletedBlock)completedBlock;


/**
 取消合成
 */
- (void)cancelComposition;



@end

NS_ASSUME_NONNULL_END

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
#import "NHMediaConfig.h"


NS_ASSUME_NONNULL_BEGIN
@class NHAddAudioCommand;

typedef void(^_Nullable NHEditCompletedBlock)(NSURL *_Nullable outputURL, NSError *_Nullable error);

@interface NHAVEditor : NSObject
@property (nonatomic, weak) id<NHAVEditorProtocol> delegate;

/**
 是否正在合成
 */
@property (nonatomic, assign, readonly) BOOL isCompositioning;

/**
 当前合成进度
 */
@property (nonatomic, assign, readonly) CGFloat currentProgress;

/**
 视频源的地址，只支持本地视频
 */
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
 @param customConfig 自定义插入音频的配置，传空则使用默认配置，详情参考：NHAudioConfig.h
 @param completedBlock completedBlock description
 */
- (void)addAudioWithAudioURL:(NSURL *)audioURL
                customConfig:(void(^_Nullable)(NHAudioConfig *config))customConfig
              completedBlock:(NHEditCompletedBlock)completedBlock;

/**
 添加水印
 property:`currentProgress`获取当前进度
 
 @param layer 一个画好的 CALayer
 @param customConfig 传空则使用默认配置，详情参考：NHWatermarkConfig.h
 @param completedBlock completedBlock description
 */
- (void)addWatermarkWithLayer:(CALayer *)layer
                 customConfig:(void(^_Nullable)(NHWatermarkConfig *config))customConfig
               completedBlock:(NHEditCompletedBlock)completedBlock;

/**
 导出视频
 可通过 @property:`currentProgress` 获取当前进度

 @param outputURL 视频导出地址，不设：默认导出到 `tmp` 目录下，以当前时间戳为文件名
 @param customConfig
 1.视频导出分辨率 default：AVAssetExportPresetPassthrough
 2.视频导出的文件类型 default：AVFileTypeQuickTimeMovie
 3.传空则使用默认配置，详情参考：NHAudioConfig.h
 @param completedBlock completedBlock description
 */
- (void)exportMediaWithOutputURL:(NSURL *_Nullable)outputURL
                    customConfig:(void(^_Nullable)(NHExporyConfig *config))customConfig
                  completedBlock:(NHEditCompletedBlock)completedBlock;

/**
 每重新开始合成前，都需要调用下此方法，用于重置历史的水印和音频信息
 */
- (void)resetBeforeRestartingComposition;

/**
 取消合成
 */
- (void)cancelComposition;



@end

NS_ASSUME_NONNULL_END

//
//  NHAVEditorProtocol.h
//  NHAVEditorExamples
//
//  Created by XiuDan on 2019/8/3.
//  Copyright © 2019 XiuDan. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN
@class NHAVEditor;

typedef enum : NSUInteger {
  NHAVEditorTypeUnknown,   /**< 未知 */
  NHAVEditorTypeWatermark, /**< 添加水印 */
  NHAVEditorTypeAudio,     /**< 添加音频 */
  NHAVEditorTypeExport,    /**< 导出 */
} NHAVEditorType; /**< 编辑的类型 */

@protocol NHAVEditorProtocol <NSObject>
@optional;


/**
 合成中

 @param editor editor description
 @param progress 进度
 @param type 合成/编辑类型，可以用此来区分当前执行的是那个任务
 */
- (void)editorCompositioning:(NHAVEditor *)editor progress:(CGFloat)progress type:(NHAVEditorType)type;

/**
 合成完成

 @param editor editor description
 @param type 合成/编辑类型，可以用此来区分当前执行的是那个任务
 @param error 错误详情，如果有
 */
- (void)editorCompositioned:(NHAVEditor *)editor type:(NHAVEditorType)type error:(NSError *_Nullable)error;

/**
 导出中

 @param editor editor description
 @param progress 导出进度
 @param type 合成/编辑类型，可以用此来区分当前执行的是那个任务
 */
- (void)editorExporting:(NHAVEditor *)editor
               progress:(CGFloat)progress
                   type:(NHAVEditorType)type;

/**
 导出完成

 @param editor editor description
 @param outputURL 导出的地址，在导出成功时
 @param type 合成/编辑类型，可以用此来区分当前执行的是那个任务
 @param error 错误详情，如果有
 */
- (void)editorExported:(NHAVEditor *)editor
             outputURL:(NSURL *_Nullable)outputURL
                  type:(NHAVEditorType)type
                 error:(NSError *_Nullable)error;

@end

NS_ASSUME_NONNULL_END

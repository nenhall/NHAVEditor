//
//  NHMediaCommandProtocol.h
//  NHAVEditorExamples
//
//  Created by XiuDan on 2019/8/3.
//  Copyright © 2019 XiuDan. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class NHMediaCommand;

@protocol NHMediaCommandProtocol <NSObject>
@optional;

/**
 合成中

 @param editor editor description
 @param progress progress description
 */
- (void)mediaCompositioning:(NHMediaCommand *)editor progress:(CGFloat)progress;

/**
 合成完成

 @param editor editor description
 @param error 错误信息，如果有
 */
- (void)mediaCompositioned:(NHMediaCommand *)editor error:(NSError *_Nullable)error;

/**
 导出完成

 @param editor editor description
 @param outputURL 导出地址，如果导出成功
 @param error 错误信息，如果有
 */
- (void)mediaExportCompleted:(NHMediaCommand *)editor outputURL:(NSURL *_Nullable)outputURL error:(NSError *_Nullable)error;

@end

NS_ASSUME_NONNULL_END

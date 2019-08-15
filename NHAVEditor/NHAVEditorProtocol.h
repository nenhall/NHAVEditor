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

typedef NS_ENUM(NSUInteger, NHAVEditorType) {
  NHAVEditorTypeAddAudio,
  NHAVEditorTypeAddWatermark,
  NHAVEditorTypeExport,
};

@protocol NHAVEditorProtocol <NSObject>
@optional;

- (void)editorCompositioning:(NHAVEditor *)editor progress:(CGFloat)progress;

- (void)editorCompositioned:(NHAVEditor *)editor error:(NSError *_Nullable)error;

- (void)editorExportCompleted:(NHAVEditor *)editor outputURL:(NSURL *_Nullable)outputURL error:(NSError *_Nullable)error;

@end

NS_ASSUME_NONNULL_END

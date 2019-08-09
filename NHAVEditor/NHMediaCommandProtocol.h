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

- (void)mediaCompositioning:(NHMediaCommand *)editor progress:(CGFloat)progress;

- (void)mediaCompositioned:(NHMediaCommand *)editor outputURL:(NSURL *_Nullable)outputURL error:(NSError *_Nullable)error;

- (void)mediaExportCompleted:(NHMediaCommand *)editor outputURL:(NSURL *_Nullable)outputURL error:(NSError *_Nullable)error;

@end

NS_ASSUME_NONNULL_END

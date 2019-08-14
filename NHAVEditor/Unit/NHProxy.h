//
//  NHProxy.h
//  NHAVEditorExamples
//
//  Created by XiuDan on 2019/8/14.
//  Copyright © 2019 XiuDan. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NHProxy : NSProxy

+ (id)proxyWithTarget:(id)target;
@property (weak, nonatomic, readonly) id target;

@end

NS_ASSUME_NONNULL_END

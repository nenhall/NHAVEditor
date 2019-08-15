//
//  NHAVEditorHeader.h
//  NHAVEditorExamples
//
//  Created by XiuDan on 2019/8/9.
//  Copyright © 2019 XiuDan. All rights reserved.
//

#ifndef NHAVEditorHeader_h
#define NHAVEditorHeader_h

///*****************************自定义的 NSLog******************************/
#ifdef DEBUG
#define NHLog(fmt, ...) NSLog((@"%@:%d " fmt), [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, ##__VA_ARGS__)
#else
#define NHLog(...)
#endif


//错误
#define ERR_INFO(Description,FailureReason,RecoverySuggestion)  [NSDictionary dictionaryWithObjectsAndKeys:(Description),NSLocalizedDescriptionKey,\
(FailureReason),NSLocalizedFailureReasonErrorKey,\
(RecoverySuggestion),NSLocalizedRecoverySuggestionErrorKey, nil]

#define NH_ERROR(statusCode,info)  [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:(statusCode) userInfo:(info)]


/** 主线程do */
NS_INLINE void nh_editor_safe_do_mainQ(dispatch_block_t block) {
  if (![[NSThread currentThread] isMainThread]) {
    dispatch_async(dispatch_get_main_queue(), block);
  } else {
    block();
  }
}

#define nh_editor_safe_block(block,...)\
if (block) {\
block(__VA_ARGS__);\
}

#endif /* NHAVEditorHeader_h */

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
#define NHLog(fmt, ...) NSLog((@"%s" fmt), __PRETTY_FUNCTION__, ##__VA_ARGS__)
#else
#define NHLog(...)
#endif


//错误
#define ERR_INFO(Description,FailureReason,RecoverySuggestion)  [NSDictionary dictionaryWithObjectsAndKeys:(Description),NSLocalizedDescriptionKey,\
(FailureReason),NSLocalizedFailureReasonErrorKey,\
(RecoverySuggestion),NSLocalizedRecoverySuggestionErrorKey, nil]

#define NH_ERROR(statusCode,info)  [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:(statusCode) userInfo:(info)]

#endif /* NHAVEditorHeader_h */

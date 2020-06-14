#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "NHAddAudioCommand.h"
#import "NHAddWatermarkCommand.h"
#import "NHAVEditor.h"
#import "NHAVEditorProtocol.h"
#import "NHGifWriter.h"
#import "NHMediaCommand.h"
#import "NHMediaCommandProtocol.h"
#import "NHMediaExportCommand.h"
#import "NHMediaWriter.h"
#import "NHPicture.h"
#import "NHAVEditorDefine.h"
#import "NHMediaConfig.h"
#import "NHProxy.h"
#import "NHThread.h"
#import "NHTimer.h"
#import "NSData+NH.h"
#import "NSDate+NH.h"

FOUNDATION_EXPORT double NHAVEditorVersionNumber;
FOUNDATION_EXPORT const unsigned char NHAVEditorVersionString[];


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

#import "AZLDrawView.h"
#import "UIBezierPath+AZLSignaturePath.h"
#import "AZLPointHelper.h"
#import "AZLWeightPoint.h"
#import "AZLBasePathProvider.h"
#import "AZLPencilPathProvider.h"
#import "AZLPenPathProvider.h"

FOUNDATION_EXPORT double AZLDrawVersionNumber;
FOUNDATION_EXPORT const unsigned char AZLDrawVersionString[];


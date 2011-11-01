//
//  BMTypes.h
//  BingMaps
//
//  Copyright (c) 2011 Microsoft Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

enum {
    BMMapModeRoad = 0,
    BMMapModeAerial,
    BMMapModeAerialWithLabels,
};
typedef NSUInteger BMMapMode;

UIKIT_EXTERN NSString *BMErrorDomain;

enum BMErrorCode {
    BMErrorUnknown = 1,
    BMErrorServerFailure,
    BMErrorLoadingThrottled,
    BMErrorEntityNotFound,
    BMErrorAuthenticationFailure,
};

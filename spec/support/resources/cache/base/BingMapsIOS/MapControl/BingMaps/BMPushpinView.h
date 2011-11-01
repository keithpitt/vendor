//
//  BMPushpinView.h
//  BingMaps
//
//  Copyright (c) 2011 Microsoft Corporation. All rights reserved.
//

#import "BMMarkerView.h"

/** \enum BMPushpinColor */
typedef enum BMPushpinColor{
    BMPushpinColorOrange = 0, /**< enum value 1 */ 
    BMPushpinColorGreen,/**< enum value 2 */ 
    BMPushpinColorRed,/**< enum value 3 */ 
	BMPushpinColorBlue,/**< enum value 4 */ 
	BMPushpinColorYellow,/**< enum value 5 */ 
	BMPushpinColorPurple,/**< enum value 6 */ 
} BMPushpinColor;

@class BMPushpinViewInternal;

@interface BMPushpinView : BMMarkerView
{
@private
    BMPushpinViewInternal *_pinInternal;
}

@property (nonatomic) BMPushpinColor pinColor;
@property (nonatomic) BOOL animatesDrop;

@end

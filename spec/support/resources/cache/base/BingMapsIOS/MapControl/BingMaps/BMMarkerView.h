//
//  BMMarkerView.h
//  BingMaps
//
//  Copyright (c) 2011 Microsoft Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

// Post this notification to re-query callout information.
UIKIT_EXTERN NSString *BMMarkerCalloutInfoDidChangeNotification;

@class BMMarkerViewInternal;
@protocol BMMarker;

@interface BMMarkerView : UIView
{
@private
    BMMarkerViewInternal *_internal;
}

- (id)initWithMarker:(id <BMMarker>)marker reuseIdentifier:(NSString *)reuseIdentifier;

@property (nonatomic, readonly) NSString *reuseIdentifier;

// Classes that override must call super.
- (void)prepareForReuse;

@property (nonatomic, retain) id <BMMarker> marker;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic) CGPoint centerOffset;
@property (nonatomic) CGPoint calloutOffset;
/** @brief A Boolean value indicating whether the marker is enabled.
 *
 * The default value of this property is YES. 
 * If the value of this property is NO, the marker view ignores touch events and cannot be selected. 
 */
@property (nonatomic, getter=isEnabled) BOOL enabled;
/** @brief A Boolean value indicating whether the annotation view is currently selected.
 * You should not set the value of this property directly. If the property contains YES, the marker view is displaying a callout bubble.
  */
@property (nonatomic, getter=isSelected) BOOL selected;
@property (nonatomic) BOOL canShowCallout;
@property (retain, nonatomic) UIView *calloutAccessoryView1;
@property (retain, nonatomic) UIView *calloutAccessoryView2;
- (void)setSelected:(BOOL)selected animated:(BOOL)animated;
@end

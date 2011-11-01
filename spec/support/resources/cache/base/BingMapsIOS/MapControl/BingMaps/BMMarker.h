//
//  BMMarker.h
//  BingMaps
//
//  Copyright (c) 2011 Microsoft Corporation. All rights reserved.
//

/**
 * @brief The BMMarker protocol models data which can be used to add markers to the map.
 *
 * The marker protocol is implemented in an object that can be represented as a marker on a map view.
 * This protocol does not specify the marker pin itself, as this can be done with a custom BMMarkerView.
 * The coordinate property is required, however the title and subtitle of the callout are optional.
 */
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@protocol BMMarker <NSObject>

@required
/**
 * @brief Latitude and longitude of the marker.
 *
 */
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

@optional
/**
 * @brief Returns the marker's title.
 *
 * @return String containing the title.
 */
- (NSString*)title;

/**
 * @brief Returns the marker's subtitle.
 *
 * @return String containing the subtitle.
 */
- (NSString*)subtitle;
@end

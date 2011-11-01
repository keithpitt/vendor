//
//  BMGeometry.h
//  BingMaps
//
//  Copyright (c) 2011 Microsoft Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

/** @brief BMCoordinateSpan defines the area spanned by a BMCoordinateRegion.
 *
 * @param latitudeDelta The delta between the north-most and south-most points of the span
 * @param longitudeDelta The delta between the east-most and west-most points of the span
 *
 * @sa BMCoordinateRegion
 */
typedef struct {
    CLLocationDegrees latitudeDelta;
    CLLocationDegrees longitudeDelta;
} BMCoordinateSpan;

/** @brief BMCoordinateRegion defines which portion of the map to display.
 *
 * @param center The center coordinate for the new BMCoordinateRegion
 * @param span The horizontal and vertical spans for the new BMCoordinateRegion
 *
 * @sa BMCoordinateSpan
 */
typedef struct {
	CLLocationCoordinate2D center;
	BMCoordinateSpan span;
} BMCoordinateRegion;

/** @brief Creates a new BMCoordinateSpan
 *
 * @param latitudeDelta The delta between the north-most and south-most points of the span
 * @param longitudeDelta The delta between the east-most and west-most points of the span
 *
 * @return A new BMCoordinateSpan
 *
 * @sa BMCoordinateRegionMake
 */
UIKIT_STATIC_INLINE BMCoordinateSpan BMCoordinateSpanMake( CLLocationDegrees latitudeDelta, CLLocationDegrees longitudeDelta ) {
    BMCoordinateSpan span;
    span.latitudeDelta = latitudeDelta;
    span.longitudeDelta = longitudeDelta;
    return span;
}

/** @brief Creates a new BMCoordinateRegion
 *
 * @param centerCoordinate The center coordinate for the new BMCoordinateRegion
 * @param span The horizontal and vertical spans for the new BMCoordinateRegion
 *
 * @return A new BMCoordinateRegion
 *
 * @sa BMCoordinateSpanMake
 */
UIKIT_STATIC_INLINE BMCoordinateRegion BMCoordinateRegionMake( CLLocationCoordinate2D centerCoordinate, BMCoordinateSpan span ) {
	BMCoordinateRegion region;
	region.center = centerCoordinate;
    region.span = span;
	return region;
}

UIKIT_EXTERN BMCoordinateRegion BMCoordinateRegionMakeWithDistance( CLLocationCoordinate2D centerCoordinate, CLLocationDistance latitudinalMeters, CLLocationDistance longitudinalMeters );

//
//  BMMapView.h
//  BingMaps
//
//  Copyright (c) 2011 Microsoft Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BingMaps/BMGeometry.h"
#import "BingMaps/BMTypes.h"
#import "BingMaps/BMMarker.h"
#import "BingMaps/BMMarkerView.h"

@protocol BMMapViewDelegate;
@class BMUserLocation;
@class BMMapViewInternal;

@interface BMMapView : UIView {
@private
    BMMapViewInternal *_internal;
}

#pragma mark -
#pragma mark Manipulation

@property(nonatomic, assign) id <BMMapViewDelegate> delegate;
@property(nonatomic) BMMapMode mapMode;
@property(nonatomic) BMCoordinateRegion region;
@property(nonatomic) BOOL zoomEnabled;
@property(nonatomic) BOOL scrollEnabled;
- (void)setRegion:(BMCoordinateRegion)region animated:(BOOL)animated;

// centerCoordinate allows the coordinate of the region to be changed without changing the zoom level.
@property(nonatomic) CLLocationCoordinate2D centerCoordinate;
- (void)setCenterCoordinate:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated;

#pragma mark -
#pragma mark Math

// Returns a region of the aspect ratio of the map view that contains the given region, with the same center point.
- (BMCoordinateRegion)regionThatFits:(BMCoordinateRegion)region;
- (CGPoint)convertCoordinate:(CLLocationCoordinate2D)coordinate toPointToView:(UIView *)view;
- (CLLocationCoordinate2D)convertPoint:(CGPoint)point toCoordinateFromView:(UIView *)view;
- (CGRect)convertRegion:(BMCoordinateRegion)region toRectToView:(UIView *)view;
- (BMCoordinateRegion)convertRect:(CGRect)rect toRegionFromView:(UIView *)view;

#pragma mark -
#pragma mark User Location

@property(nonatomic) BOOL showsUserLocation;

// The marker representing the user's location
@property(nonatomic, readonly) BMUserLocation *userLocation;
/** @brief A Boolean value indicating whether the device's current location is visible in the map view. (read-only)
 *
 * This property uses the horizontal accuracy of the current location to determine whether the user's location is visible. Thus, this property is YES if the specific coordinate is offscreen but the rectangle surrounding that coordinate (and defined by the horizontal accuracy value) is partially on the screen.
 * If the user's location cannot be determined, this property contains the value NO.
 */
@property(nonatomic, readonly, getter=isUserLocationVisible) BOOL userLocationVisible;

#pragma mark -
#pragma mark markers

// markers are models used to add markers on the map. 
// Implement mapView:viewFormarker: on BMMapViewDelegate to return the marker view for each marker.
- (void)addMarker:(id <BMMarker>)marker;
- (void)addMarkers:(NSArray *)markers;

- (void)removeMarker:(id <BMMarker>)marker;
- (void)removeMarkers:(NSArray *)markers;

@property(nonatomic, readonly) NSArray *markers;

// Currently displayed view for an marker; returns nil if the view for the marker hasn't been created yet.
- (BMMarkerView *)viewForMarker:(id <BMMarker>)marker;

// Used by the delegate to acquire an already allocated marker view, in lieu of allocating a new one.
- (BMMarkerView *)dequeueReusableMarkerViewWithIdentifier:(NSString *)identifier;

// Select or deselect a given marker.  Asks the delegate for the corresponding marker view if necessary.
- (void)selectMarker:(id <BMMarker>)marker animated:(BOOL)animated;
- (void)deselectMarker:(id <BMMarker>)marker animated:(BOOL)animated;


@property(nonatomic, copy) NSArray *selectedMarkers;

@property (nonatomic, readonly) CGRect markerVisibleRect;

@end

/** BMMapViewDelegate
 * @brief The BMMapViewDelegate protocol methods can notify you of changes related to the map.
 *
 * The BMMapViewDelegate methods are called when map tiles are being loaded, if the map view changes, and also after certain marker events.
 *
 */
@protocol BMMapViewDelegate <NSObject>
@optional

/** @brief Called just before the map view region is about to change.
 *
 * @param mapView The map view.
 * @param animated Inidicates whether the map view change is animated.
 *
 */
- (void)mapView:(BMMapView *)mapView regionWillChangeAnimated:(BOOL)animated;
/** @brief Called just after the map view region changed.
 *
 * @param mapView The map view.
 * @param animated Indicates whether the change was animated.
 *
 */
- (void)mapView:(BMMapView *)mapView regionDidChangeAnimated:(BOOL)animated;
/** @brief Called just before the map view makes requests to get map data.
 *
 * @param mapView The map view.
 *
 */
- (void)mapViewWillStartLoadingMap:(BMMapView *)mapView;
/** @brief Called just after the map view finishes getting map data.
 *
 * @param mapView The map view.
 *
 * This method is called after map tiles are downloaded from the server. For example, when panning and zooming, new map data is retrieved from the server to display the new region.
 */
- (void)mapViewDidFinishLoadingMap:(BMMapView *)mapView;
/** @brief Called when the map view encountered an error while trying to get map data.
 *
 * @param mapView The map view.
 * @param error The error.
 *
 * Use this method if you want to notify users that map data is unavailable. This method is called when there is no network connection or if other errors occurred while trying to retrieve map data.
 */
- (void)mapViewDidFailLoadingMap:(BMMapView *)mapView withError:(NSError *)error;
/** @brief Returns the view of the given marker object.
 *
 * @param mapView The map view.
 * @param marker The marker.
 * @return The view of the given marker object.
 */
- (BMMarkerView *)mapView:(BMMapView *)mapView viewForMarker:(id <BMMarker>)marker;
/** @brief Called after the marker views have been added and positioned on the map.
 *
 * @param mapView The map view.
 * @param views An array containing marker views that were added.
 * The delegate can implement this method to animate the adding of the markers' views.
 * Use the current positions of the marker views as the destinations of the animation.
 */
- (void)mapView:(BMMapView *)mapView didAddMarkerViews:(NSArray *)views;
/** @brief Called when the user taps on left and right callout accessory UIControls.
 *
 * @param mapView The map view.
 * @param view Marker view that was tapped.
 * @param control The control that was tapped.
 */
- (void)mapView:(BMMapView *)mapView markerView:(BMMarkerView *)view calloutAccessoryControlTapped:(UIControl *)control;

@end

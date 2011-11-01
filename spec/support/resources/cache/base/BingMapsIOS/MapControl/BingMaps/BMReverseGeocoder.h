//
//  BMReverseGeocoder.h
//  BingMaps
//
//  Copyright (c) 2011 Microsoft Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <BingMaps/BMTypes.h>

@class BMReverseGeocoderInternal;
@class BMEntity;
@protocol BMReverseGeocoderDelegate;

@interface BMReverseGeocoder : NSObject {
@private
    BMReverseGeocoderInternal*  _internal;
}

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

- (void)start;
- (void)cancel;

@property (nonatomic, assign) id<BMReverseGeocoderDelegate> delegate;

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;      // the exact coordinate being reverse geocoded.

@property (nonatomic, readonly) BMEntity *entity;

@property (nonatomic, readonly, getter=isQuerying) BOOL querying;

@end

/**
 * @brief The BMReverseGeocoderDelegate protocol defines the interface for receiving messages from a BMReverseGeocoder object. 
 *
 * A BMEntity object is returned from didFindEntity if a location is found for a coordinate. 
 * If no location is found or if there is an error in the request, the didFailWithError method is called 
 * with details of the error. Both delegate methods are required.
 */
@protocol BMReverseGeocoderDelegate <NSObject>
@required
/**
 * @brief Tells the delegate that a reverse geocoder successfully obtained a BMEntity and returns the BMEntity.
 *
 * @param geocoder The geocoder.
 * @param entity The entity.
 *
 */
- (void)reverseGeocoder:(BMReverseGeocoder *)geocoder didFindEntity:(BMEntity *)entity;
/**
 * @brief Tells the delegate that a reverse geocoder failed to obtain a BMEntity.
 *
 * Errors include network issues which may fall under system framework domains, and result in not found errors which have the domain BMErrorDomain and the code BMErrorEntityNotFound.
 *
 * @param geocoder The geocoder.
 * @param error The error.
 *
 */
- (void)reverseGeocoder:(BMReverseGeocoder *)geocoder didFailWithError:(NSError *)error;
@end

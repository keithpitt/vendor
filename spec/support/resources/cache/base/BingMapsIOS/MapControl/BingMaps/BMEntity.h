//
//  BMEntity.h
//  BingMaps
//
//  Copyright (c) 2011 Microsoft Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <BingMaps/BMGeometry.h>
#import <BingMaps/BMTypes.h>
#import <BingMaps/BMMarker.h>

@class BMEntityInternal;

@interface BMEntity : NSObject <BMMarker> {
@private
    BMEntityInternal* _internal;
}

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate
       bingAddressDictionary:(NSDictionary *)addressDictionary;

@property (nonatomic, readonly) NSDictionary *addressDictionary;
@property (nonatomic, readonly) NSString *addressLine;
@property (nonatomic, readonly) NSString *adminDistrict;
@property (nonatomic, readonly) NSString *adminDistrict2;
@property (nonatomic, readonly) NSString *locality;
@property (nonatomic, readonly) NSString *postalCode;
@property (nonatomic, readonly) NSString *countryRegion;
@property (nonatomic, readonly) NSString *formattedAddress;

@end


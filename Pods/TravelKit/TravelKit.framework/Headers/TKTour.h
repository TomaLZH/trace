//
//  TKTour.h
//  TravelKit
//
//  Created by Michal Zelinka on 16/06/17.
//  Copyright © 2017 Tripomatic. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Flag value denoting some additional options of a `TKTour`.
 */
typedef NS_OPTIONS(NSUInteger, TKTourFlag) {
	TKTourFlagNone                = 0,
	TKTourFlagBestSeller          = 1 << 0,
	TKTourFlagInstantConfirmation = 1 << 1,
	TKTourFlagPortableTicket      = 1 << 2,
	TKTourFlagWheelChairAccess    = 1 << 3,
	TKTourFlagSkipTheLine         = 1 << 4,
};


NS_ASSUME_NONNULL_BEGIN


///---------------------------------------------------------------------------------------
/// @name Tour Model
///---------------------------------------------------------------------------------------

/**
 @name Tour Model

 Basic Tour model keeping various information about its properties.
 */

@interface TKTour : NSObject

///---------------------------------------------------------------------------------------
/// @name Properties
///---------------------------------------------------------------------------------------

/// Global identifier.
@property (nonatomic, copy, readonly) NSString *ID NS_SWIFT_NAME(ID);

/// Displayable name of the tour, translated if possible. Example: _Buckingham Palace_.
@property (nonatomic, copy, readonly) NSString *title;

/// Short perex introducing the tour.
@property (nonatomic, copy, nullable, readonly) NSString *perex;

/// Price value. Provided in `USD`.
@property (nonatomic, strong, nullable, readonly) NSNumber *price;

/// Original price value. Usable for discount calculation. Value in `USD`.
@property (nonatomic, strong, nullable, readonly) NSNumber *originalPrice;

/// Star rating value.
///
/// @note Possible values: double in range `0`--`5`.
@property (nonatomic, strong, nullable, readonly) NSNumber *rating;

/// Duration string. Should be provided in a target language.
///
/// @note Duration may be specified by either a string or numeric values.
@property (nonatomic, copy, nullable, readonly) NSString *duration;

/// Minimal duration in seconds.
///
/// @note Duration may be specified by either a string or numeric values.
@property (nonatomic, copy, nullable, readonly) NSNumber *durationMin;

/// Maximal duration in seconds.
///
/// @note Duration may be specified by either a string or numeric values.
@property (nonatomic, copy, nullable, readonly) NSNumber *durationMax;

/// Online URL of the Tour.
@property (nonatomic, strong, nullable, readonly) NSURL *URL;

/// Thumbnail URL to an image of approximate size 600×400 pixels.
@property (nonatomic, strong, nullable, readonly) NSURL *photoURL;

/// Count of reviews.
@property (nonatomic, strong, nullable, readonly) NSNumber *reviewsCount;

/// Some additional indicated flags.
@property (atomic, readonly) TKTourFlag flags;

@end

NS_ASSUME_NONNULL_END

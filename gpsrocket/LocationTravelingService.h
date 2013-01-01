
#import <CoreLocation/CLLocation.h>


@interface LocationTravelingService: NSObject
{

}

+ (BOOL) isFixedLocationAvaliable;
+ (BOOL) isTraveling;
+ (void) startTraveling;
+ (void) stopTraveling;

+ (void) setFixedLocation:(CLLocation*)aLocation;

+ (BOOL) isSet;
+ (CLLocation*) getFixedLocation;


//private
+ (void) setIsSet;
+ (void) unsetIsSet;


@end

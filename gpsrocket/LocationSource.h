
#import <CoreLocation/CLLocation.h>
#import <CoreLocation/CoreLocation.h>


@interface LocationSource: NSObject
{
    CLLocation* mMostRecentLocation;
}

- (CLLocation*) getMostRecentLocation;
+ (LocationSource*) getRegularLocationSource;
+ (LocationSource*) getTrueLocationSource;


@end


//TrueLocationSource20121229 will not intercept the system true location info if it knows the original deleate is a class of TrueLocationSource20121229.
@interface TrueLocationSource20121229: LocationSource<CLLocationManagerDelegate>
{
    CLLocationManager* mLocationManager;
}
@property (nonatomic, retain) CLLocationManager* mLocationManager;

@end

@interface TravelingLocationSource: LocationSource
{
}

@end

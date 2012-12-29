
#import <CoreLocation/CLLocation.h>
#import <CoreLocation/CoreLocation.h>


@interface LocationSource: NSObject<CLLocationManagerDelegate>
{
    CLLocationManager* mLocationManager;
    CLLocation* mMostRecentLocation;
}

@property (nonatomic, retain) CLLocationManager* mLocationManager;
@property (nonatomic, retain) CLLocation* mMostRecentLocation;


+ (LocationSource*) getRegularLocationSource;
+ (LocationSource*) getTrueLocationSource;

- (CLLocation*) getMostRecentLocation;

@end


//TrueLocationSource20121229 will not intercept the system true location info if it knows the original deleate is a class of TrueLocationSource20121229.
@interface TrueLocationSource20121229: LocationSource
{
}

@end

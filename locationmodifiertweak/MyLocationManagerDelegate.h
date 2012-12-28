#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocationManager.h>

@interface MyLocationManagerDelegate : NSObject<CLLocationManagerDelegate>
{
    id<CLLocationManagerDelegate> mOriginalDelegate;
    CLLocation* mLocationFixed;
}

@property (nonatomic, assign) id<CLLocationManagerDelegate> mOriginalDelegate;
@property (nonatomic, retain) CLLocation* mLocationFixed;

- (id) initWithOriginalDelegate:(id<CLLocationManagerDelegate>)aOriginalDelegate;

- (void) makeLocation;
@end
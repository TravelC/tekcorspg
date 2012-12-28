#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocationManager.h>

@interface MyLocationManagerDelegate : NSObject<CLLocationManagerDelegate>
{
    id<CLLocationManagerDelegate> mOriginalDelegate;
}

@property (nonatomic, assign) id<CLLocationManagerDelegate> mOriginalDelegate;

- (id) initWithOriginalDelegate:(id<CLLocationManagerDelegate>)aOriginalDelegate;

@end
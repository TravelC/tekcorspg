#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocationManager.h>


@interface MyLocationManagerDelegate : NSObject<CLLocationManagerDelegate>
{
    id<CLLocationManagerDelegate> mOriginalDelegate;
    BOOL mAlwaysNeedsTrueLocation;
    BOOL mIsLocationSet;
}

@property (nonatomic, assign) id<CLLocationManagerDelegate> mOriginalDelegate;
@property (nonatomic, assign) BOOL mAlwaysNeedsTrueLocation;
@property (nonatomic, assign) BOOL mIsLocationSet;

- (id) initWithOriginalDelegate:(id<CLLocationManagerDelegate>)aOriginalDelegate;

@end
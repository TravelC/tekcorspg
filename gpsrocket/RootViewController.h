
#import <CoreLocation/CLLocation.h>


@interface RootViewController: UIViewController
{
    UITextField* mLongtitudeValueTextField;
    UITextField* mLatitudeValueTextField;

}
@property (nonatomic, retain)     UITextField* mLongtitudeValueTextField;
@property (nonatomic, retain)     UITextField* mLatitudeValueTextField;

- (void) setFixedLocation:(CLLocation*)aLocation;
- (void) unsetFixedLocation;
- (NSString*) getFixedLocationDataFilePath;


@end

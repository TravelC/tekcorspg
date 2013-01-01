
#import <MapKit/MapKit.h>

@interface MyLocationAnnotation : NSObject <MKAnnotation>
{
    CLLocationCoordinate2D mCoordinate;
    NSString* mTitle;

}

@property (nonatomic, assign) CLLocationCoordinate2D mCoordinate;
@property (nonatomic, copy) NSString* mTitle;

- (id) initWithTitle:(NSString*)aTitle;
@end

#import <MapKit/MapKit.h>

@interface MyLocationAnnotation : NSObject <MKAnnotation>
{
    CLLocationCoordinate2D mCoordinate;
    NSString* mTitle;
    NSString* mGeoInfo;
}

@property (nonatomic, assign) CLLocationCoordinate2D mCoordinate;
@property (nonatomic, copy) NSString* mTitle;
@property (nonatomic, copy) NSString* mGeoInfo;


- (id) initWithTitle:(NSString*)aTitle;
@end
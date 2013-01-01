
#import "MyLocationAnnotation.h"

@implementation MyLocationAnnotation
@synthesize mCoordinate;
@synthesize mTitle;


- (id) initWithTitle:(NSString*)aTitle
{
    self = [super init];
    if (self)
    {
        self.mTitle = aTitle;
    }
    return self;
}

- (CLLocationCoordinate2D)coordinate;
{
    return self.mCoordinate;
}

// required if you set the MKPinAnnotationView's "canShowCallout" property to YES
- (NSString *)title
{
    return self.mTitle;
}

// optional
- (NSString *)subtitle
{
    NSString* sLocation = [NSString stringWithFormat:@"经度：%.4f \t 纬度：%.4f", self.coordinate.longitude, self.coordinate.latitude];
    return sLocation;
}

- (void)dealloc
{
    self.mTitle = nil;
    [super dealloc];
}

@end
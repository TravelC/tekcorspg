
#import "MyLocationAnnotation.h"
#import <CoreLocation/CLGeocoder.h>

@implementation MyLocationAnnotation
@synthesize mCoordinate;
@synthesize mTitle;
@synthesize mGeoInfo;

+ (NSString*) returnEmptyStringIfNil:(NSString*)aStr
{
    if (aStr)
    {
        return aStr;
    }
    else
    {
        return @"";
    }
}


- (id) initWithTitle:(NSString*)aTitle
{
    self = [super init];
    if (self)
    {
        self.mTitle = aTitle;
    }
    return self;
}

- (void) setMCoordinate:(CLLocationCoordinate2D)aCoordinate
{
    mCoordinate = aCoordinate;
    self.mGeoInfo = nil;
    
    CLLocation* sLocation = [[CLLocation alloc] initWithLatitude:mCoordinate.latitude longitude:mCoordinate.longitude];
    
    CLGeocoder* sGeocoder = [[CLGeocoder alloc] init];
    [sGeocoder reverseGeocodeLocation:sLocation completionHandler:^(NSArray *placemarks, NSError *error){
        CLPlacemark* sPlacemark = [placemarks objectAtIndex:0];
        NSString* sGeoInfo = [NSString stringWithFormat:@"%@%@%@%@%@%@", [MyLocationAnnotation returnEmptyStringIfNil:sPlacemark.country],  [MyLocationAnnotation returnEmptyStringIfNil:sPlacemark.administrativeArea],  [MyLocationAnnotation returnEmptyStringIfNil:sPlacemark.locality],  [MyLocationAnnotation returnEmptyStringIfNil:sPlacemark.subLocality],  [MyLocationAnnotation returnEmptyStringIfNil:sPlacemark.thoroughfare],  [MyLocationAnnotation returnEmptyStringIfNil:sPlacemark.subThoroughfare]];
        self.mGeoInfo = sGeoInfo;
    }];
    
    [sLocation release];
    [sGeocoder release];
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
    if (self.mGeoInfo
        && self.mGeoInfo.length > 0)
    {
        return self.mGeoInfo;
    }
    else
    {
        NSString* sLocation = [NSString stringWithFormat:@"%@：%.4f \t %@：%.4f",NSLocalizedString(@"Longitude", nil), self.coordinate.longitude, NSLocalizedString(@"Latitude", nil), self.coordinate.latitude];
        return sLocation;
    }
}

- (void)dealloc
{
    self.mTitle = nil;
    self.mGeoInfo = nil;
    [super dealloc];
}

@end
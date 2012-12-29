#import "LocationSource.h"



@implementation LocationSource
@synthesize mLocationManager;
@synthesize mMostRecentLocation;

- (id) init
{
    self = [super init];
    if (self)
    {
        self.mLocationManager = [[[CLLocationManager alloc] init] autorelease];
        self.mLocationManager.delegate = self;
        [self.mLocationManager startUpdatingLocation];
    }
    return self;
}

- (void) dealloc
{
    
    [self.mLocationManager stopUpdatingLocation];
    self.mLocationManager = nil;
    self.mMostRecentLocation = nil;
    
    [super dealloc];
}

- (CLLocation*) getMostRecentLocation
{
    return self.mMostRecentLocation;
}

#pragma mark - CLLocationManagerDelegate methods
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    self.mMostRecentLocation = newLocation;
}

//- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
//{
//    return;
//}


+ (LocationSource*) getRegularLocationSource
{
    LocationSource* sRegularLocationSource = [[[LocationSource alloc] init] autorelease];
    return sRegularLocationSource;
}

+ (LocationSource*) getTrueLocationSource
{
    LocationSource* sTrueLocationSource = [[[TrueLocationSource20121229 alloc] init] autorelease];
    return sTrueLocationSource;
}

@end


#pragma mark - TrueLocationSource20121229 class
@implementation TrueLocationSource20121229

@end


#import "LocationSource.h"
#import "LocationTravelingService.h"


@implementation LocationSource

- (void) dealloc
{
    
    [mMostRecentLocation release];
    
    [super dealloc];
}

- (CLLocation*) getMostRecentLocation
{
    return mMostRecentLocation;
}


+ (LocationSource*) getRegularLocationSource
{
    LocationSource* sRegularLocationSource = [[[TravelingLocationSource alloc] init] autorelease];
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
@synthesize mLocationManager;

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
    
    [super dealloc];
}

- (CLLocation*) getMostRecentLocation
{
    if (!mMostRecentLocation)
    {
        mMostRecentLocation = [self.mLocationManager.location retain];
    }
    
    return mMostRecentLocation;
}



#pragma mark - CLLocationManagerDelegate methods
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    [mMostRecentLocation release];
    mMostRecentLocation = [newLocation retain];
}

@end


#pragma mark - TravelingLocationSource class

@implementation TravelingLocationSource
- (id) init
{
    self = [super init];
    if (self)
    {
        //
    }
    return self;
}

- (CLLocation*) getMostRecentLocation
{
    [mMostRecentLocation release];
    mMostRecentLocation = [[LocationTravelingService getFixedLocation] retain];
    return mMostRecentLocation;
}


@end



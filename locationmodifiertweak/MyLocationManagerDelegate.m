#import "MyLocationManagerDelegate.h"


@implementation MyLocationManagerDelegate
@synthesize mOriginalDelegate;
@synthesize mLocationFixed;


- (id) initWithOriginalDelegate:(id<CLLocationManagerDelegate>)aOriginalDelegate
{
    self = [super init];
    if (self)
    {
        self.mOriginalDelegate = aOriginalDelegate;
        
        [self makeLocation];
       
    }
    return self;
}

- (void) dealloc
{
    self.mLocationFixed = nil;
    
    [super dealloc];
}

- (void) makeLocation
{
    
    CLLocation* sLocation = [[CLLocation alloc] initWithLatitude: 40.13f longitude:117.10f];
    self.mLocationFixed = sLocation;
    [sLocation release];
}

#pragma mark -
#pragma mark Responding to Location Events
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    if (self.mOriginalDelegate && [self.mOriginalDelegate respondsToSelector:@selector(locationManager:didUpdateToLocation:fromLocation:)])
    {
        CLLocation* sOldLocation = nil;
        if (!oldLocation)
        {
            sOldLocation = nil;
        }
        else
        {
            sOldLocation = [self.mLocationFixed copy];
            
        }
        
        [self.mOriginalDelegate locationManager:manager didUpdateToLocation:self.mLocationFixed fromLocation:sOldLocation];
        

    }
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"didUpdateToLocation" message:@"you are hooked" 	delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//	[alert show];
//	[alert release];
//
//    
//    if (self.mOriginalDelegate && [self.mOriginalDelegate respondsToSelector:@selector(locationManager:didUpdateToLocation:fromLocation:)])
//    {
//        [self.mOriginalDelegate locationManager:manager didUpdateToLocation:newLocation fromLocation:oldLocation];
//
//    }
//    
 
    
    
    return;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"didFailWithError" message:@"you are hooked" 	delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//	[alert show];
//	[alert release];

    if (self.mOriginalDelegate && [self.mOriginalDelegate respondsToSelector:@selector(locationManager:didFailWithError:)])
    {
        [self.mOriginalDelegate locationManager:manager didFailWithError:error];
    }
    return;
}

#pragma mark -
#pragma mark Responding to Heading Events
- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"didUpdateHeading" message:@"you are hooked" 	delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//	[alert show];
//	[alert release];

    if (self.mOriginalDelegate && [self.mOriginalDelegate respondsToSelector:@selector(locationManager:didUpdateHeading:)])
    {
        return;
    }
    
    [self.mOriginalDelegate locationManager:manager didUpdateHeading:newHeading];
    return;
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager
{
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"locationManagerShouldDisplayHeadingCalibration" message:@"you are hooked" 	delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//	[alert show];
//	[alert release];

    if (self.mOriginalDelegate && [self.mOriginalDelegate respondsToSelector:@selector(locationManagerShouldDisplayHeadingCalibration:)])
    {
        return NO;
    }
    
    return [self.mOriginalDelegate locationManagerShouldDisplayHeadingCalibration:manager];
}

#pragma mark -
#pragma mark Responding to Region Events
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"didEnterRegion" message:@"you are hooked" 	delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//	[alert show];
//	[alert release];

    if (self.mOriginalDelegate && [self.mOriginalDelegate respondsToSelector:@selector(locationManager:didEnterRegion:)])
    {
        [self.mOriginalDelegate locationManager:manager didEnterRegion:region];      
    }
    return;
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"didExitRegion" message:@"you are hooked" 	delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//	[alert show];
//	[alert release];
    if (self.mOriginalDelegate && [self.mOriginalDelegate respondsToSelector:@selector(locationManager:didExitRegion:)])
    {
        [self.mOriginalDelegate locationManager:manager didExitRegion:region];
    }
    return;
}

//- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
//{
//    [self.mOriginalDelegate locationManager:manager monitoringDidFailForRegion:region withError:error];
//    return;
//}
//
//- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
//{
//    [self.mOriginalDelegate locationManager:manager didStartMonitoringForRegion:region];
//    return;
//}

#pragma mark -
#pragma mark Responding to Authorization Changes
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"didChangeAuthorizationStatus" message:@"you are hooked" 	delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//	[alert show];
//	[alert release];

    if (self.mOriginalDelegate && [self.mOriginalDelegate respondsToSelector:@selector(locationManager:didChangeAuthorizationStatus:)])
    {
        [self.mOriginalDelegate locationManager:manager didChangeAuthorizationStatus:status];
    }
    
    return;
}


@end
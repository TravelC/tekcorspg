#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocationManager.h>
#import "MyLocationManagerDelegate.h"


MyLocationManagerDelegate* mMyDelegate;

%hook CLLocationManager

- (void) setDelegate:(id<CLLocationManagerDelegate>)aDelegate
{
	mMyDelegate = [[MyLocationManagerDelegate alloc] initWithOriginalDelegate:aDelegate];
    %orig(mMyDelegate); // Call through to the original function with a custom argument.

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"xxx" message:@"you are hooked" 	delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[alert show];
	[alert release];
}	

- (void) dealloc 
{
	[mMyDelegate release];
	mMyDelegate = nil;
	%orig;
}


%end
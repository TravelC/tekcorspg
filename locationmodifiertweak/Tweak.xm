#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocationManager.h>
#import "MyLocationManagerDelegate.h"


MyLocationManagerDelegate* mMyDelegate;

%hook CLLocationManager

- (void) setDelegate:(id<CLLocationManagerDelegate>)aDelegate
{
	if (aDelegate)
	{
		mMyDelegate = [[MyLocationManagerDelegate alloc] initWithOriginalDelegate:aDelegate];
    	%orig(mMyDelegate); // Call through to the original function with a custom argument.
	    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"setDelegate:x" message:@"you are hooked" 	delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	else
	{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"setDelegate:nil" message:@"you are hooked" 	delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[alert show];
	[alert release];
		%orig;
	}


}	

- (void) dealloc 
{
	[mMyDelegate release];
	mMyDelegate = nil;
	%orig;
}


%end
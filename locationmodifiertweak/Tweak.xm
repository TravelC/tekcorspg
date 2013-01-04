#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocationManager.h>
#import "MyLocationManagerDelegate.h"


static MyLocationManagerDelegate* mMyDelegate = nil;

%hook CLLocationManager

// Hooking a class method
+ (void)initialize 
{
	if (!mMyDelegate)
	{
		mMyDelegate = [[MyLocationManagerDelegate alloc] init];
	}
	%orig;
}

- (void) setDelegate:(id<CLLocationManagerDelegate>)aDelegate
{
	if (aDelegate)
	{
	NSLog(@"setDelegate:not nil");
	
		[mMyDelegate addOriginalDelegate:aDelegate LocationManager: self];
//		[mMyDelegate forceFixedLocationUpdateForLocationManager:self];
    	%orig(mMyDelegate); // Call through to the original function with a custom argument.
	}
	else
	{
	NSLog(@"setDelegate:nil");
	
		[mMyDelegate removeOriginalDelegateByLocationManager:self];
		%orig;
	}
}

- (CLLocation*) location
{
 /*	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"getLocation" message:@"you are hooked" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[alert show];
	[alert release];
	*/
	
	if (!mMyDelegate
		|| [mMyDelegate needsTrueLocationForLocationManager:self])
	{
		return %orig;
	}
	else
	{
		FixedLocationData* sFixedLocationData = [mMyDelegate getFixedLocationData];
		if (sFixedLocationData
			&& sFixedLocationData.mIsSet)
		{
		NSLog(@"location:fixed");
			return sFixedLocationData.mFixedLocation;
		}
		else
		{
		NSLog(@"location:orig");
		
			return %orig;	
		}
	}
}

- (void) dealloc 
{
	[mMyDelegate removeOriginalDelegateByLocationManager:self];
	%orig;
}

///////////////////////////////
/*
// Hooking a class method
+ (void)initialize 
{
UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"initialize" message:@"you are hooked" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
[alert show];
[alert release];
	if (!mMyDelegate)
	{
		mMyDelegate = [[MyLocationManagerDelegate alloc] init];
	}
	return %orig;
}

- (void) setDelegate:(id<CLLocationManagerDelegate>)aDelegate
{
	if (aDelegate)
	{
		mMyDelegate = [[MyLocationManagerDelegate alloc] initWithOriginalDelegate:aDelegate];
    	%orig(mMyDelegate); // Call through to the original function with a custom argument.
	}
	else
	{
		%orig;
	}
}

- (CLLocation*) location
{
 	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"getLocation" message:@"you are hooked" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[alert show];
	[alert release];
	
	return %orig;
}

- (void) dealloc 
{
	%orig;
}
*/
///////////////////////////////////////

%end
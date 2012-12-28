#import "RootViewController.h"


#define FIXED_LOCATION_FILE_NAME  @"h.xh"


@implementation RootViewController
@synthesize mLongtitudeValueTextField;
@synthesize mLatitudeValueTextField;


- (void) dealloc
{
    self.mLongtitudeValueTextField = nil;
    self.mLatitudeValueTextField = nil;
    
    [super dealloc];
}

- (void)loadView {
    
	UIView* sView = [[[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]] autorelease];
    sView.backgroundColor = [UIColor whiteColor];
    self.view = sView;
    
    UILabel* sLongtitudeLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 50,  100, 40)];
    sLongtitudeLabel.text = @"longtitude: ";
    [self.view addSubview: sLongtitudeLabel];
    [sLongtitudeLabel release];
    
    UITextField* sLongtitudeValueTextField = [[UITextField alloc] initWithFrame:CGRectMake(110, 50, 150, 40)];
    sLongtitudeValueTextField.keyboardType = UIKeyboardTypeDecimalPad;
    sLongtitudeValueTextField.borderStyle = UITextBorderStyleRoundedRect;
    sLongtitudeValueTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;

    [self.view addSubview: sLongtitudeValueTextField];

    self.mLongtitudeValueTextField = sLongtitudeValueTextField;
    [sLongtitudeValueTextField release];
    
    
    UILabel* sLatitudeLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 100,  100, 40)];
    sLatitudeLabel.text = @"latitude: ";
    [self.view addSubview: sLatitudeLabel];
    [sLatitudeLabel release];
    
    UITextField* sLatitudeValueTextField = [[UITextField alloc] initWithFrame:CGRectMake(110, 100, 150, 40)];
    sLatitudeValueTextField.keyboardType = UIKeyboardTypeDecimalPad;
    sLatitudeValueTextField.borderStyle = UITextBorderStyleRoundedRect;
    sLatitudeValueTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;

    [self.view addSubview: sLatitudeValueTextField];
    
    self.mLatitudeValueTextField = sLatitudeValueTextField;
    [sLatitudeValueTextField release];
    
    UIButton* sConfirmButton = [UIButton buttonWithType: UIButtonTypeRoundedRect];
    [sConfirmButton setTitle: @"Confirm" forState: UIControlStateNormal];
    [sConfirmButton addTarget: self action: @selector(confirmButtonPressed) forControlEvents: UIControlEventTouchDown];
    [sConfirmButton setFrame: CGRectMake( 110, 170, 150, 40)];
    
    [self.view addSubview:sConfirmButton];
    
}



- (void) confirmButtonPressed
{
    double sLongtitudeDouble = [self.mLongtitudeValueTextField.text doubleValue];
    double sLatitudeDobule =  [self.mLatitudeValueTextField.text doubleValue]
    ;
    
    if (sLongtitudeDouble == 0
        && sLatitudeDobule == 0)
    {
        [self unsetFixedLocation];
    }
    else
    {
        CLLocation* sLocation = [[CLLocation alloc] initWithLatitude: sLatitudeDobule longitude: sLongtitudeDouble];
        [self setFixedLocation: sLocation];
        [sLocation release];
    }
    
    return;
}

- (void) setFixedLocation:(CLLocation*)aLocation
{
    NSMutableDictionary* sLocationDict = [NSMutableDictionary dictionaryWithCapacity: 2];
    
    [sLocationDict setValue: [NSNumber numberWithBool:YES] forKey:@"isset"];
    //CLLocation in NSDictionary cannot be written to file. cos, 
    //This method recursively validates that all the contained objects are property list objects (instances of NSData, NSDate, NSNumber, NSString, NSArray, or NSDictionary) before writing out the file, and returns NO if all the objects are not property list objects, since the resultant file would not be a valid property list.
    [sLocationDict setValue:[NSKeyedArchiver archivedDataWithRootObject:aLocation] forKey:@"location"];

    [sLocationDict writeToFile: [self getFixedLocationDataFilePath] atomically:YES];
}

- (void) unsetFixedLocation
{
    NSMutableDictionary* sLocationDict = [NSMutableDictionary dictionaryWithCapacity: 1];
    
    [sLocationDict setValue: [NSNumber numberWithBool:NO] forKey:@"isset"];
    [sLocationDict writeToFile: [self getFixedLocationDataFilePath] atomically:YES];

}

- (NSString*) getFixedLocationDataFilePath
{
    NSString* sBundlePath = [[NSBundle mainBundle] bundlePath];
    NSString* sPath = [sBundlePath stringByAppendingPathComponent: FIXED_LOCATION_FILE_NAME];
    
//    NSLog(@"bundlePath:%@ Path:%@", sBundlePath, sPath);
    return sPath;
}





@end

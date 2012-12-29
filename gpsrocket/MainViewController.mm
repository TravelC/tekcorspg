#import "MainViewController.h"
#import "SettingController.h"
#import "TraveledLocationPickerController.h"


#define FIXED_LOCATION_FILE_NAME  @"h.xh"


@implementation MainViewController
@synthesize mMapView;
@synthesize mRegularLocationSource;
@synthesize mTrueLocationSource;

- (id) init
{
    self = [super init];
    if (self)
    {
        //setting return text for navigation controller push
        UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
        temporaryBarButtonItem.title = @"返回";
        self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
        [temporaryBarButtonItem release];

        //set bar items on navigation bar; ver weird tool bar items setting here does not work.
        UIBarButtonItem* sSettingBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"设置" style:UIBarButtonItemStyleBordered target:self action:@selector(presentSettingController)];
        self.navigationItem.rightBarButtonItem = sSettingBarButtonItem;
        [sSettingBarButtonItem release];
        
        UIBarButtonItem* sLocationHistoryBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"历史" style:UIBarButtonItemStyleBordered target:self action:@selector(presentHistoryController)];
        self.navigationItem.leftBarButtonItem = sLocationHistoryBarButtonItem;
        [sLocationHistoryBarButtonItem release];

        //
        self.mRegularLocationSource = [LocationSource getRegularLocationSource];
        self.mTrueLocationSource = [LocationSource getTrueLocationSource];
    }
    return self;
}

- (void) dealloc
{
    self.mMapView = nil;
    self.mRegularLocationSource = nil;
    self.mTrueLocationSource = nil;
    
    [super dealloc];
}

- (void)loadView {
    
	UIView* sView = [[[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]] autorelease];
    sView.backgroundColor = [UIColor whiteColor];
    self.view = sView;
    
    CGFloat sX = 0;
    CGFloat sY = 0;
    CGFloat sWidth = self.view.bounds.size.width;
    CGFloat sHeight = self.view.bounds.size.height;
    MKMapView* sMapView = [[MKMapView alloc] initWithFrame:CGRectMake(sX, sY, sWidth, sHeight)];
    [sMapView setMapType:MKMapTypeStandard];
   
    
    [self.view addSubview: sMapView];
    self.mMapView = sMapView;
    [sMapView release];
    
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    
    [self goToTraveledLocationIfSet];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController setToolbarHidden: NO animated: NO];
    
    UIBarButtonItem* sCurrentLocationBarButtonItem = [[UIBarButtonItem alloc] initWithTitle: @"现在位置" style:UIBarButtonItemStyleBordered target:self action:@selector(goToCurrentDeviceLocation)];
    
    UIBarButtonItem* sSpacerBarButtonItem =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil ];
    
    
    UIBarButtonItem* sSetLocationBarButtonItem = [[UIBarButtonItem alloc] initWithTitle: @"选择穿越位置" style: UIBarButtonItemStyleBordered target:self action:@selector(presentTraveledLocationPickerController)];
    
    [self setToolbarItems: [NSArray arrayWithObjects: sCurrentLocationBarButtonItem, sSpacerBarButtonItem, sSetLocationBarButtonItem, nil] animated: YES];
    
    [sCurrentLocationBarButtonItem release];
    [sSpacerBarButtonItem release];
    [sSetLocationBarButtonItem release];

}



- (void) presentHistoryController
{
    //test
    [self goToTraveledLocationIfSet];

    return;
}

- (void) presentSettingController
{
    SettingController* sSettingController = [[SettingController alloc] initWithTitle:@"设置"];
    sSettingController.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:sSettingController animated:YES];
    
    
    [sSettingController release];

}

- (void) presentTraveledLocationPickerController
{
    TraveledLocationPickerController* sTraveledLocationPickerController = [[SettingController alloc] initWithTitle:@"选取穿越位置"];
    sTraveledLocationPickerController.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:sTraveledLocationPickerController animated:YES];
    
    
    [sTraveledLocationPickerController release];

    
    return;
}

- (void) goToTraveledLocationIfSet
{
    CLLocation* sLocation = self.mRegularLocationSource.mMostRecentLocation;
    [self goToLocation: sLocation];
}

- (void) goToCurrentDeviceLocation
{
    CLLocation* sLocation = self.mTrueLocationSource.mMostRecentLocation;
    [self goToLocation: sLocation];
}

- (void) goToLocation: (CLLocation*)aLocation
{
//    CLLocationCoordinate2D theCoordinate;
//    theCoordinate.latitude=24.138727;
//    theCoordinate.longitude=120.713827;
//    MKCoordinateSpan theSpan;
//    theSpan.latitudeDelta=0.1;
//    theSpan.longitudeDelta=0.1;
//    MKCoordinateRegion theRegion;
//    theRegion.center=theCoordinate;
//    theRegion.span=theSpan;
//    [sMapView setRegion:theRegion];
    
    MKCoordinateRegion sRegion;
    sRegion.center = aLocation.coordinate;
    
    MKCoordinateSpan sSpan;
    sSpan.latitudeDelta=0.1;
    sSpan.longitudeDelta=0.1;

    sRegion.span = sSpan;
    
    [self.mMapView setRegion: sRegion];
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

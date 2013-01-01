#import <QuartzCore/QuartzCore.h>
#import "MainViewController.h"
#import "SettingController.h"
#import "TraveledLocationPickerController.h"
#import "LocationTravelingService.h"
#import "SharedVariables.h"


@implementation MainViewController
@synthesize mMapView;
@synthesize mStartStopBarButtonItem;
@synthesize mTraveledLocationBarButtonItem;
@synthesize mGlobalLocationButton;
@synthesize mInfoBoardLabel;
@synthesize mDeviceLocationAnnotation;
@synthesize mTraveledLocationAnnotation;
@synthesize mRegularLocationSource;
@synthesize mTrueLocationSource;
@synthesize mAppearedBefore;

- (id) init
{
    self = [super init];
    if (self)
    {
        self.mAppearedBefore = NO;
        
        //1. setting return text for navigation controller push
        UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
        temporaryBarButtonItem.title = @"返回";
        self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
        [temporaryBarButtonItem release];

        //2. set bar items on navigation bar; ver weird tool bar items setting here does not work.
        self.title = @"GPS穿越器";
        
        UIButton* sButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
        [sButton addTarget:self action:@selector(presentAboutController) forControlEvents:UIControlEventTouchDown];
        UIBarButtonItem* sAboutBarButton = [[UIBarButtonItem alloc]initWithCustomView:sButton];
        self.navigationItem.rightBarButtonItem = sAboutBarButton;
        [sAboutBarButton release];
        
        
        
        //3. set annotation.
        self.mDeviceLocationAnnotation = [[[MyLocationAnnotation alloc] initWithTitle:@"当前位置"] autorelease];
        self.mTraveledLocationAnnotation = [[[MyLocationAnnotation alloc] initWithTitle:@"穿越位置"] autorelease];

        //set location source
        self.mRegularLocationSource = [LocationSource getRegularLocationSource];
        self.mTrueLocationSource = [LocationSource getTrueLocationSource];
        
        //test
//        [LocationTravelingService setFixedLocation:[[[CLLocation alloc] initWithLatitude: 22.516077385444596 longitude: 113.99166869960027] autorelease]];
    }
    return self;
}

- (void) dealloc
{
    self.mMapView = nil;
    self.mStartStopBarButtonItem = nil;
    self.mTraveledLocationBarButtonItem = nil;
    self.mGlobalLocationButton = nil;
    self.mInfoBoardLabel = nil;
    self.mDeviceLocationAnnotation = nil;
    self.mTraveledLocationAnnotation = nil;
    self.mRegularLocationSource = nil;
    self.mTrueLocationSource = nil;
    
    [super dealloc];
}

- (void)loadView {
    

    CGRect sAppFrame = [[UIScreen mainScreen] applicationFrame];

    sAppFrame.size.height -= self.navigationController.navigationBar.bounds.size.height-self.navigationController.toolbar.bounds.size.height;
    
	UIView* sView = [[[UIView alloc] initWithFrame:sAppFrame] autorelease];
    sView.backgroundColor = [UIColor whiteColor];
    self.view = sView;
    

    MKMapView* sMapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    [sMapView setMapType:MKMapTypeStandard];
    sMapView.delegate = self;
   
    
    [self.view addSubview: sMapView];
    self.mMapView = sMapView;
    [sMapView release];
    
    
    UIView* sInfoboardView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 30)];
    sInfoboardView.backgroundColor = [UIColor clearColor];
        CAGradientLayer* sBackgroundGadientLayer =[[CAGradientLayer alloc] init];
    [sBackgroundGadientLayer setBounds:sInfoboardView.bounds];
    [sBackgroundGadientLayer setPosition:sInfoboardView.center];
    [sBackgroundGadientLayer setColors:[NSArray arrayWithObjects:(id)COLOR_GRADIENT_START_INFO_BOARD.CGColor, (id)COLOR_GRADIENT_END_INFO_BOARD.CGColor,nil]];
    [sInfoboardView.layer insertSublayer:sBackgroundGadientLayer atIndex:0];
    [sBackgroundGadientLayer release];
    
    UILabel* sLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, self.view.bounds.size.width-5, 15)];
    sLabel.backgroundColor = [UIColor clearColor];
    sLabel.textColor = [UIColor whiteColor];
    sLabel.font = [UIFont systemFontOfSize: 13];
    [sInfoboardView addSubview:sLabel];
    self.mInfoBoardLabel = sLabel;
    [sLabel release];
    
    [self.view addSubview:sInfoboardView];
    [sInfoboardView release];

    
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController setToolbarHidden: NO animated: NO];

    UIBarButtonItem* sCurrentLocationBarButtonItem = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed:@"current_location20.png"] style:UIBarButtonItemStylePlain target:self action:@selector(centerDeviceLocation)];
    
    UIBarButtonItem* sSpacerBarButtonItem =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil ];
    
     UIBarButtonItem* sStartStopBarButtonItem = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed:@"play20.png"] style:UIBarButtonItemStyleDone target:self action:@selector(startOrStopTraveling)];
    self.mStartStopBarButtonItem = sStartStopBarButtonItem;

    
    UIBarButtonItem* sSpacerBarButtonItem2 =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil ];
    
    UIBarButtonItem* sTraveledLocationBarButtonItem = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed:@"travelinglocation20.png"] style: UIBarButtonItemStylePlain target:self action:@selector(centerTraveledLocationIfSet)];
    self.mTraveledLocationBarButtonItem = sTraveledLocationBarButtonItem;
    
    [self setToolbarItems: [NSArray arrayWithObjects: sCurrentLocationBarButtonItem, sSpacerBarButtonItem, sStartStopBarButtonItem, sSpacerBarButtonItem2, sTraveledLocationBarButtonItem, nil] animated: YES];
    
    [sCurrentLocationBarButtonItem release];
    [sSpacerBarButtonItem release];
    [sStartStopBarButtonItem release];
    [sSpacerBarButtonItem2 release];
    [sTraveledLocationBarButtonItem release];
    
    //globalview button above mapview
    UIButton* sGlobalViewButton = [UIButton buttonWithType: UIButtonTypeCustom];
    [sGlobalViewButton setFrame: CGRectMake(self.view.bounds.size.width-27-10, self.view.bounds.size.height-27-100, 27, 27)];
    [sGlobalViewButton setImage: [UIImage imageNamed:@"globalview20.png"] forState:UIControlStateNormal];
    sGlobalViewButton.layer.cornerRadius  = 4;
    sGlobalViewButton.backgroundColor = COLOR_FLOAT_BUTTON_ON_MAP;
    [sGlobalViewButton addTarget: self action:@selector(centerTraveledAndDeviceLocation) forControlEvents: UIControlEventTouchDown];
    [self.view addSubview: sGlobalViewButton]; 
    
    self.mGlobalLocationButton = sGlobalViewButton;
    
    

    //
    UILongPressGestureRecognizer* sLongPressGenstureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressOnMapview:)];
//    sLongPressGenstureRecognizer.minimumPressDuration = 2.0;  //user must press for 2 seconds
    [self.mMapView addGestureRecognizer:sLongPressGenstureRecognizer];
    [sLongPressGenstureRecognizer release];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    [self refreshAll];
    
    //
    if (!self.mAppearedBefore)
    {
        if ([LocationTravelingService isTraveling])
        {
            [self centerTraveledLocationIfSet];
        }
        else
        {
            [self centerDeviceLocation];
        }
        
        [self addAnnotations];
        
        self.mAppearedBefore = YES;
    }
}


- (void) refreshTravelingLocationAvailablityStatus
{
    if ([LocationTravelingService isFixedLocationAvaliable])
    {
        self.mTraveledLocationBarButtonItem.enabled = YES;
        self.mGlobalLocationButton.enabled = YES;
    }
    else
    {
        self.mTraveledLocationBarButtonItem.enabled = NO;
        self.mGlobalLocationButton.enabled = NO;
    }
}


- (void) addAnnotations
{
    CLLocation* sTravlingLocation = [self.mRegularLocationSource getMostRecentLocation];
    CLLocation* sDeviceLocation = [self.mTrueLocationSource getMostRecentLocation];

    self.mDeviceLocationAnnotation.mCoordinate = sDeviceLocation.coordinate;
    self.mTraveledLocationAnnotation.mCoordinate  = sTravlingLocation.coordinate;
    
//    [self.mMapView removeAnnotation: self.mDeviceLocationAnnotation];
    [self.mMapView addAnnotation:self.mDeviceLocationAnnotation];
    
//    [self.mMapView removeAnnotation:self.mTraveledLocationAnnotation];
    [self.mMapView addAnnotation:self.mTraveledLocationAnnotation];
    
    
}

- (void) refreshTravelingStatus
{
    if ([LocationTravelingService isTraveling])
    {
        self.mStartStopBarButtonItem.image = [UIImage imageNamed:@"pause20.png"];
        self.mInfoBoardLabel.text = @"您正在穿越...";
        [self centerTraveledLocationIfSet];
    }
    else
    {
        self.mStartStopBarButtonItem.image = [UIImage imageNamed:@"play20.png"];
        self.mInfoBoardLabel.text = @"已退出穿越";
    }
//    [self refreshAnnotations];
    [self.mMapView setNeedsDisplay];
}


- (void) refreshAll
{
    [self refreshTravelingLocationAvailablityStatus];
    [self refreshTravelingStatus];
}

- (void) presentHistoryController
{
    //test
    return;
}

- (void) presentAboutController
{
    SettingController* sAboutViewController = [[SettingController alloc] initWithTitle:@"关于"];
    UIBarButtonItem *sReturnButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"完成", nil) style:UIBarButtonItemStylePlain target:self action:@selector(returnToMainController)];
    sAboutViewController.navigationItem.rightBarButtonItem = sReturnButton;
    [sReturnButton release];
    
    UINavigationController* sNavigationControllerOfAboutVC = [[UINavigationController alloc]initWithRootViewController:sAboutViewController];
    sNavigationControllerOfAboutVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    if ([self respondsToSelector:@selector(presentViewController:animated:completion:)])
    {
        [self presentViewController:sNavigationControllerOfAboutVC animated:YES completion:nil];
    }
    else
    {
        [self presentModalViewController:sNavigationControllerOfAboutVC animated:YES];
    }

    [sAboutViewController release];
    [sNavigationControllerOfAboutVC release];

}

- (void) returnToMainController
{
    if ([self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)])
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [self dismissModalViewControllerAnimated:YES];
    }
    return;
}


//- (void) presentTraveledLocationPickerController
//{
//    TraveledLocationPickerController* sTraveledLocationPickerController = [[SettingController alloc] initWithTitle:@"选取穿越位置"];
//    sTraveledLocationPickerController.hidesBottomBarWhenPushed = YES;
//    
//    [self.navigationController pushViewController:sTraveledLocationPickerController animated:YES];
//    
//    
//    [sTraveledLocationPickerController release];
//        
//    return;
//}

- (void) startOrStopTraveling
{
    if ([LocationTravelingService isTraveling])
    {
        [LocationTravelingService stopTraveling];
        [self refreshTravelingStatus];
        [self.mMapView deselectAnnotation:self.mTraveledLocationAnnotation animated:YES];
        [[self.mMapView viewForAnnotation:self.mTraveledLocationAnnotation] setNeedsDisplay];
    }
    else
    {
        if ([LocationTravelingService isFixedLocationAvaliable])
        {
            [LocationTravelingService startTraveling];
            [self refreshTravelingStatus];
            [self.mMapView selectAnnotation:self.mTraveledLocationAnnotation animated:YES];
            [[self.mMapView viewForAnnotation:self.mTraveledLocationAnnotation] setNeedsDisplay];
        }
        else
        {
            NSLog(@"You MUST set a traveling location first.");
        }
    }
}

- (void) centerTraveledLocationIfSet
{
    if ([LocationTravelingService isFixedLocationAvaliable])
    {
        CLLocation* sLocation = [self.mRegularLocationSource getMostRecentLocation];
        [self goToLocation: sLocation];
    }
}

- (void) centerDeviceLocation
{
    CLLocation* sLocation = [self.mTrueLocationSource getMostRecentLocation];

    [self goToLocation: sLocation];
}

-(void) centerTraveledAndDeviceLocation
{
    if (![LocationTravelingService isFixedLocationAvaliable])
    {
        return;
    }
    
    CLLocation* sTravlingLocation = [self.mRegularLocationSource getMostRecentLocation];
    CLLocation* sDeviceLocation = [self.mTrueLocationSource getMostRecentLocation];
    
    CLLocationCoordinate2D sMidLocationCoordinate2D;
    sMidLocationCoordinate2D.latitude = (sTravlingLocation.coordinate.latitude + sDeviceLocation.coordinate.latitude)/2.0;
    sMidLocationCoordinate2D.longitude = (sTravlingLocation.coordinate.longitude + sDeviceLocation.coordinate.longitude)/2.0;
    
    MKCoordinateSpan sSpan;
    sSpan.latitudeDelta = fabs(sTravlingLocation.coordinate.latitude-sDeviceLocation.coordinate.latitude) + 0.1;
    sSpan.longitudeDelta = fabs(sTravlingLocation.coordinate.longitude-sDeviceLocation.coordinate.longitude) + 0.1;

//    MKCoordinateRegion sRegion;
//    sRegion.center = sMidLocationCoordinate2D;
//    sRegion.span = sSpan;
    
//    [self.mMapView setRegion: sRegion animated: YES];
    
    CLLocation* sLocation = [[[CLLocation alloc] initWithLatitude: sMidLocationCoordinate2D.latitude longitude:sMidLocationCoordinate2D.longitude] autorelease];
    [self goToLocation:sLocation span: sSpan animated: YES];
    
    return;
}

- (void) goToLocation: (CLLocation*)aLocation
{
    MKCoordinateSpan sSpan;
    sSpan.latitudeDelta=0.1;
    sSpan.longitudeDelta=0.1;

    [self goToLocation: aLocation span: sSpan animated:YES];
}


- (void) goToLocation: (CLLocation*)aLocation span:(MKCoordinateSpan)aSpan animated:(BOOL)animated
{    
    MKCoordinateRegion sRegion;
    sRegion.center = aLocation.coordinate;
    sRegion.span = aSpan;
    
    [self.mMapView setRegion: sRegion animated: animated];
}

#pragma mark - MKMapViewDelegate methods
- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    // if it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
  
    if ([annotation isEqual: self.mDeviceLocationAnnotation])
    {
        MKAnnotationView* sPinView = (MKAnnotationView *)[self.mMapView dequeueReusableAnnotationViewWithIdentifier:@"customAnnotationView"];
        if (!sPinView)
        {
            sPinView = [[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"customAnnotationView"] autorelease];
            //        sPinView.animatesDrop = YES;
            sPinView.canShowCallout = YES;
        }
        else
        {
            sPinView.annotation = annotation;
        }
        sPinView.image = [UIImage imageNamed:@"currenlocation24.png"];
        return sPinView;
    }
    else if ([annotation isEqual: self.mTraveledLocationAnnotation])
    {
        MKPinAnnotationView* sPinView = (MKPinAnnotationView *)[self.mMapView dequeueReusableAnnotationViewWithIdentifier:@"pinAnnotationView"];
        if (!sPinView)
        {
            sPinView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pinAnnotationView"] autorelease];
            sPinView.animatesDrop = YES;
            sPinView.canShowCallout = YES;
            sPinView.pinColor = MKPinAnnotationColorRed;
        }
        else
        {
            sPinView.annotation = annotation;
        }
        return sPinView;
    }
    else
    {
        return nil;
    }

}

- (void)longPressOnMapview:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
    
    CGPoint sTouchPoint = [gestureRecognizer locationInView:self.mMapView];
    CLLocationCoordinate2D sTouchMapCoordinate = [self.mMapView convertPoint:sTouchPoint toCoordinateFromView:self.mMapView];
    
    //1. remove the last annotation
    [self.mMapView removeAnnotation:self.mTraveledLocationAnnotation];
    self.mTraveledLocationAnnotation.mCoordinate = sTouchMapCoordinate;
    
    //2. add new annotation and select it to show its annotationview
    [self.mMapView addAnnotation: self.mTraveledLocationAnnotation];
    [self.mMapView selectAnnotation:self.mTraveledLocationAnnotation animated:YES];

    //3. update new fixed location.
    [LocationTravelingService setFixedLocation:[[[CLLocation alloc] initWithLatitude: sTouchMapCoordinate.latitude longitude: sTouchMapCoordinate.longitude] autorelease]];

}


@end

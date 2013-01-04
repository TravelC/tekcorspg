#import <QuartzCore/QuartzCore.h>
#import "MainViewController.h"
#import "AboutViewController.h"
#import "TraveledLocationPickerController.h"
#import "LocationTravelingService.h"
#import "SharedVariables.h"

#define TRAVELING_DISTNACE_ALLOWED  5000 //in meters

@implementation MainViewController
@synthesize mMapView;
@synthesize mStartStopBarButtonItem;
@synthesize mTraveledLocationBarButtonItem;
@synthesize mGlobalLocationButton;
@synthesize mInfoBoardLabel;
@synthesize mDeviceLocationAnnotation;
@synthesize mTraveledLocationAnnotation;
@synthesize mCircle;
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
        self.mTrueLocationSource.mDelegate = self;
        
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
    self.mCircle = nil;
    self.mDeviceLocationAnnotation = nil;
    self.mTraveledLocationAnnotation = nil;
    self.mRegularLocationSource = nil;
    self.mTrueLocationSource = nil;
    
    [super dealloc];
}

- (void)loadView {
    

    CGRect sAppFrame = [[UIScreen mainScreen] applicationFrame];
    sAppFrame.size.height -= (44+44);

    
//    NSLog(@"y: %.1f \theight:%.1f", sAppFrame.origin.y, sAppFrame.size.height);
    
	UIView* sView = [[[UIView alloc] initWithFrame:sAppFrame] autorelease];
    sView.backgroundColor = [UIColor whiteColor];
    self.view = sView;
    
//    NSLog(@"height of self.view.bounds:%.1f",self.view.bounds.size.height);

    //self.mMapView
    MKMapView* sMapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    [sMapView setMapType:MKMapTypeStandard];
    sMapView.delegate = self;
//    sMapView.showsUserLocation = YES;
    
    [self.view addSubview: sMapView];
    self.mMapView = sMapView;
    [sMapView release];
    
    //self.mInfoBoard
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
    [sGlobalViewButton setFrame: CGRectMake(self.view.bounds.size.width-27-10, self.view.bounds.size.height-27-10, 27, 27)];
    [sGlobalViewButton setImage: [UIImage imageNamed:@"globalview20.png"] forState:UIControlStateNormal];
    sGlobalViewButton.layer.cornerRadius  = 4;
    sGlobalViewButton.backgroundColor = COLOR_FLOAT_BUTTON_ON_MAP;
    [sGlobalViewButton addTarget: self action:@selector(showGlobalView) forControlEvents: UIControlEventTouchDown];
    [self.view addSubview: sGlobalViewButton]; 
    
    self.mGlobalLocationButton = sGlobalViewButton;
    
    

    //
    UILongPressGestureRecognizer* sLongPressGenstureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressOnMapview:)];
//    sLongPressGenstureRecognizer.minimumPressDuration = 0.4;
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
        [self addAnnotations];
        [self addOverlay];
        if ([LocationTravelingService isTraveling])
        {
            [self centerTraveledLocationIfSetWithSelection:NO];
        }
        else
        {
            [self showGlobalView];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
    
    //
    if (!self.mAppearedBefore)
    {
        if ([LocationTravelingService isTraveling])
        {
            [self.mMapView selectAnnotation:self.mTraveledLocationAnnotation animated:YES];
        }
        else
        {
//            [self.mMapView selectAnnotation:self.mDeviceLocationAnnotation animated:YES];
        }
        self.mAppearedBefore = YES;
    }
}



- (void) refreshTravelingLocationAvailablityStatus
{
    if ([LocationTravelingService isFixedLocationAvaliable])
    {
        self.mTraveledLocationBarButtonItem.enabled = YES;
    }
    else
    {
        self.mTraveledLocationBarButtonItem.enabled = NO;
    }
}


- (void) addAnnotations
{
    CLLocation* sDeviceLocation = [self.mTrueLocationSource getMostRecentLocation];
    if (sDeviceLocation)
    {
        self.mDeviceLocationAnnotation.mCoordinate = sDeviceLocation.coordinate;
        [self.mMapView addAnnotation:self.mDeviceLocationAnnotation];
    }

    CLLocation* sTravlingLocation = [self.mRegularLocationSource getMostRecentLocation];
    if (sTravlingLocation)
    {
        self.mTraveledLocationAnnotation.mCoordinate  = sTravlingLocation.coordinate;
        [self.mMapView addAnnotation:self.mTraveledLocationAnnotation];
    }
}

- (void) addOverlay
{
    CLLocation* sDeviceLocation = [self.mTrueLocationSource getMostRecentLocation];

    self.mCircle = [MKCircle circleWithCenterCoordinate:sDeviceLocation.coordinate radius:TRAVELING_DISTNACE_ALLOWED];
    
    [self.mMapView addOverlay:self.mCircle];
}

- (void) switchTravelingStatusNotice
{
    if ([LocationTravelingService isTraveling])
    {
        self.mStartStopBarButtonItem.image = [UIImage imageNamed:@"pause20.png"];
        self.mInfoBoardLabel.text = @"您正在穿越...";
    }
    else
    {
        self.mStartStopBarButtonItem.image = [UIImage imageNamed:@"play20.png"];
        self.mInfoBoardLabel.text = @"已退出穿越";
    }
}


- (void) refreshAll
{
    [self refreshTravelingLocationAvailablityStatus];
    [self switchTravelingStatusNotice];
}

- (void) presentHistoryController
{
    //test
    return;
}

- (void) presentAboutController
{
    AboutViewController* sAboutViewController = [[AboutViewController alloc] initWithTitle:@"关于"];
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

- (void) startOrStopTraveling
{
    if ([LocationTravelingService isTraveling])
    {
        [LocationTravelingService stopTraveling];
        [self switchTravelingStatusNotice];
        [self.mMapView deselectAnnotation:self.mTraveledLocationAnnotation animated:YES];
        [[self.mMapView viewForAnnotation:self.mTraveledLocationAnnotation] setNeedsDisplay];
    }
    else
    {
        if ([LocationTravelingService isFixedLocationAvaliable])
        {
            [LocationTravelingService startTraveling];
            [self centerTraveledLocationIfSet];
            [self switchTravelingStatusNotice];
            [self.mMapView selectAnnotation:self.mTraveledLocationAnnotation animated:YES];
            [[self.mMapView viewForAnnotation:self.mTraveledLocationAnnotation] setNeedsDisplay];
        }
        else
        {
            NSLog(@"You MUST set a traveling location first.");
            NSString* sNotice = @"请用手指长按蓝色圆圈范围内，以选取穿越位置";
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提醒" message:sNotice 	delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            [alert release];

        }
    }
}

- (void) centerTraveledLocationIfSetWithSelection:(BOOL)aSelecting
{
    if ([LocationTravelingService isFixedLocationAvaliable])
    {
        CLLocation* sLocation = [self.mRegularLocationSource getMostRecentLocation];
        [self goToLocation: sLocation];
        if (aSelecting)
        {
            [self.mMapView selectAnnotation:self.mTraveledLocationAnnotation animated:YES];
        }
    }
}

- (void) centerDeviceLocationWithSelection:(BOOL)aSelecting
{
    CLLocation* sLocation = [self.mTrueLocationSource getMostRecentLocation];

    [self goToLocation: sLocation];
    if (aSelecting)
    {
        [self.mMapView selectAnnotation:self.mDeviceLocationAnnotation animated:YES];  
    }

}

- (void) centerTraveledLocationIfSet
{
    [self centerTraveledLocationIfSetWithSelection: YES];
}

- (void) centerDeviceLocation
{
    [self centerDeviceLocationWithSelection: YES];
}

-(void) showGlobalView
{
    [self.mMapView setVisibleMapRect:self.mCircle.boundingMapRect animated:YES];
    return;
}

- (void) goToLocation: (CLLocation*)aLocation
{
    MKCoordinateSpan sSpan;
    
    sSpan.latitudeDelta=0.005;
    sSpan.longitudeDelta=0.005;

    [self goToLocation: aLocation span: sSpan animated:YES];
}


- (void) goToLocation: (CLLocation*)aLocation span:(MKCoordinateSpan)aSpan animated:(BOOL)animated
{    
    MKCoordinateRegion sRegion;
    sRegion.center = aLocation.coordinate;
    sRegion.span = aSpan;
    
    [self.mMapView setRegion: sRegion animated: animated];
}

- (void)longPressOnMapview:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
    
    CGPoint sTouchPoint = [gestureRecognizer locationInView:self.mMapView];
    CLLocationCoordinate2D sTouchMapCoordinate = [self.mMapView convertPoint:sTouchPoint toCoordinateFromView:self.mMapView];
    
    if ([self canSetTravelingLocationAt: [[[CLLocation alloc] initWithLatitude:sTouchMapCoordinate.latitude longitude: sTouchMapCoordinate.longitude] autorelease]])
    {
        //1. remove the last annotation
        [self.mMapView removeAnnotation:self.mTraveledLocationAnnotation];
        
        //2. update mTraveledLocationAnnotation's location
        self.mTraveledLocationAnnotation.mCoordinate = sTouchMapCoordinate;
        
        //3. enable travling location view button if needed
        if (![LocationTravelingService isFixedLocationAvaliable])
        {
            self.mTraveledLocationBarButtonItem.enabled = YES;
        }
        
        //4. add new annotation
        [self.mMapView addAnnotation: self.mTraveledLocationAnnotation];
        
        //5. update new fixed location.
        [LocationTravelingService setFixedLocation:[[[CLLocation alloc] initWithLatitude: sTouchMapCoordinate.latitude longitude: sTouchMapCoordinate.longitude] autorelease]];
        
        //6. select new annotation to show its annotationview
        [self.mMapView selectAnnotation:self.mTraveledLocationAnnotation animated:YES];

    }
    else
    {
        NSLog(@"Sorry, for the time being, you can only travel within the shadow circle.");
        NSString* sNotice = [NSString stringWithFormat:@"您现在的穿越范围是%dkm（蓝色圆圈以内），请下载新版本以扩大范围", TRAVELING_DISTNACE_ALLOWED/1000];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提醒" message:sNotice 	delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [alert release];

    }
}

- (BOOL) canSetTravelingLocationAt:(CLLocation*)aLocation
{
    CLLocation* sCurrentLocation = [self.mTrueLocationSource getMostRecentLocation];
    
    CLLocationDistance sDistance = [sCurrentLocation distanceFromLocation:aLocation];
    
    if (sDistance <= TRAVELING_DISTNACE_ALLOWED)
    {
        return YES;
    }
    else
    {
        //test
//        return YES;
        return NO;
    }
}


#pragma mark - LocationSourceDelegate

/*
- (void) locationSource:(id)aLocationSource withNewLocation:(CLLocation*)aNewLocation oldLocation:(CLLocation*)aOldLocation
{
    NSLog(@"zzzzz");

    if ([aLocationSource isEqual: self.mTrueLocationSource])
    {
        NSLog(@"1111111");

        //refresh annotation and overlay of device location.
        if (aNewLocation.coordinate.latitude != self.mDeviceLocationAnnotation.coordinate.latitude ||
            aNewLocation.coordinate.longitude != self.mDeviceLocationAnnotation.coordinate.longitude)
        {
            NSLog(@"22222");

            NSLog(@"a: 经度：%.4f \t 纬度：%.4f", self.mDeviceLocationAnnotation.coordinate.longitude, self.mDeviceLocationAnnotation.coordinate.latitude);
            //annotation.
            [self.mMapView removeAnnotation: self.mDeviceLocationAnnotation];
            self.mDeviceLocationAnnotation.mCoordinate = aNewLocation.coordinate;
            NSLog(@"b: 经度：%.4f \t 纬度：%.4f", self.mDeviceLocationAnnotation.coordinate.longitude, self.mDeviceLocationAnnotation.coordinate.latitude);

            
            [self.mMapView addAnnotation: self.mDeviceLocationAnnotation];

            //overlay.
            [self.mMapView removeOverlay:self.mCircle];
            self.mCircle = [MKCircle circleWithCenterCoordinate:self.mDeviceLocationAnnotation.coordinate radius:TRAVELING_DISTNACE_ALLOWED];
            [self.mMapView addOverlay:self.mCircle];
            
        }
    }
}
*/

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

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id < MKOverlay >)overlay
{
    MKCircleView* circleView = [[[MKCircleView alloc] initWithOverlay:overlay] autorelease];
    circleView.strokeColor = [UIColor blueColor];
    circleView.lineWidth = 1.0;
    circleView.lineDashPhase = 15;
    //Uncomment below to fill in the circle
//    circleView.fillColor = [UIColor redColor];
    return circleView;
}


@end

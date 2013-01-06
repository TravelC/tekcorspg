#import <QuartzCore/QuartzCore.h>
#import "MainViewController.h"
#import "AboutViewController.h"
#import "TraveledLocationPickerController.h"
#import "LocationTravelingService.h"
#import "SharedVariables.h"

#define TRAVELING_DISTNACE_ALLOWED  5000 //in meters

@implementation MainViewController
@synthesize mMapView;
@synthesize mDeviceLocationBarButtonItem;
@synthesize mStartStopBarButtonItem;
@synthesize mTraveledLocationBarButtonItem;
@synthesize mGlobalLocationButton;
@synthesize mInfoBoardLabel;
@synthesize mDeviceLocationAnnotation;
@synthesize mTraveledLocationAnnotation;
@synthesize mCircle;
@synthesize mTravelingLocationSource;
@synthesize mTrueLocationSource;
@synthesize mAppearedBefore;

@synthesize mLocationDelta;

@synthesize mIsInChina;;
@synthesize mLocationEnabled;

- (id) init
{
    self = [super init];
    if (self)
    {
        self.mAppearedBefore = NO;
        self.mIsInChina = [self isInChina];
        self.mLocationEnabled = NO;
        
        //1. setting return text for navigation controller push
        UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
        temporaryBarButtonItem.title = NSLocalizedString(@"Return", nil);
        self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
        [temporaryBarButtonItem release];

        //2. set bar items on navigation bar; ver weird tool bar items setting here does not work.
        self.title = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        
        UIButton* sButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
        sButton.showsTouchWhenHighlighted = NO;
        [sButton addTarget:self action:@selector(presentAboutController) forControlEvents:UIControlEventTouchDown];
        UIBarButtonItem* sAboutBarButton = [[UIBarButtonItem alloc]initWithCustomView:sButton];
        self.navigationItem.rightBarButtonItem = sAboutBarButton;
        [sAboutBarButton release];
        
        
        
        //3. set annotation.
        self.mDeviceLocationAnnotation = [[[MyLocationAnnotation alloc] initWithTitle:NSLocalizedString(@"Current Location", nil)] autorelease];
        self.mTraveledLocationAnnotation = [[[MyLocationAnnotation alloc] initWithTitle:NSLocalizedString(@"Target Location", nil)] autorelease];

        //set location source
        self.mTravelingLocationSource = [LocationSource getRegularLocationSource];
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
    self.mDeviceLocationBarButtonItem = nil;
    self.mStartStopBarButtonItem = nil;
    self.mTraveledLocationBarButtonItem = nil;
    self.mGlobalLocationButton = nil;
    self.mInfoBoardLabel = nil;
    self.mCircle = nil;
    self.mDeviceLocationAnnotation = nil;
    self.mTraveledLocationAnnotation = nil;
    self.mTravelingLocationSource = nil;
    self.mTrueLocationSource = nil;
    
    self.mLocationDelta = nil;
    
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
    sMapView.showsUserLocation = YES;
//    [sMapView setUserTrackingMode:MKUserTrackingModeFollow animated:NO];
    [sMapView.userLocation addObserver:self forKeyPath:@"location" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:nil];
    
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
    sLabel.numberOfLines = 0;
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

    UIBarButtonItem* sCurrentLocationBarButtonItem = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed:@"current_location20.png"] style:UIBarButtonItemStylePlain target:self action:@selector(showDeviceLocationView)];
    self.mDeviceLocationBarButtonItem = sCurrentLocationBarButtonItem;
    
    UIBarButtonItem* sSpacerBarButtonItem =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil ];
    
     UIBarButtonItem* sStartStopBarButtonItem = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed:@"play20.png"] style:UIBarButtonItemStyleDone target:self action:@selector(startOrStopTraveling)];
    self.mStartStopBarButtonItem = sStartStopBarButtonItem;

    
    UIBarButtonItem* sSpacerBarButtonItem2 =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil ];
    
    UIBarButtonItem* sTraveledLocationBarButtonItem = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed:@"travelinglocation20.png"] style: UIBarButtonItemStylePlain target:self action:@selector(showTravelingLocationView)];
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
    
    
    [self refreshTravelingLocationAvailablityStatus];
    [self refreshTravelingStatusNotice];


}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    if (!self.mAppearedBefore)
    {
//        [self refreshTravelingLocationAvailablityStatus];
//        [self refreshTravelingStatusNotice];
    }
   
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];    
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

- (void) refreshTravelingStatusNotice
{
    if ([LocationTravelingService isTraveling])
    {
        self.mStartStopBarButtonItem.image = [UIImage imageNamed:@"pause20.png"];
        self.mInfoBoardLabel.text = NSLocalizedString(@"Exploring On...", nil);
    }
    else
    {
        self.mStartStopBarButtonItem.image = [UIImage imageNamed:@"play20.png"];
        self.mInfoBoardLabel.text =  NSLocalizedString(@"Exploring Off...", nil);
    }
}

- (void) refreshWhenLocationEnabledChange
{
    if (self.mLocationEnabled)
    {
        self.mDeviceLocationBarButtonItem.enabled = YES;
        [self refreshTravelingLocationAvailablityStatus];
        self.mStartStopBarButtonItem.enabled = YES;
        self.mGlobalLocationButton.enabled = YES;
        
        [self refreshTravelingStatusNotice];
    }
    else
    {
        self.mDeviceLocationBarButtonItem.enabled = NO;
        self.mTraveledLocationBarButtonItem.enabled = NO;
        self.mStartStopBarButtonItem.enabled = NO;
        self.mGlobalLocationButton.enabled = NO;
        
        self.mInfoBoardLabel.text =  NSLocalizedString(@"Location service unvailable, check your settings please.", nil);
    }
}

#pragma mark - mapview decoration methods
////////////////////////////////////////////////////
- (void) decorateMapview
{
    if (!self.mAppearedBefore)
    {
        [self addAnnotations];
        [self addOverlay];
        
        if ([LocationTravelingService isTraveling])
        {
            [self showTravelingLocationViewWithAnnotation:NO];
            [self selectAnnotation:self.mTraveledLocationAnnotation AfterDelay:2];
        }
        else
        {
            [self showGlobalView];
        }
                
        self.mAppearedBefore = YES;
    }

}

- (void) addAnnotations
{
    CLLocation* sDeviceLocation = [self.mTrueLocationSource getMostRecentLocation];
        
    if (sDeviceLocation)
    {
        CLLocationCoordinate2D sAdjustedDeviceCoordinate = [self adjustLocationCoordinate: sDeviceLocation.coordinate Reverse: NO];
        self.mDeviceLocationAnnotation.mCoordinate = sAdjustedDeviceCoordinate;
        [self.mMapView addAnnotation:self.mDeviceLocationAnnotation];
    }

    CLLocation* sTravlingLocation = [self.mTravelingLocationSource getMostRecentLocation];
    
    if (sTravlingLocation)
    {
#ifdef DEBUG
        NSLog(@"_________B1:sTravlingLocation.coordinate: %@：%.4f \t %@：%.4f",NSLocalizedString(@"Longitude", nil), sTravlingLocation.coordinate.longitude, NSLocalizedString(@"Latitude", nil), sTravlingLocation.coordinate.latitude);
#endif
        
        CLLocationCoordinate2D sAdjustedTravelingCoordinate = [self adjustLocationCoordinate: sTravlingLocation.coordinate Reverse: NO];
#ifdef DEBUG
        NSLog(@"_________B2:sAdjustedTravelingCoordinate: %@：%.4f \t %@：%.4f",NSLocalizedString(@"Longitude", nil), sAdjustedTravelingCoordinate.longitude, NSLocalizedString(@"Latitude", nil), sAdjustedTravelingCoordinate.latitude);
#endif

        
        self.mTraveledLocationAnnotation.mCoordinate  = sAdjustedTravelingCoordinate;
        [self.mMapView addAnnotation:self.mTraveledLocationAnnotation];
    }
}

- (void) addOverlay
{
    CLLocation* sDeviceLocation = [self.mTrueLocationSource getMostRecentLocation];

    CLLocation* sAdjustedDeviceLocation = [self adjustLocation: sDeviceLocation];
    
    self.mCircle = [MKCircle circleWithCenterCoordinate:sAdjustedDeviceLocation.coordinate radius:TRAVELING_DISTNACE_ALLOWED];
    
    [self.mMapView addOverlay:self.mCircle];
}


#pragma mark - about controller methods
////////////////////////////////////////////////////

- (void) presentAboutController
{
    AboutViewController* sAboutViewController = [[AboutViewController alloc] initWithTitle:NSLocalizedString(@"About", nil)];
    UIBarButtonItem *sReturnButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil) style:UIBarButtonItemStylePlain target:self action:@selector(returnToMainController)];
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


#pragma mark - methods respoding to user events
////////////////////////////////////////////////////

- (void) startOrStopTraveling
{
    if ([LocationTravelingService isTraveling])
    {
        [LocationTravelingService stopTraveling];
        [self refreshTravelingStatusNotice];
        [self.mMapView deselectAnnotation:self.mTraveledLocationAnnotation animated:YES];
        [[self.mMapView viewForAnnotation:self.mTraveledLocationAnnotation] setNeedsDisplay];
    }
    else
    {
        if ([LocationTravelingService isFixedLocationAvaliable])
        {
            [LocationTravelingService startTraveling];
            [self showTravelingLocationView];
            [self refreshTravelingStatusNotice];
            [self.mMapView selectAnnotation:self.mTraveledLocationAnnotation animated:YES];
            [[self.mMapView viewForAnnotation:self.mTraveledLocationAnnotation] setNeedsDisplay];
        }
        else
        {
#ifdef DEBUG
            NSLog(@"You MUST set a traveling location first.");
#endif
            NSString* sNotice = NSLocalizedString(@"To set target location, please long press the map in the area of the blue circle", nil);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notice", nil) message:sNotice 	delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [alert show];
            [alert release];

        }
    }
}

- (void)longPressOnMapview:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
    
    CGPoint sTouchPoint = [gestureRecognizer locationInView:self.mMapView];
    CLLocationCoordinate2D sTouchMapCoordinate = [self.mMapView convertPoint:sTouchPoint toCoordinateFromView:self.mMapView];
    
    if ([self canSetTravelingLocationAt: [[[CLLocation alloc] initWithLatitude:sTouchMapCoordinate.latitude longitude: sTouchMapCoordinate.longitude] autorelease]])
    {
        
        //0. adjust touched location
        CLLocationCoordinate2D sAdjustedTouchCoordinate2D = [self adjustLocationCoordinate: sTouchMapCoordinate Reverse:YES];
        
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
        [LocationTravelingService setFixedLocation:[[[CLLocation alloc] initWithLatitude:sAdjustedTouchCoordinate2D.latitude longitude: sAdjustedTouchCoordinate2D.longitude] autorelease]];
        
        //6. select new annotation to show its annotationview
        [self.mMapView selectAnnotation:self.mTraveledLocationAnnotation animated:YES];
        
    }
    else
    {
//        NSLog(@"Sorry, for the time being, you can only travel within the shadow circle.");
        NSString* sNotice = [NSString stringWithFormat:NSLocalizedString(@"For now, you can only explore places within %d kilometer(s). Update and explore around the globe.", nil), TRAVELING_DISTNACE_ALLOWED/1000];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notice",nil) message:sNotice 	delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

#pragma mark - utility methods
////////////////////////////////////////////////////

- (void) selectAnnotationImp:(NSTimer*)timer
{
    NSDictionary* sDict = [timer userInfo];
    
    id<MKAnnotation> sAnnotation = [sDict objectForKey:@"annotation"];
    
    if (sAnnotation)
    {
        [self.mMapView selectAnnotation:sAnnotation animated:YES];
    }
}

- (void) selectAnnotation:(id<MKAnnotation>)aAnnotation AfterDelay:(NSTimeInterval)aSeconds
{
    
    NSDictionary* sDict = [NSDictionary dictionaryWithObject: aAnnotation forKey:@"annotation"];
    NSTimer* sTimer = [[[NSTimer alloc] initWithFireDate: [NSDate dateWithTimeIntervalSinceNow:aSeconds]interval:0 target:self selector: @selector(selectAnnotationImp:) userInfo:sDict repeats:NO] autorelease];
    
    [[NSRunLoop currentRunLoop] addTimer:sTimer forMode:NSDefaultRunLoopMode];
}

- (BOOL) isInChina
{
    NSLocale *locale = [NSLocale currentLocale];
    NSString *countryCode = [locale objectForKey: NSLocaleCountryCode];
 
#ifdef DEBUG
    NSString *countryName = [locale displayNameForKey: NSLocaleCountryCode value:countryCode];
    NSLog(@"countryCode: %@ \tcountryName: %@", countryCode, countryName);
#endif
    
    if ([countryCode isEqualToString:@"CN"])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

#pragma mark - view showing methods
///////////////////////////////////////////////////////////////////////////////
- (void) showTravelingLocationViewWithAnnotation:(BOOL)aAnnotaionOn
{
    if ([LocationTravelingService isFixedLocationAvaliable])
    {
        CLLocation* sLocation = [self.mTravelingLocationSource getMostRecentLocation];
        [self goToLocation: sLocation];
        if (aAnnotaionOn)
        {
            [self.mMapView selectAnnotation:self.mTraveledLocationAnnotation animated:YES];
        }
    }
}

- (void) showDeviceLocationViewWithAnnotation:(BOOL)aAnnotationOn
{
    CLLocation* sLocation = [self.mTrueLocationSource getMostRecentLocation];

    [self goToLocation: sLocation];
    if (aAnnotationOn)
    {
        [self.mMapView selectAnnotation:self.mDeviceLocationAnnotation animated:YES];  
    }

}

- (void) showTravelingLocationView
{
    [self showTravelingLocationViewWithAnnotation: YES];
}

- (void) showDeviceLocationView
{
    [self showDeviceLocationViewWithAnnotation: YES];
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
    
    CLLocationCoordinate2D sAdjustedCoordinate2D = [self adjustLocationCoordinate:aLocation.coordinate Reverse:NO];
    
    sRegion.center = sAdjustedCoordinate2D;
    sRegion.span = aSpan;
    
    [self.mMapView setRegion: sRegion animated: animated];
}


#pragma mark - location set control
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
//       // return YES;
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

-(void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    //hide annotation view for userLocation.
    MKAnnotationView *ulv = [mapView viewForAnnotation:mapView.userLocation];
    ulv.hidden = YES;
}

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


#pragma mark - location drift fix
///////////////////////////////////////////////////////////////////////////////

//for now, we adjust location based on the delta of the userlocation of mapview and the device location(if it's not traveling),or that of the userlocation of mapview and the traveling location(if it's traveling).  cos the mars coordinate's delta changes dramatically for locations not near. so this delta-of-near-location-based method works only when device location and traveling location are in the same small region.
- (CLLocationCoordinate2D) adjustLocationCoordinate:(CLLocationCoordinate2D)aCLLocationCoordinate2D Reverse:(BOOL)aReverse
{
    if (self.mIsInChina
        && self.mLocationDelta)
    {
        //        NSLog(@"ori: %@：%.4f \t %@：%.4f",NSLocalizedString(@"Longitude", nil), aCLLocationCoordinate2D.longitude, NSLocalizedString(@"Latitude", nil), aCLLocationCoordinate2D.latitude);
        //
        
        //        NSLog(@"delta: %@：%.4f \t %@：%.4f",NSLocalizedString(@"Longitude", nil), self.mLocationDelta.coordinate.longitude, NSLocalizedString(@"Latitude", nil), self.mLocationDelta.coordinate.latitude);
        
        
        CLLocationCoordinate2D sCoordindate2D;
        if (!aReverse)
        {
            sCoordindate2D.latitude = aCLLocationCoordinate2D.latitude + self.mLocationDelta.coordinate.latitude;
            sCoordindate2D.longitude = aCLLocationCoordinate2D.longitude + self.mLocationDelta.coordinate.longitude;
        }
        else
        {
            sCoordindate2D.latitude = aCLLocationCoordinate2D.latitude - self.mLocationDelta.coordinate.latitude;
            sCoordindate2D.longitude = aCLLocationCoordinate2D.longitude - self.mLocationDelta.coordinate.longitude;
        }
        
        //        NSLog(@"adjusted: %@：%.4f \t %@：%.4f",NSLocalizedString(@"Longitude", nil), sCoordindate2D.longitude, NSLocalizedString(@"Latitude", nil), sCoordindate2D.latitude);
        return sCoordindate2D;
    }
    else
    {
        return aCLLocationCoordinate2D;
    }
}

- (CLLocation*) adjustLocation:(CLLocation*)aLocation
{
    CLLocationCoordinate2D sCoordindate2D = [self adjustLocationCoordinate:aLocation.coordinate Reverse:NO];
    
    CLLocation* sLocation = [[[CLLocation alloc] initWithCoordinate:sCoordindate2D altitude:aLocation.altitude horizontalAccuracy:aLocation.horizontalAccuracy verticalAccuracy:aLocation.verticalAccuracy timestamp:aLocation.timestamp] autorelease];
    
    return sLocation;
}

- (void) onDriftUpdated
{
    [self decorateMapview];
}

- (void) updateLocationDrift:(CLLocation*)aAdjustedRegularLocation
{
    if (!self.mLocationDelta
        || self.mLocationDelta.altitude == -1)
    {
        CLLocation* sOriginalLocation = nil;
        CLLocationDistance sTagForLocationDeltaType = 0;
        
        if (![LocationTravelingService isTraveling])
        {
            sOriginalLocation = [self.mTrueLocationSource getMostRecentLocation];
            sTagForLocationDeltaType = 1;
            
        }
        else
        {
            if (!self.mLocationDelta)
            {
                sOriginalLocation = [self.mTravelingLocationSource getMostRecentLocation];
                sTagForLocationDeltaType = -1;
            }
            else
            {
                return;
            }
        }
        
        CLLocationCoordinate2D sCoordindate2D;
        
        sCoordindate2D.latitude = aAdjustedRegularLocation.coordinate.latitude - sOriginalLocation.coordinate.latitude;
        sCoordindate2D.longitude = aAdjustedRegularLocation.coordinate.longitude - sOriginalLocation.coordinate.longitude;
        CLLocation* sLocationDelta = [[CLLocation alloc] initWithCoordinate:sCoordindate2D altitude:sTagForLocationDeltaType horizontalAccuracy:0 verticalAccuracy:-1 timestamp: [NSDate date]];
        
        self.mLocationDelta = sLocationDelta;
        
        [sLocationDelta release];
        
        //
        [self onDriftUpdated];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    CLLocation* sAdjustedRegularLocation = self.mMapView.userLocation.location;
    
#ifdef DEBUG
    NSLog(@"mMapView.userLocation: %@：%.4f \t %@：%.4f",NSLocalizedString(@"Longitude", nil), sAdjustedRegularLocation.coordinate.longitude, NSLocalizedString(@"Latitude", nil), sAdjustedRegularLocation.coordinate.latitude);
#endif
    
    if (!self.mLocationEnabled
        && fabs(sAdjustedRegularLocation.coordinate.latitude) < 0.1
        && fabs(sAdjustedRegularLocation.coordinate.longitude) < 0.1)
    {
        [self refreshWhenLocationEnabledChange];
        return;
    }
    else
    {
        self.mLocationEnabled = YES;
        [self refreshWhenLocationEnabledChange];
        
        // 这里就是偏移后的坐标，与用户实际坐标相减，就是当前位置的坐标偏移值
        if (self.mIsInChina)
        {
            [self updateLocationDrift: sAdjustedRegularLocation];
        }
        else
        {
            [self decorateMapview];
        }
    }
    
}


@end

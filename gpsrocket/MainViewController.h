
#import <CoreLocation/CLLocation.h>
#import <MapKit/MapKit.h>
#import "LocationSource.h"
#import "MyLocationAnnotation.h"

//MKReverseGeocoderDelegate
//CLGeocoder
@interface MainViewController: UIViewController<MKMapViewDelegate, LocationSourceDelegate>
{
    MKMapView* mMapView;
    
    UIBarButtonItem* mStartStopBarButtonItem;
    UIBarButtonItem* mTraveledLocationBarButtonItem;
    UIButton* mGlobalLocationButton;
    
    UILabel* mInfoBoardLabel;
    
    MyLocationAnnotation*  mDeviceLocationAnnotation;
    MyLocationAnnotation*  mTraveledLocationAnnotation;
    
    MKCircle* mCircle;

    LocationSource* mRegularLocationSource;
    LocationSource* mTrueLocationSource;
    
    BOOL mAppearedBefore;
}

@property (nonatomic, retain)  MKMapView* mMapView;
@property (nonatomic, retain)  UIBarButtonItem* mStartStopBarButtonItem;
@property (nonatomic, retain)  UIBarButtonItem* mTraveledLocationBarButtonItem;
@property (nonatomic, retain)  UIButton* mGlobalLocationButton;
@property (nonatomic, retain)  UILabel* mInfoBoardLabel;

@property (nonatomic, retain)  MyLocationAnnotation*  mDeviceLocationAnnotation;
@property (nonatomic, retain)  MyLocationAnnotation*  mTraveledLocationAnnotation;

@property (nonatomic, retain)  MKCircle* mCircle;

@property (nonatomic, retain)  LocationSource* mRegularLocationSource;
@property (nonatomic, retain)  LocationSource* mTrueLocationSource;

@property (nonatomic, assign)  BOOL mAppearedBefore;

- (void) refreshAll;

- (BOOL) canSetTravelingLocationAt:(CLLocation*)aLocation;


- (void) addAnnotations;
- (void) addOverlay;


- (void) centerTraveledLocationIfSet;
- (void) centerDeviceLocation;
- (void) showGlobalView;

- (void) centerDeviceLocationWithSelection:(BOOL)aSelecting;
- (void) centerTraveledLocationIfSetWithSelection:(BOOL)aSelecting;

- (void) goToLocation: (CLLocation*)aLocation;
- (void) goToLocation: (CLLocation*)aLocation span:(MKCoordinateSpan)aSpan animated:(BOOL)animated;
@end

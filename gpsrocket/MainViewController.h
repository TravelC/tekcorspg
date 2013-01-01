
#import <CoreLocation/CLLocation.h>
#import <MapKit/MapKit.h>
#import "LocationSource.h"
#import "MyLocationAnnotation.h"


@interface MainViewController: UIViewController<MKMapViewDelegate>
{
    MKMapView* mMapView;
    
    UIBarButtonItem* mStartStopBarButtonItem;
    UIBarButtonItem* mTraveledLocationBarButtonItem;
    UIButton* mGlobalLocationButton;
    
    UILabel* mInfoBoardLabel;
    
    MyLocationAnnotation*  mDeviceLocationAnnotation;
    MyLocationAnnotation*  mTraveledLocationAnnotation;

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

@property (nonatomic, retain)  LocationSource* mRegularLocationSource;
@property (nonatomic, retain)  LocationSource* mTrueLocationSource;

@property (nonatomic, assign)  BOOL mAppearedBefore;

- (void) refreshAll;
- (void) addAnnotations;

- (void) centerTraveledLocationIfSet;
- (void) centerDeviceLocation;
- (void) centerTraveledAndDeviceLocation;

- (void) goToLocation: (CLLocation*)aLocation;
- (void) goToLocation: (CLLocation*)aLocation span:(MKCoordinateSpan)aSpan animated:(BOOL)animated;
@end


#import <CoreLocation/CLLocation.h>
#import <MapKit/MapKit.h>
#import "LocationSource.h"



@interface MainViewController: UIViewController
{
    MKMapView* mMapView;
    
    LocationSource* mRegularLocationSource;
    LocationSource* mTrueLocationSource;
}

@property (nonatomic, retain)  MKMapView* mMapView;
@property (nonatomic, retain)  LocationSource* mRegularLocationSource;
@property (nonatomic, retain)  LocationSource* mTrueLocationSource;


- (void) setFixedLocation:(CLLocation*)aLocation;
- (void) unsetFixedLocation;
- (NSString*) getFixedLocationDataFilePath;


//- (void) presentHistoryController;
//- (void) presentSettingController;
//- (void) presentTraveledLocationPickerController;


- (void) goToTraveledLocationIfSet;
- (void) goToCurrentDeviceLocation;
- (void) goToLocation: (CLLocation*)aLocation;

@end

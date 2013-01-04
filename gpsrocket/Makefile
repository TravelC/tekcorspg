include theos/makefiles/common.mk

APPLICATION_NAME = GPSRocket
GPSRocket_FILES = main.m GPSRocketApplication.mm LocationTravelingService.mm MainViewController.mm  MyLocationAnnotation.mm  AboutViewController.mm TraveledLocationPickerController.mm LocationSource.mm	SVProgressHUD.m	CustomCellBackgroundView.m
GPSRocket_FRAMEWORKS = UIKit CoreGraphics QuartzCore CoreLocation MapKit
GPSRocket_LDFLAGS = -lUMFeedback	-lMobClickLibrary	-lz

include $(THEOS_MAKE_PATH)/application.mk

before-package::
	@sh before_package.sh


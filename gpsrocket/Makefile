include theos/makefiles/common.mk

APPLICATION_NAME = GPSRocket
GPSRocket_FILES = main.m GPSRocketApplication.mm LocationTravelingService.mm MainViewController.mm  MyLocationAnnotation.mm SettingController.mm TraveledLocationPickerController.mm LocationSource.mm
GPSRocket_FRAMEWORKS = UIKit CoreGraphics QuartzCore CoreLocation MapKit

include $(THEOS_MAKE_PATH)/application.mk

before-package::
	@sh before_package.sh


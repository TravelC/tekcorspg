include theos/makefiles/common.mk

APPLICATION_NAME = GPSRocket
GPSRocket_FILES = main.m GPSRocketApplication.mm RootViewController.mm
GPSRocket_FRAMEWORKS = UIKit CoreGraphics CoreLocation

include $(THEOS_MAKE_PATH)/application.mk

before-package::
	@sh before_package.sh


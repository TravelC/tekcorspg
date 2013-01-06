//
//  SVProgressHUD.h
//
//  Created by Sam Vermette on 27.03.11.
//  Copyright 2011 Sam Vermette. All rights reserved.
//
//  https://github.com/samvermette/SVProgressHUD
//

#import <UIKit/UIKit.h>
#import <AvailabilityMacros.h>

enum {
    SVProgressHUDMaskTypeNone = 1, // allow user interactions while HUD is displayed
    SVProgressHUDMaskTypeClear, // don't allow
    SVProgressHUDMaskTypeBlack, // don't allow and dim the UI in the back of the HUD
    SVProgressHUDMaskTypeGradient // don't allow and dim the UI with a a-la-alert-view bg gradient
};

typedef NSUInteger SVProgressHUDMaskType;


@interface SVProgressHUD : UIView
{
    UIWindow* mOrignalKeyWindow;;

    
    SVProgressHUDMaskType maskType;
    NSTimer *fadeOutTimer;
    UIWindow *overlayWindow;
    
    UIView *hudView;
    UILabel *stringLabel;
    UIImageView *imageView;
    UIActivityIndicatorView *spinnerView;
    CGFloat visibleKeyboardHeight;
}
@property (nonatomic, retain) UIWindow *mOrignalKeyWindow;


@property (nonatomic, assign) SVProgressHUDMaskType maskType;
@property (nonatomic, retain) NSTimer *fadeOutTimer;

@property (nonatomic, retain) UIWindow *overlayWindow;
@property (nonatomic, retain) UIView *hudView;
@property (nonatomic, retain) UILabel *stringLabel;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UIActivityIndicatorView *spinnerView;

@property (nonatomic, assign) CGFloat visibleKeyboardHeight;

- (void) constructAllViews;


- (void)showWithStatus:(NSString*)string maskType:(SVProgressHUDMaskType)hudMaskType networkIndicator:(BOOL)show;
- (void)setStatus:(NSString*)string;
- (void)registerNotifications;
- (void)moveToPoint:(CGPoint)newCenter rotateAngle:(CGFloat)angle;
- (void)positionHUD:(NSNotification*)notification;

- (void)dismiss;
- (void)dismissWithStatus:(NSString*)string error:(BOOL)error;
- (void)dismissWithStatus:(NSString*)string error:(BOOL)error afterDelay:(NSTimeInterval)seconds;

+ (void)show;
+ (void)showWithStatus:(NSString*)status;
+ (void)showWithStatus:(NSString*)status maskType:(SVProgressHUDMaskType)maskType;
+ (void)showWithMaskType:(SVProgressHUDMaskType)maskType;

+ (void)showSuccessWithStatus:(NSString*)string;
+ (void)showSuccessWithStatus:(NSString *)string duration:(NSTimeInterval)duration;
+ (void)showErrorWithStatus:(NSString *)string;
+ (void)showErrorWithStatus:(NSString *)string duration:(NSTimeInterval)duration;

+ (void)setStatus:(NSString*)string; // change the HUD loading status while it's showing

+ (void)dismiss; // simply dismiss the HUD with a fade+scale out animation
+ (void)dismissWithSuccess:(NSString*)successString; // also displays the success icon image
+ (void)dismissWithSuccess:(NSString*)successString afterDelay:(NSTimeInterval)seconds;
+ (void)dismissWithError:(NSString*)errorString; // also displays the error icon image
+ (void)dismissWithError:(NSString*)errorString afterDelay:(NSTimeInterval)seconds;

+ (BOOL)isVisible;

+ (void) setBackgroudColorForHudView: (UIColor*) aBGColor;


+ (SVProgressHUD*)sharedView;


@end

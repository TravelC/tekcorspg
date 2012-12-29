#import "SettingController.h"



@implementation SettingController

- (id) initWithTitle:(NSString*)aTitle
{
    self = [super init];
    if (self)
    {
        self.title = aTitle;
    }
    return self;
}

- (void) dealloc
{
    [super dealloc];
}

- (void)loadView {
    
	UIView* sView = [[[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]] autorelease];
    sView.backgroundColor = [UIColor whiteColor];
    self.view = sView;
    
    
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    

}

@end

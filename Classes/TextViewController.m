#import "TextViewController.h"
#import "AdvancedTableViewCellsAppDelegate.h" // for SharedAdBannerView macro
#import "Constants.h"
#import "MobiSageSDK.h"
#import "WiAdView.h"
#import "CommonADView.h"
#import "AdsConfig.h"
#import "DoMobView.h"

@implementation TextViewController

@synthesize contentView,textView,index,mAdView,composeViewController;
-(void)loadAd
{
    AdsConfig* config = [AdsConfig sharedAdsConfig];
    if (![config isInitialized]) {
        [config init:@""];
    }
    
    NSString* currentAds = [config getCurrentAd];
    while (![config isCurrentAdsValid]) {
        [config toNextAd];
    }
    NSLog(@"getCurrentAd()::%@--(%d,%d)",[config getCurrentAd],config.mCurrentIndex,[config getAdsCount]);
    
    //iPad or not
    BOOL isPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);    
    if(NSOrderedSame==[AdsPlatformDomob caseInsensitiveCompare:currentAds])
    { 
        
        DoMobView* domobView = [DoMobView requestDoMobViewWithSize:isPad?DOMOB_SIZE_748x110:DOMOB_SIZE_320x48 WithDelegate:self];
        self.mAdView = domobView;
        /*
         float width = isPad?DOMOB_SIZE_748x110.width:DOMOB_SIZE_320x48.width;
         float height = isPad?DOMOB_SIZE_748x110.height:DOMOB_SIZE_320x48.height;
         domobView.frame = CGRectMake(([[UIScreen mainScreen] applicationFrame].size.width -width)/2, 0, width, height);       
         
         
         [self.view addSubview:domobView];*/
        
    }
    else if(NSOrderedSame==[AdsPlatformYoumi caseInsensitiveCompare:currentAds])
    {
        
    }
    else if(NSOrderedSame==[AdsPlatformMobisage caseInsensitiveCompare:currentAds])
    {            
        //    //一般Banner广告，320X40的banner广告，设置广告轮显效果
        int width = 320;
        int height = 40;
        int marginTop = 0;
        NSUInteger adSize = Ad_320X40;
        //NSString* publisherID = kMobiSageID_iPhone;
        if (isPad) {
            width = 748;
            height = 110;
            adSize = Ad_748X110;
            //publisherID = kMobiSageID_iPad;
        }
        //此处设置PublishID,moved to main
        //if(!sMobiSagePubliserIdSet)
        //{
        //   sMobiSagePubliserIdSet = YES;
        //  [[MobiSageManager getInstance] setPublisherID:publisherID];
        //}
        
        MobiSageAdBanner * adBanner = [[MobiSageAdBanner alloc] initWithAdSize:adSize];
        self.mAdView = adBanner;
        //设置广告轮显方式
        [adBanner setSwitchAnimeType:Random];
        adBanner.frame = CGRectMake(([[UIScreen mainScreen] applicationFrame].size.width -width)/2, marginTop, width, height);
        [self.view addSubview:adBanner];
        [adBanner release];            
    }    
    else if(NSOrderedSame==[AdsPlatformWooboo caseInsensitiveCompare:currentAds])
    {
        CommonADView* myCommonADView = [[CommonADView alloc] initWithPID:kWoobooPublisherID
                                                                  status:NO
                                                               locationX:0 
                                                               locationY:0 
                                                             displayType:CommonBannerScreen 
                                                       screenOrientation:CommonOrientationPortrait];
        self.mAdView = myCommonADView;
        [self.view addSubview:myCommonADView];
        [myCommonADView release];
        CGRect frame = [UIScreen mainScreen].bounds;
        [myCommonADView setDisplayType:CommonBannerScreen 
                             locationX:(frame.size.width-myCommonADView.frame.size.width)/2 
                             locationY:myCommonADView.frame.origin.y];
        [myCommonADView startADRequest];
    }    
    else
    {
        NSString* publisherID = kWiyunID_iPhone;
        WiAdViewStyle style = kWiAdViewStyleBanner320_50;
        if(isPad)
        {
            publisherID = kWiyunID_iPad;
            style = kWiAdViewStyleBanner768_110;
        }
        
        //创建广告窗口
        WiAdView* adView = [WiAdView adViewWithResId:publisherID style:style];
        self.mAdView = adView;
        //设置Delegate对象
        adView.delegate = self;
        //设置广告背景色
        adView.adBgColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0f];
        adView.adTextColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:1.0f];
        //把广告窗口加入窗口View
        [self.view addSubview:adView];
        //开始请求广告窗口
        [adView requestAd];
    }
    
    CGSize adSize = mAdView.frame.size;	    
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    int screenWidth = [[UIScreen mainScreen]bounds].size.width;
    if (UIDeviceOrientationIsLandscape(deviceOrientation))
        screenWidth = [[UIScreen mainScreen]bounds].size.height;
    CGRect frame = mAdView.frame;
	frame.origin.x = (screenWidth - adSize.width)/2;
    mAdView.frame = frame;
    
    //index adjusted
    [config toNextAd];
    while (![config isCurrentAdsValid]) {
        [config toNextAd];
    }
}
#pragma mark -
#pragma mark DoMobDelegate methods
- (UIViewController *)domobCurrentRootViewControllerForAd:(DoMobView *)doMobView
{
	return self;
}

- (NSString *)domobPublisherIdForAd:(DoMobView *)doMobView
{
	// 请到www.domob.cn网站注册获取自己的publisher id
	return kDomobPubliserID;
}

// 发布前请取消下面函数的注释

- (NSString *)domobKeywords
{
    return @"iPhone,game";
}
/*
 - (NSString *)domobPostalCode
 {
 return @"100032";
 }
 
 - (NSString *)domobDateOfBirth
 {
 return @"20101211";
 }
 
 - (NSString *)domobGender
 {
 return @"male";
 }
 
 - (double)domobLocationLongitude
 {
 return 391.0;
 }
 
 - (double)domobLocationLatitude
 {
 return -200.1;
 }
 */
- (NSString *)domobSpot:(DoMobView *)doMobView;
{
	return @"all";
}

// Sent when an ad request loaded an ad; 
// it only send once per DoMobView
- (void)domobDidReceiveAdRequest:(DoMobView *)doMobView
{
    mAdView.frame = CGRectMake((self.view.frame.size.width - self.mAdView.frame.size.width)/2,0, self.mAdView.frame.size.width, self.mAdView.frame.size.height);
	[self.view addSubview:self.mAdView];
}

- (void)domobDidFailToReceiveAdRequest:(DoMobView *)doMobView
{
}
/*
 - (UIColor *)adBackgroundColorForAd:(DoMobView *)doMobView
 {
 return [UIColor blackColor];
 }*/

- (void)domobWillPresentFullScreenModalFromAd:(DoMobView *)doMobView
{
	NSLog(@"The view will Full Screen");
}

- (void)domobDidPresentFullScreenModalFromAd:(DoMobView *)doMobView
{
	NSLog(@"The view did Full Screen");
}

- (void)domobWillDismissFullScreenModalFromAd:(DoMobView *)doMobView
{
	NSLog(@"The view will Dismiss Full Screen");
}

- (void)domobDidDismissFullScreenModalFromAd:(DoMobView *)doMobView
{
	NSLog(@"The view did Dismiss Full Screen");
}
#pragma mark -
#pragma mark 广告窗口Delegate函数

- (BOOL)WiAdUseTestMode:(WiAdView*)adView{
    //返回是否使用测试模式
    return NO;
}

- (int)WiAdTestAdType:(WiAdView*)adView{
    //返回测试广告类型
    return TEST_WIAD_TYPE_BANNER;
}

- (void)WiAdDidLoad:(WiAdView*)adView{
    //广告加载成功    
    [adView setHidden:NO];
}

- (void)WiAdDidFailLoad:(WiAdView*)adView{
    //广告加载失败
    [adView setHidden:YES];
}



-(id)initWithIndexPath:(NSIndexPath*)indexPath
{
    self = [super init];
    if(self)
    {
        self.index = indexPath;
        delegate = SharedDelegate;
    }
    return self;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)popupShareOption
{
    UIActionSheet* actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:NSLocalizedString(@"ShareTip",@"")
                                  delegate:self cancelButtonTitle:NSLocalizedString(@"Back", @"")
                                  destructiveButtonTitle:NSLocalizedString(@"EmailAlertViewTitle",@"") otherButtonTitles:nil];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{    
    switch (buttonIndex) {
        case kShareByEmail:
            [self emailShare];
            break;
            
        default:
            break;
    }
}
#pragma mark -
#pragma mark Workaround

// Launches the Mail application on the device.
-(void)launchMailAppOnDevice
{
    //    NSString *recipients = @"mailto:first@example.com?cc=second@example.com,third@example.com&subject=Hello from California!";
    //    NSString *body = @"&body=It is raining in sunny California!";
    
    NSString* content = [NSString stringWithFormat:@"<a href=\"%@\">%@</a>\r\n\n\n%@",delegate.mTrackViewUrl,delegate.mTrackName,[delegate getContent:index.row]];
    
    NSString *email = [NSString stringWithFormat:@"mailto:ramonqlee1980@gmail.com&subject=%@&body=%@", [delegate getTitle:index.row], content];
    email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}


#pragma mark -
#pragma mark Compose Mail

// Displays an email composition interface inside the application. Populates all the Mail fields. 
-(void)displayComposerSheet 
{
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    [picker setSubject:[delegate getTitle:index.row]];
    
    NSString* content = [NSString stringWithFormat:@"<a href=\"%@\">%@</a>\r\n\n\n%@",delegate.mTrackViewUrl,delegate.mTrackName,[delegate getContent:index.row]];
    [picker setMessageBody:content isHTML:YES]; 
    
    // Set up recipients
    //    NSArray *toRecipients = [NSArray arrayWithObject:@"first@example.com"]; 
    //    NSArray *bccRecipients = [NSArray arrayWithObjects:@"second@example.com", @"third@example.com", nil]; 
    NSArray *ccRecipients = [NSArray arrayWithObject:@"ramonqlee1980@gmail.com"]; 
    //    
    //    [picker setToRecipients:toRecipients];
    [picker setCcRecipients:ccRecipients];  
    //    [picker setBccRecipients:bccRecipients];
    
    // Attach an image to the email
    //    NSString *path = [[NSBundle mainBundle] pathForResource:@"rainy" ofType:@"png"];
    //    NSData *myData = [NSData dataWithContentsOfFile:path];
    //    [picker addAttachmentData:myData mimeType:@"image/png" fileName:@"rainy"];
    //    
    //    // Fill out the email body text
    //    NSString *emailBody = @"It is raining in sunny California!";
    //    [picker setMessageBody:emailBody isHTML:NO];
    
    [self presentModalViewController:picker animated:YES];
    [picker release];
}

-(IBAction)emailShare
{
    // This sample can run on devices running iPhone OS 2.0 or later  
    // The MFMailComposeViewController class is only available in iPhone OS 3.0 or later. 
    // So, we must verify the existence of the above class and provide a workaround for devices running 
    // earlier versions of the iPhone OS. 
    // We display an email composition interface if MFMailComposeViewController exists and the device can send emails.
    // We launch the Mail application on the device, otherwise.
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (mailClass != nil)
    {
        // We must always check whether the current device is configured for sending emails
        if ([mailClass canSendMail])
        {
            [self displayComposerSheet];
        }
        else
        {
            [self launchMailAppOnDevice];
        }
    }
    else
    {
        [self launchMailAppOnDevice];
    }
}
- (void)mailComposeController:(MFMailComposeViewController*)controller             didFinishWithResult:(MFMailComposeResult)result                          error:(NSError*)error;
{   
    if (result == MFMailComposeResultSent) 
    {    
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"EmailAlertViewTitle", @"") message:NSLocalizedString(@"EmailAlertViewMsg", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"Ok",@"") otherButtonTitles:nil];
        [alert show];
    }  
    [self dismissModalViewControllerAnimated:YES]; 
} 



- (void)viewDidLoad
{
    mWeibo = FALSE;
    mLoginWeiboCanceled = FALSE;
    
    [self loadAd];
    //UIBarButtonItem *btnAction = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(popupShareOption)];
    //self.navigationItem.rightBarButtonItem = btnAction;
    
    // Do any additional setup after loading the view from its nib.
    self.title = [delegate getTitle:index.row];
    
    textView.editable = NO;
    NSMutableString* content= [NSMutableString stringWithString:[delegate getContent:index.row]];
    [content replaceOccurrencesOfString:@"\n\n" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [content length])];
    textView.text = content;
    if (UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()) {
        [textView setFont:[UIFont systemFontOfSize:kIPadFontSizeEx]];
    }
    else
    {
        [textView setFont:[UIFont systemFontOfSize:kIPhoneFontSize]];
    }
    [super viewDidLoad];
}
- (IBAction)compose:(id)sender {
    mWeibo = TRUE;    
    mLoginWeiboCanceled = FALSE;
    if (mWeibo) {
        if (!_engine){
            _engine = [[OAuthEngine alloc] initOAuthWithDelegate: self];
            _engine.consumerKey = kOAuthConsumerKey;
            _engine.consumerSecret = kOAuthConsumerSecret;
        }
        [self performSelector:@selector(loadTimeline) withObject:nil afterDelay:0.5];
    }
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (mLoginWeiboCanceled) {
        mWeibo = FALSE;
        mLoginWeiboCanceled = FALSE;
    }
    
    if (mWeibo) {        
        if (!_engine){
            _engine = [[OAuthEngine alloc] initOAuthWithDelegate: self];
            _engine.consumerKey = kOAuthConsumerKey;
            _engine.consumerSecret = kOAuthConsumerSecret;
        }
        [self performSelector:@selector(loadTimeline) withObject:nil afterDelay:0.5];
    }
}
- (void)loadTimeline {
	UIViewController *controller = [OAuthController controllerToEnterCredentialsWithEngine: _engine delegate: self];
	
	if (controller) 
		[self presentModalViewController: controller animated: YES];
	else {
		NSLog(@"Authenicated for %@..", _engine.username);
		[OAuthEngine setCurrentOAuthEngine:_engine];
		//[self loadData];
		if (!composeViewController) {
            composeViewController = [[ComposeViewController alloc]init];
        }
        
        NSString*  c = [delegate getContent:index.row];      
        NSString* format = [NSString stringWithString:@"%@\n%@..."];
        NSString* title = [delegate getTitle:index.row];
        int maxAllowedLength = kWeiboMaxLength-delegate.mTrackViewUrl.length-title.length-format.length;
        
        NSString* content = [NSString stringWithFormat:format,title,[c substringToIndex:c.length>maxAllowedLength?maxAllowedLength:c.length ]];
        
        NSLog(@"weibo content length:%d",content.length);
        //content = [content stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        [composeViewController setText:content tailText:delegate.mTrackViewUrl];
        [self presentModalViewController:composeViewController animated:YES];
        [composeViewController newTweet];
        mWeibo = FALSE;
	}
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{    
    [self adjustAdSize];
}

- (void)viewDidUnload
{
	self.contentView = nil;
}

- (void)dealloc
{
    self.index = nil;   
    if ([mAdView isKindOfClass:[DoMobView class]]) {
        ((DoMobView*)mAdView).doMobDelegate = nil;
    }
    [mAdView release];
	[contentView release]; 
    contentView = nil;  
    
    [_engine release];
	[weiboClient release];
    [composeViewController release];
    [super dealloc];
}

- (void)adjustAdSize {	
	[UIView beginAnimations:@"AdResize" context:nil];
	[UIView setAnimationDuration:0.7];
    
	CGSize adSize = mAdView.frame.size;
	CGRect newFrame = mAdView.frame;
	newFrame.size.height = adSize.height;
	newFrame.size.width = adSize.width;    
    
	newFrame.origin.x = (self.view.bounds.size.width - adSize.width)/2;
    newFrame.origin.y = 0;//self.view.bounds.size.height-adSize.height;
	mAdView.frame = newFrame;
    
	[UIView commitAnimations];
} 

- (IBAction)signOut:(id)sender {
    [_engine signOut];
    [self loadTimeline];
}

//=============================================================================================================================
#pragma mark OAuthEngineDelegate
- (void) storeCachedOAuthData: (NSString *) data forUsername: (NSString *) username {
	NSUserDefaults			*defaults = [NSUserDefaults standardUserDefaults];
	
	[defaults setObject: data forKey: @"authData"];
	[defaults synchronize];
}

- (NSString *) cachedOAuthDataForUsername: (NSString *) username {
	return [[NSUserDefaults standardUserDefaults] objectForKey: @"authData"];
}

- (void)removeCachedOAuthDataForUsername:(NSString *) username{
	NSUserDefaults			*defaults = [NSUserDefaults standardUserDefaults];
	
	[defaults removeObjectForKey: @"authData"];
	[defaults synchronize];
}
//=============================================================================================================================
#pragma mark OAuthSinaWeiboControllerDelegate
- (void) OAuthController: (OAuthController *) controller authenticatedWithUsername: (NSString *) username {
	NSLog(@"Authenicated for %@", username);
}

- (void) OAuthControllerFailed: (OAuthController *) controller {
	NSLog(@"Authentication Failed!");
	//UIViewController *controller = [OAuthController controllerToEnterCredentialsWithEngine: _engine delegate: self];
	
	if (controller) 
		[self presentModalViewController: controller animated: YES];
	
}

- (void) OAuthControllerCanceled: (OAuthController *) controller {
	NSLog(@"Authentication Canceled.");
    mLoginWeiboCanceled = TRUE;
	//UIViewController *controller = [OAuthController controllerToEnterCredentialsWithEngine: _engine delegate: self];
	
	//if (controller) 
    //[self presentModalViewController: controller animated: YES];
	
}
@end

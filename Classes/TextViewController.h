#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "DoMobDelegateProtocol.h"
#import "OAuthController.h"
#import "WeiboClient.h"
#import "ComposeViewController.h"

@class OAuthEngine;

enum ShareOption
{
    kShareByEmail = 0
};


@class AdvancedTableViewCellsAppDelegate;


@interface TextViewController : UIViewController <MFMailComposeViewControllerDelegate,UIActionSheetDelegate,DoMobDelegate,OAuthControllerDelegate>
{
    UIView *contentView;
    NSIndexPath* index;
    UITextView* textView;
    AdvancedTableViewCellsAppDelegate* delegate;
    UIView* mAdView;
    
    OAuthEngine				*_engine;
	WeiboClient *weiboClient;
	ComposeViewController *composeViewController;
    BOOL mWeibo;
    BOOL mLoginWeiboCanceled;
}
@property (nonatomic, retain) IBOutlet ComposeViewController *composeViewController;
@property(nonatomic, retain) UIView *mAdView;
//@property(nonatomic,assign) NSInteger mAdIndex;
@property (nonatomic, retain) IBOutlet UITextView *textView;

@property(nonatomic, retain) IBOutlet UIView *contentView;
@property(nonatomic, retain) NSIndexPath* index;

-(id)initWithIndexPath:(NSIndexPath*)indexPath;
- (IBAction)compose:(id)sender;
- (IBAction)signOut:(id)sender;
-(IBAction)emailShare;

-(void)launchMailAppOnDevice;
-(void)displayComposerSheet ;

-(void)loadAd;
- (void)adjustAdSize;
@end


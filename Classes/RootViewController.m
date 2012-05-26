
#import "RootViewController.h"
#import "CompositeSubviewBasedApplicationCell.h"
#import "HybridSubviewBasedApplicationCell.h"
#import "AdvancedTableViewCellsAppDelegate.h"
#import "UIImageEx.h"
#import "RewardedWallViewController.h"

#import "TextViewController.h"
#import "Constants.h"
#import "AdsConfig.h"

// Define one of the following macros to 1 to control which type of cell will be used.
#define USE_INDIVIDUAL_SUBVIEWS_CELL    1	// use a xib file defining the cell
#define USE_COMPOSITE_SUBVIEW_CELL      0	// use a single view to draw all the content
#define USE_HYBRID_CELL                 0	// use a single view to draw most of the content + separate label to render the rest of the content


/*
 Predefined colors to alternate the background color of each cell row by row
 (see tableView:cellForRowAtIndexPath: and tableView:willDisplayCell:forRowAtIndexPath:).
 */
#define DARK_BACKGROUND  [UIColor colorWithRed:151.0/255.0 green:152.0/255.0 blue:155.0/255.0 alpha:1.0]
#define LIGHT_BACKGROUND [UIColor colorWithRed:172.0/255.0 green:173.0/255.0 blue:175.0/255.0 alpha:1.0]

//cell size
const NSUInteger kCellWidth = 45;
const NSUInteger kCellHeight = 60;

@implementation RootViewController

@synthesize tmpCell, data, cellNib;


#pragma mark -
#pragma mark View controller methods

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        //
        //wall = [[YouMiWall alloc] initWithAppID:kDefaultAppID_iOS withAppSecret:kDefaultAppSecret_iOS];        
        // or
         wall = [[YouMiWall alloc] init];
         wall.appID = kDefaultAppID_iOS;
         wall.appSecret = kDefaultAppSecret_iOS;
        
        // set delegate
        wall.delegate = self;
        
        // 程序启动的时候推荐应用下载
        [wall requestFeaturedApp:NO];    // 无积分推荐
        // [wall requestFeaturedApp:NO]; // 有积分激励
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];     
}

- (void)viewDidLoad
{
    [super viewDidLoad];   
	
	self.navigationController.navigationBar.tintColor = [UIColor darkGrayColor];
	
	// Configure the table view.
    self.tableView.rowHeight = 73.0;
    self.tableView.backgroundColor = DARK_BACKGROUND;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    AdvancedTableViewCellsAppDelegate* delegate = (AdvancedTableViewCellsAppDelegate*)[[UIApplication sharedApplication]delegate];
    
    self.data = delegate.data;
	
	// create our UINib instance which will later help us load and instanciate the
	// UITableViewCells's UI via a xib file.
	//
	// Note:
	// The UINib classe provides better performance in situations where you want to create multiple
	// copies of a nib file’s contents. The normal nib-loading process involves reading the nib file
	// from disk and then instantiating the objects it contains. However, with the UINib class, the
	// nib file is read from disk once and the contents are stored in memory.
	// Because they are in memory, creating successive sets of objects takes less time because it
	// does not require accessing the disk.
	//
	self.cellNib = [UINib nibWithNibName:@"IndividualSubviewsBasedApplicationCell" bundle:nil];
    self.title = NSLocalizedString(@"Title", @"");//@"HappyLife";
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle: NSLocalizedString(@"Back",@"") style: UIBarButtonItemStyleBordered target: nil action: nil];  
    [[self navigationItem] setBackBarButtonItem: newBackButton];  
    [newBackButton release]; 
    
    
    // Create a final modal view controller
//	UIButton* modalViewButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
//	[modalViewButton addTarget:self action:@selector(modalViewAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *donateButton = [[UIBarButtonItem alloc] initWithTitle: NSLocalizedString(@"Donate",@"") style: UIBarButtonItemStyleBordered target: self action:@selector(donateViewAction:)];  
	self.navigationItem.rightBarButtonItem = donateButton;
	[donateButton release];

}

- (void)viewDidUnload
{
	[super viewDidLoad];
	
	self.data = nil;
 	self.tmpCell = nil;
	self.cellNib = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}


#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [data count]/2;//one for title,one for content
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ApplicationCell";
    
    ApplicationCell *cell = (ApplicationCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if (cell == nil)
    {
#if USE_INDIVIDUAL_SUBVIEWS_CELL
        [self.cellNib instantiateWithOwner:self options:nil];
		cell = tmpCell;
		self.tmpCell = nil;
		
#elif USE_COMPOSITE_SUBVIEW_CELL
        cell = [[[CompositeSubviewBasedApplicationCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                            reuseIdentifier:CellIdentifier] autorelease];
		
#elif USE_HYBRID_CELL
        cell = [[[HybridSubviewBasedApplicationCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                         reuseIdentifier:CellIdentifier] autorelease];
#endif
    }
    
	// Display dark and light background in alternate rows -- see tableView:willDisplayCell:forRowAtIndexPath:.
    cell.useDarkBackground = (indexPath.row % 2 == 0);
        AdvancedTableViewCellsAppDelegate *delegate = (AdvancedTableViewCellsAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    const CGSize size = CGSizeMake(kCellWidth,kCellHeight);    
	// Configure the data for the cell. 
    NSString* iconName = [NSString stringWithFormat:@"%.3d",indexPath.row];     
    NSString *iconPath = [[NSBundle mainBundle] pathForResource:iconName ofType:@"jpg"];
    UIImage* image = [[UIImage alloc]initWithContentsOfFile:iconPath];
    cell.icon = [image scaleWithSize:size];
    [image release];
     
    cell.publisher = @"";//[dataItem objectForKey:@"Publisher"];
    cell.name = [delegate getTitle:indexPath.row];
    
      
    cell.price = @"";//[dataItem objectForKey:@"Price"];
	
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = ((ApplicationCell *)cell).useDarkBackground ? DARK_BACKGROUND : LIGHT_BACKGROUND;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didSelectRowAtIndexPath:%d",indexPath.row);
    
    AdvancedTableViewCellsAppDelegate *delegate = (AdvancedTableViewCellsAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    TextViewController *detail = (TextViewController*)[[TextViewController alloc] initWithIndexPath:indexPath];
    [delegate.navigationController pushViewController:detail animated:YES];
    [detail release];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}
#pragma mark  -- UIAlertViewDelegate --
//根据被点击按钮的索引处理点击事件
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSLog(@"clickedButtonAtIndex:%d",buttonIndex);
    
}
//AlertView已经消失时
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	NSLog(@"didDismissWithButtonIndex");
}
//AlertView即将消失时
- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
	NSLog(@"willDismissWithButtonIndex");
}

- (void)alertViewCancel:(UIAlertView *)alertView {
	NSLog(@"alertViewCancel");
}
//AlertView已经显示时
- (void)didPresentAlertView:(UIAlertView *)alertView {
	NSLog(@"didPresentAlertView");
}
//AlertView即将显示时
- (void)willPresentAlertView:(UIAlertView *)alertView {
	NSLog(@"willPresentAlertView");
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc
{
    wall.delegate = nil;
    [wall release];
    
    [data release];
	[tmpCell release];
	[cellNib release];
	
    [super dealloc];
}

-(IBAction)donateViewAction:(id)sender
{
    /*UIAlertView* alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Donate", @"") message:NSLocalizedString(@"DonateBody", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"Ok",@"") otherButtonTitles:nil];
    [alert show];
    [alert release];*/
    
    UIViewController *detailViewController;
    //if (indexPath.row == 0) {
        detailViewController = [[RewardedWallViewController alloc] init];
    ////} else if (indexPath.row == 1) {
     //   detailViewController = [[NoneRewardedWallViewController alloc] init];
    //}
    
    [self.navigationController pushViewController:detailViewController animated:YES];
}
#pragma mark - YouMiWall delegate

- (void)didReceiveFeaturedApp:(YouMiWall *)adWall {
//    success = YES;
    
    // 第一次请求成功，如果当前界面可见则立马显示出来
//    if (visible) {
//        [adWall showFeaturedApp];
//        show = YES;
//    }
}

- (void)didFailToReceiveFeaturedApp:(YouMiWall *)adWall error:(NSError *)error {
//    success = NO;
}

#pragma mark API
- (IBAction)modalViewAction:(id)sender
{
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"AboutTitle", @"") message:NSLocalizedString(@"About", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"Done",@"") otherButtonTitles:nil];
    [alert show];
    [alert release];
}

@end
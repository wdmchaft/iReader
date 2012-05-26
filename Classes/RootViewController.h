#import <UIKit/UIKit.h>
#import "ApplicationCell.h"
#import "ModalViewController.h"
#import "Constants.h"
#import "YouMiWall.h"

@interface RootViewController : UITableViewController<UIAlertViewDelegate,YouMiWallDelegate>
{
	ApplicationCell *tmpCell;
    NSMutableArray *data;
    YouMiWall *wall;
	// referring to our xib-based UITableViewCell ('IndividualSubviewsBasedApplicationCell')
	UINib *cellNib;
}

@property (nonatomic, retain) IBOutlet ApplicationCell *tmpCell;
@property (nonatomic, retain) NSMutableArray *data;

@property (nonatomic, retain) UINib *cellNib;

@end




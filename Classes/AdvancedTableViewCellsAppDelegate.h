
#define SharedDelegate (AdvancedTableViewCellsAppDelegate*)[[UIApplication sharedApplication]delegate]

@interface AdvancedTableViewCellsAppDelegate : NSObject <UIApplicationDelegate>
{
    UIWindow *window;
    UINavigationController *navigationController;
    NSMutableArray *data;
    NSString* mCurrentFileName;
    NSString* mDataPath;
    NSString* mTrackViewUrl;
    NSString* mTrackName;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) NSMutableArray* data;
@property (nonatomic, assign) NSString* mCurrentFileName;
@property (nonatomic, assign) NSString* mDataPath;
@property (nonatomic, retain) NSString* mTrackViewUrl;
@property (nonatomic, retain) NSString* mTrackName;



- (NSString *)getTitle:(const NSUInteger)index;
- (NSString *)getContent:(const NSUInteger)index;
-(NSString*)getNodeContent:(const NSUInteger)index firstContent:(BOOL) first;
+(NSString*)getMonthDay;
+(NSString*)getTodayFileName;
-(void)releaseMemory;
- (void)loadData;

//for ads config
-(void)startAdsConfigReceive;
-(void)parseAdsConfig;

//update
-(void)checkUpdate;
// 比较oldVersion和newVersion，如果oldVersion比newVersion旧，则返回YES，否则NO
// Version format[X.X.X]
+(BOOL)CompareVersionFromOldVersion : (NSString *)oldVersion
                         newVersion : (NSString *)newVersion;

@end


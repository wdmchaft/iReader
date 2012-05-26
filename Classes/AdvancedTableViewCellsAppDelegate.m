
#import "AdvancedTableViewCellsAppDelegate.h"
#import "RootViewController.h"
#import "CDetailData.h"
#import "XPathQuery.h"//another xml parser wrapper
#import "AdsConfig.h"
#import "NetworkManager.h"
#import "ASIFormDataRequest.h"

@interface AdvancedTableViewCellsAppDelegate()
// Properties that don't need to be seen by the outside world.

@property (nonatomic, assign, readonly ) BOOL                               isReceiving;
@property (nonatomic, strong, readwrite) NSURLConnection *                  connection;
@property (nonatomic, copy,   readwrite) NSString *                         filePath;
@property (nonatomic, strong, readwrite) NSOutputStream *                   fileStream;

@end


@implementation AdvancedTableViewCellsAppDelegate

@synthesize connection    = _connection;
@synthesize filePath      = _filePath;
@synthesize fileStream    = _fileStream;

@synthesize window;
@synthesize navigationController;
@synthesize data;
@synthesize mCurrentFileName,mDataPath,mTrackViewUrl,mTrackName;

#pragma mark -
#pragma mark Application lifecycle
#pragma mark -
#pragma mark Memory management

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    // the user clicked one of the OK/Cancel buttons
    if (buttonIndex == 1)
    {        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mTrackViewUrl]];
    }
}
-(void)checkUpdate
{
    
    NSString *version = @"";
    NSString* updateLookupUrl = [NSString stringWithFormat:@"http://itunes.apple.com/lookup?id=%@",kAppIdOnAppstore];
    NSURL *url = [NSURL URLWithString:updateLookupUrl];
    ASIFormDataRequest* versionRequest = [ASIFormDataRequest requestWithURL:url];
    [versionRequest setRequestMethod:@"GET"];
    [versionRequest setDelegate:self];
    [versionRequest setTimeOutSeconds:150];
    [versionRequest addRequestHeader:@"Content-Type" value:@"application/json"]; 
    [versionRequest startSynchronous];
    
    //Response string of our REST call
    NSString* jsonResponseString = [versionRequest responseString];
    
    NSDictionary *loginAuthenticationResponse = [jsonResponseString objectFromJSONString];
    
    NSArray *configData = [loginAuthenticationResponse valueForKey:@"results"];
    NSString* releaseNotes;
    for (id config in configData) 
    {
        version = [config valueForKey:@"version"];
        self.mTrackViewUrl = [config valueForKey:@"trackViewUrl"];
        releaseNotes = [config valueForKey:@"releaseNotes"]; 
        self.mTrackName = [config valueForKey:@"trackName"];
        NSLog(mTrackName);
    }
    NSString *localVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    //Check your version with the version in app store
    if ([AdvancedTableViewCellsAppDelegate CompareVersionFromOldVersion:localVersion newVersion:version]) 
    {        
        UIAlertView *createUserResponseAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NewVersion", @"") message: @"" delegate:self cancelButtonTitle:NSLocalizedString(@"Back", @"") otherButtonTitles: NSLocalizedString(@"Ok", @""), nil];
        [createUserResponseAlert show]; 
        [createUserResponseAlert release];
    }
}
// 比较oldVersion和newVersion，如果oldVersion比newVersion旧，则返回YES，否则NO
// Version format[X.X.X]
+(BOOL)CompareVersionFromOldVersion : (NSString *)oldVersion
                         newVersion : (NSString *)newVersion
{
    NSArray*oldV = [oldVersion componentsSeparatedByString:@"."];
    NSArray*newV = [newVersion componentsSeparatedByString:@"."];
    
    if (oldV.count == newV.count) {
        for (NSInteger i = 0; i < oldV.count; i++) {
            NSInteger old = [(NSString *)[oldV objectAtIndex:i] integerValue];
            NSInteger new = [(NSString *)[newV objectAtIndex:i] integerValue];
            if (old < new) {
                return YES;
            }
        }
        return NO;
    } else {
        return NO;
    }
}

- (void)loadData
{
    
    // Load the data.
#ifdef kSingleFile
    NSString *dataPath = [[NSBundle mainBundle] pathForResource:@"lyrics" ofType:@"xml"];
#elif defined kHistory
    NSString *dataPath = [[NSBundle mainBundle] pathForResource:[AdvancedTableViewCellsAppDelegate getMonthDay] ofType:@"xml"];
#else    
    self.mCurrentFileName = [AdvancedTableViewCellsAppDelegate getTodayFileName];    
    NSString *dataPath = [[NSBundle mainBundle] pathForResource:self.mCurrentFileName ofType:@"txt"];
#endif
    
    if ([dataPath isEqualToString:mDataPath]) {
        return;
    }
    [self checkUpdate];
    [self startAdsConfigReceive];
    
    if ([mDataPath length] !=0 ) {
        [mDataPath release];
    }
    mDataPath = [[NSString alloc]initWithString:dataPath];
    
    NSData* responseData = [[NSData alloc] initWithContentsOfFile:mDataPath];
    //NSLog(@"%@",responseData);
    NSString *xpathQueryString = @"//channel/item/*"; 
    self.data = (NSMutableArray*)PerformXMLXPathQuery(responseData, xpathQueryString);
    [responseData release];
}
/**
 parse ads config from server 
 if failed to get configuration,just use the default config
 */
-(void)parseAdsConfig
{
    AdsConfig *config = [AdsConfig sharedAdsConfig];
    [config init:self.filePath];
}

#pragma mark * Core transfer code

// This is the code that actually does the networking.

- (BOOL)isReceiving
{
    return (self.connection != nil);
}

- (void)startAdsConfigReceive
// Starts a connection to download the current URL.
{
    BOOL                success;
    NSURL *             url;	
    NSURLRequest *      request;
    if(self.connection!=nil)
    {
        return;
    }
    
    assert(self.connection == nil);         // don't tap receive twice in a row!
    assert(self.fileStream == nil);         // ditto
    assert(self.filePath == nil);           // ditto
    
    // First get and check the URL.
    
    url = [[NetworkManager sharedInstance] smartURLForString:AdsUrl];
    success = (url != nil);
    
    // If the URL is bogus, let the user know.  Otherwise kick off the connection.
    
    if ((url != nil)) {
        
        // Open a stream for the file we're going to receive into.
        
        self.filePath = [[NetworkManager sharedInstance] pathForTemporaryFileWithPrefix:@"Get"];
        assert(self.filePath != nil);
        
        //remove this file first
        NSError* error;
        NSFileManager* fileMgr = [NSFileManager defaultManager];
        if ([fileMgr fileExistsAtPath:self.filePath]) {
            if (![fileMgr removeItemAtPath:self.filePath error:&error])
                NSLog(@"Unable to delete file: %@", [error localizedDescription]);
        }
        self.fileStream = [NSOutputStream outputStreamToFileAtPath:self.filePath append:NO];
        assert(self.fileStream != nil);
        
        [self.fileStream open];
        
        // Open a connection for the URL.
        
        request = [NSURLRequest requestWithURL:url];
        assert(request != nil);
        
        self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
        assert(self.connection != nil);
        [[NetworkManager sharedInstance] didStartNetworkOperation];
    }
}
- (void)receiveDidStopWithStatus:(NSString *)statusString
{
    if (statusString == nil) {
        assert(self.filePath != nil);
        [self parseAdsConfig];
    }    
    [[NetworkManager sharedInstance] didStopNetworkOperation];
}
- (void)stopReceiveWithStatus:(NSString *)statusString
// Shuts down the connection and displays the result (statusString == nil) 
// or the error status (otherwise).
{
    if (self.connection != nil) {
        [self.connection cancel];
        self.connection = nil;
    }
    if (self.fileStream != nil) {
        [self.fileStream close];
        self.fileStream = nil;
    }
    [self receiveDidStopWithStatus:statusString];
    self.filePath = nil;
}

- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response
// A delegate method called by the NSURLConnection when the request/response 
// exchange is complete.  We look at the response to check that the HTTP 
// status code is 2xx and that the Content-Type is acceptable.  If these checks 
// fail, we give up on the transfer.
{
#pragma unused(theConnection)
    NSHTTPURLResponse * httpResponse;
    NSString *          contentTypeHeader;
    
    assert(theConnection == self.connection);
    
    httpResponse = (NSHTTPURLResponse *) response;
    assert( [httpResponse isKindOfClass:[NSHTTPURLResponse class]] );
    
    if ((httpResponse.statusCode / 100) != 2) {
        [self stopReceiveWithStatus:[NSString stringWithFormat:@"HTTP error %zd", (ssize_t) httpResponse.statusCode]];
    } else {
        // -MIMEType strips any parameters, strips leading or trailer whitespace, and lower cases 
        // the string, so we can just use -isEqual: on the result.
        contentTypeHeader = [httpResponse MIMEType];
        if (contentTypeHeader == nil) {
            [self stopReceiveWithStatus:@"No Content-Type!"];
        } 
//        else if ( ! [contentTypeHeader isEqual:@"image/jpeg"] 
//                   && ! [contentTypeHeader isEqual:@"image/png"] 
//                   && ! [contentTypeHeader isEqual:@"image/gif"] ) {
//            [self stopReceiveWithStatus:[NSString stringWithFormat:@"Unsupported Content-Type (%@)", contentTypeHeader]];
//        }
    }    
}

- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)dataRev
// A delegate method called by the NSURLConnection as data arrives.  We just 
// write the data to the file.
{
#pragma unused(theConnection)
    NSInteger       dataLength;
    const uint8_t * dataBytes;
    NSInteger       bytesWritten;
    NSInteger       bytesWrittenSoFar;
    
    assert(theConnection == self.connection);
    
    dataLength = [dataRev length];
    dataBytes  = [dataRev bytes];
    
    bytesWrittenSoFar = 0;
    do {
        bytesWritten = [self.fileStream write:&dataBytes[bytesWrittenSoFar] maxLength:dataLength - bytesWrittenSoFar];
        assert(bytesWritten != 0);
        if (bytesWritten == -1) {
            [self stopReceiveWithStatus:@"File write error"];
            break;
        } else {
            bytesWrittenSoFar += bytesWritten;
        }
    } while (bytesWrittenSoFar != dataLength);
}

- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error
// A delegate method called by the NSURLConnection if the connection fails. 
// We shut down the connection and display the failure.  Production quality code 
// would either display or log the actual error.
{
#pragma unused(theConnection)
#pragma unused(error)
    assert(theConnection == self.connection);
    
    [self stopReceiveWithStatus:@"Connection failed"];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection
// A delegate method called by the NSURLConnection when the connection has been 
// done successfully.  We shut down the connection with a nil status, which 
// causes the image to be displayed.
{
#pragma unused(theConnection)
    assert(theConnection == self.connection);
    
    [self stopReceiveWithStatus:nil];
}

-(void)releaseMemory
{
    self.data = nil;
    //self.mCurrentFileName = nil;
    [[AdsConfig sharedAdsConfig] release];
}
- (void)dealloc
{
    if ([mDataPath length] !=0 ) {
        [mDataPath release];
    }
    [mTrackViewUrl release];
    [mTrackName release];
    [navigationController release];
    //[window release];
    [self releaseMemory];
    [super dealloc];
}
- (void)applicationWillEnterForeground:(UIApplication *)application __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_4_0)
{    
    [self loadData];
}
- (void)applicationDidBecomeActive:(UIApplication *)application
{     
    [self loadData];
}
+(int)getDayCountBeforeMonth:(int)month
{
    int c = 0;
    switch (month) {
        case 1:
            c = 31;
            break;
            
        case 2:
        { 
            c = 28 + [AdvancedTableViewCellsAppDelegate getDayCountBeforeMonth:month-1]; 
        }  
            break;
            
        case 3:
        case 5:
        case 7:
        case 8:
        case 10:
        case 12:
        { 
            c = 31 + [AdvancedTableViewCellsAppDelegate getDayCountBeforeMonth:month-1]; 
        }  
            break;
            
        case 4:
        case 6:
        case 9:
        case 11:
        { 
            c = 30 + [AdvancedTableViewCellsAppDelegate getDayCountBeforeMonth:month-1]; 
        }  
            break;
            
        default:
            break;
    }
    return c;
}
+(int)getTodayOffset:(int)month day:(int)day
{    
    return [AdvancedTableViewCellsAppDelegate getDayCountBeforeMonth:month]+day;
}
+(NSString*)getTodayFileName
{
    //get today
    NSCalendar *cal = [NSCalendar currentCalendar];
    
    unsigned int unitFlags = NSMonthCalendarUnit | NSDayCalendarUnit ;
    NSDateComponents *dd = [cal components:unitFlags fromDate:[NSDate date]]; 
    //get date count before today
    int count = ([dd month]==1)?[dd day]:[AdvancedTableViewCellsAppDelegate getTodayOffset:[dd month] day:[dd day]];
    //get file name
    NSString* fileName = [NSString stringWithFormat:@"%.03d_Unicode",count];
    NSLog(@"%@",fileName);
    return fileName;
}
+(NSString*)getMonthDay
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    
    unsigned int unitFlags = NSMonthCalendarUnit | NSDayCalendarUnit ;
    NSDateComponents *dd = [cal components:unitFlags fromDate:[NSDate date]]; 
    
    return [NSString stringWithFormat:@"%d%d",[dd month],[dd day]];       
}
- (void)applicationDidFinishLaunching:(UIApplication *)application
{    
    
    [window addSubview:[navigationController view]];
    [window makeKeyAndVisible];
}
- (NSString *)getContent:(const NSUInteger)index
{
    return [self getNodeContent:index firstContent:NO];
}
// Retrieves the content of an XML node, such as the temperature, wind, 
// or humidity in the weather report. 
//
-(NSString *)getTitle:(const NSUInteger)index
{    
    return [self getNodeContent:index firstContent:YES];
}
-(NSString*)getNodeContent:(const NSUInteger)index firstContent:(BOOL) first
{
    NSString* result = @"";
    const NSUInteger plusCount = 2;//
    const NSUInteger contentIndex = index*plusCount+((YES==first)?0:1);
    if(contentIndex < [data count])
    {
        NSDictionary* dict = [data objectAtIndex:contentIndex];
        result = [dict objectForKey:@"nodeContent"];
    }
    return result;
}



@end


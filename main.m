#import <UIKit/UIKit.h>
#import "MobiSageSDK.h"
#import "AdsConfig.h"
#import "YouMiWall.h"

int main(int argc, char *argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; 
    
    [[MobiSageManager getInstance] setPublisherID:kMobiSageID_iPhone];
    
    //disable youmi wall gps
    [YouMiWall setShouldGetLocation:NO];
    
    int retVal = UIApplicationMain(argc, argv, nil, nil);
    [pool release];
    return retVal;
}

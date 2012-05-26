//
//  AdsConfig.m
//  HappyLife
//
//  Created by ramon lee on 5/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AdsConfig.h"
#import "XPathQuery.h"

@interface AdsConfig()

- (NSString *)getAdsValidity:(const NSUInteger)index;

-(NSString *)getAdsName:(const NSUInteger)index;

-(NSString*)getNodeContent:(const NSUInteger)index firstContent:(BOOL) first;
@end

@implementation AdsConfig
@synthesize mData,mCurrentIndex;

-(void)dealloc
{
    [mData release];
    [super dealloc];
}
+(AdsConfig*)sharedAdsConfig
{
    static dispatch_once_t  onceToken;
    static AdsConfig * sSharedInstance;
    
    dispatch_once(&onceToken, ^{
        sSharedInstance = [[AdsConfig alloc] init];
    });
    return sSharedInstance;
}
-(BOOL)isInitialized
{
    return mData!=nil && [mData count]>0;
}
//TODO::init with data 
-(void)init:(NSString*)path
{    
    if(path != nil && path.length>0)
    {
        NSData* responseData = [[NSData alloc] initWithContentsOfFile:path];
        //NSLog(@"%@",responseData);
        NSString *xpathQueryString = @"//channel/item/*"; 
        self.mData = (NSMutableArray*)PerformXMLXPathQuery(responseData, xpathQueryString);
        [responseData release];
    }
    
    //load local one
    if (self.mData == nil) {
        NSString* defaultConfig = [[NSBundle mainBundle] pathForResource:kDefaultAds ofType:@"xml"];
        
        NSData*  responseData = [[NSData alloc] initWithContentsOfFile:defaultConfig];
        NSString *xpathQueryString = @"//channel/item/*";
        if (mData!=nil) {
            [mData release];
        }
        self.mData = (NSMutableArray*)PerformXMLXPathQuery(responseData, xpathQueryString);
        [responseData release];
    }
    
    mCurrentIndex = 0;
}
-(NSString*)getFirstAd
{
    mCurrentIndex = 0;
    if (self.mData != nil) {
        return  [self getAdsName:mCurrentIndex];     
    }
    return @"";
}
-(NSString*)getLastAd
{
    mCurrentIndex = 0;
    if (self.mData != nil) {
        mCurrentIndex = [mData count] -1;
        return  [self getAdsName:mCurrentIndex];     
    }
    return @"";
}
-(NSInteger)getAdsCount
{
    return (self.mData==nil)?0:[self.mData count]/2;
}
-(NSString*)toNextAd
{
    mCurrentIndex++;
    if (mCurrentIndex > [self getAdsCount]) {
        mCurrentIndex = 0;
    }
    return [self getCurrentAd];
}
-(NSString*)getCurrentAd
{
    if (self.mData != nil && mCurrentIndex < [mData count]) {
        return  [self getAdsName:mCurrentIndex];     
    }
    return @"";
}
-(BOOL)isCurrentAdsValid
{
    return [[self getAdsValidity:mCurrentIndex] isEqualToString:@"1"];
}

- (NSString *)getAdsValidity:(const NSUInteger)index
{
    return [self getNodeContent:index firstContent:NO];
}
// Retrieves the content of an XML node, such as the temperature, wind, 
// or humidity in the weather report. 
//
-(NSString *)getAdsName:(const NSUInteger)index
{    
    return [self getNodeContent:index firstContent:YES];
}
-(NSString*)getNodeContent:(const NSUInteger)index firstContent:(BOOL) first
{
    NSString* result = @"";
    const NSUInteger plusCount = 2;//
    const NSUInteger contentIndex = index*plusCount+((YES==first)?0:1);
    if(contentIndex < [mData count])
    {
        NSDictionary* dict = [mData objectAtIndex:contentIndex];
        result = [dict objectForKey:@"nodeContent"];
    }
    return result;
}
@end

//
//  AdsConfig.h
//  HappyLife
//
//  Created by ramon lee on 5/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

//switch for ads config
//#define MakeToast
//#define TraditionalChineseMedicine
//#define SpouseTalks
#define Humer
//#define EnglishPrefix
//#define EnglishSuffix

#ifdef MakeToast
//code macro
#define kSingleFile

//weibo key and secret
//sina weibo
#define kOAuthConsumerKey				@"319938111"		//REPLACE ME
#define kOAuthConsumerSecret			@"1618d139b2ea94d0ddb5ef931245265a"		//REPLACE ME

//appid
#define kAppIdOnAppstore @"471656942"

//wall
//修改为你自己的AppID和AppSecret
#define kDefaultAppID_iOS           @"6b875a1db75ff9e5" // youmi default app id
#define kDefaultAppSecret_iOS       @"e6983e250159ac64" // youmi default app secret


//id for ads
#define kMobiSageID_iPhone  @"e270159b22cc4c98a64e4402db48e96d"
#define kWiyunID_iPhone  @"84f03bdec273a137"
#define kWiyunID_iPad    @"29ae6d7c8172f013"
#define kWoobooPublisherID  @"3126e9a7c08e452090ff8fa179495797"
#define kDomobPubliserID @"56OJyOqouMF2HGNhFr"

#elif defined TraditionalChineseMedicine
//appid
#define kAppIdOnAppstore @"495815697"

//wall
//修改为你自己的AppID和AppSecret
#define kDefaultAppID_iOS           @"5aa5eabf0f6bef1d" // youmi default app id
#define kDefaultAppSecret_iOS       @"5e9ee87631d15545" // youmi default app secret


//id for ads
#define kMobiSageID_iPhone  @"72e2cc8d57084b0399d9d69565fb20e0"
#define kWiyunID_iPhone  @"2d6890f29731ab0b"
#define kWiyunID_iPad    @"fccb122fc023a241"
#define kWoobooPublisherID  @"5aded4d9ce6243fda3e3aae4d120cc3e"
#define kDomobPubliserID @"56OJyOqouMF2HGNhFr"

#elif defined SpouseTalks

//weibo key and secret

//sina weibo
#define kOAuthConsumerKey				@"2886644695"
#define kOAuthConsumerSecret			@"a228f8dcfb9a9c1d9b5cb033a55d847c"

//appid
#define kAppIdOnAppstore @"472818080"

//wall
//修改为你自己的AppID和AppSecret
#define kDefaultAppID_iOS           @"ba0c9bbac0715f60" // youmi default app id
#define kDefaultAppSecret_iOS       @"791a20f91e1b9576" // youmi default app secret


//id for ads
#define kMobiSageID_iPhone  @"6d72113c585b40c594a879eff708c7bf"
#define kWiyunID_iPhone  @"414121e947429b2e"
#define kWiyunID_iPad    @"86a3f5d37440f024"
#define kWoobooPublisherID  @"3f7625340cb7490a95f92a0bef2b4b3b"
#define kDomobPubliserID @"56OJyOqouMEW97fZ+N"
#elif defined Humer

//sina weibo
#define kOAuthConsumerKey				@"2951554241"
#define kOAuthConsumerSecret			@"1d89a8b78ddd95d32c20bf72ca6dcfb6"


//appid
#define kAppIdOnAppstore @"469265895"

//wall
//修改为你自己的AppID和AppSecret
#define kDefaultAppID_iOS           @"ba0c9bbac0715f60" // youmi default app id
#define kDefaultAppSecret_iOS       @"791a20f91e1b9576" // youmi default app secret


//id for ads
#define kMobiSageID_iPhone  @"009a0187005c4e3989a5e8009fed8a47"
#define kWiyunID_iPhone  @"f4c8b82394761b8a"
#define kWiyunID_iPad    @"07b740b29274e601"
#define kWoobooPublisherID  @"09967f2472a14ca389ded0a82484836d"
#define kDomobPubliserID @"56OJyOqouMEW97fZ+N"
#elif defined EnglishSuffix
//code macro
#define kSingleFile

//appid
#define kAppIdOnAppstore @"471768694"

//wall
//修改为你自己的AppID和AppSecret
#define kDefaultAppID_iOS           @"be4ff0dc2f9e7eb5" // youmi default app id
#define kDefaultAppSecret_iOS       @"2262cc0dbff4ebca" // youmi default app secret


//id for ads
#define kMobiSageID_iPhone  @"146761bebeb844e3aadfff30cb52d26e"
#define kWiyunID_iPhone  @"fbb38fa6d2042250"
#define kWiyunID_iPad    @"b88e5d4dd473e1a3"
#define kWoobooPublisherID  @"211021fd50d14a2c83ba906420b29719"
#define kDomobPubliserID @"56OJyOqouMEW97fZ+N"

#elif defined EnglishPrefix
//code macro
#define kSingleFile

//appid
#define kAppIdOnAppstore @"472058981"

//wall
//修改为你自己的AppID和AppSecret
#define kDefaultAppID_iOS           @"be4ff0dc2f9e7eb5" // youmi default app id
#define kDefaultAppSecret_iOS       @"2262cc0dbff4ebca" // youmi default app secret


//id for ads
#define kMobiSageID_iPhone  @"c441c7a278a24c66b33cb6ae149e3929"
#define kWiyunID_iPhone  @"6093441723009b0f"
#define kWiyunID_iPad    @"2701171f41658221"
#define kWoobooPublisherID  @"211021fd50d14a2c83ba906420b29719"
#define kDomobPubliserID @"56OJyOqouMEW97fZ+N"

#endif



//ads url
#define kDefaultAds @"defaultAds"
#define AdsUrl @"http://www.idreems.com/example.php?adsconfig.xml"


//ads platform names
#define AdsPlatformWooboo @"Wooboo"
#define AdsPlatformWiyun @"Wiyun"
#define AdsPlatformMobisage @"Mobisage"
#define AdsPlatformDomob @"Domob"
#define AdsPlatformYoumi @"Youmi"//not implemented right now

#define kWeiboMaxLength 140

@interface AdsConfig : NSObject
{
    NSMutableArray *mData;
    NSInteger mCurrentIndex;
}
@property (nonatomic, retain) NSMutableArray* mData;
@property (nonatomic, assign) NSInteger mCurrentIndex;

+(AdsConfig*)sharedAdsConfig;
-(void)init:(NSString*)path;

-(NSString*)getFirstAd;

-(NSString*)getLastAd;

-(NSInteger)getAdsCount;

-(NSString*)toNextAd;

-(NSString*)getCurrentAd;

-(BOOL)isCurrentAdsValid;

-(BOOL)isInitialized;

-(void)dealloc;

@end

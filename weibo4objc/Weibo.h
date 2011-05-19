//
//  Weibo.h
//  weibo4objc
//
//  Created by fanng yuan on 11/29/10.
//  Copyright 2010 fanngyuan@sina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "OAToken.h"
#import "Constants.h"
#import "HttpClient.h"
#import "Status.h"
#import "Comment.h"
#import "DirectMessage.h"
#import "InvalidParameterException.h"
#import "ServerSideException.h"

static const double nilLatitude = 200;
static const double nilLongitude = 200;
static const weiboId nilReplyId = 0;

@interface Weibo : NSObject {
	@private HttpClient * client;
	
	NSString * _consumerKey;
	NSString * _consumerSecret;
	OAToken * _accessToken;
	
	// basic auth - deprecated
	NSString * _username;
	NSString * _password;	
	Auth authType;	
}

@property (readwrite,retain) NSString * _consumerKey;
@property (readwrite,retain) NSString * _consumerSecret;
@property (readwrite,retain) OAToken * _accessToken;

// basic auth - deprecated
@property (readwrite,retain) NSString * _username;
@property (readwrite,retain) NSString * _password;	
@property (readwrite,assign) Auth authType;

-(id)init;

// Configuration and Accessors
+ (NSString *)version; 
- (NSString *)clientName; 
- (NSString *)clientVersion;
- (NSString *)clientURL;
- (NSString *)clientSourceToken;
- (void)setClientName:(NSString *)name version:(NSString *)version URL:(NSString *)url token:(NSString *)token;
- (NSString *)APIDomain;
- (void)setAPIDomain:(NSString *)domain;
- (BOOL)usesSecureConnection; // YES = uses HTTPS, default is YES

- (BOOL)requestRequestToken;
- (NSString *) askUserForAuthorization;
- (NSString *)requestAccessToken;


// Utility methods
- (NSString *)getImageAtURL:(NSString *)urlString;

//status and comment
- (NSArray *)getPublicTimeline:(int) count; // statuses/public_timeline
- (NSArray *)getFriendsTimeline:(weiboId) sinceId maxId:(weiboId) maxid count:(int ) maxCount page:(int) currentPage;
- (NSArray *)getUserTimeline:(weiboId) uid userId:(int ) userId screenName:(NSString *) screenName 
			  sinceId:(weiboId) sinceId maxId:(weiboId) maxid count:(int ) maxCount page:(int) currentPage;
- (NSArray *)getMentions:(weiboId) sinceId maxId:(weiboId) maxid count:(int ) maxCount page:(int) currentPage;
- (NSArray *)getCommentsTimeline:(weiboId) sinceId maxId:(weiboId) maxid count:(int) maxCount page:(int) currentPage;
- (NSArray *)getCommentsByMe:(weiboId) sinceId maxId:(weiboId) maxid count:(int) maxCount page:(int) currentPage;
- (NSArray *)getCommentsToMe:(weiboId) sinceId maxId:(weiboId) maxid count:(int) maxCount page:(int) currentPage;
- (NSArray *)getComments:(weiboId) statusId count:(weiboId) maxCount page:(int) currentPage;
- (NSString *)getStatusCount:(weiboId[]) ids;
- (NSString *)getStatusUnread:(int ) withOrNotNewStatus sinceId:(weiboId) sinceId;
- (NSString *)resetCount;
- (Status *)getStatusShow:(weiboId) statusId;
- (Status *)getStatusByUidStatusId:(weiboId) stautsId uid:(int) uid;
- (Status *)statusUpdate:(NSString *) status inReplyToStatusId:(weiboId) replyToId latitude:(double) lat longitude:(double) longitude;
- (Status *)statusUpload:(NSString *) status pic:(NSString *) pic latitude:(double ) lat longitude:(double) longitude;
- (Status *)statusDestroy:(weiboId) statusId;
- (Status *)statusRepost:(weiboId) statusId status:(NSString *) status;
- (Comment *)comment:(weiboId) statusId commentString:(NSString *) commentString;
- (Comment *)commentDestroy:(weiboId) commentId;
- (Comment *)commentDestroyBatch:(weiboId[] )commentIds;
- (Comment *)statusReply:(weiboId ) statusId commentId:(weiboId ) commentId comment:(NSString *) comment;

//emotions
- (NSString *)getEmotions;

//direct message
- (NSArray *)getDms:(weiboId ) sinceId maxId:(weiboId ) maxid count:(int) maxCount page:(int) currentPage;
- (NSArray *)getDmsSent:(weiboId) sinceId maxId:(weiboId) maxid count:(int ) maxCount page:(int) currentPage;
- (DirectMessage *)newDm:(weiboId) userId screenName:(NSString *) screenName dmText:(NSString *) dm;
- (DirectMessage *)dmDestroy:(weiboId) dmId;
- (NSArray *)dmDestroyBatch:(weiboId[]) dmIds;
@end

//
//  Weibo.m
//  weibo4objc
//
//  Created by fanng yuan on 11/29/10.
//  Copyright 2010 fanngyuan@sina. All rights reserved.
//

#import "Weibo.h"
#import "HttpMethod.h"
#import "Base64.h"
#import "JsonStatusParser.h"
#import "StringPart.h"
#import "FilePart.h"

extern NSString * callbackURL;

@interface Weibo (Private) 

- (NSString *) generateParameterString:(NSDictionary *) parameters;
- (void *) generateBodyDic:(NSMutableDictionary *) bodyDic paraKey:(NSString *) key paraValue:(NSString *) value;	
-(HttpMethod *) getMethod:(NSString *) urlString;
-(HttpMethod *) putMethod:(NSString *) urlString;	
-(HttpMethod *) postMethd:(NSString *) urlString;
- (NSString *) retrieveData:(NSString *) urlString callMethod:(methodEnum ) methodE body:(NSDictionary *) httpbody;
-(NSString * ) uploadData:(NSString *) status url:(NSString *) urlString picture:(NSString *) pic lat:(double ) lat log:(double) log;
- (NSDictionary *) setAuth;

@end

@implementation Weibo

@synthesize _consumerKey;
@synthesize _consumerSecret;
@synthesize _accessToken;

@synthesize _username;
@synthesize _password;
@synthesize authType;


NSString * baseUrl = @"http://220.181.129.103/";
NSString * error = @"error_code";

-(id) init{
	self = [super init];
	if(self != nil){
		client = [[HttpClient alloc] init];
		authType = OAUTH;
	}
	return self;
}

-(void) dealloc{
	[_consumerKey release];
	[_consumerSecret release];
	[_accessToken release];
	[_username release];
	[_password release];
	[client release];
	[super dealloc];
}

- (NSArray *)getPublicTimeline:(int) count{
	NSMutableString * urlString = [[NSMutableString alloc] init];
	[urlString appendString:baseUrl];
	[urlString appendFormat:@"statuses/public_timeline.json?source=%@",_consumerKey];
	if(count > 0)
		[urlString appendFormat:@"&count=%d",count];
	NSString * resultString = [self retrieveData:urlString callMethod:GET body:nil];
	NSArray * result = [JsonStatusParser parseToStatuses:resultString];
	[urlString release];
	[result autorelease];
	[resultString release];
	return result;
}

- (Status *)statusUpdate:(NSString *) status inReplyToStatusId:(weiboId) replyToId latitude:(double) lat longitude:(double) longitude{
    if(status == nil){
		InvalidParameterException * exception = [InvalidParameterException 
												 exceptionWithName:@"Invalid Parameter Exception" reason:@"Status should not be nil. " userInfo:nil];
		@throw exception;
	}
    NSMutableString * urlString = [[NSMutableString alloc] init];
	[urlString appendString:baseUrl];
	[urlString appendFormat:@"statuses/update.json"];
	NSMutableDictionary * mbody = [[NSMutableDictionary alloc] init];
	[mbody setObject:status forKey:@"status"];
	if(replyToId!=nilReplyId)
        [self generateBodyDic:mbody paraKey:@"in_reply_to_status_id" paraValue:[NSString stringWithFormat:@"%llu",replyToId]];
	if(lat != nilLatitude)
        [self generateBodyDic:mbody paraKey:@"lat" paraValue:[NSString stringWithFormat:@"%f",lat] ];
	if(longitude != nilLongitude)
        [self generateBodyDic:mbody paraKey:@"long" paraValue:[NSString stringWithFormat:@"%f",longitude] ];
	NSString * resultString = [self retrieveData:urlString callMethod: POST body:mbody];
	NSRange range = [resultString rangeOfString:error];
	if(range.location == NSNotFound){
		Status * result = [JsonStatusParser parseToStatus:resultString];
		[urlString release];
		[result autorelease];
		[resultString release];
		[mbody release];
		return result;	
	}else{
		ServerSideException * exception = [[[ServerSideException alloc] init] autorelease];
		ServerSideError * errorMsg = [JsonStatusParser parsetoServerSideError:resultString];
		[exception setError:errorMsg];
		[errorMsg release];
		[urlString release];
		[resultString release];
		[mbody release];
		@throw exception;
	}
}

- (Status *)statusUpload:(NSString *) status pic:(NSString *) pic latitude:(double ) latitude longitude:(double) longitude{
	if(status == nil||pic == nil){
		InvalidParameterException * exception = [InvalidParameterException 
												 exceptionWithName:@"Invalid Parameter Exception" reason:@"Status should not be nil. " userInfo:nil];
		@throw exception;
	}
	NSMutableString * urlString = [[NSMutableString alloc] init];
	[urlString appendString:baseUrl];
	[urlString appendFormat:@"statuses/upload.json?source=%@",_consumerKey];
	NSString * resultString = [self uploadData:status url:urlString picture:pic lat:latitude log:longitude];
	NSRange range = [resultString rangeOfString:error];
	if(range.location == NSNotFound){
		Status * result = [JsonStatusParser parseToStatus:resultString];
		[urlString release];
		[result autorelease];
		[resultString release];
		return result;	
	}else{
		ServerSideException * exception = [[[ServerSideException alloc] init] autorelease];
		ServerSideError * errorMsg = [JsonStatusParser parsetoServerSideError:resultString];
		[exception setError:errorMsg];
		[errorMsg release];
		[urlString release];
		[resultString release];
		@throw exception;
	}
}

-(NSString * ) uploadData:(NSString *) status url:(NSString *) urlString picture:(NSString *) pic lat:(double ) lat log:(double) log{
	NSURL * url = [[NSURL alloc] initWithString:urlString];
	HttpMethod * method = [[HttpMethod alloc] initWithMethod:MULTI];
	StringPart * statusPart = [[StringPart alloc] initWithParameter:status withName:@"status"];
	NSURL * picUrl = [[NSURL alloc] initWithString:pic];
	FilePart * picPart = [[FilePart alloc] initWithNameAndFile:@"pic" file:picUrl];
	[method addPart:statusPart];
	[method addPart:picPart];
	if(lat != nilLatitude){
		StringPart * latPart = [[StringPart alloc] initWithParameter:[[[NSString alloc] initWithFormat:@"%f",lat] autorelease] withName:@"latitude"];
		[method addPart:latPart];
		[latPart release];
	}
	if(log != nilLongitude){
		StringPart * logPart = [[StringPart alloc] initWithParameter:[[[NSString alloc] initWithFormat:@"%f",log] autorelease] withName:@"longitude"];
		[method addPart:logPart];
		[logPart release];
	}	
	[method setUrl:url];
	NSDictionary * headers = [self setAuth];
	[method setHeaderFields:headers];
	HttpResponse * response =[client executeMethod:method];
	[url release];
	[method release];
	return [response responseString];
}

- (NSArray *)getFriendsTimeline:(weiboId) sinceId maxId:(weiboId) maxid count:(int) maxCount page:(int) currentPage{
	NSMutableString * urlString = [[NSMutableString alloc] init];
	[urlString appendString:baseUrl];
	[urlString appendFormat:@"statuses/friends_timeline.json"];
	NSDictionary * paraDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%lld",sinceId],@"since_id",[NSString stringWithFormat:@"%lld",maxid],@"max_id",[NSString stringWithFormat:@"%d",maxCount],@"count",[NSString stringWithFormat:@"%d",currentPage],@"page",nil];
    NSString * paraString = [self generateParameterString:paraDic];
    [urlString appendString:paraString];
    NSString * resultString = [self retrieveData:urlString callMethod:GET body:paraDic];
	NSArray * result = [JsonStatusParser parseToStatuses:resultString];
	[urlString release];
	[result autorelease];
	[resultString release];
	return result;	
}

- (NSArray *)getUserTimeline:(weiboId) uid userId:(int) userId screenName:(NSString *) screenName 
sinceId:(weiboId) sinceId maxId:(weiboId) maxid count:(int) maxCount page:(int) currentPage{
	NSMutableString * urlString = [[NSMutableString alloc] init];
	[urlString appendString:baseUrl];
	// uid will lost at here temporarily
	[urlString appendFormat:@"statuses/user_timeline.json?source=%@",_consumerKey];
	NSDictionary * paraDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithLongLong:uid],@"user_id",[NSNumber numberWithLongLong:sinceId],@"since_id",[NSNumber numberWithLongLong:maxid],@"max_id",[NSNumber numberWithInt:maxCount],@"count",
							  [NSNumber numberWithInt:currentPage],@"page",nil];
	NSString * paraString = [self generateParameterString:paraDic];
	[urlString appendFormat:paraString];
	[paraString release];
	NSString * resultString = [self retrieveData:urlString callMethod:GET body:nil];
	NSArray * result = [JsonStatusParser parseToStatuses:resultString];
	[urlString release];
	[result autorelease];
	[resultString release];
	return result;		
}

- (NSArray *)getMentions:(weiboId) sinceId maxId:(weiboId) maxid count:(int) maxCount page:(int) currentPage{
	NSMutableString * urlString = [[NSMutableString alloc] init];
	[urlString appendString:baseUrl];
	[urlString appendFormat:@"statuses/mentions.json?source=%@",_consumerKey];
	NSDictionary * paraDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithLongLong:sinceId],
							  @"since_id",[NSNumber numberWithLongLong:maxid],@"max_id",
							  [NSNumber numberWithInt:maxCount],@"count",
							  [NSNumber numberWithInt:currentPage],@"page",nil];
	NSString * paraString = [self generateParameterString:paraDic];
	[urlString appendFormat:@"%@",paraString];
	[paraString release];
	NSString * resultString = [self retrieveData:urlString callMethod:GET body:nil];
	NSArray * result = [JsonStatusParser parseToStatuses:resultString];
	[urlString release];
	[result autorelease];
	[resultString release];
	return result;			
}

- (NSArray *)getCommentsTimeline:(weiboId) sinceId maxId:(weiboId) maxid count:(int) maxCount page:(int) currentPage{
	NSMutableString * urlString = [[NSMutableString alloc] init];
	[urlString appendString:baseUrl];
	[urlString appendFormat:@"statuses/comments_timeline.json?source=%@",_consumerKey];
	NSDictionary * paraDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithLongLong:sinceId],@"since_id",
							  [NSNumber numberWithLongLong:maxid],@"max_id",[NSNumber numberWithInt:maxCount],@"count",
							  [NSNumber numberWithInt:currentPage],@"page",nil];
	NSString * paraString = [self generateParameterString:paraDic];
	[urlString appendFormat:@"%@",paraString];
	[paraString release];
	NSString * resultString = [self retrieveData:urlString callMethod:GET body:nil];
	NSArray * result = [JsonStatusParser parseToComments:resultString];
	[urlString release];
	[result autorelease];
	[resultString release];
	return result;			
}

- (NSArray *)getCommentsByMe:(weiboId) sinceId maxId:(weiboId) maxid count:(int) maxCount page:(int) currentPage{
	NSMutableString * urlString = [[NSMutableString alloc] init];
	[urlString appendString:baseUrl];
	[urlString appendFormat:@"statuses/comments_by_me.json?source=%@",_consumerKey];
	NSDictionary * paraDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithLongLong:sinceId],@"since_id",
							  [NSNumber numberWithLongLong:maxid],@"max_id",[NSNumber numberWithInt:maxCount],@"count",
							  [NSNumber numberWithInt:currentPage],@"page",nil];
	NSString * paraString = [self generateParameterString:paraDic];
	[urlString appendFormat:@"%@",paraString];
	[paraString release];
	NSString * resultString = [self retrieveData:urlString callMethod:GET body:nil];
	NSArray * result = [JsonStatusParser parseToComments:resultString];
	[urlString release];
	[result autorelease];
	[resultString release];
	return result;				
}

- (NSArray *)getCommentsToMe:(weiboId) sinceId maxId:(weiboId) maxid count:(int) maxCount page:(int) currentPage{
	NSMutableString * urlString = [[NSMutableString alloc] init];
	[urlString appendString:baseUrl];
	[urlString appendFormat:@"statuses/comments_timeline.json?source=%@",_consumerKey];
	NSDictionary * paraDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithLongLong:sinceId],@"since_id",
							  [NSNumber numberWithLongLong:maxid],@"max_id",[NSNumber numberWithInt:maxCount],@"count",
							  [NSNumber numberWithInt:currentPage],@"page",nil];
	NSString * paraString = [self generateParameterString:paraDic];
	[urlString appendFormat:@"%@",paraString];
	[paraString release];
	NSString * resultString = [self retrieveData:urlString callMethod:GET body:nil];
	NSArray * result = [JsonStatusParser parseToComments:resultString];
	[urlString release];
	[result autorelease];
	[resultString release];
	return result;				
}

- (NSArray *)getComments:(weiboId) statusId count:(int) maxCount page:(int) currentPage{
	NSMutableString * urlString = [[NSMutableString alloc] init];
	[urlString appendString:baseUrl];
	[urlString appendFormat:@"statuses/comments.json?source=%@",_consumerKey];
	NSDictionary * paraDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithLongLong:statusId],@"id",
							  [NSNumber numberWithInt:maxCount],@"count",
							  [NSNumber numberWithInt:currentPage],@"page",nil];
	NSString * paraString = [self generateParameterString:paraDic];
	[urlString appendFormat:@"%@",paraString];
	[paraString release];
	NSString * resultString = [self retrieveData:urlString callMethod:GET body:nil];
	NSArray * result = [JsonStatusParser parseToStatuses:resultString];
	[urlString release];
	[result autorelease];
	[resultString release];
	return result;				
}

- (Comment *)comment:(weiboId) statusId commentString:(NSString *) commentString{
	if(statusId == NULL||commentString==nil){
		InvalidParameterException * exception = [InvalidParameterException 
												 exceptionWithName:@"Invalid Parameter Exception" reason:@"Status should not be nil. " userInfo:nil];
		@throw exception;
	}
	NSMutableString * urlString = [[NSMutableString alloc] init];
	[urlString appendString:baseUrl];
	[urlString appendFormat:@"statuses/comment.json?source=%@",_consumerKey];
	//todo add new check
	NSDictionary * mbody = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithLongLong:statusId],@"id",
							commentString,@"comment",nil];
	NSString * resultString = [self retrieveData:urlString callMethod:POST body:mbody];
	Comment * result = [JsonStatusParser parseToComment:resultString];
	[urlString release];
	[result autorelease];
	[resultString release];
	return result;					
}

- (NSString *) retrieveData:(NSString *) urlString callMethod:(methodEnum ) methodE body:(NSDictionary *) httpbody{
    NSURL * url = [[NSURL alloc] initWithString:urlString];
	HttpMethod * method = [[HttpMethod alloc] initWithMethod:methodE];
	[method setUrl:url];
	NSDictionary * headers = [self setAuthWithURL:urlString HttpMethod:methodE Parameters:httpbody];
	[method setHeaderFields:headers];
	[method setBody:httpbody]; 
	HttpResponse * response =[client executeMethod:method];
	[url release];
	[method release];
	return [response responseString]; 
}


- (NSArray *)getDms:(weiboId) sinceId maxId:(weiboId) maxid count:(int) maxCount page:(int) currentPage{
	NSMutableString * urlString = [[NSMutableString alloc] init];
	[urlString appendString:baseUrl];
	[urlString appendFormat:@"direct_messages.json?source=%@",_consumerKey];
	NSDictionary * paraDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithLongLong:sinceId],@"since_id",
							  [NSNumber numberWithLongLong:maxid],@"max_id",[NSNumber numberWithInt:maxCount],@"count",
							  [NSNumber numberWithInt:maxCount],@"page",nil];
	NSString * paraString = [self generateParameterString:paraDic];
	[urlString appendFormat:@"%@",paraString];
	[paraString release];
	NSString * resultString = [self retrieveData:urlString callMethod:GET body:nil];
	NSArray * result = [JsonStatusParser parseToDms:resultString];
	[urlString release];
	[result autorelease];
	[resultString release];
	return result;					
}

- (NSArray *)getDmsSent:(weiboId) sinceId maxId:(weiboId) maxid count:(int) maxCount page:(int) currentPage{
	NSMutableString * urlString = [[NSMutableString alloc] init];
	[urlString appendString:baseUrl];
	[urlString appendFormat:@"direct_messages/sent.json?source=%@",_consumerKey];
	NSDictionary * paraDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithLongLong:sinceId],@"since_id",
							  [NSNumber numberWithLongLong:maxid],@"max_id",[NSNumber numberWithInt:maxCount],@"count",
							  [NSNumber numberWithInt:currentPage],@"page",nil];
	NSString * paraString = [self generateParameterString:paraDic];
	[urlString appendFormat:@"%@",paraString];
	[paraString release];
	NSString * resultString = [self retrieveData:urlString callMethod:GET body:nil];
	NSArray * result = [JsonStatusParser parseToDms:resultString];
	[urlString release];
	[result autorelease];
	[resultString release];
	return result;						
}

- (DirectMessage *)newDm:(int) userId screenName:(NSString *) screenName dmText:(NSString *) dm{
	if(userId<0||screenName==nil||dm==nil){
		InvalidParameterException * exception = [InvalidParameterException 
												 exceptionWithName:@"Invalid Parameter Exception" reason:@"Status should not be nil. " userInfo:nil];
		@throw exception;
	}
	NSMutableString * urlString = [[NSMutableString alloc] init];
	[urlString appendString:baseUrl];
	[urlString appendFormat:@"direct_messages/new.json?source=%@",_consumerKey];
	NSDictionary * mbody = [NSDictionary dictionaryWithObjectsAndKeys:dm,@"text",nil];
	NSString * resultString = [self retrieveData:urlString callMethod:POST body:mbody];
	DirectMessage * result = [JsonStatusParser parseToDm:resultString];
	[urlString release];
	[result autorelease];
	[resultString release];
	return result;					
}

- (DirectMessage *)dmDestroy:(weiboId) dmId{
	if(dmId<0){
		InvalidParameterException * exception = [InvalidParameterException 
												 exceptionWithName:@"Invalid Parameter Exception" reason:@"Status should not be nil. " userInfo:nil];
		@throw exception;		
	}
	NSMutableString * urlString = [[NSMutableString alloc] init];
	[urlString appendString:baseUrl];
	[urlString appendFormat:@"direct_messages/destroy/%lf.json?source=%@",dmId,_consumerKey];
	NSString * resultString = [self retrieveData:urlString callMethod:POST body:nil];
	DirectMessage * result = [JsonStatusParser parseToDm:resultString];
	[urlString release];
	[result autorelease];
	[resultString release];
	return result;						
}

- (Status *)statusDestroy:(weiboId) statusId{
	if(statusId<0){
		InvalidParameterException * exception = [InvalidParameterException 
												 exceptionWithName:@"Invalid Parameter Exception" reason:@"Status should not be nil. " userInfo:nil];
		@throw exception;		
	}
	NSMutableString * urlString = [[NSMutableString alloc] init];
	[urlString appendString:baseUrl];
	[urlString appendFormat:@"statuses/destroy/%lf.json?source=%@",statusId,_consumerKey];
	NSString * resultString = [self retrieveData:urlString callMethod:POST body:nil];
	Status * result = [JsonStatusParser parseToStatus:resultString];
	[urlString release];
	[result autorelease];
	[resultString release];
	return result;							
}

- (Status *)statusRepost:(weiboId) statusId status:(NSString *) status{
	if(status == nil||statusId<=0){
		InvalidParameterException * exception = [InvalidParameterException 
												 exceptionWithName:@"Invalid Parameter Exception" reason:@"Status should not be nil. " userInfo:nil];
		@throw exception;
	}
	NSMutableString * urlString = [[NSMutableString alloc] init];
	[urlString appendString:baseUrl];
	[urlString appendFormat:@"statuses/repost.json?source=%@",_consumerKey];
	NSDictionary * mbody = [NSDictionary dictionaryWithObjectsAndKeys:statusId,@"id",status,@"status",nil];
	NSString * resultString = [self retrieveData:urlString callMethod: POST body:mbody];
	Status * result = [JsonStatusParser parseToStatus:resultString];
	[urlString release];
	[result autorelease];
	[resultString release];
	return result;		
}

- (Comment *)commentDestroy:(weiboId) commentId{
	if(commentId<=0){
		InvalidParameterException * exception = [InvalidParameterException 
												 exceptionWithName:@"Invalid Parameter Exception" reason:@"Status should not be nil. " userInfo:nil];
		@throw exception;		
	}
	NSMutableString * urlString = [[NSMutableString alloc] init];
	[urlString appendString:baseUrl];
	[urlString appendFormat:@"statuses/comment_destroy/%lf.json?source=%@",commentId,_consumerKey];
	NSString * resultString = [self retrieveData:urlString callMethod:POST body:nil];
	Comment * result = [JsonStatusParser parseToComment:resultString];
	[urlString release];
	[result autorelease];
	[resultString release];
	return result;								
}

- (NSDictionary *) setAuth{
	[Base64 initialize];
	NSMutableString * tmpString = [[NSMutableString alloc]init];
	[tmpString appendFormat:_username];
	[tmpString appendFormat:@":"];
	[tmpString appendFormat:_password];
	NSData* data=[tmpString dataUsingEncoding:NSUTF8StringEncoding];
	NSString * baseString = [Base64 encode:data];
	NSString * authString = [[NSString alloc] initWithFormat:@"%@ %@",@"Basic",baseString];
	NSDictionary * headers = [NSDictionary dictionaryWithObjectsAndKeys:authString,@"Authorization",nil];
	[authString release];
	[tmpString release];
	return headers;
}

- (NSDictionary *) setAuthWithURL:(NSString *) urlString HttpMethod:(methodEnum) methodE  Parameters:(NSMutableDictionary *) parameters{
    
    
    _accessToken = [[OAToken alloc] init];
    
    _accessToken.key = [[NSUserDefaults standardUserDefaults] objectForKey:@"accessTokenKey"];
    _accessToken.secret = [[NSUserDefaults standardUserDefaults] objectForKey:@"accessTokenSecret"];
    _accessToken.verifier = [[NSUserDefaults standardUserDefaults] objectForKey:@"accessTokenVerifier"];
    
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:_consumerKey
													secret:_consumerSecret];
    
    OauthSingnature *request = [[OauthSingnature alloc] initWithURL:urlString
                                                           consumer:consumer
                                                              token:_accessToken
                                                              realm:nil
                                                  signatureProvider:nil];
        
    NSArray * values = [parameters allValues];
    NSArray * keys = [parameters allKeys];
    NSMutableArray * parameter = [[NSMutableArray alloc] init];
    for (int i=0; i < [values count]; i++) {
        OARequestParameter * requestParameter = [OARequestParameter requestParameterWithName:[keys objectAtIndex:i] value:[values objectAtIndex:i]];
        [parameter addObject:requestParameter];
    }
    
    [request setParameters:parameter];
	[request setMethod:methodE];
    [request setUrlStringWithoutQuery:[[urlString componentsSeparatedByString:@"?"] objectAtIndex:0]];
    
    NSString *authString = [request getSingnatureString];
    
    NSDictionary * headers = [NSDictionary dictionaryWithObjectsAndKeys:authString,@"Authorization",nil];
    
    return headers;
    
}


- (BOOL)requestRequestToken{
	NSMutableString * urlString = [[NSMutableString alloc] init];
	[urlString appendString:baseUrl];
	[urlString appendFormat:@"oauth/request_token"];    
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:_consumerKey
													secret:_consumerSecret];
	OauthSingnature *request = [[OauthSingnature alloc] initWithURL:urlString
                                                           consumer:consumer
                                                              token:nil
                                                              realm:nil
                                                  signatureProvider:nil];
	[request setMethod:POST];
    NSString * headerString = [request getSingnatureString];
    
    //Set Header
    NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithObject:headerString forKey:@"Authorization"];
    
    NSString * queryString = [request getQueryString];
     [urlString appendFormat:@"?%@",queryString];
     NSLog(@"urlString:%@",urlString);
     
    
    NSURL * url = [[NSURL alloc] initWithString:urlString];
    
    HttpMethod * method = [[HttpMethod alloc] initWithMethod:POST];
    [method setUrl:url];
	[method setHeaderFields:headers];
    
    //Post Request
	HttpResponse * response =[client executeMethod:method];
	[url release];
	[method release];
    
    NSString *responseBody = [[NSString alloc] initWithData:[response responseData]
                                                   encoding:NSUTF8StringEncoding];
    _accessToken = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
    
    
    if (_accessToken.secret != nil) {
        return YES;
    }
    return NO;
}

- (NSString *) askUserForAuthorization{
    
    NSString *address = [NSString stringWithFormat:
                         @"http://api.t.sina.com.cn/oauth/authorize?oauth_token=%@",
                         _accessToken.key];
    
    
    //You Also Can Use a WebView Here
    NSURL * url = [NSURL URLWithString:address];
    [[UIApplication sharedApplication] openURL:url];
    
    /*  
        
        //1.Set a URL Type in Your App Info, Then Set Callback URL To Your URL Schemes:
            callbackURL = @"yourSchemes://";
        
     
        //2.Use Following Method To Get Callback:
            for UIKit:
                - (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url;
            for AppKit:
                - (void)handleURLEvent:(NSAppleEventDescriptor*)event withReplyEvent:(NSAppleEventDescriptor*)replyEvent;
                
     
        //3.Save Your Verifier Like This:
          [[NSUserDefaults standardUserDefaults] setObject:(NSString *)pin forKey:@"accessTokenVerifier"];
     
     
        //4.If You Done Saving , Performance:
          [self requestAccessToken];
     
    */

}

- (NSString *)requestAccessToken{
    
    NSMutableString * urlString = [[NSMutableString alloc] init];
	[urlString appendString:baseUrl];
	[urlString appendFormat:@"oauth/access_token"];    
    NSURL * url = [[NSURL alloc] initWithString:urlString];
	HttpMethod * method = [[HttpMethod alloc] initWithMethod:POST];
	[method setUrl:url];
    
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:_consumerKey
													secret:_consumerSecret];
    
    _accessToken.verifier = [[NSUserDefaults standardUserDefaults] stringForKey:@"accessTokenVerifier"];
    	
	OauthSingnature *request = [[OauthSingnature alloc] initWithURL:urlString
                                                           consumer:consumer
                                                              token:_accessToken
                                                              realm:nil
                                                  signatureProvider:nil];
	
	[request setMethod:POST];
    
    NSString * headerString = [request getSingnatureString];
    
    NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithObject:headerString forKey:@"Authorization"];
    
	[method setHeaderFields:headers];
    
	HttpResponse * response =[client executeMethod:method];
	[url release];
	[method release];
    
    NSString *responseBody = [[NSString alloc] initWithData:[response responseData]
                                                   encoding:NSUTF8StringEncoding];
    
    _accessToken = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
    
    [[NSUserDefaults standardUserDefaults] setObject:_accessToken.key forKey:@"accessTokenKey"];
    [[NSUserDefaults standardUserDefaults] setObject:_accessToken.secret forKey:@"accessTokenSecret"];
    
    //start using.
    
    return [response responseString];
    
}


- (NSString *) generateParameterString:(NSDictionary *) parameters{
	NSMutableString * result = [[NSMutableString alloc] init];
	for(NSString * key in parameters){
		NSData * value = [parameters objectForKey:key];
		if(value != nil){
			[result appendFormat:@"&%@=%@",key,[[NSString alloc] initWithData:value encoding:encoding]];
		}
	}
	return result;
}

- (void *) generateBodyDic:(NSMutableDictionary *) bodyDic paraKey:(NSString *) key paraValue:(NSString *) value{
	if(value!=nil){
		[bodyDic setObject:value forKey:key];
	}
}

+ (NSString *)version{
} 
- (NSString *)clientName{
} 
- (NSString *)clientVersion{}
- (NSString *)clientURL{}
- (NSString *)clientSourceToken{}
- (void)setClientName:(NSString *)name version:(NSString *)version URL:(NSString *)url token:(NSString *)token{}
- (NSString *)APIDomain{}
- (void)setAPIDomain:(NSString *)domain{}
- (BOOL)usesSecureConnection{}
- (NSString *)getImageAtURL:(NSString *)urlString{}

-(HttpMethod *) getMethod:(NSString *) urlString{
	HttpMethod * method = [[HttpMethod alloc] init];
	return method;
}

-(HttpMethod *) putMethod:(NSString *) urlString{
	HttpMethod * method = [[HttpMethod alloc] initWithMethod:PUT];
	return method;	
}

-(HttpMethod *) postMethd:(NSString *) urlString{
	HttpMethod * method =[[HttpMethod alloc] initWithMethod:POST];
	return method;
}

@end

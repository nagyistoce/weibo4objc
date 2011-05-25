//
//  HttpMethod.h
//  weibo4objc
//
//  Created by fanng yuan on 11/30/10.
//  Copyright 2010 fanngyuan@sina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpResponse.h"
#import "HttpMethodDelegate.h"
#import "PartBase.h"
#import "Constants.h"

typedef enum methodEnum {
    GET = 1,
    PUT = 2,
	POST = 3,
	MULTI = 4
} methodEnum;

@interface HttpMethod : NSObject {
	NSObject<HttpMethodDelegate> * delegate;
	BOOL needAsyncExcute;
	NSMutableDictionary * headerFields;
	NSMutableDictionary * body;
	NSURL * url;
	Auth auth;
}

-(id) init;
-(id) initWithMethod:(methodEnum ) httpMethod;

@property (readwrite,assign) BOOL needAsyncExcute;
@property (readwrite,retain) NSMutableDictionary * headerFields;
@property (readwrite,retain) NSMutableDictionary * body;
@property (readwrite,retain) NSURL * url;
@property (readwrite,assign) Auth auth;

-(void) setHeaderFieldsWithDictionary:(NSDictionary *)headerField;
-(void) setBodyWithDictionary:(NSDictionary *)aBody;
-(HttpResponse *) execute;
-(void) addPart:(PartBase *) part;

@end

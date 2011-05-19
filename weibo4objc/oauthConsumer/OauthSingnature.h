//
//  OauthSingnature.h
//  weibo4objc
//
//  Created by fanng yuan on 3/11/11.
//  Copyright 2011 fanngyuan@sina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OAConsumer.h"
#import "OAToken.h"
#import "OASignatureProviding.h"
#import "HttpMethod.h"
#import "Constants.h"

@interface OauthSingnature : NSObject {
@protected
    OAConsumer *consumer;
    OAToken *token;
    NSString *realm;
    NSString *signature;
    id<OASignatureProviding> signatureProvider;
    NSString *nonce;
    NSString *timestamp;
	NSArray *parameters;
	NSMutableDictionary *extraOAuthParameters;
	NSString *urlStringWithoutQuery;
	methodEnum method;
	Auth auth;
}
@property(readonly) NSString *signature;
@property(readonly) NSString *nonce;
@property(retain) NSString * urlStringWithoutQuery;
@property(assign) methodEnum method;
@property(assign) Auth auth;
@property(retain) NSArray * parameters;

- (id)initWithURL:(NSString *)urlString
		 consumer:(OAConsumer *)aConsumer
			token:(OAToken *)aToken
            realm:(NSString *)aRealm
signatureProvider:(id<OASignatureProviding, NSObject>)aProvider;

- (id)initWithURL:(NSString *)urlString
		 consumer:(OAConsumer *)aConsumer
			token:(OAToken *)aToken
            realm:(NSString *)aRealm
signatureProvider:(id<OASignatureProviding, NSObject>)aProvider
            nonce:(NSString *)aNonce
        timestamp:(NSString *)aTimestamp;

- (NSString *)getSingnatureString;
- (NSString *)getQueryString ;
- (void)setOAuthParameterName:(NSString*)parameterName withValue:(NSString*)parameterValue;

@end

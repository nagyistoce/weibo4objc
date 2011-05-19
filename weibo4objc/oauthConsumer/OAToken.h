//
//  OAToken.h
//  weibo4objc
//
//  Created by fanng yuan on 3/11/11.
//  Copyright 2011 fanngyuan@sina. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OAToken : NSObject {
@protected
	NSString *key;
	NSString *secret;
    NSString *verifier;
}
@property(retain) NSString *verifier;
@property(retain) NSString *key;
@property(retain) NSString *secret;

- (id)initWithKey:(NSString *)aKey secret:(NSString *)aSecret;
- (id)initWithUserDefaultsUsingServiceProviderName:(NSString *)provider prefix:(NSString *)prefix;
- (id)initWithHTTPResponseBody:(NSString *)body;
- (int)storeInUserDefaultsWithServiceProviderName:(NSString *)provider prefix:(NSString *)prefix;

@end

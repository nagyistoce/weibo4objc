//
//  OAHMAC_SHA1SignatureProvider.m
//  weibo4objc
//
//  Created by fanng yuan on 3/11/11.
//  Copyright 2011 fanngyuan@sina. All rights reserved.
//

#import "OAHMAC_SHA1SignatureProvider.h"
#import <CommonCrypto/CommonHMAC.h>

#include "Base64Transcoder.h"

@implementation OAHMAC_SHA1SignatureProvider

- (NSString *)name 
{
    return @"HMAC-SHA1";
}

- (NSString *)signClearText:(NSString *)text withSecret:(NSString *)secret 
{
    NSData *secretData = [secret dataUsingEncoding:NSUTF8StringEncoding];
    NSData *clearTextData = [text dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char result[20];
	CCHmac(kCCHmacAlgSHA1, [secretData bytes], [secretData length], [clearTextData bytes], [clearTextData length], result);

    //Base64 Encoding
    
    char base64Result[32];
    size_t theResultLength = 32;
    Base64EncodeData(result, 20, base64Result, &theResultLength);
    NSData *theData = [NSData dataWithBytes:base64Result length:theResultLength];
    
    NSString *base64EncodedResult = [[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding];
    return [base64EncodedResult autorelease];
}

@end

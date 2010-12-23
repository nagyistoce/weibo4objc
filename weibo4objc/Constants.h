/*
 *  Constants.h
 *  weibo4objc
 *
 *  Created by fanng yuan on 11/29/10.
 *  Copyright 2010 fanngyuan@sina. All rights reserved.
 *
 */

//for status get method
#define	defaultSinceId = 0;
#define	defaultCount = 200;
#define	defaultPage	= 1;

//for status unread
#define withNewStatus = 1;
#define withoutNewStatus = 0;

//base url
const static NSString * baseUrl = @"http://api.t.sina.com.cn/";

const static NSStringEncoding encoding = NSUTF8StringEncoding;

const static NSString * error = @"error_code";
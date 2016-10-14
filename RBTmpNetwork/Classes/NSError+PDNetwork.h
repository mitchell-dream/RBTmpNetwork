//
//  NSError+PDNetwork.h
//  Pudding
//
//  Created by baxiang on 16/9/1.
//  Copyright © 2016年 Zhi Kuiyu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
/**
 *  客户端网络错误
 */
UIKIT_EXTERN  NSString * const PDNetworkRequestErrorDomain;
typedef NS_ENUM(NSInteger, PDErrorCode) {
    
    PDErrorCodeNotConnectedToInternet   = NSURLErrorNotConnectedToInternet,/*网络连接失败*/
    PDErrorCodeTimeout                  = NSURLErrorTimedOut,/*请求超时*/
    PDErrorCodeNetworkConnectionLost    = NSURLErrorNetworkConnectionLost,/*网络连接丢失*/
    PDErrorCodeCannotConnectToHost      = NSURLErrorCannotConnectToHost,/*不能连接到服务器*/
    PDErrorCodeRequestHightFrequency = 10001,/*网络请求频率过高*/
    PDErrorCodeDownloadFailure = 10002, /*下载数据失败*/
    PDErrorCodeRequestSendFailure = 1003, /*网络请求失败*/
    PDErrorCodeRequestParseFailure = 1004,/*数据解析失败*/
};

@interface NSError (PDNetwork)
-(NSString*)errorDescription;
+(instancetype)errorWithDomain:(NSString *)domain code:(NSInteger)code description:(NSString *)description;
- (BOOL)isNetworkConnectionError;

@end

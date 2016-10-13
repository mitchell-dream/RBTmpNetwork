//
//  NSError+PDNetwork.m
//  Pudding
//
//  Created by baxiang on 16/9/1.
//  Copyright © 2016年 Zhi Kuiyu. All rights reserved.
//

#import "NSError+PDNetwork.h"

NSString * const PDNetworkRequestErrorDomain  = @"PDNetworkRequestErrorDomain";

@implementation NSError (PDNetwork)
-(void)setErrorDescription:(NSString *)errorDescription{

}

+(instancetype)errorWithDomain:(NSString *)domain code:(NSInteger)code description:(NSString *)description
{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    if ([description isKindOfClass:[NSString class]]) {
        userInfo[NSLocalizedDescriptionKey] = description;
    }
    NSDictionary *info = (userInfo.count) ? [userInfo copy] : nil;
    return [self errorWithDomain:domain code:code userInfo:info];
}
- (BOOL)isNetworkConnectionError {
    if ([self.domain isEqualToString:NSURLErrorDomain]) {
        switch (self.code) {
            case NSURLErrorTimedOut:
            case NSURLErrorCannotFindHost:
            case NSURLErrorCannotConnectToHost:
            case NSURLErrorNetworkConnectionLost:
            case NSURLErrorDNSLookupFailed:
            case NSURLErrorNotConnectedToInternet:
            case NSURLErrorInternationalRoamingOff:
            case NSURLErrorCallIsActive:
            case NSURLErrorDataNotAllowed:
                return YES;
        }
    }
    return NO;
}
/**
 *  NSURLError 中文转换
 *
 *  @param netError <#netError description#>
 *
 *  @return <#return value description#>
 */
- (NSString *)URLErrorDescription {
    switch (self.code) {
        // 网络错误
        case NSURLErrorTimedOut:
            return @"网络请求超时";
        case NSURLErrorNotConnectedToInternet:
            return @"无法连接网络"; //-1009
        case NSURLErrorNetworkConnectionLost:
            return @"网络请求中断";
        case NSURLErrorDNSLookupFailed:
            return @"域名解析失败";
        case NSURLErrorCancelled:
            return @"网络请求取消";
        case NSURLErrorCannotFindHost:
            return @"无法解析URL中的服务器";
        // 服务器错误
        case NSURLErrorCannotConnectToHost:
            return @"服务器连接失败";
        case NSURLErrorRedirectToNonExistentLocation:
            return @"服务器配置错误";
        case NSURLErrorBadServerResponse:
            return @"服务器异常";
        case NSURLErrorHTTPTooManyRedirects:
            return @"服务器定向错误";
        // 客户端错误
        case NSURLErrorBadURL:
            return @"URL地址错误";
        case NSURLErrorUnsupportedURL:
            return @"非法的URL";
        default:
            return self.localizedDescription == nil ? @"网络异常" : self.localizedDescription;
    }
}

-(NSString*)errorDescription{
    if ([self.domain isEqualToString:NSURLErrorDomain]) {
        return [self URLErrorDescription];
    }else if ([self.domain isEqualToString:PDNetworkRequestErrorDomain]){
        return self.localizedDescription == nil ? @"网络异常" : self.localizedDescription;
    }
    return self.localizedDescription == nil ? [NSString stringWithFormat:@"%@%zd",self.domain,self.code] : self.localizedDescription;
}

@end

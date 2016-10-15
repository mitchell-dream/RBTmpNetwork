//
//  PDNetworkLogger.m
//  Pudding
//
//  Created by baxiang on 16/8/29.
//  Copyright © 2016年 Zhi Kuiyu. All rights reserved.
//

#import "RBNetworkLogger.h"

@implementation RBNetworkLogger

+ (void)logDebugRequestInfoWithURL:(NSString *)url
                        methodName:(NSString *)methodName
                            params:(NSDictionary *)params
                reachabilityStatus:(NSInteger)reachabilityStatus{
#ifdef DEBUG
    NSMutableString *logString = [NSMutableString stringWithString:@"\n\n**********************************************************************************\n*                                    Request                                     *\n**********************************************************************************\n\n"];
    [logString appendFormat:@"URL:\t\t\t\t\t%@\n",url];
    [logString appendFormat:@"MethodName:\t%@\n",methodName];
    [logString appendFormat:@"Param:\t\t\t\t%@\n",params.count ? params : @""];
    NSString *netReachability = nil;
    switch (reachabilityStatus) {
        case 2:
            netReachability = @"WIFI";
            break;
        case 1:
            netReachability = @"2G/3G/4G";
            break;
        default:
            netReachability = @"无网络";
            break;
    }
    [logString appendFormat:@"Net:\t\t\t\t\t%@",netReachability];
    [logString appendFormat:@"\n\n**********************************************************************************\n*                                  Request End                                   *\n**********************************************************************************\n\n\n\n"];
    NSLog(@"%@", logString);
#endif
}

+ (void)logDebugResponseInfoWithSessionDataTask:(NSURLSessionTask *)sessionDataTask
                                 responseObject:(id)response
                                          error:(NSError *)error {
#ifdef DEBUG
    NSMutableString *logString = [NSMutableString stringWithString:@"\n\n==================================================================================\n=                                  Net Response                                  =\n==================================================================================\n\n"];
    BOOL shouldLogError = error ? YES : NO;
    if ([sessionDataTask.response isKindOfClass:[NSHTTPURLResponse class]]) {
        [logString appendFormat:@"Status:\t\t\t\t\t%ld\n", (long)[(NSHTTPURLResponse *)sessionDataTask.response statusCode]];
    }
    if (shouldLogError) {
        [logString appendFormat:@"Error Domain:\t\t\t\t\t\t\t%@\n", error.domain];
        [logString appendFormat:@"Error Domain Code:\t\t\t\t\t\t%ld\n", (long)error.code];
        [logString appendFormat:@"Error Localized Description:\t\t\t%@\n", error.localizedDescription];
        [logString appendFormat:@"Error Localized Failure Reason:\t\t\t%@\n", error.localizedFailureReason];
        [logString appendFormat:@"Error Localized Recovery Suggestion:\t%@\n\n", error.localizedRecoverySuggestion];
    }
    [logString appendFormat:@"Response:\t\t\t\t%@\n\n", response];
    
    
    [logString appendString:@"\n----------------------------  Related Request Content  ---------------------------\n"];
    [logString appendFormat:@"\nHTTP URL:\t\t\t%@", sessionDataTask.currentRequest.URL];
    [logString appendFormat:@"\n\nHTTP Header:\n\t%@", sessionDataTask.currentRequest.allHTTPHeaderFields];
    if (sessionDataTask.currentRequest.HTTPBody) {
        [logString appendFormat:@"\n\nHTTP Body:\n\t%@", [[NSString alloc] initWithData:sessionDataTask.currentRequest.HTTPBody encoding:NSUTF8StringEncoding]];
    }
    [logString appendFormat:@"\n\n==================================================================================\n=                               Net Response End                                 =\n==================================================================================\n\n\n\n"];
    NSLog(@"%@", logString);
#endif
}
+ (void)logCacheInfoWithResponseData:(id)responseData {
#ifdef DEBUG
    NSMutableString *logString = [NSMutableString stringWithString:@"\n\n==================================================================================\n=                                Cached Response                                 =\n==================================================================================\n\n"];
    [logString appendFormat:@"Response:\n\t%@\n\n", responseData];
    [logString appendFormat:@"\n\n==================================================================================\n=                              Cached Response End                               =\n==================================================================================\n\n\n\n"];
    NSLog(@"%@", logString);
#endif
}

@end

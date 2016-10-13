//
//  PDNetworkLogger.h
//  Pudding
//
//  Created by baxiang on 16/8/29.
//  Copyright © 2016年 Zhi Kuiyu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RBNetworkLogger : NSObject

+ (void)logDebugRequestInfoWithURL:(NSString *)url
                        methodName:(NSString *)methodName
                            params:(NSDictionary *)params reachabilityStatus:(NSInteger)reachabilityStatus;

+ (void)logDebugResponseInfoWithSessionDataTask:(NSURLSessionTask *)sessionDataTask
                                 responseObject:(id)response
                                          error:(NSError *)error;

+ (void)logCacheInfoWithResponseData:(id)responseData;
@end

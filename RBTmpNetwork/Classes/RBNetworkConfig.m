//
//  PDNetworkConfig.m
//  Pudding
//
//  Created by baxiang on 16/8/29.
//  Copyright © 2016年 Zhi Kuiyu. All rights reserved.
//

#import "RBNetworkConfig.h"
NSString * PDNetConfig_Msg_List = @"msg/gethistorybytime";  //消息中心
NSString * PDNetConfig_Family_List = @"moment/list";        //家庭动态列表
#define  PDNetworkDownloadName @"PDNetworkDownloadName"
@implementation RBNetworkConfig
+ (RBNetworkConfig *)defaultConfig {
    static RBNetworkConfig *_defaultConfig = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultConfig = [[RBNetworkConfig alloc] init];
    });
    return _defaultConfig;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        _acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/plain", nil];
        _defaultRequestSerializer = PDRequestSerializerTypeHTTP;
        _defaultResponseSerializer = PDResponseSerializerTypeJSON;
        _defaultTimeoutInterval = 20.0f;
        _enableDebug = YES;
        _defaultAcceptableStatusCodes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(200, 500)];
        _maxConcurrentOperationCount = 4;
    }
    return self;
}

-(NSString *)downloadFolderPath{
    if (!_downloadFolderPath) {
        NSString *docmentPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        NSString *tempDownloadFolder = [docmentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_Download",[[NSBundle mainBundle] bundleIdentifier]]];
        NSError *error = nil;
        if (![[NSFileManager defaultManager] fileExistsAtPath:tempDownloadFolder]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:tempDownloadFolder withIntermediateDirectories:YES attributes:nil error:&error];
        }
        _downloadFolderPath = tempDownloadFolder;
    }
    return _downloadFolderPath;
}


@end

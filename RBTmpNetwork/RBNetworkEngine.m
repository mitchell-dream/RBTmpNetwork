//
//  PDNetworkEngine.m
//  Pudding
//
//  Created by baxiang on 16/8/29.
//  Copyright © 2016年 Zhi Kuiyu. All rights reserved.
//

#import "RBNetworkEngine.h"
#import "AFNetworking.h"
#import "RBUploadRequest.h"
#import "NSError+PDNetwork.h"
#import "RBNetworkLogger.h"
#import "RBNetworkCache.h"
#import <CommonCrypto/CommonDigest.h>
#import <libkern/OSAtomic.h>
#import  <objc/runtime.h>
#import "RBNetworkUtilities.h"
#import "RBReachability.h"
#import "RBNetworkUtilities.h"

@interface NSDictionary (PDNetworkEngine)
- (NSMutableDictionary *)merge:(NSDictionary *)dict;
@end
@implementation NSDictionary (PDNetworkEngine)
- (NSMutableDictionary *)merge:(NSDictionary *)dict {
    @try {
        NSMutableDictionary *result = nil;
        if ([self isKindOfClass:[NSMutableDictionary class]]) {
            result = (NSMutableDictionary *)self;
        } else {
            result = [NSMutableDictionary dictionaryWithDictionary:self];
        }
        for (id key in dict) {
            if (result[key] == nil) {
                result[key] = dict[key];
            } else {
                if ([result[key] isKindOfClass:[NSDictionary class]] &&
                    [dict[key] isKindOfClass:[NSDictionary class]]) {
                    result[key] = [result[key] merge:dict[key]];
                } else {
                    result[key] = dict[key];
                }
            }
        }
        return result;
    }
    @catch (NSException *exception) {
        return [self mutableCopy];
    }
}
@end

@interface NSObject(PDNetworkEngine)
@property(nonatomic,strong)NSString * pd_URLString;
@property(nonatomic,strong)NSDictionary *pd_paramsDict;
@property (nonatomic, copy)NSString *pd_identifier;
@end
@implementation NSObject(PDNetworkEngine)

-(void)setPd_URLString:(NSString *)pd_URLString{
  objc_setAssociatedObject(self, @selector(pd_URLString), pd_URLString, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(NSString *)pd_URLString{
    return  objc_getAssociatedObject(self, _cmd);
}
-(void)setPd_paramsDict:(NSDictionary *)pd_paramsDict{
  objc_setAssociatedObject(self, @selector(pd_paramsDict), pd_paramsDict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(NSDictionary *)pd_paramsDict{
  return  objc_getAssociatedObject(self, _cmd);
}

-(void)setPd_identifier:(NSString *)pd_identifier{
   objc_setAssociatedObject(self, @selector(pd_identifier), pd_identifier, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(NSString *)pd_identifier{
  return  objc_getAssociatedObject(self, _cmd);
}

@end
#define LOCK(...) OSSpinLockLock(&_lock); \
__VA_ARGS__; \
OSSpinLockUnlock(&_lock);
@interface RBNetworkEngine()
@property (nonatomic, strong) NSMutableDictionary <NSString*, __kindof RBNetworkRequest*>*requestRecordDict;
@property (nonatomic,strong) AFHTTPSessionManager *sessionManager;
@property (nonatomic, strong) NSMutableArray <__kindof RBDownloadRequest *> *downloadingModels;
@property (nonatomic, strong) NSMutableDictionary <NSString *, __kindof RBDownloadRequest *> *downloadModelsDict;
@end
@implementation RBNetworkEngine{
  
    OSSpinLock _lock;
}

+ (RBNetworkEngine *)defaultEngine
{
    static RBNetworkEngine *_defaultEngine = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultEngine = [[RBNetworkEngine alloc] init];
    });
    return _defaultEngine;
}



- (instancetype)init
{
    self = [super init];
    if(self){
        _requestRecordDict = [NSMutableDictionary dictionary];
        _sessionManager = [AFHTTPSessionManager manager];
        _sessionManager.operationQueue.maxConcurrentOperationCount = [RBNetworkConfig defaultConfig].maxConcurrentOperationCount;
        _lock = OS_SPINLOCK_INIT;
        _downloadingModels = [[NSMutableArray alloc] initWithCapacity:1];
        _downloadModelsDict = [[NSMutableDictionary alloc] initWithCapacity:1];
    }
    return self;
}

- (BOOL)isConnectionAvailable
{
    return [[RBReachability reachability]isReachable];
}

- (NSString *)urlStringByRequest:(__kindof RBNetworkRequest *)request {
    NSString *detailUrl = request.requestURL;
    if ([detailUrl hasPrefix:@"http"]) {
        return detailUrl;
    }
    NSString *baseUrlString;
    if ([request.requestBaseURL length] > 0) {
        baseUrlString = request.requestBaseURL;
    } else {
        baseUrlString = [RBNetworkConfig defaultConfig].baseUrlString;;
    }
    return [NSString stringWithFormat:@"%@%@",baseUrlString,detailUrl];
}
- (NSDictionary *)requestParamByRequest:(__kindof RBNetworkRequest  *)request {
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
    if (request.requestParameters&&[request.requestParameters isKindOfClass:[NSDictionary class]]) {
        [tempDict addEntriesFromDictionary:request.requestParameters];
        
    }
    NSDictionary *baseRequestParamSource = [RBNetworkConfig defaultConfig].baseRequestParams;
    if (baseRequestParamSource != nil) {
        NSDictionary *mergeDict =[baseRequestParamSource merge:tempDict];
        [tempDict addEntriesFromDictionary:mergeDict];
    }
    return tempDict;
}
-(NSString*)identifierByRequest:(__kindof RBNetworkRequest *)request{
    NSData *data = [NSJSONSerialization dataWithJSONObject:request.pd_paramsDict options:NSJSONWritingPrettyPrinted error:nil];
    NSString *paramString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *cacheKey = [NSString stringWithFormat:@"%@%@%@",request.httpMethodString,request.pd_URLString,paramString];
    return [RBNetworkUtilities md5String:cacheKey];
}
- (void)setupSessionManagerRequestSerializerByRequest:(__kindof RBNetworkRequest *)request {
    //配置requestSerializerType
    self.sessionManager.requestSerializer = request.requestSerializer == PDRequestSerializerTypeHTTP ? [AFHTTPRequestSerializer serializer] : [AFJSONRequestSerializer serializer];
    self.sessionManager.responseSerializer = request.responseSerializer == PDResponseSerializerTypeHTTP ? [AFHTTPResponseSerializer serializer] : [AFJSONResponseSerializer serializer];
    //配置请求头
    NSDictionary *baseRequestHeaders = [RBNetworkConfig defaultConfig].baseRequestHeaders;
    [baseRequestHeaders enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [self.sessionManager.requestSerializer setValue:obj forHTTPHeaderField:key];
    }];
    NSDictionary *requestHeaders = request.requestHeaders ;
    [requestHeaders enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [self.sessionManager.requestSerializer setValue:obj forHTTPHeaderField:key];
    }];
    //配置请求超时时间
    self.sessionManager.requestSerializer.timeoutInterval = request.requestTimeout;
}

-(void)cacheDataWithRequest:(__kindof RBNetworkRequest *)request{
    id cacheData = [RBNetworkCache cacheForKey:request.pd_identifier];
    if (cacheData&&request.completionBlock) {
        request.isCacheData = YES;
        request.completionBlock(request,cacheData,nil);
    }
}
-(void)POST:(NSString*)URLString parameters:(NSDictionary*)paramters CompletionBlock:(PDRequestCompletionBlock)completionBlock;{
    RBNetworkRequest *request = [[[RBNetworkRequest class] alloc] initWithURLString:URLString method:PDRequestMethodPost params:paramters];
    [request startWithCompletionBlock:completionBlock];
}

- (void)executeRequestTask:(RBNetworkRequest *)request{
    request.pd_URLString = [self urlStringByRequest:request];
    request.pd_paramsDict = [self requestParamByRequest:request];
    request.pd_identifier = [self identifierByRequest:request];
    [self setupSessionManagerRequestSerializerByRequest:request];
    if (![self isConnectionAvailable]) {
        [self cacheDataWithRequest:request];
        NSError *error =[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorNotConnectedToInternet description:@"网络连接失败"];
        if (request.completionBlock) {
             request.completionBlock(request,nil,error);
        }
        return;
    }
    if ([RBNetworkConfig defaultConfig].enableDebug) {
        [RBNetworkLogger logDebugRequestInfoWithURL:request.pd_URLString  methodName:request.httpMethodString params:request.pd_paramsDict reachabilityStatus:[[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus]];
    }
    NSIndexSet *acceptableStatusCodes = request.acceptableStatusCodes ?: [RBNetworkConfig defaultConfig].defaultAcceptableStatusCodes;
    if (acceptableStatusCodes) {
        self.sessionManager.responseSerializer.acceptableStatusCodes = acceptableStatusCodes;
    }
    if ([request isKindOfClass:[RBDownloadRequest class]]) {
        [self _startDownloadTask:(RBDownloadRequest*)request];
    }else if ([request isKindOfClass:[RBUploadRequest class]]){
        [self _startUploadTask:(RBUploadRequest*)request];
    }else{
        [self _startRequestTask:request];
    }
}
- (void)cancelTask:(RBNetworkRequest *)requestTask{
    [requestTask.sessionTask cancel];
    [self removeRequestObject:requestTask];
    [requestTask clearRequestBlock];
}
-(void)cancelAllTask{
    NSDictionary *copyRecorddDict = [_requestRecordDict  copy];
   [copyRecorddDict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, __kindof RBNetworkRequest * _Nonnull requestTask, BOOL * _Nonnull stop) {
       [self cancelTask:requestTask];
   }];
}
#pragma mark 普通请求
- (void)_startRequestTask:(RBNetworkRequest *)requestTask{
    if (self.requestRecordDict[requestTask.pd_identifier]) {
        NSError *error =[NSError errorWithDomain:PDNetworkRequestErrorDomain code:PDErrorCodeRequestHightFrequency description:@"网络请求频率过高"];
        if (requestTask.completionBlock) {
            requestTask.completionBlock(requestTask,nil,error);
        }
        return;
    }
    if (requestTask.cachePolicy== PDNetworkCachePolicyNeedCache) {
        [self cacheDataWithRequest:requestTask];
    }
    __block  NSURLSessionDataTask *dataTask = nil;
    NSError *error = nil;
    NSMutableURLRequest *request = [self.sessionManager.requestSerializer requestWithMethod:requestTask.httpMethodString URLString:requestTask.pd_URLString parameters:requestTask.pd_paramsDict error:&error];
    if (error) {
        NSError *error =[NSError errorWithDomain:PDNetworkRequestErrorDomain code:PDErrorCodeRequestSendFailure description:@"网络请求失败"];
        if (requestTask.completionBlock) {
            requestTask.completionBlock(requestTask,nil,error);
        }
        return;
    }
    dataTask = [self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nonnull responseObject, NSError * _Nonnull error) {
        if ([RBNetworkConfig defaultConfig].enableDebug) {
            [RBNetworkLogger logDebugResponseInfoWithSessionDataTask:dataTask responseObject:responseObject  error:error];
        }
        if (!error) {
            [self handleRequestSuccess:dataTask responseObject:responseObject];
        }else{
            [self handleRequestFailure:dataTask responseObject:responseObject error:error];
        }
    }];
    dataTask.pd_identifier = [NSString stringWithFormat:@"%@",requestTask.pd_identifier];
    requestTask.sessionTask = dataTask;
    [dataTask resume];
    [self addRequestObject:requestTask];
}
- (void)_startUploadTask:(RBUploadRequest *)uploadTask{
        NSError *error = nil;
        NSMutableURLRequest *request =  [self.sessionManager.requestSerializer multipartFormRequestWithMethod:uploadTask.httpMethodString URLString:uploadTask.pd_URLString parameters:uploadTask.pd_paramsDict constructingBodyWithBlock:uploadTask.constructingBodyBlock error:&error];
      if (error) {
        NSError *error =[NSError errorWithDomain:PDNetworkRequestErrorDomain code:PDErrorCodeRequestSendFailure description:@"上传文件失败"];
        if (uploadTask.completionBlock) {
            uploadTask.completionBlock(uploadTask,nil,error);
        }
          return;
       }
        request.timeoutInterval = uploadTask.requestTimeout;
        [[uploadTask.requestHeaders allKeys] enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *value = [uploadTask.requestHeaders valueForKey:key];
            [request addValue:value forHTTPHeaderField:key];
        }];
           __block  NSURLSessionUploadTask *uploadDataTask = nil;
          uploadDataTask = [self.sessionManager uploadTaskWithStreamedRequest:request  progress:^(NSProgress *progress){
                if (uploadTask.progerssBlock) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        uploadTask.progerssBlock(uploadTask,progress);
                    });
                }
            }completionHandler:^(NSURLResponse * _Nonnull response, id  _Nonnull responseObject, NSError * _Nonnull error){
                if (!error) {
                    [self handleRequestSuccess:uploadDataTask responseObject:responseObject];
                }else{
                    [self handleRequestFailure:uploadDataTask responseObject:responseObject error:error];
                }
            }];
            uploadDataTask.pd_identifier = [NSString stringWithFormat:@"%@",uploadDataTask.pd_identifier];
            uploadTask.sessionTask = uploadDataTask;
            [uploadDataTask resume];
            [self addRequestObject:uploadTask];
    
}

- (void)addRequestObject:(__kindof RBNetworkRequest*)request {
    if (request == nil)    return;
    LOCK( _requestRecordDict[request.pd_identifier] = request);
}

- (void)removeRequestObject:(__kindof RBNetworkRequest*)request {
    if(request == nil)  return;
    LOCK( [_requestRecordDict removeObjectForKey:request.pd_identifier]);
}
- (void)handleRequestSuccess:(NSURLSessionTask *)sessionTask responseObject:(id)response {
    RBNetworkRequest  *request = _requestRecordDict[sessionTask.pd_identifier];
    if (request.cachePolicy == PDNetworkCachePolicyNeedCache) {
        [RBNetworkCache saveCache:response forKey:request.pd_identifier];
    }
    [self removeRequestObject:request];
    if(request.completionBlock) {
        request.isCacheData = NO;
        //id  jsonData =[response valueForKeyPath:request.responseContentDataKey];
        request.completionBlock(request,response,nil);
    }
}
- (void)handleRequestFailure:(NSURLSessionTask *)sessionTask responseObject:responseObject error:(NSError *)error {
    RBNetworkRequest  *request = _requestRecordDict[sessionTask.pd_identifier];
    [self removeRequestObject:request];
    
    if (request.completionBlock) {
        request.completionBlock(request,nil,error);
    }
    
}

//- (void)handleModelWithRequest:(PDNetworkRequest *)request response:(id)response{
//    Class responseModelClass = request.responseModelClass;
//    id responseData = response;
//    if ([response isKindOfClass:[NSDictionary class]]) {
//        id  jsonData =[response valueForKeyPath:request.responseContentDataKey];
//        if ([jsonData isKindOfClass:[NSArray class]]) {
//            if ([responseModelClass isSubclassOfClass:[NSArray class]]) {
//              responseData =jsonData;
//            }else{
//              responseData  = [NSArray modelArrayWithClass:responseModelClass json:jsonData];
//            }
//        }else if ([jsonData isKindOfClass:[NSDictionary class]]){
//            if ([responseModelClass isSubclassOfClass:[NSDictionary class]]) {
//                responseData = jsonData;
//            }else{
//               responseData = [responseModelClass modelWithJSON:jsonData];
//            }
//        }
//    }
//    if (request.completionBlock) {
//        if ([responseData isKindOfClass:responseModelClass]) {
//            request.isCacheData = NO;
//            request.completionBlock(request,responseData,nil);
//        }else{
//            NSError *parseError = [NSError errorWithDomain:PDNetworkRequestErrorDomain code:PDErrorCodeRequestParseFailure description:@"数据解析失败"];
//            request.completionBlock(request,nil,parseError);
//        }
//    }
//}



#pragma mark download
-(void)_startDownloadTask:(RBDownloadRequest *)downloadRequest{
    if ([[NSFileManager defaultManager] fileExistsAtPath:downloadRequest.filePath]) {
        if (downloadRequest.completionBlock) {
             downloadRequest.completionBlock(downloadRequest,[NSURL fileURLWithPath:downloadRequest.filePath],nil);
        }
        return ;
    }
    downloadRequest.resumeData = [NSData dataWithContentsOfFile:downloadRequest.resumeFilePath];
    if (downloadRequest.resumeData.length == 0) {
        NSMutableURLRequest *request = [self.sessionManager.requestSerializer requestWithMethod:downloadRequest.httpMethodString URLString:downloadRequest.pd_URLString parameters:downloadRequest.pd_paramsDict error:nil];
        downloadRequest.downloadTask = [self.sessionManager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
            [self setValuesForDownloadModel:downloadRequest withProgress:downloadProgress.fractionCompleted];
            if (downloadRequest.progerssBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    downloadRequest.progerssBlock(downloadRequest,downloadProgress);
                });
                
            }
        } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            return [NSURL fileURLWithPath:downloadRequest.filePath];
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            if (error) {
                [self _cancelDownloadTaskWithDownloadModel:downloadRequest];
                if (downloadRequest.completionBlock) {
                     NSError *downError = [NSError errorWithDomain:PDNetworkRequestErrorDomain code:PDErrorCodeDownloadFailure description:@"下载失败"];
                     downloadRequest.completionBlock(downloadRequest,nil,downError);
                }
               
            }else{
                [self.downloadModelsDict removeObjectForKey:downloadRequest.pd_URLString];
                if (downloadRequest.completionBlock) {
                    downloadRequest.completionBlock(downloadRequest,[NSURL fileURLWithPath:downloadRequest.filePath],nil);
                }
                [self deletePlistFileWithDownloadModel:downloadRequest];
            }
        }];
        
    }else{
        
        downloadRequest.totalBytesWritten = [self getResumeByteWithDownloadModel:downloadRequest];
        downloadRequest.downloadTask = [self.sessionManager downloadTaskWithResumeData:downloadRequest.resumeData progress:^(NSProgress * _Nonnull downloadProgress) {
            [self setValuesForDownloadModel:downloadRequest withProgress:[self.sessionManager downloadProgressForTask:downloadRequest.downloadTask].fractionCompleted];if (downloadRequest.progerssBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    downloadRequest.progerssBlock(downloadRequest,downloadProgress);
                });
            } downloadRequest.progerssBlock(downloadRequest,downloadProgress);
            
        } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            return [NSURL fileURLWithPath:downloadRequest.filePath];
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            if (error) {
                [self _cancelDownloadTaskWithDownloadModel:downloadRequest];
                if (downloadRequest.completionBlock) {
                   downloadRequest.completionBlock(downloadRequest,nil,error);
                }
            }else{
                [self.downloadModelsDict removeObjectForKey:downloadRequest.pd_URLString];
                if (downloadRequest.completionBlock) {
                    downloadRequest.completionBlock(downloadRequest,[NSURL fileURLWithPath:downloadRequest.filePath],nil);
                }
                
                [self deletePlistFileWithDownloadModel:downloadRequest];
            }
        }];
    }
    [self _resumeDownloadWithDownloadModel:downloadRequest];
}

-(void)_resumeDownloadWithDownloadModel:(RBDownloadRequest *)downloadModel{
    if (downloadModel.downloadTask) {
        downloadModel.downloadDate = [NSDate date];
        [downloadModel.downloadTask resume];
        self.downloadModelsDict[downloadModel.pd_URLString] = downloadModel;
        [self.downloadingModels addObject:downloadModel];
    }
}

-(void)_cancelDownloadTaskWithDownloadModel:(RBDownloadRequest *)downloadModel{
    if (!downloadModel) return;
    NSURLSessionTaskState state = downloadModel.downloadTask.state;
    if (state == NSURLSessionTaskStateRunning) {
        [downloadModel.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            downloadModel.resumeData = resumeData;
            @synchronized (self) {
                BOOL isSuc = [downloadModel.resumeData writeToFile:downloadModel.resumeFilePath atomically:YES];
                [self saveTotalBytesExpectedToWriteWithDownloadModel:downloadModel];
                if (isSuc) {
                    downloadModel.resumeData = nil;
                    [self.downloadModelsDict removeObjectForKey:downloadModel.pd_URLString];
                    [self.downloadingModels removeObject:downloadModel];
                }
            }
        }];
    }
}


-(RBDownloadRequest *)_getDownloadingModelWithURLString:(NSString *)URLString{
    return self.downloadModelsDict[URLString];
}

#pragma mark - private methods

-(void)setValuesForDownloadModel:(RBDownloadRequest *)downloadModel withProgress:(double)progress{
    NSTimeInterval interval = -1 * [downloadModel.downloadDate timeIntervalSinceNow];
    downloadModel.totalBytesWritten = downloadModel.downloadTask.countOfBytesReceived;
    downloadModel.totalBytesExpectedToWrite = downloadModel.downloadTask.countOfBytesExpectedToReceive;
    downloadModel.downloadProgress = progress;
    downloadModel.downloadSpeed = (int64_t)((downloadModel.totalBytesWritten - [self getResumeByteWithDownloadModel:downloadModel]) / interval);
    if (downloadModel.downloadSpeed != 0) {
        int64_t remainingContentLength = downloadModel.totalBytesExpectedToWrite  - downloadModel.totalBytesWritten;
        int currentLeftTime = (int)(remainingContentLength / downloadModel.downloadSpeed);
        downloadModel.downloadLeft = currentLeftTime;
    }
}

-(int64_t)getResumeByteWithDownloadModel:(RBDownloadRequest *)downloadModel{
    int64_t resumeBytes = 0;
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:downloadModel.resumeFilePath];
    if (dict) {
        resumeBytes = [dict[@"NSURLSessionResumeBytesReceived"] longLongValue];
    }
    return resumeBytes;
}

-(NSString *)getTmpFileNameWithDownloadModel:(RBDownloadRequest *)downloadModel{
    NSString *fileName = nil;
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:downloadModel.resumeFilePath];
    if (dict) {
        fileName = dict[@"NSURLSessionResumeInfoTempFileName"];
    }
    return fileName;
}

-(void)createFolderAtPath:(NSString *)path{
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) return;
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
}

-(void)deletePlistFileWithDownloadModel:(RBDownloadRequest *)downloadModel{
    if (downloadModel.downloadTask.countOfBytesReceived == downloadModel.downloadTask.countOfBytesExpectedToReceive) {
        [[NSFileManager defaultManager] removeItemAtPath:downloadModel.resumeFilePath error:nil];
        [self removeTotalBytesExpectedToWriteWhenDownloadFinishedWithDownloadModel:downloadModel];
    }
}

-(NSString *)managerPlistFilePath{
    NSString *downloadPath =[RBNetworkConfig defaultConfig].downloadFolderPath;
    if (![[NSFileManager defaultManager] fileExistsAtPath:downloadPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:downloadPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return [downloadPath stringByAppendingPathComponent:@"PDDownloadManager.plist"];
}

-(nullable NSMutableDictionary <NSString *, NSString *> *)managerPlistDict{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:[self managerPlistFilePath]];
    return dict;
}

-(void)saveTotalBytesExpectedToWriteWithDownloadModel:(RBDownloadRequest *)downloadModel{
    NSMutableDictionary <NSString *, NSString *> *dict = [self managerPlistDict];
    [dict setValue:[NSString stringWithFormat:@"%lld", downloadModel.downloadTask.countOfBytesExpectedToReceive] forKey:downloadModel.pd_URLString];
    [dict writeToFile:[self managerPlistFilePath] atomically:YES];
}

-(void)removeTotalBytesExpectedToWriteWhenDownloadFinishedWithDownloadModel:(RBDownloadRequest *)downloadModel{
    NSMutableDictionary <NSString *, NSString *> *dict = [self managerPlistDict];
    [dict removeObjectForKey:downloadModel.pd_URLString];
    [dict writeToFile:[self managerPlistFilePath] atomically:YES];
}

@end

//
//  PDDownloadRequest.m
//  Pudding
//
//  Created by baxiang on 16/8/29.
//  Copyright © 2016年 Zhi Kuiyu. All rights reserved.
//

#import "RBDownloadRequest.h"

@implementation RBDownloadRequest

+(void)downloadWithURL:(nonnull NSString*)URL parametes:(nullable NSDictionary*)parametes progress:(nullable PDRequestProgressBlock )progressBlock complete:(nullable PDRequestCompletionBlock) completionBlock{
    RBDownloadRequest *downloadRequest = [[RBDownloadRequest alloc] initWithURLString:URL method:PDRequestMethodGet params:parametes];
    downloadRequest.progerssBlock = progressBlock;
    [downloadRequest startWithCompletionBlock:completionBlock];
}
-(NSString *)fileName{
    if (!_fileName) {
        NSURL *fileURL = [NSURL URLWithString:self.requestURL];
        _fileName = [fileURL lastPathComponent];
    }
    return _fileName;
}
-(NSString *)fileFolderPath{
    if (!_fileFolderPath) {
        _fileFolderPath = [RBNetworkConfig defaultConfig].downloadFolderPath;
    }
    return _fileFolderPath;
}
-(NSString *)filePath{
    if (!_filePath) {
        _filePath = [self.fileFolderPath stringByAppendingPathComponent:self.fileName];
    }
    return _filePath;
}
- (NSString *)resumeFilePath{
    if (!_resumeFilePath) {
        _resumeFilePath = [self.fileFolderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",self.fileName]];
    }
    return _resumeFilePath;
}
@end

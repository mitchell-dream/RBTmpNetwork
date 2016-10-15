//
//  PDNetworkUtilities.h
//  Pudding
//
//  Created by baxiang on 16/8/30.
//  Copyright © 2016年 Zhi Kuiyu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RBNetworkUtilities : NSObject

+ (BOOL)validateUrl:(NSString *)url;
+ (NSString *)md5String:(NSString *)string;
@end

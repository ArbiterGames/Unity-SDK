//
//  ArbiterSession.h
//  Arbiter
//
//  Created by Andy Zinsser on 12/6/13.
//  Copyright (c) 2013 Arbiter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ArbiterSession : NSObject
{
    void (^_completionHandler)(NSString *param);
}

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, strong) NSString *username;

- (id)initWithUserId:(NSString *)userId callback:(void(^)(NSString *))handler;

@end

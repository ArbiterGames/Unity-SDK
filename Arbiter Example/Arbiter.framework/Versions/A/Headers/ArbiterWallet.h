//
//  ArbiterWallet.h
//  Arbiter
//
//  Created by Andy Zinsser on 12/10/13.
//  Copyright (c) 2013 Arbiter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ArbiterWallet : NSObject

@property (strong, nonatomic) NSString* balance;
@property (strong, nonatomic) NSString* depositAddress;
@property (strong, nonatomic) NSString* previousWithdrawAddress;

- (id)initWithDetails:(NSDictionary *)wallet;

@end

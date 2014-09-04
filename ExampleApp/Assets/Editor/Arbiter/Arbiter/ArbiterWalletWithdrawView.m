//
//  ArbiterWalletWithdrawView.m
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/4/14.
//
//

#import "ArbiterWalletWithdrawView.h"
#import "Arbiter.h"


@implementation ArbiterWalletWithdrawView

{
    Arbiter *_arbiter;
}


- (id)initWithFrame:(CGRect)frame andArbiterInstance:(Arbiter *)arbiterInstance
{
    self = [super initWithFrame:frame];
    if ( self ) {
        _arbiter = arbiterInstance;
        [self renderLayout];
    }
    return self;
}

- (void)renderLayout
{
    NSLog(@"TODO: Build out withdraw view layout");
}

@end

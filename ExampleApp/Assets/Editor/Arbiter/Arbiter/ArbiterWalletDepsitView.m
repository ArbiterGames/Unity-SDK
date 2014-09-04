//
//  ArbiterWalletDepsitView.m
//  Unity-iPhone
//
//  Created by Andy Zinsser on 9/4/14.
//
//

#import "ArbiterWalletDepsitView.h"
#import "Arbiter.h"

@implementation ArbiterWalletDepsitView
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
    NSLog(@"TODO: Build out deposit view layou");
}



@end

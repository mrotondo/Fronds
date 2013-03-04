//
//  FRPlant.m
//  Fronds
//
//  Created by Mike Rotondo on 2/18/13.
//  Copyright (c) 2013 Kletondle. All rights reserved.
//

#import "FRPlant.h"

@implementation FRPlant

- (id)init
{
    self = [super init];
    if (self) {
        self.size = 1.0;
        self.color = [UIColor colorWithRed:(arc4random() / (float)0x100000000) * 0.1 green:(arc4random() / (float)0x100000000) blue:(arc4random() / (float)0x100000000) * 0.1 alpha:1.0];
    }
    return self;
}

@end

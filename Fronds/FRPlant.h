//
//  FRPlant.h
//  Fronds
//
//  Created by Mike Rotondo on 2/18/13.
//  Copyright (c) 2013 Kletondle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FRPlant : NSObject

@property (nonatomic) CGPoint relativeLocation;
@property (nonatomic) float growth;
@property (nonatomic) float size;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic) float angle;

@end

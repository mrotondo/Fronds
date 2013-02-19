//
//  FRView.m
//  Fronds
//
//  Created by Mike Rotondo on 2/18/13.
//  Copyright (c) 2013 Kletondle. All rights reserved.
//

#import "FRView.h"
#import "FRPlant.h"

@interface FRView ()

@property (nonatomic, strong) NSMutableArray *plants;
@property (nonatomic) CGPoint planetCenter;
@property (nonatomic) float planetRadius;

@property (nonatomic, strong) NSTimer *drawTimer;
@property (nonatomic, strong) NSDate *timeStarted;
@property (nonatomic) NSTimeInterval timePassed;

@end


@implementation FRView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithFrame:self.frame];
    if (self) {
        self.timeStarted = [NSDate date];
        self.drawTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 / 30.0 target:self selector:@selector(makeDraw) userInfo:nil repeats:YES];
    }
    return self;
}

- (void)createPlants
{
    self.plants = [NSMutableArray array];
    for (int i = 0; i < 2000; i++)
    {
        float circleAngle = M_PI + ((arc4random() / (float)0x100000000) * M_PI);
        float circleDistance = (arc4random() / (float)0x100000000) * self.planetRadius;
        CGPoint circleCenter = CGPointMake(circleDistance * cosf(circleAngle),
                                           circleDistance * sinf(circleAngle));
        FRPlant *plant = [[FRPlant alloc] init];
        plant.relativeLocation = circleCenter;
        [self.plants addObject:plant];
    }
}

- (void)layoutSubviews
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self.planetRadius = self.bounds.size.height / 2;
        
        [self createPlants];
    });

    self.planetCenter = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height);
}

- (void)makeDraw
{
    self.timePassed = [[NSDate date] timeIntervalSinceDate:self.timeStarted];
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    UIBezierPath * screenPath = [UIBezierPath bezierPathWithRect:self.bounds];
    [[UIColor blackColor] setFill];
    [screenPath fill];
    
    CGSize planetSize = CGSizeMake(self.planetRadius * 2, self.planetRadius * 2);
    CGRect planetRect = CGRectMake(self.planetCenter.x - self.planetRadius,
                                   self.planetCenter.y - self.planetRadius,
                                   planetSize.width, planetSize.height);
    UIBezierPath *planetPath = [UIBezierPath bezierPathWithOvalInRect:planetRect];

    UIColor *earthsSoil = [UIColor colorWithRed:0.648 green:0.480 blue:0.074 alpha:1.000];
    [earthsSoil setFill];
    [earthsSoil setStroke];
    
    planetPath.lineWidth = 20;
    [planetPath fill];
    [planetPath stroke];
    
    float sunshineRotationRate = 1.3;  // radians/s
    float sunshineAngle = 1.5 * M_PI + self.timePassed * sunshineRotationRate;
    float minSunshineAngle = sunshineAngle - 0.5 * M_PI;
    float maxSunshineAngle = sunshineAngle + 0.5 * M_PI;
    
    for (FRPlant *plant in self.plants) {
        CGPoint dotCenter = plant.relativeLocation;
        
        float dotAngle = atan2f(dotCenter.y, dotCenter.x) + 2 * M_PI;
        
        UIColor *dotColor = [UIColor whiteColor];
        float dotRadius = 8;

        BOOL isInSunshine = NO;
        
        if (fmodf(minSunshineAngle, 2 * M_PI) > fmodf(maxSunshineAngle, 2 * M_PI))
        {
            if (dotAngle > fmodf(minSunshineAngle, 2 * M_PI))
            {
                // We only have dots in the top half of the circle so this should always work
                isInSunshine = YES;
            }
        }
        else if (dotAngle > fmodf(minSunshineAngle, 2 * M_PI) && dotAngle < fmodf(maxSunshineAngle, 2 * M_PI))
        {
            isInSunshine = YES;
        }
        
        if (isInSunshine)
        {
            dotColor = [UIColor greenColor];
            dotRadius = (arc4random() / (float)0x100000000) * 10 + 10;
        }
        
        CGSize dotSize = CGSizeMake(dotRadius * 2, dotRadius * 2);
        CGRect dotRect = CGRectMake(self.planetCenter.x + dotCenter.x - dotRadius,
                                    self.planetCenter.y + dotCenter.y - dotRadius,
                                    dotSize.width, dotSize.height);
        UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:dotRect];
        
        [dotColor setFill];
        [[UIColor blackColor] setStroke];
        
//        path.lineWidth = 1;
//        [path fill];
//        [path stroke];

        if (isInSunshine)
        {
            plant.size += 0.1;
        }
        else
        {
            plant.size = MAX(0.1, plant.size - 0.3);
        }
        
        UIBezierPath *plantPath = [UIBezierPath bezierPath];
        CGPoint startPoint = CGPointMake(self.planetCenter.x + dotCenter.x, self.planetCenter.y + dotCenter.y);
        [plantPath moveToPoint:startPoint];
        CGPoint plantVector = CGPointMake(cosf(dotAngle), sinf(dotAngle));
        
        CGPoint previousPoint = startPoint;
        for (int i = 0; i < 10; i++)
        {
            float plantLength = plant.size * 10 * (arc4random() / (float)0x100000000);
            CGPoint plantOffset = CGPointMake(plant.size * 5 * ((arc4random() / (float)0x100000000) * 2 - 1),
                                              plant.size * 5 * ((arc4random() / (float)0x100000000) * 2 - 1));
            CGPoint nextPoint = CGPointMake(previousPoint.x + plantVector.x * plantLength + plantOffset.x,
                                            previousPoint.y + plantVector.y * plantLength + plantOffset.y);
            [plantPath addLineToPoint:nextPoint];
            previousPoint = nextPoint;
        }
        
        
        [plant.color setStroke];
        [plantPath stroke];
    
    }

    UIBezierPath *sunshinePath = [UIBezierPath bezierPathWithArcCenter:self.planetCenter radius:self.planetRadius * 10 startAngle:minSunshineAngle endAngle:maxSunshineAngle clockwise:YES];

    [[UIColor yellowColor] setFill];
    [sunshinePath fillWithBlendMode:kCGBlendModeSourceAtop alpha:0.5];
}

@end

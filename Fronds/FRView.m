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
    for (int i = 0; i < 200; i++)
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

    UIColor *earthsSoil = [UIColor colorWithRed:0.159 green:0.082 blue:0 alpha:1.000];
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
        
//        UIColor *dotColor = [UIColor whiteColor];
//        float dotRadius = 8;

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
        
//        if (isInSunshine)
//        {
//            dotColor = [UIColor greenColor];
//            dotRadius = (arc4random() / (float)0x100000000) * 10 + 10;
//        }
      
//        CGSize dotSize = CGSizeMake(dotRadius * 2, dotRadius * 2);
//        CGRect dotRect = CGRectMake(self.planetCenter.x + dotCenter.x - dotRadius,
//                                    self.planetCenter.y + dotCenter.y - dotRadius,
//                                    dotSize.width, dotSize.height);
//        UIBezierPath *dotPath = [UIBezierPath bezierPathWithOvalInRect:dotRect];
//        
//        [dotColor setFill];
//        [[UIColor blackColor] setStroke];
//        
//        dotPath.lineWidth = 1;
//        [dotPath fill];
//        [dotPath stroke];

        if (isInSunshine)
        {
            plant.size += 0.1;
        }
        else
        {
            plant.size = MAX(0.1, plant.size - 0.3);
        }
        
//        UIBezierPath *plantPath = [UIBezierPath bezierPath];
        UIBezierPath *plantPath;
        CGPoint startPoint = CGPointMake(self.planetCenter.x + dotCenter.x, self.planetCenter.y + dotCenter.y);
        [plantPath moveToPoint:startPoint];
//        CGPoint plantVector = CGPointMake(cosf(dotAngle), sinf(dotAngle));
//        
//        CGPoint previousPoint = startPoint;
        for (int i = 0; i < 10; i++)
        {
//            float plantLength = plant.size * 10 * (arc4random() / (float)0x100000000);
//            CGPoint plantOffset = CGPointMake(plant.size * 5 * ((arc4random() / (float)0x100000000) * 2 - 1),
//                                              plant.size * 5 * ((arc4random() / (float)0x100000000) * 2 - 1));
//            float plantLength = plant.size * 10;
//            CGPoint plantOffset = CGPointMake(plant.size * 5,
//                                              plant.size * 5);
//            CGPoint nextPoint = CGPointMake(previousPoint.x + plantVector.x * plantLength + plantOffset.x,
//                                            previousPoint.y + plantVector.y * plantLength + plantOffset.y);
//            [plantPath addLineToPoint:nextPoint];
//            previousPoint = nextPoint;
            plantPath = [self spiralPathWithX:self.planetCenter.x + dotCenter.x withY:self.planetCenter.y + dotCenter.y withTurns:(int)(plant.size * 5)];
        }
        
        
        [plant.color setStroke];
        [plantPath stroke];
    
    }

    UIBezierPath *sunshinePath = [UIBezierPath bezierPathWithArcCenter:self.planetCenter radius:self.planetRadius * 10 startAngle:minSunshineAngle endAngle:maxSunshineAngle clockwise:YES];

    [[UIColor yellowColor] setFill];
    [sunshinePath fillWithBlendMode:kCGBlendModeSourceAtop alpha:0.5];
}

- (UIBezierPath *)spiralPathWithX:(double)centerX withY:(double)centerY withTurns:(int)turns {
	
	int iDegrees = 15;			// Angle between points. 15, 20, 24, 30.
	int iN = 360 / iDegrees;		// Total number of points.
	double dAngleOne;			// iDegrees as radians.
	double dAngle;				// Cumulative radians while stepping.
	double dSpace = 5.0;		// Space between turns.
	double dSpaceStep;			// dSpace/iN.
	double dR = 0;				// Radius of inside circle.
    double X = 0.0;				// x co-ordinate of a point.
	double Y = 0.0;				// y co-ordinate of a point.
    
	// Control- and end-points.
	// First 2 points are control-points.
	// Third point is end-point.
	dAngleOne = M_PI * iDegrees / 180.0;
	dSpaceStep = 0; // -dSpace / (double)iN;
	double iCount = -1;
	
	CGPoint c1 = CGPointMake(0, 0);
	CGPoint c2 = CGPointMake(0, 0);
	
	UIBezierPath *path = [UIBezierPath bezierPath];
	[path moveToPoint:CGPointMake(centerX, centerY)];
	
	for (int k = 0; k < turns; k++)
	{
		for (int i = iDegrees; i <= 360; i += iDegrees)
		{
			dSpaceStep += dSpace / (double)iN;
			dAngle = M_PI * i / 180.0;
			
			// Get points.
			iCount += 1;
			if ((iCount == 0) || (iCount == 1))
			{
				// Control-point.
				X = ((dR + dSpaceStep) / cos(dAngleOne)) * cos(dAngle) + centerX;
				Y = ((dR + dSpaceStep) / cos(dAngleOne)) * sin(dAngle) + centerY;
				
				if (iCount == 0)
					c1 = CGPointMake(X, Y);
				else
					c2 = CGPointMake(X, Y);
			}
			else
			{
				// End-point.
				X = (dR + dSpaceStep) * cos(dAngle) + centerX;
				Y = (dR + dSpaceStep) * sin(dAngle) + centerY;
				iCount = -1;
				
				[path addCurveToPoint:CGPointMake(X, Y) controlPoint1:c1 controlPoint2:c2];
			}
		}
	}
	
	return path;
}

@end

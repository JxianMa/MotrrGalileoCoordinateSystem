//
//  ViewController.m
//  CoordinateSystem
//
//  Created by MaJixian on 7/9/15.
//  Copyright (c) 2015 MaJixian. All rights reserved.
//
//  The code is for a constructs a match from the coordinates on view to Motrr Galileo®.
//  If you detect something from front camera on iPhone and you want Motrr Galileo® to rotate to that place and check out,
//  This code will achieve that. It reflects the real 3D world into the coordinates on iPhone camera view.
//  When you tap one point from the coordinate on iPhone, Motrr Galileo® will rotate to that point and set that point to the center of the screen.
//  CAUTION: When iPhone is in portrait mode, which means that Motrr Galileo® stands straight, the system only support turn left and right since
//  Motrr Galileo® cannot move either up or down when it stands.

#import "ViewController.h"
#import <GalileoControl/GalileoControl.h>


@interface ViewController ()<GCGalileoDelegate>

@end

//Once you click the move button, the point will move 10 pixels
#define movingStep 10.0f;

@implementation ViewController
{
    __weak IBOutlet UIView *coordinateView;
    CGFloat screenWidth;
    CGFloat screenHeight;
    CGFloat xCoordinate;
    CGFloat yCoordinate;
    CGFloat originalPosition;
    UIView *currentPoint;
    BOOL isShowingLandscapeView;
    UIDeviceOrientation deviceOrientation;
}

- (void)viewDidLoad {
    [self.view setUserInteractionEnabled:NO];
    [super viewDidLoad];
    [self.view sendSubviewToBack:coordinateView];
    CGRect screenRect = [[UIScreen mainScreen]bounds];
    isShowingLandscapeView = NO;
    screenWidth = screenRect.size.width;
    screenHeight = screenRect.size.height;
    NSLog(@"Screen width:%f, Screen height:%f",screenWidth,screenHeight);
    [self setupPortraitCoordinator];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    [GCGalileo sharedGalileo].delegate = self;
    [[GCGalileo sharedGalileo] waitForConnection];

    // Do any additional setup after loading the view, typically from a nib.
}

- (void)orientationChanged:(NSNotification *)notification
{
    deviceOrientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsLandscape(deviceOrientation) &&
        !isShowingLandscapeView)
    {
        NSLog(@"-------------------landscape-------------------");
        for (UIView *view in coordinateView.subviews) {
            [view removeFromSuperview];
        }
        [self setupLandScapeCoordinator];
        [self dismissViewControllerAnimated:YES completion:nil];
        isShowingLandscapeView = YES;
    }
    else if (UIDeviceOrientationIsPortrait(deviceOrientation) &&
             isShowingLandscapeView)
    {
        NSLog(@"-------------------portrait--------------------");
        for (UIView *view in coordinateView.subviews) {
            [view removeFromSuperview];
        }
        [self setupPortraitCoordinator];
        isShowingLandscapeView = NO;
    }
}

- (void)setupPortraitCoordinator
{

    //Setup Y axis
    UIView *Yaxis = [[UIView alloc]initWithFrame:CGRectMake(screenWidth/2, 0, 5, screenHeight)];
    [Yaxis setBackgroundColor:[UIColor blackColor]];
    [coordinateView addSubview:Yaxis];
    
    //Setup X axis
    UIView *Xaxis = [[UIView alloc]initWithFrame:CGRectMake(0, screenHeight/2, screenWidth, 5)];
    [Xaxis setBackgroundColor:[UIColor blackColor]];
    [coordinateView addSubview:Xaxis];
    
    //Setup orignal point
    xCoordinate = screenWidth/2;
    yCoordinate = screenHeight/2;
    currentPoint = [[UIView alloc]initWithFrame:CGRectMake(xCoordinate, yCoordinate, 5, 5)];
    [currentPoint setBackgroundColor:[UIColor redColor]];
    [coordinateView addSubview:currentPoint];
}

- (void)setupLandScapeCoordinator
{
    //Setup Y axis
    UIView *Yaxis = [[UIView alloc]initWithFrame:CGRectMake(0, screenWidth/2, screenHeight,5)];
    [Yaxis setBackgroundColor:[UIColor blackColor]];
    [coordinateView addSubview:Yaxis];

    //Setup X axis
    UIView *Xaxis = [[UIView alloc]initWithFrame:CGRectMake(screenHeight/2, 0, 5, screenWidth)];
    [Xaxis setBackgroundColor:[UIColor blackColor]];
    [coordinateView addSubview:Xaxis];
    
    //Setup orignal point
    xCoordinate = screenHeight/2;
    yCoordinate = screenWidth/2;
    currentPoint = [[UIView alloc]initWithFrame:CGRectMake(xCoordinate, yCoordinate, 5, 5)];
    [currentPoint setBackgroundColor:[UIColor redColor]];
    [coordinateView addSubview:currentPoint];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)resetPosition:(UIButton *)sender
{
    [self resetGalileoToOriginalPoint];
}

- (IBAction)movingUp:(UIButton *)sender
{
    NSLog(@"yCoordinate:%f",yCoordinate);
    if (UIDeviceOrientationIsLandscape(deviceOrientation))
    {
        if (yCoordinate > 0) {
            yCoordinate = yCoordinate - movingStep;
            CGFloat galileoMovingAngle = -90/(screenWidth/2)*movingStep;
            [self moveGalileoToAngleTilt:galileoMovingAngle];
        }else{
            yCoordinate = 0;
        }
        [self moveToPointOnScreen];
    }
}

- (IBAction)movingLeft:(UIButton *)sender
{
    NSLog(@"xCoordinate:%f",xCoordinate);
    if (UIDeviceOrientationIsPortrait(deviceOrientation)){
        if (xCoordinate > 0) {
            xCoordinate = xCoordinate - movingStep;
            CGFloat galileoMovingAngle = 90/(screenWidth/2)*movingStep;
            [self moveGalileoToAngleTilt:galileoMovingAngle];
            
        }else{
            xCoordinate = 0;
        }
        [self moveToPointOnScreen];
    }else if (UIDeviceOrientationIsLandscape(deviceOrientation)){
        if (xCoordinate > 0) {
            xCoordinate = xCoordinate - movingStep;
            CGFloat galileoMovingAngle = 90/(screenHeight/2)*movingStep;
            [self moveGalileoToAnglePan:galileoMovingAngle];
        }else{
            xCoordinate = 0;
        }
        [self moveToPointOnScreen];
    }
}

- (IBAction)movingDown:(UIButton *)sender
{
    NSLog(@"yCoordinate:%f",yCoordinate);
    if (UIDeviceOrientationIsLandscape(deviceOrientation))
    {
        if (yCoordinate < screenWidth-5) {
            yCoordinate = yCoordinate + movingStep;
            CGFloat galileoMovingAngle = 90/(screenWidth/2)*movingStep;
            [self moveGalileoToAngleTilt:galileoMovingAngle];
        }else{
            yCoordinate = screenWidth-5;
        }
        [self moveToPointOnScreen];
    }
}

- (IBAction)movingRight:(UIButton *)sender
{
    NSLog(@"xCoordinate:%f",xCoordinate);
    if (UIDeviceOrientationIsPortrait(deviceOrientation))
    {
        if (xCoordinate < screenWidth-5) {
            xCoordinate = xCoordinate + movingStep;
            CGFloat galileoMovingAngle = -90/(screenWidth/2)*movingStep;
            [self moveGalileoToAngleTilt:galileoMovingAngle];
        }else{
            xCoordinate = screenWidth - 5;
        }
        [self moveToPointOnScreen];
    }else if (UIDeviceOrientationIsLandscape(deviceOrientation))
    {
        if (xCoordinate < screenHeight-5) {
            xCoordinate = xCoordinate + movingStep;
            CGFloat galileoMovingAngle = -90/(screenHeight/2)*movingStep;
            [self moveGalileoToAnglePan:galileoMovingAngle];
        }else{
            xCoordinate = screenHeight-5;
        }
        [self moveToPointOnScreen];
    }
}

- (IBAction)screenTap:(UITapGestureRecognizer *)sender
{
    if (UIDeviceOrientationIsLandscape(deviceOrientation)) {
        CGPoint tapLocation = [sender locationInView:self.view];
        NSLog(@"tapLocation:(x:%f,y:%f)",tapLocation.x,tapLocation.y);
        xCoordinate = tapLocation.x;
        yCoordinate = tapLocation.y;
        [self moveToPointOnScreen];
        CGFloat xLocation = xCoordinate - screenHeight/2;
        CGFloat yLocation = yCoordinate - screenWidth/2;
        
        //Point locates in the 1st quadrant
        if (xLocation > 0 && yLocation < 0) {
            CGFloat galileoMovingAngleX = -(xLocation/(screenHeight/2))*90;
            CGFloat galileoMovingAngleY = (yLocation/(screenWidth/2))*90;
            [self moveGalileoToSpecificLocationWithXCoordinates:galileoMovingAngleX andYCoordinates:galileoMovingAngleY];
        }
        
        //Point locates in the 2nd quadrant
        if (xLocation < 0 && yLocation < 0){
            CGFloat galileoMovingAngleX = -(xLocation/(screenHeight/2))*90;
            CGFloat galileoMovingAngleY = (yLocation/(screenWidth/2))*90;
            [self moveGalileoToSpecificLocationWithXCoordinates:galileoMovingAngleX andYCoordinates:galileoMovingAngleY];
        }
        
        //Point locates in the 3rd quadrant
        if (xLocation < 0 && yLocation > 0){
            CGFloat galileoMovingAngleX = -(xLocation/(screenHeight/2))*90;
            CGFloat galileoMovingAngleY = (yLocation/(screenWidth/2))*90;
            [self moveGalileoToSpecificLocationWithXCoordinates:galileoMovingAngleX andYCoordinates:galileoMovingAngleY];
        }

        
        //Point locates in the 4th quadrant
        if (xLocation > 0 && yLocation > 0) {
            CGFloat galileoMovingAngleX = -(xLocation/(screenHeight/2))*90;
            CGFloat galileoMovingAngleY = (yLocation/(screenWidth/2))*90;
            [self moveGalileoToSpecificLocationWithXCoordinates:galileoMovingAngleX andYCoordinates:galileoMovingAngleY];
        }
        
    }
    
    
}

- (void)moveToPointOnScreen
{
    [currentPoint setFrame:CGRectMake(xCoordinate, yCoordinate, 5, 5)];
}

- (void)moveGalileoToAngleTilt:(CGFloat)galileoMovingAngle
{
    void (^completionBlock) (BOOL) = ^(BOOL wasCommandPreempted)
    {
        if (!wasCommandPreempted) [self controlDidReachTargetPosition];
    };
    NSLog(@"galileoMovingAngle:%f",galileoMovingAngle);
    [[[GCGalileo sharedGalileo] positionControlForAxis:GCControlAxisTilt] incrementTargetPosition:galileoMovingAngle
                                                                                  completionBlock: completionBlock
                                                                              waitUntilStationary:NO];
}

- (void)moveGalileoToAnglePan:(CGFloat)galileoMovingAngle
{
    void (^completionBlock) (BOOL) = ^(BOOL wasCommandPreempted)
    {
        if (!wasCommandPreempted) [self controlDidReachTargetPosition];
    };
    NSLog(@"galileoMovingAngle:%f",galileoMovingAngle);
    [[[GCGalileo sharedGalileo] positionControlForAxis:GCControlAxisPan] incrementTargetPosition:galileoMovingAngle
                                                                                  completionBlock: completionBlock
                                                                              waitUntilStationary:NO];
}

- (void)moveGalileoToSpecificLocationWithXCoordinates:(CGFloat)x andYCoordinates:(CGFloat)y
{
    void (^completionBlock) (BOOL) = ^(BOOL wasCommandPreempted)
    {
        if (!wasCommandPreempted) [self controlDidReachTargetPosition];
    };
    [[[GCGalileo sharedGalileo] positionControlForAxis:GCControlAxisPan] setTargetPosition:x completionBlock:completionBlock waitUntilStationary:NO];
    [[[GCGalileo sharedGalileo] positionControlForAxis:GCControlAxisTilt] setTargetPosition:y completionBlock:completionBlock waitUntilStationary:NO];
}

- (void)resetGalileoToOriginalPoint
{
    if (UIDeviceOrientationIsPortrait(deviceOrientation)) {
        [currentPoint setFrame:CGRectMake(screenWidth/2,screenHeight/2, 5, 5)];
        xCoordinate = screenWidth/2;
        yCoordinate = screenHeight/2;
    }
    if (UIDeviceOrientationIsLandscape(deviceOrientation)) {
        [currentPoint setFrame:CGRectMake(screenHeight/2,screenWidth/2, 5, 5)];
        xCoordinate = screenHeight/2;
        yCoordinate = screenWidth/2;
    }

    void (^completionBlock) (BOOL) = ^(BOOL wasCommandPreempted)
    {
        if (!wasCommandPreempted) [self controlDidReachTargetPosition];
    };
    NSLog(@"Reset to original point");
    [[[GCGalileo sharedGalileo] positionControlForAxis:GCControlAxisPan] setTargetPosition:originalPosition                                               completionBlock: completionBlock
                                                                       waitUntilStationary:NO];
    [[[GCGalileo sharedGalileo] positionControlForAxis:GCControlAxisTilt] setTargetPosition:originalPosition                                               completionBlock: completionBlock
                                                                       waitUntilStationary:NO];
    [self moveToPointOnScreen];
}


#pragma mark -
#pragma mark PositionControl delegate

- (void) controlDidReachTargetPosition
{
    if ([[GCGalileo sharedGalileo] isConnected])NSLog(@"Galileo has arrived target position!");
}

- (void) galileoDidConnect
{
    [self.view setUserInteractionEnabled:YES];
    NSLog(@"Galileo is connected.");
    GCPositionControl *positionControl = [[GCPositionControl alloc]init];
    //The default setting for proporty currentPosition is to set the position when Galileo is turned on
    NSLog(@"current Position:%f",positionControl.currentPosition);
    originalPosition = positionControl.currentPosition;
}

- (void) galileoDidDisconnect
{
    NSLog(@"Galileo is disconnected");
    [[GCGalileo sharedGalileo] waitForConnection];
}



@end

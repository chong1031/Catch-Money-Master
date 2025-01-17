//
//  JADSKScrollingNode.m
//  FirstLetters
//
//  Created by Jennifer Dobson on 7/25/14.
//  Copyright (c) 2014 Jennifer Dobson. All rights reserved.
//

#import "JADSKScrollingNode.h"
#import "LHSceneSubclass.h"
#import "shared.h"
@interface JADSKScrollingNode()

@property (nonatomic) CGFloat minYPosition;
@property (nonatomic) CGFloat maxYPosition;
@property (nonatomic, strong) UIPanGestureRecognizer *gestureRecognizer;
@property (nonatomic) CGFloat yOffset;

@end


static const CGFloat kScrollDuration = .3;
LHSceneSubclass *myscene;
SKSpriteNode *snode;
@implementation JADSKScrollingNode
@synthesize sliderDelegate;
-(id)initWithSize:(CGSize)size
{
    self = [super init];
    
    if (self)
    {
        _size = size;
        _yOffset = [self calculateAccumulatedFrame].origin.y;
       
    }
    return self;
    
}

-(void)addChild:(SKNode *)node
{
    [super addChild:node];
    _yOffset = [self calculateAccumulatedFrame].origin.y;
}


-(CGFloat) minYPosition
{
    CGSize parentSize = self.parent.frame.size;
    
  
    CGFloat minPosition =(parentSize.height - [self calculateAccumulatedFrame].size.height - _yOffset);
    
    return minPosition;
    
    
}

-(CGFloat) maxYPosition
{
    return 0;
}

-(void)scrollToBottom
{
    self.position = CGPointMake(0, self.maxYPosition);
}

-(void)scrolltoMiddle{
    self.position=CGPointMake(0, self.minYPosition/2.5);
}

-(void)scrollToTop
{
    self.position = CGPointMake(0, self.minYPosition);
}

-(void)scrolltoCustom:(float)value{
    self.position=CGPointMake(0,value);
}

-(void)enableScrollingOnView:(UIView*)view
{
    if (!_gestureRecognizer) {
        _gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanFrom:)];
        _gestureRecognizer.delegate = self;
        [view addGestureRecognizer:self.gestureRecognizer];
        }
}

-(void)disableScrollingOnView:(UIView*)view
{
    if (_gestureRecognizer) {
        [view removeGestureRecognizer:_gestureRecognizer];
        _gestureRecognizer = nil;
    }
}

-(void)handlePanFrom:(UIPanGestureRecognizer*)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        
        CGPoint translation = [recognizer translationInView:recognizer.view];
        translation = CGPointMake(translation.x, -translation.y);
        [self panForTranslation:translation];
        [recognizer setTranslation:CGPointZero inView:recognizer.view];
        
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        CGPoint velocity = [recognizer velocityInView:recognizer.view];
        CGPoint pos = self.position;
        CGPoint p = mult(velocity, kScrollDuration);
        
        CGPoint newPos = CGPointMake(pos.x, pos.y - p.y);
        newPos = [self constrainStencilNodesContainerPosition:newPos];
        
        SKAction *moveTo = [SKAction moveTo:newPos duration:kScrollDuration];
        //SKAction *moveMask = [SKAction moveTo:[self maskPositionForNodePosition:newPos] duration:kScrollDuration];
        [moveTo setTimingMode:SKActionTimingEaseOut];
        //[moveMask setTimingMode:SKActionTimingEaseOut];
        [self runAction:moveTo];
        //[self.maskNode runAction:moveMask];
    }
}

-(void)panForTranslation:(CGPoint)translation
{
    self.position = CGPointMake(self.position.x, self.position.y+translation.y);
    [self.sliderDelegate moveSliderWithValue:(int)translation.y];
}

- (CGPoint)constrainStencilNodesContainerPosition:(CGPoint)position {
    
    
    CGPoint retval = position;
    
    retval.x = self.position.x;
    
    retval.y = MAX(retval.y, self.minYPosition);
    retval.y = MIN(retval.y, self.maxYPosition);
    if(retval.y>-121.0){
        retval.y=-121.0;
    }
    [shared sharedInstance].shopbutton=retval.y;
    NSLog(@"retval %@",NSStringFromCGPoint(retval));
    [[shared sharedInstance].mainScene getScrollbutton];
    return retval;
}

CGPoint mult(const CGPoint v, const CGFloat s) {
	return CGPointMake(v.x*s, v.y*s);
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    SKNode* grandParent = self.parent.parent;
    
    if (!grandParent) {
        grandParent = self.parent;
    }
    CGPoint touchLocation = [touch locationInNode:grandParent];
    
    if (!CGRectContainsPoint(self.parent.frame,touchLocation)){
        return NO;
    }
    return YES;
}

@end

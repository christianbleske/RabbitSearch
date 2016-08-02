//
//  MyScene.m
//  RabbitSearch
//
//  Created by Christian Bleske on 04.01.14.
//  Copyright (c) 2014 Christian Bleske. All rights reserved.
//

@import AVFoundation;
#import "GameScene.h"


@interface GameScene ()

@property (nonatomic, strong) SKSpriteNode *background;
@property (nonatomic, strong) SKSpriteNode *selectedNode;
@property (nonatomic, strong) SKLabelNode *textNode;
@property (nonatomic, strong) SKSpriteNode *basket;
@property (nonatomic, strong) SKLabelNode *rabbitCounterLabel;
@property (nonatomic, strong) SKSpriteNode *titleScreen;
@property (nonatomic, strong) SKLabelNode *titleLabel;


@end

static NSString * const kAnimalNodeName = @"movable";

static const uint8_t rabbitCategory = 1;
static const uint8_t worldCategory = 2;
static const uint8_t leftSide = 3;

static const float heavyLevel = 0.6;
static const float mediumLevel = 0.9;
static const float easyLevel = 1.3;

@implementation GameScene {
    SKSpriteNode *_butterfly;
    NSArray *_movingButterflyFrames;
    SKSpriteNode *_animatedSprite;
    NSArray *_animatedSpriteFrames;
    AVAudioPlayer *_backgroundAudioPlayer;
    bool _gameOver;
    NSInteger _rabbitCounter;
    NSInteger _rabbitToFound;
    SKSpriteNode *_movingSpriteNode;
    Boolean levelOneFinished;
    Boolean levelTwoFinished;
    Boolean levelThreeFinished;
    Boolean levelFourFinished;
    NSInteger _level;
    CFTimeInterval  lastFrameStartTime;
    CGPoint _lastPosSelectedNode;
    BOOL _goOnClicked;
    float _timeFrameToCatchRabbit;
}

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        
        //TODO: Melodie spielen???
        //Play Sound with SKAction
        /* SKAction* soundAction = [SKAction playSoundFileNamed:@"bird.mp3" waitForCompletion:NO];
         [self runAction:soundAction]; */
        _level = 1;
        [self initTitleScreen];
    }
    
    
    return self;
}

-(void)initGame{
    [_backgroundAudioPlayer stop];
    [self removeAllActions];
    
    [_background removeAllChildren];
    
    _goOnClicked = FALSE;
    
    lastFrameStartTime = 0;
    _rabbitCounter = 0;
    _background.position = CGPointMake(0,0); //Wieder zum Anfang des Spielfeldes bewegen

    if (_level==1) {
        [self initLevel1]; }
    if (_level==2) {
        [self initLevel2];}
    if (_level==3){
        [self initLevel3];}
    if (_level==4){
        [self initLevel4];
    }
    if (_level > 4){
        [self initTitleScreen];
    }

    //[self startBackgroundMusic];
}

- (void)initTitleScreen {
    //_background = [SKSpriteNode spriteNodeWithImageNamed:@"summerbackground"];
    [self removeAllChildren];
    [_backgroundAudioPlayer stop];
    _titleScreen = [SKSpriteNode spriteNodeWithImageNamed:@"title"];
    
    float posX, posY;
    posX = self.frame.size.width;
    posY = self.frame.size.height;
    CGSize bgSize = CGSizeMake(posX, posY);
    
    [_titleScreen setSize:bgSize];
    [_titleScreen setName:@"titlescreen"];
    [_titleScreen setAnchorPoint:CGPointZero];
    
    [self addChild:_titleScreen];
    [self addTitleLabel];
    [self addStartLabel];
    [self infoLabel];
    [self copyrightLabel];
    //[self addOptionLabel];
    //Die Level sollen nicht direkt anwählbar sein.
    //[self addLevelMenu];
    //Initialisierung zum Start (falls keine Option gewählt wurde)
    //_rabbitToFound = 1;
}

- (void)initEndTitleScreen {

    [self removeAllChildren];
    [_backgroundAudioPlayer stop];
    SKSpriteNode *_endtitleScreen = [SKSpriteNode spriteNodeWithImageNamed:@"endtitle"];
    
    float posX, posY;
    posX = self.frame.size.width;
    posY = self.frame.size.height;
    CGSize bgSize = CGSizeMake(posX, posY);
    
    [_endtitleScreen setSize:bgSize];
    [_endtitleScreen setName:@"endtitelsreen"];
    [_endtitleScreen setAnchorPoint:CGPointZero];
    
    [self addChild:_endtitleScreen];
    
    SKLabelNode *lblNode;
    lblNode = [[SKLabelNode alloc] initWithFontNamed:@"Baskerville-BoldItalic"];
    lblNode.name = @"lblEndNode";
    lblNode.text = NSLocalizedString(@"lblEndNode",nil);
    lblNode.fontSize = 72;
    //lblNode.scale = 0.5;
    lblNode.position = CGPointMake(self.frame.size.width/2, self.frame.size.height * 0.8);
    lblNode.fontColor = [SKColor colorWithRed:96.0f/255.0f green:155.0f/255.0f blue:227.0f/255.0f alpha:1.0f];
    [self addChild:lblNode];
    
    _goOnClicked = false;
    for (NSInteger i=0;i<80;i++) {
        [self startBalloonAnimation];
    }
    [self addGoOnLabel];

}


-(void)waitScreen:(NSString*) _levelName WaitDuration:(NSInteger) _waitDuration {
    
    SKLabelNode *lblNode;
    lblNode = [[SKLabelNode alloc] initWithFontNamed:@"Baskerville-BoldItalic"];
    lblNode.name = @"lblNode";
    lblNode.text = _levelName;
    lblNode.fontSize = 62;
    //lblNode.scale = 0.5;
    lblNode.position = CGPointMake(self.frame.size.width/2, self.frame.size.height * 0.5);
    lblNode.fontColor = [SKColor colorWithRed:96.0f/255.0f green:155.0f/255.0f blue:227.0f/255.0f alpha:1.0f];
    [self addChild:lblNode];

    SKAction *wait = [SKAction waitForDuration: _waitDuration];
    SKAction *fadeAway = [SKAction fadeOutWithDuration: 0.7];
    SKAction *remove = [SKAction removeFromParent];
    SKAction *action = [SKAction sequence:@[wait, fadeAway, remove]];
    //[_background runAction:action];
    
    [lblNode runAction:action];
    
    //SKAction *action2 = [SKAction sequence:@[remove]];
    //[lblNode runAction:action2];

   // [lblNode removeFromParent];
}

- (void)initLevel1 {
    _background = [SKSpriteNode spriteNodeWithImageNamed:@"springbackground"];
    float posX, posY;
    posX = self.frame.size.width;
    posX = posX * 4;
    posY = self.frame.size.height;
    CGSize bgSize = CGSizeMake(posX, posY);
    
    [_background setSize:bgSize];
    [_background setName:@"background"];
    [_background setAnchorPoint:CGPointZero];
    
    [self addChild:_background];
    
    [self initPhysicsBodyForBackground];
    
    [self waitScreen:NSLocalizedString(@"msgSpring",nil) WaitDuration:1];
    
    [_background addChild: [self addSprite:1500
                                     Pos_y:250 PicName:@"springhouse1.gif" Moveable:false Pos_z:0]];
    //Maus
    [self animatedSpriteFixedPosition:@"mouse1.gif" ImageName2:@"mouse2.gif" XPos:1500 YPos:80 TimePerFrame:0.9];
    
    [_background addChild: [self addSprite:1750
                                     Pos_y:240 PicName:@"springhouse2.gif" Moveable:false Pos_z:0]];
    [_background addChild: [self addSprite:2200
                                     Pos_y:230 PicName:@"springhouse3.gif" Moveable:false Pos_z:0]];
    //[_background addChild: [self addSprite:2000
    //                                 Pos_y:self.frame.size.height-100 PicName:@"sun.png" Moveable:false Pos_z:0]];
    [_background addChild: [self addSprite:250
                                     Pos_y:280 PicName:@"springtree1.gif" Moveable:false Pos_z:0]];
    [_background addChild: [self addSprite:500
                                     Pos_y:290 PicName:@"springtree2.gif" Moveable:false Pos_z:0]];
    [_background addChild: [self addSprite:700
                                     Pos_y:285 PicName:@"springtree1.gif" Moveable:false Pos_z:0]];
    [_background addChild: [self addSprite:2450
                                     Pos_y:280 PicName:@"springtree1.gif" Moveable:false Pos_z:0]];
    [_background addChild: [self addSprite:2700
                                     Pos_y:270 PicName:@"springtree2.gif" Moveable:false Pos_z:0]];
    [_background addChild: [self addSprite:3000
                                     Pos_y:285 PicName:@"springtree1.gif" Moveable:false Pos_z:0]];
    [_background addChild: [self addSprite:3200
                                     Pos_y:280 PicName:@"springtree2.gif" Moveable:false Pos_z:0]];
    [_background addChild: [self addSprite:3500
                                     Pos_y:285 PicName:@"springtree1.gif" Moveable:false Pos_z:0]];
    [_background addChild: [self addSprite:3700
                                     Pos_y:275 PicName:@"springtree2.gif" Moveable:false Pos_z:0]];
    [_background addChild: [self addSprite:3900
                                     Pos_y:290 PicName:@"springtree1.gif" Moveable:false Pos_z:0]];
    [_background addChild: [self addSprite:50
                                     Pos_y:400 PicName:@"branchbird.gif" Moveable:false Pos_z:0]];
    //2. Ebene
    [self addRabbits];
    
    //1. Ebene
    [_background addChild: [self addSprite:180
                                     Pos_y:[self getRandomNumberBetween:50 to:90] PicName:@"springbush5.gif" Moveable:false Pos_z:1]];
    [_background addChild: [self addSprite:500
                                     Pos_y:[self getRandomNumberBetween:50 to:90] PicName:@"springstone.gif" Moveable:false Pos_z:1]];
    [_background addChild: [self addSprite:900
                                     Pos_y:[self getRandomNumberBetween:50 to:90] PicName:@"springbush1.gif" Moveable:false Pos_z:1]];
    [_background addChild: [self addSprite:1200
                                     Pos_y:[self getRandomNumberBetween:50 to:90] PicName:@"springbush2.gif" Moveable:false Pos_z:1]];
    [_background addChild: [self addSprite:1800
                                     Pos_y:[self getRandomNumberBetween:50 to:90] PicName:@"springbush3.gif" Moveable:false Pos_z:1]];
    [_background addChild: [self addSprite:2100
                                     Pos_y:[self getRandomNumberBetween:50 to:90] PicName:@"springbush4.gif" Moveable:false Pos_z:1]];
    [_background addChild: [self addSprite:2400
                                     Pos_y:[self getRandomNumberBetween:50 to:90] PicName:@"springstone.gif" Moveable:false Pos_z:1]];
    [_background addChild: [self addSprite:2800
                                     Pos_y:[self getRandomNumberBetween:50 to:90] PicName:@"springbush5.gif" Moveable:false Pos_z:1]];
    [_background addChild: [self addSprite:3100
                                     Pos_y:[self getRandomNumberBetween:50 to:90] PicName:@"springbush1.gif" Moveable:false Pos_z:1]];
    [_background addChild: [self addSprite:3400
                                     Pos_y:[self getRandomNumberBetween:50 to:90] PicName:@"springbush2.gif" Moveable:false Pos_z:1]];
    [_background addChild: [self addSprite:3900
                                     Pos_y:80 PicName:@"springbush1.gif" Moveable:false Pos_z:1]];
    
    [self addRabbitCounter];
    [self addBasket];

    //schedule Bird
    SKAction *wait = [SKAction waitForDuration:15];
    SKAction *moveSprite = [SKAction runBlock:^{
        [self moveAnimatedSprite:@"rflyingbird1" ImageName2:@"rflyingbird2" YPos:512 Duration:25 TimePerFrame:0.1];
    }];
    
    SKAction *updateSprite = [SKAction sequence:@[wait, moveSprite]];
    [self runAction:[SKAction repeatActionForever:updateSprite]];
    
/*    SKAction *playSound = [SKAction playSoundFileNamed:@"bird.mp3" waitForCompletion:NO];
    //SKAction *wait = [SKAction waitForDuration:20];
    SKAction *action = [SKAction sequence:@[playSound, wait]];
    [self runAction:[SKAction repeatActionForever:action]]; */
    
    //[self loadSpriteFrames]; //Butterfly
    
    [self startBackgroundSound:@"bird.mp3"];

}
    
- (void)initLevel2 {
    _background = [SKSpriteNode spriteNodeWithImageNamed:@"summerbackground"];
    float posX, posY;
    posX = self.frame.size.width;
    posX = posX * 4;
    posY = self.frame.size.height;
    CGSize bgSize = CGSizeMake(posX, posY);
    
    [_background setSize:bgSize];
    [_background setName:@"background"];
    [_background setAnchorPoint:CGPointZero];
    
    [self addChild:_background];
    
    [self initPhysicsBodyForBackground];
    [self waitScreen:NSLocalizedString(@"msgSummer",nil) WaitDuration:1];
    
    //[self addStartLabel];
    //[self addOptionLabel];
    //Initialisierung zum Start (falls keine Option gewählt wurde)
   

    //_background.texture = [SKTexture textureWithImageNamed:@"summerbackground"];
    //Beschreibung des ersten Spielfeldes (Level1)
    
    //3. Ebene
    [_background addChild: [self addSprite:1500
                                     Pos_y:250 PicName:@"summerhouse1.gif" Moveable:false Pos_z:0]];
    [_background addChild: [self addSprite:1750
                                     Pos_y:240 PicName:@"summerhouse2.gif" Moveable:false Pos_z:0]];
    [_background addChild: [self addSprite:2200
                                     Pos_y:230 PicName:@"summerhouse3.gif" Moveable:false Pos_z:0]];
    [_background addChild: [self addSprite:250
                                     Pos_y:280 PicName:@"summertree1.gif" Moveable:false Pos_z:0]];
    [_background addChild: [self addSprite:500
                                     Pos_y:290 PicName:@"summertree2.gif" Moveable:false Pos_z:0]];
    [_background addChild: [self addSprite:700
                                     Pos_y:285 PicName:@"summertree3.gif" Moveable:false Pos_z:0]];
    [_background addChild: [self addSprite:2450
                                     Pos_y:280 PicName:@"summertree1.gif" Moveable:false Pos_z:0]];
    [_background addChild: [self addSprite:2700
                                     Pos_y:270 PicName:@"summertree2.gif" Moveable:false Pos_z:0]];
    [_background addChild: [self addSprite:3000
                                     Pos_y:285 PicName:@"summertree3.gif" Moveable:false Pos_z:0]];
    [_background addChild: [self addSprite:3200
                                     Pos_y:280 PicName:@"summertree2.gif" Moveable:false Pos_z:0]];
    [_background addChild: [self addSprite:3500
                                     Pos_y:285 PicName:@"summertree3.gif" Moveable:false Pos_z:0]];
    [_background addChild: [self addSprite:3700
                                     Pos_y:275 PicName:@"summertree2.gif" Moveable:false Pos_z:0]];
    [_background addChild: [self addSprite:3900
                                     Pos_y:290 PicName:@"summertree1.gif" Moveable:false Pos_z:0]];
    //2. Ebene
    [self addRabbits];

    //1. Ebene
    [_background addChild: [self addSprite:180
                                     Pos_y:[self getRandomNumberBetween:80 to:90] PicName:@"summerstone.gif" Moveable:false Pos_z:1]];
    [_background addChild: [self addSprite:500
                                     Pos_y:[self getRandomNumberBetween:80 to:90] PicName:@"summerbush4.gif" Moveable:false Pos_z:1]];
    [_background addChild: [self addSprite:900
                                     Pos_y:[self getRandomNumberBetween:80 to:90] PicName:@"summerbush1.gif" Moveable:false Pos_z:1]];
    [_background addChild: [self addSprite:1200
                                     Pos_y:[self getRandomNumberBetween:80 to:90] PicName:@"summerbush3.gif" Moveable:false Pos_z:1]];
    [_background addChild: [self addSprite:1800
                                     Pos_y:[self getRandomNumberBetween:80 to:90] PicName:@"summerbush2.gif" Moveable:false Pos_z:1]];
    [_background addChild: [self addSprite:2100
                                     Pos_y:[self getRandomNumberBetween:80 to:90] PicName:@"summerstone.gif" Moveable:false Pos_z:1]];
    [_background addChild: [self addSprite:2400
                                     Pos_y:[self getRandomNumberBetween:80 to:90] PicName:@"summerbush1.gif" Moveable:false Pos_z:1]];
    [_background addChild: [self addSprite:2800
                                     Pos_y:[self getRandomNumberBetween:80 to:90] PicName:@"summerbush3.gif" Moveable:false Pos_z:1]];
    [_background addChild: [self addSprite:3100
                                     Pos_y:[self getRandomNumberBetween:80 to:90] PicName:@"summerstone.gif" Moveable:false Pos_z:1]];
    [_background addChild: [self addSprite:3400
                                     Pos_y:[self getRandomNumberBetween:80 to:90] PicName:@"summerbush4.gif" Moveable:false Pos_z:1]];
    [_background addChild: [self addSprite:3900
                                     Pos_y:[self getRandomNumberBetween:80 to:90] PicName:@"summerstone.gif" Moveable:false Pos_z:1]];
    
    [self addRabbitCounter];
    [self addBasket];
    
 /*   SKAction *playSound = [SKAction playSoundFileNamed:@"duck.mp3" waitForCompletion:NO];
    SKAction *wait = [SKAction waitForDuration:20];
    SKAction *action = [SKAction sequence:@[playSound, wait]];
    [self runAction:[SKAction repeatActionForever:action]]; */
    
    [self startBackgroundSound:@"duck.mp3"];
    
    [self moveImageOverScreen:@"lduck" rightImageName:@"rduck" duration:50 yPos:20];
    
    SKAction *wait2 = [SKAction waitForDuration:1];
    SKAction *callBlowball = [SKAction runBlock:^{
        [self startHeapAnimation:@"blowball.gif" Image2Name:@"blowball.gif" Landscape:TRUE];
    }];
    
    SKAction *updateBlowball = [SKAction sequence:@[wait2,callBlowball]];
    [self runAction:[SKAction repeatActionForever:updateBlowball]];

   
}

- (void)initLevel3 {
    //[_background removeAllChildren];
    //[_background setTexture:[SKTexture textureWithImageNamed:@"autumn"]];
    _background = nil;
    _background = [SKSpriteNode spriteNodeWithImageNamed:@"autumnbackground"];
    float posX, posY;
    posX = self.frame.size.width;
    posX = posX * 4;
    posY = self.frame.size.height;
    CGSize bgSize = CGSizeMake(posX, posY);
    
    [_background setSize:bgSize];
    [_background setName:@"background"];
    [_background setAnchorPoint:CGPointZero];
    
    [self addChild:_background];
    [self initPhysicsBodyForBackground];
    [self waitScreen:NSLocalizedString(@"msgAutumn",nil) WaitDuration:1];
    
    //3. Ebene
    [_background addChild: [self addSprite:50
                                     Pos_y:400 PicName:@"squirrel.gif" Moveable:false Pos_z:0]];
    [_background addChild: [self addSprite:1500
                                     Pos_y:250 PicName:@"autumnhouse1.gif" Moveable:false Pos_z:0]];
    [_background addChild: [self addSprite:1750
                                     Pos_y:240 PicName:@"autumnhouse2.gif" Moveable:false Pos_z:0]];
    [_background addChild: [self addSprite:2200
                                     Pos_y:230 PicName:@"autumnhouse3.gif" Moveable:false Pos_z:0]];
    [_background addChild: [self addSprite:250
                                     Pos_y:280 PicName:@"autumntree1.gif" Moveable:false Pos_z:0]];
    [_background addChild: [self addSprite:500
                                     Pos_y:290 PicName:@"autumntree2.gif" Moveable:false Pos_z:0]];
    [_background addChild: [self addSprite:700
                                     Pos_y:285 PicName:@"autumntree3.gif" Moveable:false Pos_z:0]];
    [_background addChild: [self addSprite:1000
                                     Pos_y:200 PicName:@"mushroom1.gif" Moveable:false Pos_z:0]];
    [_background addChild: [self addSprite:1300
                                     Pos_y:220 PicName:@"seat.gif" Moveable:false Pos_z:0]];
    [_background addChild: [self addSprite:1600
                                     Pos_y:180 PicName:@"autumnstone.gif" Moveable:false Pos_z:0]];
    [_background addChild: [self addSprite:2450
                                     Pos_y:280 PicName:@"autumntree4.gif" Moveable:false Pos_z:0]];
    [_background addChild: [self addSprite:2700
                                     Pos_y:270 PicName:@"autumntree2.gif" Moveable:false Pos_z:0]];
    [_background addChild: [self addSprite:3000
                                     Pos_y:285 PicName:@"autumntree3.gif" Moveable:false Pos_z:0]];
    [_background addChild: [self addSprite:3200
                                     Pos_y:280 PicName:@"autumntree1.gif" Moveable:false Pos_z:0]];
    [_background addChild: [self addSprite:3350
                                     Pos_y:200 PicName:@"mushroom2.gif" Moveable:false Pos_z:0]];
    [_background addChild: [self addSprite:3500
                                     Pos_y:285 PicName:@"autumntree4.gif" Moveable:false Pos_z:0]];
    [_background addChild: [self addSprite:3700
                                     Pos_y:275 PicName:@"autumntree2.gif" Moveable:false Pos_z:0]];
    [_background addChild: [self addSprite:3900
                                     Pos_y:290 PicName:@"autumntree1.gif" Moveable:false Pos_z:0]];
    
    //2. Ebene
    [self addRabbits];
    
    //1. Ebene
    [_background addChild: [self addSprite:180
                                     Pos_y:[self getRandomNumberBetween:50 to:90] PicName:@"autumnbush1.gif" Moveable:false Pos_z:1]];
    [_background addChild: [self addSprite:500
                                     Pos_y:[self getRandomNumberBetween:50 to:90] PicName:@"autumnbush2.gif" Moveable:false Pos_z:1]];
    [_background addChild: [self addSprite:900
                                     Pos_y:[self getRandomNumberBetween:50 to:90] PicName:@"autumnbush3.gif" Moveable:false Pos_z:1]];
    [_background addChild: [self addSprite:1200
                                     Pos_y:[self getRandomNumberBetween:50 to:90] PicName:@"autumnbush3.gif" Moveable:false Pos_z:1]];
    [_background addChild: [self addSprite:1800
                                     Pos_y:[self getRandomNumberBetween:50 to:90] PicName:@"autumnbush1.gif" Moveable:false Pos_z:1]];
    [_background addChild: [self addSprite:2100
                                     Pos_y:[self getRandomNumberBetween:50 to:90] PicName:@"autumnbush2.gif" Moveable:false Pos_z:1]];
    [_background addChild: [self addSprite:2400
                                     Pos_y:[self getRandomNumberBetween:50 to:90] PicName:@"autumnbush3.gif" Moveable:false Pos_z:1]];
    [_background addChild: [self addSprite:2800
                                     Pos_y:[self getRandomNumberBetween:50 to:90] PicName:@"autumnbush1.gif" Moveable:false Pos_z:1]];
    [_background addChild: [self addSprite:3100
                                     Pos_y:[self getRandomNumberBetween:50 to:90] PicName:@"autumnbush2.gif" Moveable:false Pos_z:1]];
    [_background addChild: [self addSprite:3400
                                     Pos_y:[self getRandomNumberBetween:50 to:90] PicName:@"autumnbush1.gif" Moveable:false Pos_z:1]];
    [_background addChild: [self addSprite:3900
                                     Pos_y:[self getRandomNumberBetween:50 to:90] PicName:@"autumnbush3.gif" Moveable:false Pos_z:1]];
    
    [self addRabbitCounter];
    [self addBasket];
    //[self moveImageOnBottom:@"lhedgehog.gif" rightImageName:@"rhedgehog.gif" duration:25 yPos:45];
    
    //schedule Hedgehog
    SKAction *wait = [SKAction waitForDuration:15];
    SKAction *moveSprite = [SKAction runBlock:^{
        [self moveAnimatedSprite:@"hedgehog1" ImageName2:@"hedgehog2" YPos:45 Duration:50 TimePerFrame:0.5];
    }];
    
    //SKAction *playSound = [SKAction playSoundFileNamed:@"wind.mp3" waitForCompletion:NO];
    //SKAction *updateSprite = [SKAction sequence:@[playSound, wait, moveSprite]];
    SKAction *updateSprite = [SKAction sequence:@[wait, moveSprite]];
    [self runAction:[SKAction repeatActionForever:updateSprite]];
    
    SKAction *wait2 = [SKAction waitForDuration:1];
    SKAction *callLeaf = [SKAction runBlock:^{
        [self startHeapAnimation:@"leaf1.gif" Image2Name:@"leaf2.gif" Landscape:TRUE];
    }];
    
    SKAction *updateLeaf = [SKAction sequence:@[wait2,callLeaf]];
    [self runAction:[SKAction repeatActionForever:updateLeaf]];
    
    [self startBackgroundSound:@"wind.mp3"];
    
}

- (void)initLevel4 {
    _background = nil;
    _background = [SKSpriteNode spriteNodeWithImageNamed:@"winterbackground"];
    float posX, posY;
    posX = self.frame.size.width;
    posX = posX * 4;
    posY = self.frame.size.height;
    CGSize bgSize = CGSizeMake(posX, posY);
    
    [_background setSize:bgSize];
    [_background setName:@"background"];
    [_background setAnchorPoint:CGPointZero];
    
    [self addChild:_background];
    [self initPhysicsBodyForBackground];
    [self waitScreen:NSLocalizedString(@"msgWinter",nil) WaitDuration:1];
    
    //3 Ebene
    [self animatedSpriteFixedPosition:@"owl1.gif" ImageName2:@"owl2.gif" XPos:50 YPos:400 TimePerFrame:0.8];

    [_background addChild: [self addSprite:1500
                                     Pos_y:250 PicName:@"snowman.gif" Moveable:false Pos_z:0]];
    [_background addChild: [self addSprite:1500
                                     Pos_y:250 PicName:@"winterhouse1.gif" Moveable:false Pos_z:0]];
    [_background addChild: [self addSprite:1750
                                     Pos_y:240 PicName:@"winterhouse2.gif" Moveable:false Pos_z:0]];
    [_background addChild: [self addSprite:2000
                                     Pos_y:200 PicName:@"snowman.gif" Moveable:false Pos_z:0]];
    [_background addChild: [self addSprite:2200
                                     Pos_y:230 PicName:@"winterhouse3.gif" Moveable:false Pos_z:0]];
    [_background addChild: [self addSprite:250
                                     Pos_y:280 PicName:@"wintertree1.gif" Moveable:false Pos_z:0]];
    [_background addChild: [self addSprite:500
                                     Pos_y:290 PicName:@"wintertree2.gif" Moveable:false Pos_z:0]];
    [_background addChild: [self addSprite:700
                                     Pos_y:285 PicName:@"wintertree1.gif" Moveable:false Pos_z:0]];
    [_background addChild: [self addSprite:1000
                                     Pos_y:240 PicName:@"birdhouse.gif" Moveable:false Pos_z:0]];
    [_background addChild: [self addSprite:2450
                                     Pos_y:280 PicName:@"wintertree1.gif" Moveable:false Pos_z:0]];
    [_background addChild: [self addSprite:2700
                                     Pos_y:270 PicName:@"wintertree2.gif" Moveable:false Pos_z:0]];
    [_background addChild: [self addSprite:3000
                                     Pos_y:285 PicName:@"wintertree1.gif" Moveable:false Pos_z:0]];
    [_background addChild: [self addSprite:3200
                                     Pos_y:280 PicName:@"wintertree2.gif" Moveable:false Pos_z:0]];
    [_background addChild: [self addSprite:3500
                                     Pos_y:285 PicName:@"wintertree1.gif" Moveable:false Pos_z:0]];
    [_background addChild: [self addSprite:3700
                                     Pos_y:275 PicName:@"wintertree2.gif" Moveable:false Pos_z:0]];
    [_background addChild: [self addSprite:3900
                                     Pos_y:290 PicName:@"wintertree1.gif" Moveable:false Pos_z:0]];
    
    [self animatedSpriteFixedPosition:@"squirrel1.gif" ImageName2:@"squirrel2.gif" XPos:1600 YPos:100 TimePerFrame:0.9];
    
    //2. Ebene
    [self addRabbits];
    
    //1. Ebene
    [_background addChild: [self addSprite:180
                                     Pos_y:[self getRandomNumberBetween:50 to:90] PicName:@"winterbush1.gif" Moveable:false Pos_z:1]];
    [_background addChild: [self addSprite:500
                                     Pos_y:[self getRandomNumberBetween:50 to:90] PicName:@"winterbush2.gif" Moveable:false Pos_z:1]];
    [_background addChild: [self addSprite:900
                                     Pos_y:[self getRandomNumberBetween:50 to:90] PicName:@"winterbush4.gif" Moveable:false Pos_z:1]];
    [_background addChild: [self addSprite:1200
                                     Pos_y:[self getRandomNumberBetween:50 to:90] PicName:@"winterbush3.gif" Moveable:false Pos_z:1]];
    [_background addChild: [self addSprite:1800
                                     Pos_y:[self getRandomNumberBetween:50 to:90] PicName:@"winterstone.gif" Moveable:false Pos_z:1]];
    [_background addChild: [self addSprite:2100
                                     Pos_y:[self getRandomNumberBetween:50 to:90] PicName:@"winterbush2.gif" Moveable:false Pos_z:1]];
    [_background addChild: [self addSprite:2400
                                     Pos_y:[self getRandomNumberBetween:50 to:90] PicName:@"winterbush4.gif" Moveable:false Pos_z:1]];
    [_background addChild: [self addSprite:2800
                                     Pos_y:[self getRandomNumberBetween:50 to:90] PicName:@"winterbush5.gif" Moveable:false Pos_z:1]];
    [_background addChild: [self addSprite:3100
                                     Pos_y:[self getRandomNumberBetween:50 to:90] PicName:@"winterbush2.gif" Moveable:false Pos_z:1]];
    [_background addChild: [self addSprite:3400
                                     Pos_y:[self getRandomNumberBetween:50 to:90] PicName:@"winterbush1.gif" Moveable:false Pos_z:1]];
    [_background addChild: [self addSprite:3900
                                     Pos_y:[self getRandomNumberBetween:50 to:90] PicName:@"winterbush4.gif" Moveable:false Pos_z:1]];
    
    [self addRabbitCounter];
    [self addBasket];
    
/*    SKAction *playSound = [SKAction playSoundFileNamed:@"owl.mp3" waitForCompletion:NO];
    SKAction *wait = [SKAction waitForDuration:10];
    SKAction *action = [SKAction sequence:@[playSound, wait]];
    [self runAction:[SKAction repeatActionForever:action]]; */
    
    [self startBackgroundSound:@"owl.mp3"];

    SKAction *wait2 = [SKAction waitForDuration:1];
    SKAction *callSnowflake = [SKAction runBlock:^{
        [self startHeapAnimation:@"snowflake1.gif" Image2Name:@"snowflake2.gif" Landscape:FALSE];
    }];
    
    SKAction *updateSnowflake = [SKAction sequence:@[wait2,callSnowflake]];
    [self runAction:[SKAction repeatActionForever:updateSnowflake]];

}

- (void)moveImageOverScreen:(NSString*)_leftImageName rightImageName:(NSString*)_rightImageName duration:(NSInteger) _duration yPos:(NSInteger)_yPos {
    //Sprite erzeugen
    _movingSpriteNode = [SKSpriteNode spriteNodeWithImageNamed:_rightImageName];
    _movingSpriteNode.name = @"NotMoveable";
    _movingSpriteNode.position = CGPointMake(0,_yPos);
    _movingSpriteNode.zPosition = 1;
    [self addChild:_movingSpriteNode];
    
    //Sprite über den Bildschirm bewegen
    
    SKAction *moveImage1 = [SKAction moveToX:4096 duration:_duration];//10];
    SKAction* changeImage1 = [SKAction setTexture:[SKTexture textureWithImageNamed:_leftImageName]];
    [_movingSpriteNode runAction:changeImage1];
    
    SKAction *moveImage2 = [SKAction moveToX:0 duration:_duration];//10];
    SKAction* changeImage2 = [SKAction setTexture:[SKTexture textureWithImageNamed:_rightImageName]];
    [_movingSpriteNode runAction:changeImage2];
    
    SKAction *moveSequence = [SKAction sequence:@[moveImage1, changeImage1, moveImage2, changeImage2]];
    SKAction *repeat = [SKAction repeatActionForever:moveSequence];
    [_movingSpriteNode runAction:repeat];
}

-(void)animatedSpriteFixedPosition:(NSString*)_imageName1 ImageName2:(NSString*)_imageName2 XPos:(NSInteger)_xPos YPos:(NSInteger)_yPos TimePerFrame:(float)_timePerFrame{

    SKSpriteNode *node;
    node.name = @"NotMoveable";
    node = [SKSpriteNode spriteNodeWithImageNamed:_imageName1];
    node.position = CGPointMake(_xPos, _yPos);
    node.zPosition = 1;
    [_background addChild:node];

    //[self addChild:node];
    
    SKTexture *rbirdWingsDown = [SKTexture textureWithImageNamed:_imageName1];
    SKTexture *rbirdWingsUp = [SKTexture textureWithImageNamed:_imageName2];
    SKAction *spin = [SKAction animateWithTextures:@[rbirdWingsDown,rbirdWingsUp] timePerFrame:_timePerFrame];
    SKAction *spinForever = [SKAction repeatActionForever:spin];
    [node runAction:spinForever];

}

-(void)moveAnimatedSprite:(NSString*)_imageName1 ImageName2:(NSString*)_imageName2 YPos:(NSInteger)_yPos Duration:(NSInteger)_duration TimePerFrame:(float)_timePerFrame {
    
    SKSpriteNode *node;
    
    node = [SKSpriteNode spriteNodeWithImageNamed:_imageName1];
    node.name = @"NotMoveable";
    node.position = CGPointMake(0, _yPos);
    node.zPosition = 1;
    [self addChild:node];
    
    SKTexture *rbirdWingsDown = [SKTexture textureWithImageNamed:_imageName1];
    SKTexture *rbirdWingsUp = [SKTexture textureWithImageNamed:_imageName2];
    SKAction *spin = [SKAction animateWithTextures:@[rbirdWingsDown,rbirdWingsUp] timePerFrame:_timePerFrame];
    SKAction *spinForever = [SKAction repeatActionForever:spin];
    [node runAction:spinForever];
    
    /*SKTexture *lbirdWingsDown = [SKTexture textureWithImageNamed:@"lflyingbird1"];
     SKTexture *lbirdWingsUp = [SKTexture textureWithImageNamed:@"lflyingbird2"];
     SKAction *spin2 = [SKAction animateWithTextures:@[lbirdWingsDown,lbirdWingsUp] timePerFrame:0.1];
     SKAction *spinForever2 = [SKAction repeatActionForever:spin2];
     [node runAction:spinForever2];*/
    
    
    SKAction *move = [SKAction moveToX:4096 duration:_duration];
    //SKAction *move2 = [SKAction moveToX:0 duration:10];
    SKAction *remove = [SKAction removeFromParent];
    //SKAction *wait = [SKAction waitForDuration:1];
    
    SKAction *moveSequence = [SKAction sequence:@[move,remove]];
    // SKAction *moveSequence = [SKAction sequence:@[move,spinForever, move2,spinForever2]];
    SKAction *repeat = [SKAction repeatActionForever:moveSequence];
    [node runAction:repeat];
    
}

/*-(void)animateSprite
 {
 //This is our general runAction method to make our bear walk.
 //By using a withKey if this gets called while already running it will remove the first action before
 //starting this again.
 
     [_butterfly runAction:[SKAction repeatActionForever:[SKAction animateWithTextures:_movingButterflyFrames
                                                                       timePerFrame:0.05f
                                                                             resize:NO
                                                                            restore:YES]] withKey:@"movingButterflyKey"];
     return;
 }
 
 -(void)loadSpriteFrames {
     //Setup the array to hold the walking frames
     NSMutableArray *moveFrames = [NSMutableArray array];
 
     //Load the TextureAtlas for the bear
     SKTextureAtlas *animatedAtlas = [SKTextureAtlas atlasNamed:@"butterfly"];
 
     //Load the animation frames from the TextureAtlas
     int numImages = animatedAtlas.textureNames.count;
     for (int i=1; i <= numImages/2; i++) {
        NSString *textureName = [NSString stringWithFormat:@"butterfly%d", i];
        SKTexture *temp = [animatedAtlas textureNamed:textureName];
        [moveFrames addObject:temp];
     }
     _movingButterflyFrames = moveFrames;
 
     //Create bear sprite, setup position in middle of the screen, and add to Scene
     SKTexture *temp = _movingButterflyFrames[0];
     _butterfly = [SKSpriteNode spriteNodeWithTexture:temp];
    //rabbit.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
     _butterfly.position = CGPointMake(3900, 160);
     [_background addChild:_butterfly];
     [self animateSprite];
 
 } */

- (void)startBackgroundSound:(NSString*)soundName
{
    NSError *err;
//    NSURL *file = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"bird.mp3" ofType:nil]];
    NSURL *file = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:soundName ofType:nil]];
    _backgroundAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:file error:&err];
    if (err) {
        NSLog(@"error in audio play %@",[err userInfo]);
        return;
    }
    [_backgroundAudioPlayer prepareToPlay];
    
    // this will play the music infinitely
    _backgroundAudioPlayer.numberOfLoops = -1;
    [_backgroundAudioPlayer setVolume:1.0];
    [_backgroundAudioPlayer play];
}

-(void) addRabbits {
    for (NSInteger i=0; i < _rabbitToFound; i++) {
        NSInteger l = [self getRandomNumberBetween:1 to:8];
        NSString *textureName = [NSString stringWithFormat:@"rabbit%ld.png", (long)l];
        
        SKSpriteNode *rabbit = [self addSprite:[self getRandomNumberBetween:100 to:4000] Pos_y:[self getRandomNumberBetween:120 to:130] PicName:textureName Moveable:true Pos_z:0];
        
        //Konfiguriergung des Hasen als physikalisches Objekt
        rabbit.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:rabbit.frame.size.height];
        rabbit.physicsBody.dynamic = NO;
        rabbit.physicsBody.allowsRotation = NO;
        //rabbit.physicsBody.angularDamping = 0.0;
        rabbit.physicsBody.affectedByGravity = NO;
        rabbit.physicsBody.restitution = 0.6;
        //Handle Contact
        rabbit.physicsBody.categoryBitMask = rabbitCategory;
        rabbit.physicsBody.collisionBitMask = worldCategory;
        rabbit.physicsBody.contactTestBitMask = worldCategory;
        
        NSInteger rNumber = [self getRandomNumberBetween:76 to:100];
        SKAction *moveUp = [SKAction moveByX: 0 y: rNumber duration: 0.5];
        SKAction *moveDown = [SKAction moveByX: 0 y: -rNumber duration: 0.3];
        rNumber = [self getRandomNumberBetween:51 to:75];
        SKAction *moveUp2 = [SKAction moveByX: 0 y: rNumber duration: 0.5];
        SKAction *moveDown2 = [SKAction moveByX: 0 y: -rNumber duration: 0.3];
        rNumber = [self getRandomNumberBetween:26 to:50];
        SKAction *moveUp3 = [SKAction moveByX: 0 y: rNumber duration: 0.5];
        SKAction *moveDown3 = [SKAction moveByX: 0 y: -rNumber duration: 0.3];
        rNumber = [self getRandomNumberBetween:1 to:25];
        SKAction *moveUp4 = [SKAction moveByX: 0 y: rNumber duration: 0.5];
        SKAction *moveDown4 = [SKAction moveByX: 0 y: -rNumber duration: 0.3];
        SKAction *wait = [SKAction waitForDuration:[self getRandomNumberBetween:1 to:5]];
        
        SKAction *moveSequence = [SKAction sequence:@[wait,moveUp,moveDown,moveUp2,moveDown2,moveUp3,moveDown3,moveUp4,moveDown4,wait]];
        //[rabbit runAction:repe]
        SKAction *repeat = [SKAction repeatActionForever:moveSequence];
        [rabbit runAction:repeat];
        
        [_background addChild:rabbit];
    }
}

-(void) initPhysicsBodyForBackground {
    /*SKPhysicsBody* borderBody = [SKPhysicsBody bodyWithEdgeLoopFromRect: CGRectMake(_background.frame.origin.x, _background.frame.origin.y, _background.frame.size.width, 1)];*/
    SKPhysicsBody* borderBody = [SKPhysicsBody bodyWithEdgeLoopFromRect: _background.frame];
    // 2 Set physicsBody of scene to borderBody
    self.physicsBody = borderBody;
    // 3 Set the friction of that physicsBody to 0
    self.physicsBody.friction = 0.0f;
    self.physicsWorld.contactDelegate = self;
    
    //self.physicsWorld.contactDelegate = self;
    
   /* CGRect leftRect = CGRectMake(self.frame.origin.x, self.frame.origin.y, 1, self.frame.size.height);
    SKNode* left = [SKNode node];
    left.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:leftRect];
    left.physicsBody.dynamic = NO;
    left.physicsBody.affectedByGravity = NO;
    [self addChild:left];
    left.physicsBody.categoryBitMask = leftSide; */
}

-(void)didBeginContact:(SKPhysicsContact *)contact {
   //SKPhysicsBody *firstBody = contact.bodyA;
   //SKPhysicsBody *secondBody = contact.bodyB;
    if([[_selectedNode name] isEqualToString:kAnimalNodeName]) {
        _selectedNode.physicsBody.dynamic = NO;
        _selectedNode.physicsBody.affectedByGravity = NO;
        _selectedNode.position = CGPointMake(_selectedNode.position.x, _selectedNode.position.y+40);
    }
  /*  if ((contact.bodyA.categoryBitMask == rabbitCategory) && (contact.bodyB.categoryBitMask == worldCategory)) {
            _selectedNode.physicsBody.dynamic = NO;
            _selectedNode.physicsBody.affectedByGravity = NO;
    }*/
}

- (void)startGame {
    //TODO: Zu Testzwecken reduziert
    _rabbitToFound = 10;//[self getRandomNumberBetween:6 to:10];
    [self initGame];
}

-(int)getRandomNumberBetween:(int)from to:(int)to {
    
    return (int)from + arc4random() % (to-from+1);
}
    
- (SKSpriteNode *)addSprite:(NSInteger)pos_x Pos_y:(NSInteger)pos_y PicName:(NSString*)picName Moveable:(bool)moveable Pos_z:(NSInteger)pos_z
{
    SKSpriteNode *sKSpriteNode = [SKSpriteNode spriteNodeWithImageNamed:picName];
    sKSpriteNode.position = CGPointMake(pos_x,pos_y);
    
    if (moveable) {
        sKSpriteNode.name = kAnimalNodeName;
    } else {
        sKSpriteNode.name = @"NotMoveable";
        sKSpriteNode.zPosition = pos_z;
    }
    
    return sKSpriteNode;
}

-(void)addTitleLabel {
    _titleLabel = [[SKLabelNode alloc] initWithFontNamed:@"Baskerville-BoldItalic"];
    _titleLabel.name = @"titleLabel";
    _titleLabel.text = NSLocalizedString(@"gameTitle",nil); //@"Fang den Hasen";
    _titleLabel.fontSize = 72;
    //rabbitCounterLabel.scale = 0.5;
    _titleLabel.position = CGPointMake(self.frame.size.width/2,self.frame.size.height*0.85);
    _titleLabel.fontColor = [SKColor colorWithRed:96.0f/255.0f green:155.0f/255.0f blue:227.0f/255.0f alpha:1.0f];
    [self addChild:_titleLabel];
}

-(void)addRabbitCounter {
    _rabbitCounterLabel = [[SKLabelNode alloc] initWithFontNamed:@"Baskerville-BoldItalic"];
    _rabbitCounterLabel.name = @"rabbitCounterLabel";
    _rabbitCounterLabel.text = @"";//NSLocalizedString(@"rabbitConterStartValue",nil);//@"0 Hasen";
    _rabbitCounterLabel.fontSize = 62;
    //rabbitCounterLabel.scale = 0.5;
    _rabbitCounterLabel.position = CGPointMake(self.frame.size.width-340,self.frame.size.height-90);
    _rabbitCounterLabel.fontColor = [SKColor colorWithRed:83.0f/255.0f green:134.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
    [self addChild:_rabbitCounterLabel];
}

-(void)addStartLabel {
    SKLabelNode *restartLabel;
    restartLabel = [[SKLabelNode alloc] initWithFontNamed:@"Baskerville-BoldItalic"];
    restartLabel.name = @"restartLabel";
    restartLabel.text = NSLocalizedString(@"textRestartLabel",nil);//@"Spiel starten?";
    restartLabel.fontSize = 42;
    //restartLabel.scale = 0.5;
    restartLabel.position = CGPointMake(self.frame.size.width/2, self.frame.size.height * 0.1);
    restartLabel.fontColor = [SKColor colorWithRed:246.0f/255.0f green:105.0f/255.0f blue:4.0f/255.0f alpha:1.0f];
    [self addChild:restartLabel];
    
    /*CGPoint point = CGPointMake(self.frame.size.width*0.8, self.frame.size.height * 0.5);
    //SKSpriteNode *node = [self addSprite:point.x Pos_y:point.y PicName:@"startbutton.png" Moveable:false Pos_z:0];
    SKSpriteNode *node = [self addSprite:point.x Pos_y:point.y PicName:@"nextbutton.png" Moveable:false Pos_z:0];
    node.name = @"startbutton";
    [self addChild:node];*/
}

-(void)infoLabel {
    SKLabelNode *restartLabel;
    restartLabel = [[SKLabelNode alloc] initWithFontNamed:@"Baskerville-BoldItalic"];
    restartLabel.name = @"infoLabel";
    restartLabel.text = NSLocalizedString(@"textInfoLabel",nil);//@"Spiel starten?";
    restartLabel.fontSize = 22;
    //restartLabel.scale = 0.5;
    restartLabel.position = CGPointMake(self.frame.size.width/2, self.frame.size.height * 0.8);
    restartLabel.fontColor = [SKColor colorWithRed:96.0f/255.0f green:155.0f/255.0f blue:227.0f/255.0f alpha:1.0f];
    [self addChild:restartLabel];
}

-(void)addGoOnLabel {
/*    SKLabelNode *goOnLabel;
    goOnLabel = [[SKLabelNode alloc] initWithFontNamed:@"Baskerville-BoldItalic"];
    goOnLabel.name = @"goOnLabel";
    goOnLabel.text = NSLocalizedString(@"textGoOnLabel",nil);//@"Weiter ?";
    goOnLabel.fontSize = 42;
    //restartLabel.scale = 0.5;
    goOnLabel.position = CGPointMake(self.frame.size.width/2, self.frame.size.height * 0.4);
    goOnLabel.fontColor = [SKColor colorWithRed:96.0f/255.0f green:155.0f/255.0f blue:227.0f/255.0f alpha:1.0f];
    [self addChild:goOnLabel];*/
    CGPoint point = CGPointMake(self.frame.size.width/2, self.frame.size.height * 0.4);
    SKSpriteNode *node = [self addSprite:point.x Pos_y:point.y PicName:@"nextbutton.png" Moveable:false Pos_z:0];
    node.name = @"nextbutton";
    [self addChild:node];
}

-(void)copyrightLabel {
    SKLabelNode *restartLabel;
    restartLabel = [[SKLabelNode alloc] initWithFontNamed:@"Baskerville-BoldItalic"];
    restartLabel.name = @"copyrightLabel";
    restartLabel.text = NSLocalizedString(@"textCopyright",nil);//@"Spiel starten?";
    restartLabel.fontSize = 12;
    //restartLabel.scale = 0.5;
    restartLabel.position = CGPointMake(self.frame.size.width/8, self.frame.size.height * 0.01);
    restartLabel.fontColor = [SKColor colorWithRed:96.0f/255.0f green:155.0f/255.0f blue:227.0f/255.0f alpha:1.0f];
    [self addChild:restartLabel];
}


/*-(void)addDifficultLevelMenu {
    SKLabelNode *lblLevel1;
    lblLevel1 = [[SKLabelNode alloc] initWithFontNamed:@"Baskerville-BoldItalic"];
    lblLevel1.name = @"lblEasy";
    lblLevel1.text = @"Einfach";
    lblLevel1.fontSize = 38;
    //lblLevel1.fon
    //restartLabel.scale = 0.5;
    lblLevel1.position = CGPointMake(self.frame.size.width/2, self.frame.size.height * 0.28);
    lblLevel1.fontColor = [SKColor purpleColor];
    [self addChild:lblLevel1];
    
    SKLabelNode *lblLevel2;
    lblLevel2 = [[SKLabelNode alloc] initWithFontNamed:@"Baskerville-BoldItalic"];
    lblLevel2.name = @"lblMedium";
    lblLevel2.text = @"Mittel";
    lblLevel2.fontSize = 38;
    //restartLabel.scale = 0.5;
    lblLevel2.position = CGPointMake(self.frame.size.width/2, self.frame.size.height * 0.22);
    lblLevel2.fontColor = [SKColor purpleColor];
    [self addChild:lblLevel2];
    
    SKLabelNode *lblLevel3;
    lblLevel3 = [[SKLabelNode alloc] initWithFontNamed:@"Baskerville-BoldItalic"];
    lblLevel3.name = @"lblHeavy";
    lblLevel3.text = @"Schwer";
    lblLevel3.fontSize = 38;
    //restartLabel.scale = 0.5;
    lblLevel3.position = CGPointMake(self.frame.size.width/2, self.frame.size.height * 0.16);
    lblLevel3.fontColor = [SKColor purpleColor];
    [self addChild:lblLevel3];
}*/

-(void)addLevelMenu {
    SKLabelNode *lblLevel1;
    lblLevel1 = [[SKLabelNode alloc] initWithFontNamed:@"Baskerville-BoldItalic"];
    lblLevel1.name = @"lblLevel1";
    lblLevel1.text = @"Frühling";
    lblLevel1.fontSize = 38;
    //lblLevel1.fon
    //restartLabel.scale = 0.5;
    lblLevel1.position = CGPointMake(self.frame.size.width/2, self.frame.size.height * 0.28);
    lblLevel1.fontColor = [SKColor colorWithRed:96.0f/255.0f green:155.0f/255.0f blue:227.0f/255.0f alpha:1.0f];
    [self addChild:lblLevel1];
    
    SKLabelNode *lblLevel2;
    lblLevel2 = [[SKLabelNode alloc] initWithFontNamed:@"Baskerville-BoldItalic"];
    lblLevel2.name = @"lblLevel2";
    lblLevel2.text = @"Sommer";
    lblLevel2.fontSize = 38;
    //restartLabel.scale = 0.5;
    lblLevel2.position = CGPointMake(self.frame.size.width/2, self.frame.size.height * 0.22);
    lblLevel2.fontColor = [SKColor colorWithRed:96.0f/255.0f green:155.0f/255.0f blue:227.0f/255.0f alpha:1.0f];
    [self addChild:lblLevel2];
    
    SKLabelNode *lblLevel3;
    lblLevel3 = [[SKLabelNode alloc] initWithFontNamed:@"Baskerville-BoldItalic"];
    lblLevel3.name = @"lblLevel3";
    lblLevel3.text = @"Herbst";
    lblLevel3.fontSize = 38;
    //restartLabel.scale = 0.5;
    lblLevel3.position = CGPointMake(self.frame.size.width/2, self.frame.size.height * 0.16);
    lblLevel3.fontColor = [SKColor colorWithRed:96.0f/255.0f green:155.0f/255.0f blue:227.0f/255.0f alpha:1.0f];
    [self addChild:lblLevel3];
   
    SKLabelNode *lblLevel4;
    lblLevel4 = [[SKLabelNode alloc] initWithFontNamed:@"Baskerville-BoldItalic"];
    lblLevel4.name = @"lblLevel4";
    lblLevel4.text = @"Winter";
    lblLevel4.fontSize = 38;
    //restartLabel.scale = 0.5;
    lblLevel4.position = CGPointMake(self.frame.size.width/2, self.frame.size.height * 0.10);
    lblLevel4.fontColor = [SKColor colorWithRed:96.0f/255.0f green:155.0f/255.0f blue:227.0f/255.0f alpha:1.0f];
    [self addChild:lblLevel4];


}


-(void)addBasket {
    _basket = [SKSpriteNode spriteNodeWithImageNamed:@"boxClosed.gif"];
    _basket.name = @"boxClosed";
    _basket.position = CGPointMake(self.frame.size.width-150,self.frame.size.height-140);
    [self addChild:_basket];
}


- (void)didMoveToView:(SKView *)view {
    UIPanGestureRecognizer *gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanFrom:)];
    [[self view] addGestureRecognizer:gestureRecognizer];
}

- (void)handlePanFrom:(UIPanGestureRecognizer *)recognizer {
	if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        CGPoint touchLocation = [recognizer locationInView:recognizer.view];
        
        touchLocation = [self convertPointFromView:touchLocation];
        
        [self selectNodeForTouch:touchLocation];
        
        
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        
        CGPoint translation = [recognizer translationInView:recognizer.view];
        translation = CGPointMake(translation.x, -translation.y);
        [self panForTranslation:translation];
        [recognizer setTranslation:CGPointZero inView:recognizer.view];
        
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        if (![[_selectedNode name] isEqualToString:kAnimalNodeName]) {
            //Damit auch nur der Hintergrund bewegt wird und keine NotMovable Sprites (z.B. Bäume etc.)
            if([[_selectedNode name] isEqualToString:@"background"]){
                float scrollDuration = 0.1;
                CGPoint velocity = [recognizer velocityInView:recognizer.view];
                CGPoint pos = [_selectedNode position];
                CGPoint p = mult(velocity, scrollDuration);
            
                CGPoint newPos = CGPointMake(pos.x + p.x, pos.y + p.y);
                newPos = [self boundLayerPos:newPos];
                [_selectedNode removeAllActions];
            
                SKAction *moveTo = [SKAction moveTo:newPos duration:scrollDuration];
                [moveTo setTimingMode:SKActionTimingEaseOut];
                [_selectedNode runAction:moveTo];
            } /*else {
                if (([[_selectedNode name] isEqualToString:@"NotMoveable"])) {
                    float scrollDuration = 0.4;
                    CGPoint velocity = [recognizer velocityInView:recognizer.view];
                    CGPoint pos = [_selectedNode position];
                    CGPoint p = mult(velocity, scrollDuration);
                    
                    CGPoint newPos = CGPointMake(pos.x + p.x, pos.y + p.y);
                    newPos = [self boundLayerPos:newPos];

                }
            }*/
        }
        
    }
}

- (void)panForTranslation:(CGPoint)translation {
    CGPoint position = [_selectedNode position];
    if([[_selectedNode name] isEqualToString:kAnimalNodeName]) {
        //Bewegt die Moveable Sprites
       /* if (((position.x + translation.x)>0) && ((position.y + translation.y)>_selectedNode.frame.size.height)) {
            if (((position.x + translation.x)<self.frame.size.width) && ((position.y + translation.y)<self.frame.size.height))*/
                [_selectedNode setPosition:CGPointMake(position.x + translation.x, position.y + translation.y)];
        //}
    } else {
        //Bewegt (nur) den Hintergrund
        
        if([[_selectedNode name] isEqualToString:@"background"]) {
            CGPoint newPos = CGPointMake(position.x + translation.x, position.y + translation.y);
            NSLog(@"Background");
            NSLog(@"X= %F",newPos.x);
            NSLog(@"Y= %F",newPos.y);
            [_background setPosition:[self boundLayerPos:newPos]];
            
            //NSLog(@"%f txpos=X", newPos.x);
        }  else {
            //Auswahl ist nicht der Hinter sondern ein NotMoveable Objekt. Position im Parent ermitteln und bewegen
            SKNode *parentNode = _selectedNode.parent;
            CGPoint position = [parentNode position];
            CGPoint newPos = CGPointMake(position.x + translation.x, position.y + translation.y);
            NSLog(@"NotMoveable");
            NSLog(@"X= %F",newPos.x);
            NSLog(@"Y= %F",newPos.y);
            [_background setPosition:[self boundLayerPos:newPos]];
        }
    }
}


- (void)selectNodeForTouch:(CGPoint)touchLocation {
    //1
    SKSpriteNode *touchedNode = (SKSpriteNode *)[self nodeAtPoint:touchLocation];
    
    //2
	if(![_selectedNode isEqual:touchedNode]) {
		//[_selectedNode removeAllActions];
		[_selectedNode runAction:[SKAction rotateToAngle:0.0f duration:0.1]];
        
		_selectedNode = touchedNode;
        //TODO: Es sollte die Möglichkeit bestehen, das sich das gefangene Häschen losreißt
		//3 -> Zappel-Animation
		if([[touchedNode name] isEqualToString:kAnimalNodeName]) {
			SKAction *sequence = [SKAction sequence:@[[SKAction rotateByAngle:degToRad(-16.0f) duration:0.1],
													  [SKAction rotateByAngle:0.0 duration:0.1],
													  [SKAction rotateByAngle:degToRad( 16.0f) duration:0.1]]];
			[_selectedNode runAction:[SKAction repeatActionForever:sequence]];
            
		}
	}
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  /*  UITouch *touch = [touches anyObject];
    CGPoint positionInScene = [touch locationInNode:self]; */
  //  NSLog(@"touchesBegan");
    
    for (UITouch *touch in touches) {
        SKNode *n = [self nodeAtPoint:[touch locationInNode:self]];
        //if (n != self && [n.name isEqual: @"restartLabel"]) {
        if (n != self && [n.name isEqual: @"titlescreen"]) {
            [self removeAllChildren];
            _level = 1;
            [self startGame];
            //return;
        }//
        
/*        if (n != self && [n.name isEqual: @"optionLabel"]) {
            [[self childNodeWithName:@"restartLabel"] removeFromParent];
            //[[self childNodeWithName:@"optionLabel"] removeFromParent];
            //[self addOptionMenu];
            return;
        } */

        if (n != self && [n.name isEqual: @"lblLevel1"]) {
            [self removeAllChildren];
            [self removeAllActions];
            _level = 1;
            [self startGame];
        }
        if (n != self && [n.name isEqual: @"lblLevel2"]) {
            _level = 2;
            [self removeAllChildren];
            [self removeAllActions];
            [self startGame];
        }
        if (n != self && [n.name isEqual: @"lblLevel3"]) {
            _level = 3;
            [self removeAllChildren];
            [self removeAllActions];
            [self startGame];
        }
        if (n != self && [n.name isEqual: @"lblLevel4"]) {
            _level = 4;
            [self removeAllChildren];
            [self removeAllActions];
            [self startGame];
        }
        //if (n != self && [n.name isEqual: @"goOnLabel"]) {
        if (n != self && [n.name isEqual: @"nextbutton"]) {
            _goOnClicked = TRUE;
            [self removeAllChildren];
            [self removeAllActions];
            [self startGame];
        }//
        //Schwierigkeitsgrad
   /*     if (n != self && [n.name isEqual: @"lblEasy"]) {
            _timeFrameToCatchRabbit = easyLevel;
            ((SKLabelNode*)n).fontColor = [SKColor redColor];
                    }
        if (n != self && [n.name isEqual: @"lblMedium"]) {
            _timeFrameToCatchRabbit = mediumLevel;
            ((SKLabelNode*)n).fontColor = [SKColor redColor];
        }
        if (n != self && [n.name isEqual: @"lblEasy"]) {
            _timeFrameToCatchRabbit = easyLevel;
            ((SKLabelNode*)n).fontColor = [SKColor redColor];
        }*/

    }

}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
    for (UITouch *touch in touches) {
        SKNode *n = [self nodeAtPoint:[touch locationInNode:self]];
        if (n != self && [n.name isEqual: kAnimalNodeName]) {
            _basket.texture = [SKTexture textureWithImageNamed:@"boxOpen.gif"];
            return;
        }
    }
    
    //NSLog(@"touchesMoved");
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
  //UITouch *touch = [touches anyObject];
  //CGPoint positionInScene = [touch locationInNode:self];
  //NSLog(@"touchesEnded");
   
    if ([_selectedNode.name isEqualToString:kAnimalNodeName]) {
    }
    
}

- (CGPoint)boundLayerPos:(CGPoint)newPos {
    CGSize winSize = self.size;
    CGPoint retval = newPos;
    retval.x = MIN(retval.x, 0);
    retval.x = MAX(retval.x, -[_background size].width+ winSize.width);
    retval.y = [self position].y;
    return retval;
}

-(void)changeRabbitCounter {
    _rabbitCounter++;
    //NSString *counterString = [NSString stringWithFormat:NSLocalizedString(@"rabbitConuter",nil), (long)_rabbitCounter];
    NSString *counterString = [NSString stringWithFormat:@"%ld", (long)_rabbitCounter];
    self.rabbitCounterLabel.text = counterString;
    
    
    //Alte Hasensymbole löschen???
    CGPoint point;
    NSInteger rx = 30;
    for (NSInteger i=0;i<_rabbitCounter;i++) {
        point = CGPointMake(self.frame.size.width-330,self.frame.size.height-70);
        SKSpriteNode *node = [self addSprite:point.x+rx Pos_y:point.y PicName:@"rabbitcounter.png" Moveable:false Pos_z:0];
        rx = rx+30;
        [self addChild:node];
    }
    
    //self.textNode.text = counterString;
}

CGPoint mult(const CGPoint v, const CGFloat s) {
	return CGPointMake(v.x*s, v.y*s);
}

float degToRad(float degree) {
	return degree / 180.0f * M_PI;
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    if([[_selectedNode name] isEqualToString:kAnimalNodeName]) {
        if ([_selectedNode intersectsNode:_basket]) {
            [_selectedNode removeFromParent];
            [self changeRabbitCounter];
            _basket.texture = [SKTexture textureWithImageNamed:@"boxClosed.gif"];
            _selectedNode = _background;
        } else {
            if (lastFrameStartTime==0) {
                //Hase befindet sich noch in Bewegung Richtung Korb...
                //_selectedNode.physicsBody.dynamic = YES;
                //_selectedNode.physicsBody.affectedByGravity = YES;
                lastFrameStartTime = currentTime;
                //_selectedNode.physicsBody.dynamic = YES;
                //[_selectedNode removeAllActions];
                if([[_selectedNode name] isEqualToString:kAnimalNodeName]) {
                    _lastPosSelectedNode = _selectedNode.position;
                }
            } else {
               float deltaTime = currentTime - lastFrameStartTime;
               if (deltaTime > easyLevel) {
                   //[_selectedNode removeAllActions];
                   lastFrameStartTime=0;
                   _selectedNode.physicsBody.dynamic = YES;
                   _selectedNode.physicsBody.affectedByGravity = YES;
                  // _selectedNode = _background;
                   _basket.texture = [SKTexture textureWithImageNamed:@"boxClosed.gif"];
                }
                

            }
            
        }
        
        if (_rabbitCounter == _rabbitToFound) {
            [self removeAllActions];
            for (NSInteger i=0;i<20;i++) {
              [self startBalloonAnimation];
            }
            [self waitScreen:NSLocalizedString(@"rabbitsCatched",nil) WaitDuration:5];
            [self addGoOnLabel];
            _level++;
            //return;
            if (_level == 5) {
                [self initEndTitleScreen];
            }
            if (_goOnClicked) {
                if (_level <= 4){
                    [self initGame];
                }
            }
        }

    }
   
}


-(void)startHeapAnimation:(NSString*) _image1Name Image2Name:(NSString*) _image2Name Landscape:(BOOL) _landscape{
    //not always come
    int GoOrNot = [self getRandomNumberBetween:0 to:1];
    
    if(GoOrNot == 1){
        
        SKSpriteNode *spriteNode;
        
        int randomImage = [self getRandomNumberBetween:0 to:1];
        if(randomImage == 0)
            spriteNode = [SKSpriteNode spriteNodeWithImageNamed:_image1Name];
        else
            spriteNode = [SKSpriteNode spriteNodeWithImageNamed:_image2Name];
        
        
        spriteNode.scale = 0.6;
        
        spriteNode.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        spriteNode.zPosition = 1;
        
        
        CGMutablePathRef cgpath = CGPathCreateMutable();
        
        //random values
        float xStart = [self getRandomNumberBetween:0+spriteNode.size.width to:self.frame.size.width-spriteNode.size.width ];
        float xEnd = [self getRandomNumberBetween:0+spriteNode.size.width to:self.frame.size.width-spriteNode.size.width ];
        
        //ControlPoint1
        float cp1X = [self getRandomNumberBetween:0+spriteNode.size.width to:self.frame.size.width-spriteNode.size.width ];
        float cp1Y = [self getRandomNumberBetween:0+spriteNode.size.width to:self.frame.size.width-spriteNode.size.height ];
        
        //ControlPoint2
        float cp2X = [self getRandomNumberBetween:0+spriteNode.size.width to:self.frame.size.width-spriteNode.size.width ];
        float cp2Y = [self getRandomNumberBetween:0 to:cp1Y];
        
        CGPoint s;
        CGPoint e;
        
        if(_landscape) {
            s = CGPointMake(1024.0, xStart);
            e = CGPointMake(-100.0, xEnd);
        } else {
            s = CGPointMake(xStart, 1024.0);
            e = CGPointMake(xEnd, -100.0);
        }
        
        CGPoint cp1 = CGPointMake(cp1X, cp1Y);
        CGPoint cp2 = CGPointMake(cp2X, cp2Y);
        CGPathMoveToPoint(cgpath,NULL, s.x, s.y);
        CGPathAddCurveToPoint(cgpath, NULL, cp1.x, cp1.y, cp2.x, cp2.y, e.x, e.y);
        
        SKAction *planeDestroy = [SKAction followPath:cgpath asOffset:NO orientToPath:YES duration:10];
        [self addChild:spriteNode];
        
        SKAction *remove = [SKAction removeFromParent];
        [spriteNode runAction:[SKAction sequence:@[planeDestroy,remove]]];
        
        CGPathRelease(cgpath);
        
    }
    
}

-(void)startBalloonAnimation {
    //not always come
//    int GoOrNot = [self getRandomNumberBetween:0 to:1];
    
//    if(GoOrNot == 1){
        
        SKSpriteNode *spriteNode;
        
        int randomImage = [self getRandomNumberBetween:1 to:6];
        if(randomImage == 1) {
            spriteNode = [SKSpriteNode spriteNodeWithImageNamed:@"balloon1.gif"];
        }
        if(randomImage == 2) {
            spriteNode = [SKSpriteNode spriteNodeWithImageNamed:@"balloon2.gif"];
        }
        if(randomImage == 3) {
            spriteNode = [SKSpriteNode spriteNodeWithImageNamed:@"balloon3.gif"];
        }
        if(randomImage == 4) {
            spriteNode = [SKSpriteNode spriteNodeWithImageNamed:@"balloon4.gif"];
        }
        if(randomImage == 5) {
            spriteNode = [SKSpriteNode spriteNodeWithImageNamed:@"balloon5.gif"];
        }
        if(randomImage == 6) {
            spriteNode = [SKSpriteNode spriteNodeWithImageNamed:@"balloon6.gif"];
        }

        
        
        spriteNode.scale = 0.6;
        
        spriteNode.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        spriteNode.zPosition = 1;
        
        
        CGMutablePathRef cgpath = CGPathCreateMutable();
        
        //random values
    //    float xStart = [self getRandomNumberBetween:0+spriteNode.size.width to:self.frame.size.width-spriteNode.size.width ];
    //    float xEnd = [self getRandomNumberBetween:0+spriteNode.size.width to:self.frame.size.width-spriteNode.size.width ];
        
        //ControlPoint1
        float cp1X = [self getRandomNumberBetween:0+spriteNode.size.width to:self.frame.size.width-spriteNode.size.width ];
        float cp1Y = [self getRandomNumberBetween:0+spriteNode.size.width to:self.frame.size.width-spriteNode.size.height ];
        
        //ControlPoint2
        float cp2X = [self getRandomNumberBetween:0+spriteNode.size.width to:self.frame.size.width-spriteNode.size.width ];
        float cp2Y = [self getRandomNumberBetween:0 to:cp1Y];
        
        CGPoint s;
        CGPoint e;
        s = CGPointMake(0,-100.0);//CGPointMake(xEnd,1024.0);
        e = CGPointMake(self.frame.size.height,self.frame.size.width);//CGPointMake(xStart,-100.0);
        
        CGPoint cp1 = CGPointMake(cp1X, cp1Y);
        CGPoint cp2 = CGPointMake(cp2X, cp2Y);
        CGPathMoveToPoint(cgpath,NULL, s.x, s.y);
        CGPathAddCurveToPoint(cgpath, NULL, cp1.x, cp1.y, cp2.x, cp2.y, e.x, e.y);
        
        SKAction *planeDestroy = [SKAction followPath:cgpath asOffset:NO orientToPath:YES duration:5];
        [self addChild:spriteNode];
        
        SKAction *remove = [SKAction removeFromParent];
        [spriteNode runAction:[SKAction sequence:@[planeDestroy,remove]]];
        
        CGPathRelease(cgpath);
        
//    }
    
}


@end

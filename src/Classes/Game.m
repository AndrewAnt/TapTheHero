//
//  Game.m
//  AppScaffold
//

#import "Game.h"

// --- private interface ---------------------------------------------------------------------------

@interface Game ()

- (void)setup;
- (void)onImageTouched:(SPTouchEvent *)event;
- (void)setString: (NSString *) aString;
- (void)onResize:(SPResizeEvent *)event;

@end


// --- class implementation ------------------------------------------------------------------------

@implementation Game
{
    SPSprite *_contents;
    NSTimer *timer;
    float globalTime;
    SPTextField *resultField;
    
}

- (id)init
{
    if ((self = [super init]))
    {
        [self setup];
    }
    return self;
}

- (void)dealloc
{
    // release any resources here
    [Media releaseAtlas];
    [Media releaseSound];
}

- (void)setup
{
    // This is where the code of your game will start. 
    // In this sample, we add just a few simple elements to get a feeling about how it's done.
    
    [SPAudioEngine start];  // starts up the sound engine
    
    
    // The Application contains a very handy "Media" class which loads your texture atlas
    // and all available sound files automatically. Extend this class as you need it --
    // that way, you will be able to access your textures and sounds throughout your 
    // application, without duplicating any resources.
    
    [Media initAtlas];      // loads your texture atlas -> see Media.h/Media.m
    [Media initSound];      // loads all your sounds    -> see Media.h/Media.m
    
    
    // Create some placeholder content: a background image, the Sparrow logo, and a text field.
    // The positions are updated when the device is rotated. To make that easy, we put all objects
    // in one sprite (_contents): it will simply be rotated to be upright when the device rotates.

    _contents = [SPSprite sprite];
    [self addChild:_contents];

    SPImage *background = [[SPImage alloc] initWithContentsOfFile:@"background.jpg"];
    [_contents addChild:background];
    
    SPButton *button = [SPButton buttonWithUpState:[SPTexture textureWithContentsOfFile:@"button_1.png"]];
    button.scaleX = button.scaleY = .25;
    button.pivotX = button.width * .5;
    button.pivotY = button.height * .5;
    button.x = background.width * .5;
    button.y = background.height - 50;
    [_contents addChild:button];
    
    NSString *gogogo = @"GO!";
    
    SPTextField *goField = [[SPTextField alloc] initWithText:gogogo];
    goField.fontSize = 46;
    goField.x = (button.width - goField.height) * .5;
    goField.y = (button.height - goField.height) * .5;
    [button addChild:goField];
    
    [button addEventListener:@selector(onButtonPress:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
    
    /*NSString *text = @"TAP\n"
                     @"the HERO";
    
    // If we need standart UI
    // UIView *view = Sparrow.currentController.view;
    
    
    
    SPTextField *textField = [[SPTextField alloc] initWithWidth:280 height:80 text:text];
    textField.x = (background.width - textField.width) / 2;
    textField.y = (background.height / 2) - 135;
    [_contents addChild:textField];*/

    SPImage *image = [[SPImage alloc] initWithTexture:[Media atlasTexture:@"sparrow"]];
    image.pivotX = (int)image.width  / 2;
    image.pivotY = (int)image.height / 2;
    image.x = background.width  / 2 + 60;
    image.y = background.height / 2 ;
    [_contents addChild:image];
    
    
    [self updateLocations];
    
    // play a sound when the image is touched
    [image addEventListener:@selector(onImageTouched:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
    
    // and animate it a little
    SPTween *tween = [SPTween tweenWithTarget:image time:1.5 transition:SP_TRANSITION_EASE_IN_OUT];
    [tween animateProperty:@"y" targetValue:image.y + 30];
    [tween animateProperty:@"rotation" targetValue:0.1];
    tween.repeatCount = 0; // repeat indefinitely
    tween.reverse = YES;
    [Sparrow.juggler addObject:tween];
    
    
    // The controller autorotates the game to all supported device orientations.
    // Choose the orienations you want to support in the Xcode Target Settings ("Summary"-tab).
    // To update the game content accordingly, listen to the "RESIZE" event; it is dispatched
    // to all game elements (just like an ENTER_FRAME event).
    // 
    // To force the game to start up in landscape, add the key "Initial Interface Orientation"
    // to the "App-Info.plist" file and choose any landscape orientation.
    
    [self addEventListener:@selector(onResize:) atObject:self forType:SP_EVENT_TYPE_RESIZE];
    
    // Per default, this project compiles as a universal application. To change that, enter the 
    // project info screen, and in the "Build"-tab, find the setting "Targeted device family".
    //
    // Now choose:  
    //   * iPhone      -> iPhone only App
    //   * iPad        -> iPad only App
    //   * iPhone/iPad -> Universal App  
    // 
    // Sparrow's minimum deployment target is iOS 5.
    
}

- (void)onButtonPress:(SPTouchEvent *)event
{
    [timer invalidate];
    
    NSLog(@"Result = %f", globalTime*1000);
    
    
    [self showResult];
    
    globalTime = 0.0;
}

-(void)onTick:(NSTimer *)timer {
    globalTime += 0.01;
    NSLog(@"Tick");
}

- (void)showResult
{
        
    if (globalTime != 0.0)
    {
        [_contents removeChild:resultField];
        
        NSString *result = [NSString stringWithFormat:@"%.1f", globalTime * 1000];
        
        resultField = [[SPTextField alloc] initWithText:result];
        
        resultField.x = (_contents.width  - resultField.width) *.5;
        resultField.y = _contents.height  / 2 + 30;
        resultField.color = 0x00a008;
        resultField.fontSize = 16;
        
        [_contents addChild:resultField];
    }
}

- (void)setString: (NSString *)aString
{
    //int roll = 1 + rand() % 10;
    
    NSString *startText = aString;
    
    //NSLog(@"Roll = %i", roll);
    
    SPTextField *startTextField = [[SPTextField alloc] initWithText:startText];
    startTextField.x = 130;
    startTextField.y = 60;
    startTextField.color = 0x50a048;
    
    [_contents addChild:startTextField];
}

-(void)startTimer
{
    timer = [NSTimer scheduledTimerWithTimeInterval: 0.01
                                             target: self
                                           selector: @selector(onTick:)
                                           userInfo: nil
                                            repeats: YES];
}

- (void)updateLocations
{
    int gameWidth  = Sparrow.stage.width;
    int gameHeight = Sparrow.stage.height;
    
    _contents.x = (int) (gameWidth  - _contents.width)  / 2;
    _contents.y = (int) (gameHeight - _contents.height) / 2;
}

- (void)onImageTouched:(SPTouchEvent *)event
{
    NSSet *touches = [event touchesWithTarget:self andPhase:SPTouchPhaseEnded];
    if ([touches anyObject]) [Media playSound:@"sound.caf"];
    if (touches.count == 1) [self startTimer];
    
    [self setString: @"START!"];
}

- (void)onResize:(SPResizeEvent *)event
{
    NSLog(@"new size: %.0fx%.0f (%@)", event.width, event.height, 
          event.isPortrait ? @"portrait" : @"landscape");
    
    [self updateLocations];
}

@end


//  ViewController.m
//  ImSadApp
//
//  Created by Inga on 3/23/16.
//  Copyright © 2016 Inga. All rights reserved.
//

#import "IMSIntroViewController.h"


@interface IMSIntroViewController ()

@property (nonatomic, strong) IMSDataStore *myDataStore;

@end


@implementation IMSIntroViewController



- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:YES];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        self.backgroundImageView.image = [UIImage imageNamed:@"01_Signup_bg.jpg"];
        [self.button setBackgroundImage:[UIImage imageNamed:@"01_Signup_cta_default.png"] forState:UIControlStateNormal];
        [self.button setBackgroundImage:[UIImage imageNamed:@"01_Signup_cta_highlighted.png"] forState:UIControlStateHighlighted];
        // text styling
        self.bodyCopy.textAlignment = NSTextAlignmentCenter;
        self.bodyCopy.font = [UIFont fontWithName:@"Lato-Regular" size:15];
        self.bodyCopy.textColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
        
        self.bodyCopy.hidden = YES;
        self.button.hidden = YES;
        self.buttonLabel.hidden = YES;

        [self setUpAVAudioPlayerWithFileName:@"button_tap"];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupOnBoardingState:) name:@"awsReturnedNoExistingUser" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupNoServerConnectionState:) name:@"awsReturnedErrorLookingForUser" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToHomeScreen:) name:@"awsReturnedNoThankyousForTheUser" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToGiftViewFromIntroVC:) name:@"cheerRecievedViaSNSAppClosed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToThankyouViewFromIntroVC:) name:@"thankyouRecievedViaSNSAppClosed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetUserSadness:) name:@"awsReturnedNoCurrentSadnessForExistingUser" object:nil];
    

    
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    NSLog(@"In viewDidLoad Intro VC");
    
    self.myDataStore = [IMSDataStore sharedDataStore];
    
    
    //[self checkInternetConnection];
    
    
    self.timer2 = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(setupConnectingState) userInfo:nil repeats:NO];
    

    
    
    if (self.myDataStore.receivedGiftSNSWhileAppWasClosed == NO) {
        [self checkForUserExistenceAndGiftsThankyous];
    }
    
    
    // determine phone's dimentions
    CGFloat screenScale = [[UIScreen mainScreen] scale];
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGSize screenSize = CGSizeMake(screenBounds.size.width * screenScale, screenBounds.size.height * screenScale);
    NSLog(@"screenSize.height: %f", screenSize.height); // 1136 on yellow 1334 on white yay!
    
    if (screenSize.height == 1136.000000) {
        NSLog(@"iPhone 5 View - IN INTRO VIEW - SAVED TO DATA STORE");
        self.myDataStore.isiPhone5 = YES;
        
    } else if (screenSize.height == 2208.000000) {
        NSLog(@"iPhone 6 PLUS View - IN INTRO VIEW - SAVED TO DATA STORE");
        self.myDataStore.isiPhone6Plus = YES;
        
    } else {
        NSLog(@"Not iPhone 5 View - IN INTRO VIEW");
    }

    
    [self setupCountries];
    
}


- (IBAction)buttonTapped:(UIButton *)sender {
    
    NSLog(@"button tapped");
    
    [self.audioPlayer play];
    
    if ([self.buttonLabel.text isEqualToString:@"Let's begin"]) {
        NSLog(@"In Let's begin button tapped");
        [self goToSelectGenderScreen];
    }
    
    if ([self.buttonLabel.text isEqualToString:@"Try again"]) {
        NSLog(@"In Try again button tapped");
        // run aws query method again
        [self setupConnectingState];
        [self checkForUserExistenceAndGiftsThankyous];
    }
    
}


- (void)goToSelectGenderScreen {
    
    __weak typeof(self) weakSelf = self;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    IMSSelectGenderViewController *nextView = [storyboard instantiateViewControllerWithIdentifier:@"selectGenderVC"];

    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [weakSelf.navigationController showViewController:nextView sender:self];
    }];
    
    self.faceAnimation = nil;
    
}


- (void)goToHomeScreen {
    
    __weak typeof(self) weakSelf = self;
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        IMSCheerSadViewController *cheersadVC = [storyboard instantiateViewControllerWithIdentifier:@"cheerSadVC"];
        [weakSelf.navigationController showViewController:cheersadVC sender:self];
    }];
    
}


- (void)goToInboxScreen {
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        __weak typeof(self) weakSelf = self;

        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        IMSCheerSadViewController *cheersadVC = [storyboard instantiateViewControllerWithIdentifier:@"cheerSadVC"];
        IMSGiftInboxViewController *inboxVC = [storyboard instantiateViewControllerWithIdentifier:@"inboxVC"];
        
        // Adding cheer/sad screen to navigation stack
        [weakSelf.navigationController pushViewController:cheersadVC animated:NO];
        
        // Go to Inbox
        [weakSelf.navigationController showViewController:inboxVC sender:self];
    }];
    
    //self.myDataStore.wentToInboxScreen = YES;
    
}


- (void)goToHomeScreen:(NSNotification *)notification {
    
    
    if (self.myDataStore.gifts.count == 0) {
        
        __weak typeof(self) weakSelf = self;
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            IMSCheerSadViewController *cheersadVC = [storyboard instantiateViewControllerWithIdentifier:@"cheerSadVC"];
            [weakSelf.navigationController showViewController:cheersadVC sender:self];
        }];

    }
    
    if (self.myDataStore.gifts.count > 0) {
        
        [self goToInboxScreen];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"awsReturnedNoThankyousForTheUser" object:nil];
 
}


- (void)goToGiftViewFromIntroVC:(NSNotification *)notification {
    NSLog(@"IN goToGiftViewFromIntroVC introVC");
    
    __weak typeof(self) weakSelf = self;
    
    [self downloadJSONFromAWSS3WithCompletion:^(NSData *myJsonData) {
        
        [self parseJsonWithData:myJsonData completion:^(BOOL success) {
            
            if (success) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    IMSGiftViewController *giftVC = [storyboard instantiateViewControllerWithIdentifier:@"giftVC"];
                    //UINavigationController *navigationController = (UINavigationController *)[UIApplication.sharedApplication.keyWindow rootViewController];
                    //[navigationController presentViewController:giftVC animated:YES completion:nil];
                    //[navigationController showViewController:giftVC sender:navigationController];
                    [weakSelf.navigationController presentViewController:giftVC animated:YES completion:nil];
                    
                    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
                    [center postNotificationName:@"vcInitiatedGiftViewForTheFirstTimeViaSNSForCheer" object:nil];
                }];
            }

        }];
        
    }];

    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"cheerRecievedViaSNS" object:nil];
    
}


- (void)goToThankyouViewFromIntroVC:(NSNotification *)notification {
    NSLog(@"IN goToThankyouViewFromIntroVC introVC");
    
    __weak typeof(self) weakSelf = self;
    
    [self downloadJSONFromAWSS3WithCompletion:^(NSData *myJsonData) {
        
        [self parseJsonWithData:myJsonData completion:^(BOOL success) {
            
            if (success) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    IMSGiftViewController *giftVC = [storyboard instantiateViewControllerWithIdentifier:@"giftVC"];
                    [weakSelf.navigationController presentViewController:giftVC animated:YES completion:nil];
                    
                    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
                    [center postNotificationName:@"vcInitiatedGiftViewForTheFirstTimeViaSNSForThankyou" object:nil];
                }];
            }
            
        }];
        
    }];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"thankyouRecievedViaSNSAppClosed" object:nil];
    
}


- (void)setupConnectingState {
    
    
    if (self.bodyCopy.hidden == YES && self.button.hidden == YES) {
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [UIView animateWithDuration:.6 animations:^{
                
                [self.faceAnimationView.layer removeAllAnimations];
                self.bodyCopy.hidden = YES;
                self.button.hidden = YES;
                self.buttonLabel.hidden = YES;
                self.connectingLabel.text = @"Connecting...";
                self.connectingLabel.hidden = NO;
                
                [self playConnectingAnimation];
                //self.timer2 = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(playConnectingAnimation) userInfo:nil repeats:NO];
            }];
        }];

    }
    
    
}


- (void)setupOnBoardingState:(NSNotification *)notification {
    
    NSLog(@"In setupOnBoardingState");
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        [UIView animateWithDuration:.25 animations:^{
            [self.faceAnimationView.layer removeAllAnimations];
            self.buttonLabel.text = @"Let's begin";
            self.connectingLabel.hidden = YES;
            self.bodyCopy.hidden = NO;
            self.button.hidden = NO;
            self.buttonLabel.hidden = NO;
        }];
        
//        self.timer3 = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(playSuccessfullyConnectedAnimation) userInfo:nil repeats:NO];
        
        [self playSuccessfullyConnectedAnimation];
    }];
    
    
    
    [self downloadJSONFromAWSS3WithCompletion:^(NSData *myJsonData) {
        [self parseJsonWithData:myJsonData completion:^(BOOL success) {
            NSLog(@"SUCCESSFULLY PARSED JSON");
        }];
    }];

}


- (void)setupNoServerConnectionState:(NSNotification *)notification {
    
    NSLog(@"In setupNoServerConnectionState");
    NSLog(@"checkIfConnectedToAnything in setupNoServerConnectionState");
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [UIView animateWithDuration:.25 animations:^{
            [self.faceAnimationView.layer removeAllAnimations];
            //self.faceAnimationView.image = [UIImage imageNamed:@"01_01_animation_intro_page.png"];
            
            self.connectingLabel.hidden = NO;
            self.bodyCopy.hidden = YES;
            self.button.hidden = NO;
            self.buttonLabel.hidden = NO;
            self.connectingLabel.text = @"Unable to connect to server!";
            self.buttonLabel.text = @"Try again";
            
            self.timer3 = [NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(playNoConnectionAnimation) userInfo:nil repeats:NO];
        }];
    }];

}


- (void)setUpAVAudioPlayerWithFileName:(NSString *)fileName {

    NSURL *url = [[NSBundle mainBundle] URLForResource:fileName withExtension:@"mp3"];
    NSError *error = nil;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    if (!self.audioPlayer)
    {
        NSLog(@"Error in audioPlayer: %@", [error localizedDescription]);
    } else {
        [self.audioPlayer prepareToPlay];
    }
    
}


- (void)playConnectingAnimation {
    
    NSArray *animationImages = @[@"01_01_animation_connecting.png",
                                 @"01_02_animation_connecting.png",
                                 @"01_03_animation_connecting.png",
                                 @"01_04_animation_connecting.png",
                                 @"01_05_animation_connecting.png",
                                 @"01_06_animation_connecting.png",
                                 @"01_07_animation_connecting.png",
                                 @"01_08_animation_connecting.png",
                                 @"01_09_animation_connecting.png",
                                 @"01_10_animation_connecting.png",
                                 @"01_11_animation_connecting.png",
                                 @"01_12_animation_connecting.png",
                                 @"01_13_animation_connecting.png",
                                 @"01_14_animation_connecting.png",
                                 @"01_15_animation_connecting.png"];
    
    NSMutableArray *images = [[NSMutableArray alloc] init];
    NSInteger animationImageCount = animationImages.count;
    for (int i = 0; i < animationImages.count; i++) {
        [images addObject:(id)[UIImage imageNamed:[animationImages objectAtIndex:i]].CGImage];
    }
    
    self.faceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
    self.faceAnimation.delegate = self;
    self.faceAnimation.calculationMode = kCAAnimationDiscrete;
    self.faceAnimation.duration = animationImageCount / 33.0; // 24 frames per second
    self.faceAnimation.values = images;
    self.faceAnimation.repeatCount = HUGE_VALF;  //  HUGE_VALF; // loops
    self.faceAnimation.removedOnCompletion = NO;
    self.faceAnimation.fillMode = kCAFillModeForwards;
    [self.faceAnimationView.layer addAnimation:self.faceAnimation forKey:@"animation"];
    
}


- (void)playNoConnectionAnimation {
    
    NSArray *animationImages = @[@"01_01_animation_no_connection.png",
                                 @"01_02_animation_no_connection.png",
                                 @"01_03_animation_no_connection.png",
                                 @"01_04_animation_no_connection.png",
                                 @"01_05_animation_no_connection.png",
                                 @"01_06_animation_no_connection.png",
                                 @"01_07_animation_no_connection.png",
                                 @"01_08_animation_no_connection.png",
                                 @"01_09_animation_no_connection.png",
                                 @"01_10_animation_no_connection.png",
                                 @"01_11_animation_no_connection.png",
                                 @"01_12_animation_no_connection.png",
                                 @"01_13_animation_no_connection.png",
                                 @"01_14_animation_no_connection.png",
                                 @"01_15_animation_no_connection.png",
                                 @"01_16_animation_no_connection.png",
                                 @"01_17_animation_no_connection.png",
                                 @"01_18_animation_no_connection.png"];
    
    NSMutableArray *images = [[NSMutableArray alloc] init];
    NSInteger animationImageCount = animationImages.count;
    for (int i = 0; i < animationImages.count; i++) {
        [images addObject:(id)[UIImage imageNamed:[animationImages objectAtIndex:i]].CGImage];
    }
    
    self.faceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
    self.faceAnimation.delegate = self;
    self.faceAnimation.calculationMode = kCAAnimationDiscrete;
    self.faceAnimation.duration = animationImageCount / 40.0; // 24 frames per second
    self.faceAnimation.values = images;
    self.faceAnimation.repeatCount = 1;  //  HUGE_VALF; // loops
    self.faceAnimation.removedOnCompletion = NO;
    self.faceAnimation.fillMode = kCAFillModeForwards;
    [self.faceAnimationView.layer addAnimation:self.faceAnimation forKey:@"animation"];
    
}


- (void)playSuccessfullyConnectedAnimation {
    
    NSArray *animationImages = @[@"01_01_animation_connected.png",
                                 @"01_02_animation_connected.png",
                                 @"01_03_animation_connected.png",
                                 @"01_04_animation_connected.png",
                                 @"01_05_animation_connected.png",
                                 @"01_06_animation_connected.png",
                                 @"01_07_animation_connected.png",
                                 @"01_08_animation_connected.png",
                                 @"01_09_animation_connected.png",
                                 @"01_10_animation_connected.png",
                                 @"01_11_animation_connected.png",
                                 @"01_12_animation_connected.png",
                                 @"01_13_animation_connected.png",
                                 @"01_14_animation_connected.png",
                                 @"01_15_animation_connected.png",
                                 @"01_16_animation_connected.png"];
    
    NSMutableArray *images = [[NSMutableArray alloc] init];
    NSInteger animationImageCount = animationImages.count;
    for (int i = 0; i < animationImages.count; i++) {
        [images addObject:(id)[UIImage imageNamed:[animationImages objectAtIndex:i]].CGImage];
    }
    
    self.faceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
    self.faceAnimation.delegate = self;
    self.faceAnimation.calculationMode = kCAAnimationDiscrete;
    self.faceAnimation.duration = animationImageCount / 24.0; // 24 frames per second
    self.faceAnimation.values = images;
    self.faceAnimation.repeatCount = 1;  //  HUGE_VALF; // loops
    self.faceAnimation.removedOnCompletion = NO;
    self.faceAnimation.fillMode = kCAFillModeForwards;
    [self.faceAnimationView.layer addAnimation:self.faceAnimation forKey:@"animation"];
    
}


- (void)downloadJSONFromAWSS3WithCompletion:(void (^)(NSData *myJsonData))completionBlock {
    
    // Create the S3 TransferManager Client.
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    
    // Create Documents directory for saving unzipped contents:
    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *savingFilePath = [documentsDirectory stringByAppendingPathComponent:@"s3randomGiftFile"];
    NSURL *savingFilePathURL = [NSURL fileURLWithPath:savingFilePath];
    
    // Construct the download request.
    AWSS3TransferManagerDownloadRequest *downloadRequest = [AWSS3TransferManagerDownloadRequest new];
    downloadRequest.bucket = @"pec-imsad-0000";
    downloadRequest.key = @"gifts.json";
    downloadRequest.downloadingFileURL = savingFilePathURL;
    
    [[transferManager download:downloadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id _Nullable(AWSTask * _Nonnull task) {
        
        NSLog(@"➡️ AWSS3 NETWORK CALL: S3 downloadRequest for json file");
        
        if (task.error){
            if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                switch (task.error.code) {
                    case AWSS3TransferManagerErrorCancelled:
                    case AWSS3TransferManagerErrorPaused:
                        break;
                        
                    default:
                        NSLog(@"❌ AWSS3 TASK ERROR: %@", task.error);
                        break;
                }
            } else {
                // Unknown error.
                NSLog(@"❌ AWSS3 TASK ERROR UNKNOWN: %@", task.error);
            }
        }
        
        if (task.result) {
            NSLog(@"✅ S3 JSON File downloaded successfully!");
            
            NSData *myJsonData = [NSData dataWithContentsOfFile:savingFilePath];
            
            completionBlock(myJsonData);
        }
        
        
        return nil;
        
    }];
    
    
}


- (void)parseJsonWithData:(NSData *)data completion:(void (^)(BOOL success))completionBlock {
    
    NSError *error;
    NSArray *myJson = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    //NSLog(@"my json array: %@", myJson);
    
    
    NSDictionary *productIdDict = [[NSDictionary alloc] init];
    productIdDict = myJson[0];
    
    // get apple product ID from json
    NSArray *jsonProductIds = [productIdDict allValues];
    self.myDataStore.jsonProductIds = [jsonProductIds mutableCopy];
    NSLog(@"json product IDs: %@", self.myDataStore.jsonProductIds);
    
    [self validateProductIdentifiers:self.myDataStore.jsonProductIds];
    
    
    
    NSDictionary *sadnessIdDict = [[NSDictionary alloc] init];
    sadnessIdDict = myJson[1];
    
    // get developer sadness ID from json
    NSString *mySadnessID = [sadnessIdDict objectForKey:@"sadnessID"];
    self.myDataStore.developerSadnessID = mySadnessID;
    NSLog(@"json self.myDataStore.developerSadnessID: %@", self.myDataStore.developerSadnessID);
    
    NSUInteger mapRefreshRateSec = [[sadnessIdDict objectForKey:@"mapRefreshRateSec"] integerValue];
    self.myDataStore.mapRefreshRateSec = mapRefreshRateSec;
    NSLog(@"json self.myDataStore.mapRefreshRateSec: %lu", (unsigned long)mapRefreshRateSec);
    
    self.myDataStore.cheeredPeopleCount = [[sadnessIdDict objectForKey:@"maxNumberOfPeopleToSave"] integerValue];
    NSLog(@"json self.myDataStore.cheeredPeopleCount: %lu", (unsigned long)self.myDataStore.cheeredPeopleCount);
    
    self.myDataStore.peopleTimerInterval = [[sadnessIdDict objectForKey:@"howLongToSaveMorePeopleInSec"] integerValue];
    NSLog(@"json self.myDataStore.peopleTimerInterval: %lu", (unsigned long)self.myDataStore.peopleTimerInterval);
    
    
    // adjusting the math for the send gift view conter
    if ((self.myDataStore.numberOfPeopleCheered > 0) &&   // comes from the server
        (self.myDataStore.numberOfPeopleCheered < self.myDataStore.cheeredPeopleCount)) { // fail safe. cheeredPeopleCount comes from json
        
        self.myDataStore.cheeredPeopleCount = self.myDataStore.cheeredPeopleCount - self.myDataStore.numberOfPeopleCheered;
    }
    
    
    self.myDataStore.mapClusterBucketSize = [[sadnessIdDict objectForKey:@"mapClusterBucketSize"] integerValue];
    NSLog(@"json self.myDataStore.mapClusterBucketSize: %lu", (unsigned long)self.myDataStore.mapClusterBucketSize);
    
    
    
    
    NSDictionary *setDict = [[NSDictionary alloc] init];
    setDict = myJson[2];
    
    // make an array of this week's sets
    NSArray *jsonThisWeeksSets = [setDict allValues];
    self.myDataStore.jsonThisWeeksSets = [jsonThisWeeksSets mutableCopy];
    NSLog(@"json sets: %@", self.myDataStore.jsonThisWeeksSets);
    
    
    
    // remove the opposite gender from self.myDataStore.jsonThisWeeksSets
    NSString *oppositeToUserGender = [[NSString alloc] init];
    
    if (self.myDataStore.existingUser.gender != nil) {
        if ([self.myDataStore.existingUser.gender isEqualToString:@"girl"]) {
            oppositeToUserGender = @"boy";
        }
        if ([self.myDataStore.existingUser.gender isEqualToString:@"boy"]) {
            oppositeToUserGender = @"girl";
        }
    }
    
    if (self.myDataStore.gender != nil) {
        if ([self.myDataStore.gender isEqualToString:@"girl"]) {
            oppositeToUserGender = @"boy";
        }
        if ([self.myDataStore.gender isEqualToString:@"boy"]) {
            oppositeToUserGender = @"girl";
        }
        
    }
    
    NSMutableArray *jsonThisWeeksSetsWithRemovedOppositeGender = [self.myDataStore.jsonThisWeeksSets mutableCopy];
    NSString *setNameContainingUserGender = [[NSString alloc] init];
    
    for (NSString *setName in self.myDataStore.jsonThisWeeksSets) {
        if ([setName containsString:oppositeToUserGender]) {
            setNameContainingUserGender = setName;
        }
        [jsonThisWeeksSetsWithRemovedOppositeGender removeObject:setNameContainingUserGender];
    }
    
    self.myDataStore.jsonThisWeeksSets = jsonThisWeeksSetsWithRemovedOppositeGender;
    NSLog(@"json sets with removed opposite gender: %@", self.myDataStore.jsonThisWeeksSets);
    
    
    
    
    NSDictionary *allGiftsDict = [[NSDictionary alloc] init];
    allGiftsDict = myJson[3];
    
    
    // saving ALL gifts to data store
    // i need this for thankyous that have been sitting in inbox for couple of weeks while we updated them
    // pull out json dictionaries with gift data
    NSMutableArray *jsonAllGifts = [[NSMutableArray alloc] init];
    
    NSArray *allGiftsArrays = [allGiftsDict allValues];
    for (NSArray *allGiftsArray in allGiftsArrays) {
        for (NSDictionary *aGiftDict in allGiftsArray) {
            [jsonAllGifts addObject:aGiftDict];
        }
    }
    //NSLog(@"json all gifts: %@", jsonAllGifts);
    
    
    // make IMSGift objects from those json dictionaries
    // and save them to data store
    for (NSDictionary *GiftDict in jsonAllGifts) {
        
        @autoreleasepool {
            
            IMSGift *aGift = [[IMSGift alloc] init];
            aGift.bucketName = GiftDict[@"bucketName"];
            aGift.zipName = GiftDict[@"zipName"];
            
            CGFloat animationSpeedFloat = [GiftDict[@"animationSpeed"] floatValue];
            aGift.animationSpeed = animationSpeedFloat;
            //NSLog(@"JSON ANIMATION SPEED: %.3f", aGift.animationSpeed);
            
            aGift.loopFrameNumber = [GiftDict[@"loopFrameNumber"] integerValue];
            //NSLog(@"JSON ANIMATION LOOP FRAME NUMBER: %lu", aGift.loopFrameNumber);
            
            
            CGFloat loopAnimationSpeedFloat = [GiftDict[@"loopAnimationSpeed"] floatValue];
            aGift.loopAnimationSpeed = loopAnimationSpeedFloat;
            //NSLog(@"JSON LOOP ANIMATION SPEED: %.3f", aGift.loopAnimationSpeed);
            
            NSDictionary *musicDict = GiftDict[@"music"];
            aGift.musicFileNames = [musicDict allValues];
            
            NSDictionary *bgDict = GiftDict[@"backgrounds"];
            aGift.backgroundFileNames = [bgDict allValues];
            
            
            // adding gift objects to data store
            [self.myDataStore.jsonAllGifts addObject:aGift];

        }
        
    }
    NSLog(@"JSON parsed %lu Gifts in self.myDataStore.jsonAllGifts", self.myDataStore.jsonAllGifts.count);
    
    
    
    
    // pulling out gifts appropriate for the user
    NSMutableArray *thisWeeksGifts = [[NSMutableArray alloc] init]; // array of dictionaries
    
    // pull all gift objects from those 2 sets into 1 array
    for (NSString *setName in self.myDataStore.jsonThisWeeksSets) {
        NSArray *inseption = allGiftsDict[setName];
        for (NSDictionary *gift in inseption) {
            [thisWeeksGifts addObject:gift];
        }
    }
    NSLog(@"thisWeeksGifts for the user count: %lu", thisWeeksGifts.count);
    
    
    
    // check last gift the user got
    // and remove it from self.myDataStore.jsonGifts
    if (self.myDataStore.existingUser.latestGiftName != nil) {
        
        NSDictionary *giftToRemove = [[NSDictionary alloc] init];
        
        // decoding gift name
        NSData *decodedDataZipName = [[NSData alloc] initWithBase64EncodedString:self.myDataStore.existingUser.latestGiftName options:0];
        NSString *decodedStringZipName = [[NSString alloc] initWithData:decodedDataZipName encoding:NSUTF8StringEncoding];
        NSLog(@"DECODED LAST SEEN GIFT NAME NAME: %@", decodedStringZipName);
        
        
        for (NSDictionary *giftDict in thisWeeksGifts) {
            NSString *zipName = giftDict[@"zipName"];
            if ([zipName isEqualToString:decodedStringZipName]) {
                NSLog(@"LAST GIFT NAME EXISTS");
                giftToRemove = giftDict;
            }
        }
        [thisWeeksGifts removeObject:giftToRemove];
        NSLog(@"%lu json selected gifts with the last seen removed", thisWeeksGifts.count);
    
        
        
        // add last removed gift to datastore. convert it from dictionary to IMSGift
        // to put it back in rotation throughout the app's cycle
        IMSGift *removedGift = [[IMSGift alloc] init];
        removedGift.bucketName = giftToRemove[@"bucketName"];
        removedGift.zipName = giftToRemove[@"zipName"];
        
        NSUInteger animationSpeedNSUInt = [giftToRemove[@"animationSpeed"] integerValue];
        NSNumber *animationSpeedNumb = [NSNumber numberWithUnsignedInteger:animationSpeedNSUInt];
        CGFloat animationSpeedFloat = [animationSpeedNumb floatValue];
        removedGift.animationSpeed = animationSpeedFloat;
        //NSLog(@"JSON ANIMATION SPEED: %.2f", aGift.animationSpeed);
        
        removedGift.loopFrameNumber = [giftToRemove[@"loopFrameNumber"] integerValue];
        //NSLog(@"JSON GIFT LOOP FRAME NUMBER: %lu", aGift.loopFrameNumber);
        
        
        NSUInteger loopAnimationSpeedNSUInt = [giftToRemove[@"loopAnimationSpeed"] integerValue];
        NSNumber *loopAnimationSpeedNumb = [NSNumber numberWithUnsignedInteger:loopAnimationSpeedNSUInt];
        CGFloat loopAnimationSpeedFloat = [loopAnimationSpeedNumb floatValue];
        removedGift.loopAnimationSpeed = loopAnimationSpeedFloat;
        //NSLog(@"JSON LOOP ANIMATION SPEED: %.2f", aGift.loopAnimationSpeed);
        
        NSDictionary *musicDict = giftToRemove[@"music"];
        removedGift.musicFileNames = [musicDict allValues];
        
        NSDictionary *bgDict = giftToRemove[@"backgrounds"];
        removedGift.backgroundFileNames = [bgDict allValues];
        
        
        // Saving gift objects to data store
        self.myDataStore.lastRemovedGift = removedGift;
        
    }
    
    // make gift objects from thisWeeksGifts
    // and store them in data store for later to randomly iterate over for a 'cheer'
    for (NSDictionary *GiftDict in thisWeeksGifts) {
        
        @autoreleasepool {
            
            IMSGift *aGift = [[IMSGift alloc] init];
            aGift.bucketName = GiftDict[@"bucketName"];
            aGift.zipName = GiftDict[@"zipName"];
            
            CGFloat animationSpeedFloat = [GiftDict[@"animationSpeed"] floatValue];
            aGift.animationSpeed = animationSpeedFloat;
            //NSLog(@"2. JSON ANIMATION SPEED: %.3f", aGift.animationSpeed);
            
            aGift.loopFrameNumber = [GiftDict[@"loopFrameNumber"] integerValue];
            //NSLog(@"2. JSON GIFT LOOP FRAME NUMBER: %lu", aGift.loopFrameNumber);
            
            CGFloat loopAnimationSpeedFloat = [GiftDict[@"loopAnimationSpeed"] floatValue];
            aGift.loopAnimationSpeed = loopAnimationSpeedFloat;
            //NSLog(@"2. JSON LOOP ANIMATION SPEED: %.3f", aGift.loopAnimationSpeed);
            
            NSDictionary *musicDict = GiftDict[@"music"];
            aGift.musicFileNames = [musicDict allValues];
            
            NSDictionary *bgDict = GiftDict[@"backgrounds"];
            aGift.backgroundFileNames = [bgDict allValues];
            
            
            // adding gift objects to data store
            [self.myDataStore.jsonGiftsForUser addObject:aGift];
        }
    }
    
    NSLog(@"%lu GIFTS READY FOR 'CHEER' PICKING", self.myDataStore.jsonGiftsForUser.count);

    
    // block's gets deallocated if i put nil in the method
    if (thisWeeksGifts.count == self.myDataStore.jsonGiftsForUser.count) {
        completionBlock(YES);
    }
    
}


- (void)validateProductIdentifiers:(NSArray *)productIdentifiers {
    
    SKProductsRequest *productsRequest = [[SKProductsRequest alloc]
                                          initWithProductIdentifiers:[NSSet setWithArray:productIdentifiers]];
    
    // Keep a strong reference to the request.
    self.productRequest = productsRequest;
    productsRequest.delegate = self;
    [productsRequest start];
    
}


// SKProductsRequestDelegate protocol method
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    
    self.products = response.products;
    NSLog(@"APPLE RESPONSE, %lu PRODUCTS: %@", self.products.count, self.products);
    
    // Apple didn't return my product once!!
    if (self.products.count > 0) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            self.myDataStore.autoRenewSubscription = self.products[0];
            NSLog(@"MY PRODUCT IN DATA STORE: %@", self.myDataStore.autoRenewSubscription);
        }];
    }
    
    NSLog(@"APPLE RESPONSE, %lu INVALID PRODUCT IDENTIFYERS: %@", (unsigned long)response.invalidProductIdentifiers.count, response.invalidProductIdentifiers);
    
    
    if (response.invalidProductIdentifiers.count > 0) {

        for (NSString *invalidIdentifier in response.invalidProductIdentifiers) {
            NSLog(@"INVALID PRODUCT IDENTIFIER NAME: %@", invalidIdentifier);
        }
        
        // For turning off the go-ad-free button
        self.myDataStore.subscriptionProductIDIsInvalid = YES;
    }
    
}


- (void)checkInternetConnection {
    
    // check connection to a very small, fast loading site:
    NSURL *scriptUrl = [NSURL URLWithString:@"https://aws.amazon.com/contact-us"];
    
    @autoreleasepool {
        NSData *data = [NSData dataWithContentsOfURL:scriptUrl];
        if (data) {
            NSLog(@" Device is connected to the internet");
            [self setupConnectingState];
            
        } else {
            NSLog(@" Device is not connected to the internet");
        }
    }
    
}


- (void)checkForUserExistenceAndGiftsThankyous {
    
    
    [self checkIfUserExistsWithCompletion:^(NSString *userGender, BOOL success) {
        
        if (success) {
            
            // Downloading and parsing the JSON file
            [self downloadJSONFromAWSS3WithCompletion:^(NSData *myJsonData) {
                [self parseJsonWithData:myJsonData completion:^(BOOL success) {
                    if (success) {
                        NSLog(@"SUCCESSFULLY PARSED JSON");
                    }
                }];
            }];
            
            
            
            // Query Cheer table for all attributes
            
            AWSDynamoDBQueryExpression *queryExpression = [AWSDynamoDBQueryExpression new];
            AWSDynamoDBObjectMapper *objectMapperGifts = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
            
            queryExpression.indexName = @"sadnessID-cheerRead-index"; // local secondary index
            
            queryExpression.keyConditionExpression = @"sadnessID = :partitionkeyval and cheerRead = :sortkeyval";
            
            NSDictionary *DictionaryAttributes = @{ @":partitionkeyval" : self.myDataStore.userID,
                                                    @":sortkeyval" : @"no" };
            
            queryExpression.expressionAttributeValues = DictionaryAttributes;
            queryExpression.scanIndexForward = @NO; // for items to come in newest to oldest
            queryExpression.projectionExpression = @"sadnessID, createdAtSec, createdAt, fromCity, fromCountry, toCity, toCountry, toGender, toCheer, toSadness, cheererID";
            
            [[objectMapperGifts query:[IMSCheer class] expression:queryExpression] continueWithBlock:^id(AWSTask *task) {
                NSLog(@"➡️ AWSSNS NETWORK CALL: query LSI cheer");
                
                if (task.error) {
                    NSLog(@"❌ The request failed. Error: [%@]", task.error);
                }
                if (task.exception) {
                    NSLog(@"❌ The request failed. Exception: [%@]", task.exception);
                }
                if (task.result) {
                    
                    AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
                    if (paginatedOutput.items.count > 0) {
                        NSLog(@"✅ CHEER TABLE LSI QUERY RETURNED %lu ITEMS", paginatedOutput.items.count);
                        
                        self.myDataStore.gifts = [paginatedOutput.items mutableCopy]; // only need the newest cheer
                        self.myDataStore.giftsCount = 1; // can only be one gift waiting at a time
                        self.myDataStore.inboxCount = self.myDataStore.giftsCount;
                        
                        
                        // Query Thank you table
                        
                        [DDBDynamoDBManager queryDynamoDBThankyouTableLSIForAllAttributesWithUserID:self.myDataStore.userID completion:^(NSArray *thankyous, NSError *error) {
                            
                            if (thankyous) {
                                
                                // Sorting thank yous for the inbox
                                NSArray *sortedThankyous = [thankyous sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                                    NSUInteger createdAt1 = ((IMSThankyou *)obj1).createdAtSec;
                                    NSUInteger createdAt2 = ((IMSThankyou *)obj2).createdAtSec;
                                    
                                    NSUInteger minutesBetweenDates1 = [self getMinutesBetweenOriginalTimeAndNow:createdAt1];
                                    NSUInteger minutesBetweenDates2 = [self getMinutesBetweenOriginalTimeAndNow:createdAt2];
                                    
                                    if (minutesBetweenDates1 < minutesBetweenDates2) {
                                        return NSOrderedAscending;
                                    } else {
                                        return NSOrderedDescending;
                                    }
                                }];
                                
                                for (IMSThankyou *aThankyou in sortedThankyous) {
                                    NSLog(@"sortedThankyous, aThankyou.cheerCreatedAt: %@", aThankyou.cheerCreatedAt);
                                }
                                
                                self.myDataStore.thankyous = [sortedThankyous mutableCopy];
                                self.myDataStore.inboxCount = self.myDataStore.inboxCount + thankyous.count;
                                [self goToInboxScreen];
                                
                            } else {
                                [self goToInboxScreen];
                            }
                        }];
                        
                        
                    } else {
                        NSLog(@"❗️ CHEER TABLE LSI QUERY RETURNED NO ITEMS");
                        
                        // Query Thank you table

                        [DDBDynamoDBManager queryDynamoDBThankyouTableLSIForAllAttributesWithUserID:self.myDataStore.userID completion:^(NSArray *thankyous, NSError *error) {
                            
                            if (thankyous) {
                                
                                // Sorting thank yous for the inbox
                                NSArray *sortedThankyous = [thankyous sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                                    NSUInteger createdAt1 = ((IMSThankyou *)obj1).createdAtSec;
                                    NSUInteger createdAt2 = ((IMSThankyou *)obj2).createdAtSec;
                                    
                                    NSUInteger minutesBetweenDates1 = [self getMinutesBetweenOriginalTimeAndNow:createdAt1];
                                    NSUInteger minutesBetweenDates2 = [self getMinutesBetweenOriginalTimeAndNow:createdAt2];
                                    
                                    if (minutesBetweenDates1 < minutesBetweenDates2) {
                                        return NSOrderedAscending;
                                    } else {
                                        return NSOrderedDescending;
                                    }
                                }];
                                
                                for (IMSThankyou *aThankyou in sortedThankyous) {
                                    NSLog(@"sortedThankyous, aThankyou.cheerCreatedAt: %@", aThankyou.cheerCreatedAt);
                                }
                                
                                self.myDataStore.thankyous = [sortedThankyous mutableCopy];
                                self.myDataStore.thankyousCount = thankyous.count;
                                self.myDataStore.inboxCount = self.myDataStore.inboxCount + thankyous.count;
                                [self goToInboxScreen];
                            }
                        }];
                    }
                    
                }
                return nil;
            }];
            
                 
        }
        
        
    }];
    
    
}


- (void)checkIfUserExistsWithCompletion:(void (^)(NSString *userGender, BOOL success))completionBlock {
    
    // getting ad tracker ID
    NSString *stringFromUUID = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    NSLog(@"🔵 UUID STRING: %@", [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString]);
    
    // encode the tracker to get the user id
    NSString *userID = [[[NSString stringWithFormat:@"%@", stringFromUUID] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
    
    
    // query user with the user id
    [DDBDynamoDBManager queryDynamoDBUserTableWithUserID:userID completion:^(NSArray *users, NSError *error) {
        
        if (users.count > 0) {
            // user exists
            // save user in data store
            self.myDataStore.existingUser = [users objectAtIndex:0];
            self.myDataStore.userID = self.myDataStore.existingUser.userID;
            self.myDataStore.gender = self.myDataStore.existingUser.gender;
            self.myDataStore.type = self.myDataStore.existingUser.type;
            self.myDataStore.latestGiftName = self.myDataStore.existingUser.latestGiftName;
            self.myDataStore.latestSadnessAnnouncedAtSec = self.myDataStore.existingUser.latestSadnessAnnouncedAtSec;
            self.myDataStore.latestCheeredAtSec = self.myDataStore.existingUser.latestCheeredAtSec;
            self.myDataStore.numberOfShares = self.myDataStore.existingUser.numberOfShares;
            self.myDataStore.isSadNow = self.myDataStore.existingUser.isSadNow;
            if (self.myDataStore.existingUser.fromCity != nil) {
                self.myDataStore.fromCity = self.myDataStore.existingUser.fromCity;
            }
            if (self.myDataStore.existingUser.fromCountry != nil) {
                self.myDataStore.fromCountry = self.myDataStore.existingUser.fromCountry;
            }
            if (self.myDataStore.existingUser.latestPeopleTimerStartedAtSec != 0) {
                self.myDataStore.latestPeopleTimerStartedAtSec = self.myDataStore.existingUser.latestPeopleTimerStartedAtSec;
            }
            if (self.myDataStore.existingUser.numberOfPeopleCheered != 0) {
                self.myDataStore.numberOfPeopleCheered = self.myDataStore.existingUser.numberOfPeopleCheered;
            }
            if (self.myDataStore.existingUser != nil) {
                completionBlock(self.myDataStore.existingUser.gender, YES);
            }
            
            NSLog(@"🔵 INTRO VC. EXISTING USER TYPE: %@, userID: %@", self.myDataStore.existingUser.type, self.myDataStore.existingUser.userID);
            
            
            // Querying and saving current sadness object to data store
            [DDBDynamoDBManager querySadnessWithUserID:userID completion:^(NSArray *sadnesses, NSError *error) {
                
                if (sadnesses) {
                    
                    if ([self.myDataStore.existingUser.isSadNow isEqualToString:@"yes"]) {
                        
                        IMSSadness *myCurrentSadness = [[IMSSadness alloc] init];
                        myCurrentSadness = sadnesses[0];
                        
                        CLLocationCoordinate2D myCoordinate = CLLocationCoordinate2DMake(myCurrentSadness.latitude, myCurrentSadness.longitude);
                        
                        IMSAnnotation *youAnnotation = [[IMSAnnotation alloc] initWithCoordinate:myCoordinate
                                                                                         dateSec:myCurrentSadness.createdAtSec
                                                                                            date:myCurrentSadness.createdAt
                                                                                        fromCity:myCurrentSadness.fromCity
                                                                                     fromCountry:myCurrentSadness.fromCountry
                                                                              fromCountryISOCode:myCurrentSadness.fromCountryISOCode
                                                                                          gender:myCurrentSadness.gender
                                                                                       toSadness:myCurrentSadness.toSadness
                                                                                       sadnessID:myCurrentSadness.sadnessID];
                        self.myDataStore.yourSadnessAnnotation = youAnnotation;
                        self.myDataStore.sadnessCreatedAt = myCurrentSadness.createdAt;
                        
                        NSLog(@"USER IS CURRENTLY SAD. self.myDataStore.yourSadnessAnnotation.fromCity: %@", self.myDataStore.yourSadnessAnnotation.fromCity);
                    }
                    
                }
                
            }];
            
        }
        
        if (error) {
            [self.timer2 invalidate];
            NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
            [center postNotificationName:@"awsReturnedErrorLookingForUser" object:nil];
        }
        
    }];
    
}


- (NSUInteger)getMinutesBetweenOriginalTimeAndNow:(NSUInteger)createdAtSec {
    
    NSDate *currentDate = [NSDate date]; // also absolute time
    
    // calculate the difference between right now (currentDate) and sadness created date (createdAtSec)
    NSTimeInterval timeIntervalSince1970 = [currentDate timeIntervalSince1970]; // in seconds
    
    NSUInteger timeSad = timeIntervalSince1970 - createdAtSec;
    
    CGFloat minutesInAnHour = 60;
    //    CGFloat secondsInAnHour = 3600;
    NSUInteger minutesBetweenDates = timeSad / minutesInAnHour;
    //NSLog(@"minutesBetweenDates in getminutes: %lu", minutesBetweenDates);
    
    return minutesBetweenDates;
    
}


- (void)resetUserSadness:(NSNotification *)notification {
    
    // if for some reason, the user is not actually sad on the server
    // but they are still marked as sad in their user profile
    // we reset them so they are able to press I'm Sad button
    
    if ([self.myDataStore.existingUser.isSadNow isEqualToString:@"yes"]) {
        
        self.myDataStore.existingUser.isSadNow = @"no";
        self.myDataStore.isSadNow = @"no";
        self.myDataStore.latestCheeredAtSec = 0;
        self.myDataStore.latestSadnessAnnouncedAtSec = 0;
        self.myDataStore.existingUser.latestCheeredAtSec = 0;
        self.myDataStore.existingUser.latestSadnessAnnouncedAtSec = 0;
        
        NSLog(@"SOMETHING WENT WRONG WITH SAVING USER'S GIFT LAST TIME SO WE'M RESETTING THE USER'S SADNESS DATA");
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"awsReturnedNoCurrentSadnessForExistingUser" object:nil];
    
}


- (void)viewDidDisappear:(BOOL)animated {
    NSLog(@"In introVC viewDidDisappear");
    
    [super viewDidDisappear:NO];
    
    [self cleanup];
}


- (void)dealloc {
    NSLog(@"In introVC dealloc");
    
    [self cleanup];
}


- (void)didReceiveMemoryWarning {
    NSLog(@"❗️In introVC didReceiveMemoryWarning");
    
    [super didReceiveMemoryWarning];
    
    [self cleanup];
}


- (void)cleanup {
    NSLog(@"In introVC cleanup");
    
    self.faceAnimation = nil;
    self.faceAnimationView.image = nil;
    self.backgroundImageView.image = nil;
    [self.faceAnimationView.layer removeAllAnimations];
    [self.button setBackgroundImage:nil forState:UIControlStateNormal];
    [self.button setBackgroundImage:nil forState:UIControlStateHighlighted];
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"awsReturnedNoExistingUser" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"awsReturnedErrorLookingForUser" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"awsReturnedNoThankyousForTheUser" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"cheerRecievedViaSNSAppClosed" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"thankyouRecievedViaSNSAppClosed" object:nil];

}







- (void)setupCountries {
    
    // to always get the latest contry name from Apple
    
    NSLocale *locale = [NSLocale currentLocale];
    NSLog(@"*** APPLE COUNTRY CANADA: %@", [locale displayNameForKey:NSLocaleCountryCode value:@"CA"]);
    

    
    
    IMSCountry *country1 = [[IMSCountry alloc] initWithISOCode:@"AD" centerLatitude:42.546245 centerLongitude:1.601554];
    [self.myDataStore.countryObjects addObject:country1];
    
    IMSCountry *country2 = [[IMSCountry alloc] initWithISOCode:@"AE" centerLatitude:23.424076 centerLongitude:53.847818];
    [self.myDataStore.countryObjects addObject:country2];
    
    IMSCountry *country3 = [[IMSCountry alloc] initWithISOCode:@"AF" centerLatitude:33.93911 centerLongitude:67.709953];
    [self.myDataStore.countryObjects addObject:country3];
    
    IMSCountry *country4 = [[IMSCountry alloc] initWithISOCode:@"AG" centerLatitude:17.060816 centerLongitude:-61.796428];
    [self.myDataStore.countryObjects addObject:country4];
    
    IMSCountry *country5 = [[IMSCountry alloc] initWithISOCode:@"AI" centerLatitude:18.220554 centerLongitude:-63.068615];
    [self.myDataStore.countryObjects addObject:country5];
    
    IMSCountry *country6 = [[IMSCountry alloc] initWithISOCode:@"AL" centerLatitude:41.153332 centerLongitude:20.168331];
    [self.myDataStore.countryObjects addObject:country6];
    
    IMSCountry *country7 = [[IMSCountry alloc] initWithISOCode:@"AM" centerLatitude:40.069099 centerLongitude:45.038189];
    [self.myDataStore.countryObjects addObject:country7];
    
    IMSCountry *country8 = [[IMSCountry alloc] initWithISOCode:@"AN" centerLatitude:12.226079 centerLongitude:-69.060087];
    [self.myDataStore.countryObjects addObject:country8];
    
    IMSCountry *country9 = [[IMSCountry alloc] initWithISOCode:@"AO" centerLatitude:-11.202692 centerLongitude:17.873887];
    [self.myDataStore.countryObjects addObject:country9];
    
    IMSCountry *country10 = [[IMSCountry alloc] initWithISOCode:@"AQ" centerLatitude:-75.250973 centerLongitude:-0.071389];
    [self.myDataStore.countryObjects addObject:country10];
    
    
    
    IMSCountry *country11 = [[IMSCountry alloc] initWithISOCode:@"AR" centerLatitude:-38.416097 centerLongitude:-63.616672];
    [self.myDataStore.countryObjects addObject:country11];
    
    IMSCountry *country12 = [[IMSCountry alloc] initWithISOCode:@"AS" centerLatitude:-14.270972 centerLongitude:-170.132217];
    [self.myDataStore.countryObjects addObject:country12];
    
    IMSCountry *country13 = [[IMSCountry alloc] initWithISOCode:@"AT" centerLatitude:47.516231 centerLongitude:14.550072];
    [self.myDataStore.countryObjects addObject:country13];
    
    IMSCountry *country14 = [[IMSCountry alloc] initWithISOCode:@"AU" centerLatitude:-25.274398 centerLongitude:133.775136];
    [self.myDataStore.countryObjects addObject:country14];
    
    IMSCountry *country15 = [[IMSCountry alloc] initWithISOCode:@"AW" centerLatitude:12.52111 centerLongitude:-69.968338];
    [self.myDataStore.countryObjects addObject:country15];
    
    IMSCountry *country16 = [[IMSCountry alloc] initWithISOCode:@"AZ" centerLatitude:40.143105 centerLongitude:47.576927];
    [self.myDataStore.countryObjects addObject:country16];
    
    IMSCountry *country17 = [[IMSCountry alloc] initWithISOCode:@"BA" centerLatitude:43.915886 centerLongitude:17.679076];
    [self.myDataStore.countryObjects addObject:country17];
    
    IMSCountry *country18 = [[IMSCountry alloc] initWithISOCode:@"BB" centerLatitude:13.193887 centerLongitude:-59.543198];
    [self.myDataStore.countryObjects addObject:country18];
    
    IMSCountry *country19 = [[IMSCountry alloc] initWithISOCode:@"BD" centerLatitude:23.684994 centerLongitude:90.356331];
    [self.myDataStore.countryObjects addObject:country19];
    
    IMSCountry *country20 = [[IMSCountry alloc] initWithISOCode:@"BE" centerLatitude:50.503887 centerLongitude:4.469936];
    [self.myDataStore.countryObjects addObject:country20];
    
    
    
    IMSCountry *country21 = [[IMSCountry alloc] initWithISOCode:@"BF" centerLatitude:12.238333 centerLongitude:-1.561593];
    [self.myDataStore.countryObjects addObject:country21];
    
    IMSCountry *country22 = [[IMSCountry alloc] initWithISOCode:@"BG" centerLatitude:42.733883 centerLongitude:25.48583];
    [self.myDataStore.countryObjects addObject:country22];
    
    IMSCountry *country23 = [[IMSCountry alloc] initWithISOCode:@"BH" centerLatitude:25.930414 centerLongitude:50.637772];
    [self.myDataStore.countryObjects addObject:country23];
    
    IMSCountry *country24 = [[IMSCountry alloc] initWithISOCode:@"BI" centerLatitude:-3.373056 centerLongitude:29.918886];
    [self.myDataStore.countryObjects addObject:country24];
    
    IMSCountry *country25 = [[IMSCountry alloc] initWithISOCode:@"BJ" centerLatitude:9.30769 centerLongitude:2.315834];
    [self.myDataStore.countryObjects addObject:country25];
    
    IMSCountry *country26 = [[IMSCountry alloc] initWithISOCode:@"BM" centerLatitude:32.321384 centerLongitude:-64.75737];
    [self.myDataStore.countryObjects addObject:country26];
    
    IMSCountry *country27 = [[IMSCountry alloc] initWithISOCode:@"BN" centerLatitude:4.535277 centerLongitude:114.727669];
    [self.myDataStore.countryObjects addObject:country27];
    
    IMSCountry *country28 = [[IMSCountry alloc] initWithISOCode:@"BO" centerLatitude:-16.290154 centerLongitude:-63.588653];
    [self.myDataStore.countryObjects addObject:country28];
    
    IMSCountry *country29 = [[IMSCountry alloc] initWithISOCode:@"BR" centerLatitude:-14.235004 centerLongitude:-51.92528];
    [self.myDataStore.countryObjects addObject:country29];
    
    IMSCountry *country30 = [[IMSCountry alloc] initWithISOCode:@"BS" centerLatitude:25.03428 centerLongitude:-77.39628];
    [self.myDataStore.countryObjects addObject:country30];
    
    
    
    IMSCountry *country31 = [[IMSCountry alloc] initWithISOCode:@"BT" centerLatitude:27.514162 centerLongitude:90.433601];
    [self.myDataStore.countryObjects addObject:country31];
    
    IMSCountry *country32 = [[IMSCountry alloc] initWithISOCode:@"BV" centerLatitude:-54.423199 centerLongitude:3.413194];
    [self.myDataStore.countryObjects addObject:country32];
    
    IMSCountry *country33 = [[IMSCountry alloc] initWithISOCode:@"BW" centerLatitude:-22.328474 centerLongitude:24.684866];
    [self.myDataStore.countryObjects addObject:country33];
    
    IMSCountry *country34 = [[IMSCountry alloc] initWithISOCode:@"BY" centerLatitude:53.709807 centerLongitude:27.953389];
    [self.myDataStore.countryObjects addObject:country34];
    
    IMSCountry *country35 = [[IMSCountry alloc] initWithISOCode:@"BZ" centerLatitude:17.189877 centerLongitude:-88.49765];
    [self.myDataStore.countryObjects addObject:country35];
    
    IMSCountry *country36 = [[IMSCountry alloc] initWithISOCode:@"CA" centerLatitude:56.130366 centerLongitude:-106.346771];
    [self.myDataStore.countryObjects addObject:country36];
    
    IMSCountry *country37 = [[IMSCountry alloc] initWithISOCode:@"CC" centerLatitude:-12.164165 centerLongitude:96.870956];
    [self.myDataStore.countryObjects addObject:country37];
    
    IMSCountry *country38 = [[IMSCountry alloc] initWithISOCode:@"CD" centerLatitude:-4.038333 centerLongitude:21.758664];
    [self.myDataStore.countryObjects addObject:country38];
    
    IMSCountry *country39 = [[IMSCountry alloc] initWithISOCode:@"CF" centerLatitude:6.611111 centerLongitude:20.939444];
    [self.myDataStore.countryObjects addObject:country39];
    
    IMSCountry *country40 = [[IMSCountry alloc] initWithISOCode:@"CG" centerLatitude:-0.228021 centerLongitude:15.827659];
    [self.myDataStore.countryObjects addObject:country40];
    
    
    
    IMSCountry *country41 = [[IMSCountry alloc] initWithISOCode:@"CH" centerLatitude:46.818188 centerLongitude:8.227512];
    [self.myDataStore.countryObjects addObject:country41];
    
    IMSCountry *country42 = [[IMSCountry alloc] initWithISOCode:@"CI" centerLatitude:7.539989 centerLongitude:-5.54708];
    [self.myDataStore.countryObjects addObject:country42];
    
    IMSCountry *country43 = [[IMSCountry alloc] initWithISOCode:@"CK" centerLatitude:-21.236736 centerLongitude:-159.777671];
    [self.myDataStore.countryObjects addObject:country43];
    
    IMSCountry *country44 = [[IMSCountry alloc] initWithISOCode:@"CL" centerLatitude:-35.675147 centerLongitude:-71.542969];
    [self.myDataStore.countryObjects addObject:country44];
    
    IMSCountry *country45 = [[IMSCountry alloc] initWithISOCode:@"CM" centerLatitude:7.369722 centerLongitude:12.354722];
    [self.myDataStore.countryObjects addObject:country45];
    
    IMSCountry *country46 = [[IMSCountry alloc] initWithISOCode:@"CN" centerLatitude:35.86166 centerLongitude:104.195397];
    [self.myDataStore.countryObjects addObject:country46];
    
    IMSCountry *country47 = [[IMSCountry alloc] initWithISOCode:@"CO" centerLatitude:4.570868 centerLongitude:-74.297333];
    [self.myDataStore.countryObjects addObject:country47];
    
    IMSCountry *country48 = [[IMSCountry alloc] initWithISOCode:@"CR" centerLatitude:9.748917 centerLongitude:-83.753428];
    [self.myDataStore.countryObjects addObject:country48];
    
    IMSCountry *country49 = [[IMSCountry alloc] initWithISOCode:@"CU" centerLatitude:21.521757 centerLongitude:-77.781167];
    [self.myDataStore.countryObjects addObject:country49];
    
    IMSCountry *country50 = [[IMSCountry alloc] initWithISOCode:@"CV" centerLatitude:16.002082 centerLongitude:-24.013197];
    [self.myDataStore.countryObjects addObject:country50];
    
    
    
    IMSCountry *country51 = [[IMSCountry alloc] initWithISOCode:@"CX" centerLatitude:-10.447525 centerLongitude:105.690449];
    [self.myDataStore.countryObjects addObject:country51];
    
    IMSCountry *country52 = [[IMSCountry alloc] initWithISOCode:@"CY" centerLatitude:35.126413 centerLongitude:33.429859];
    [self.myDataStore.countryObjects addObject:country52];
    
    IMSCountry *country53 = [[IMSCountry alloc] initWithISOCode:@"CZ" centerLatitude:49.817492 centerLongitude:15.472962];
    [self.myDataStore.countryObjects addObject:country53];
    
    IMSCountry *country54 = [[IMSCountry alloc] initWithISOCode:@"DE" centerLatitude:51.165691 centerLongitude:10.451526];
    [self.myDataStore.countryObjects addObject:country54];
    
    IMSCountry *country55 = [[IMSCountry alloc] initWithISOCode:@"DJ" centerLatitude:11.825138 centerLongitude:42.590275];
    [self.myDataStore.countryObjects addObject:country55];
    
    IMSCountry *country56 = [[IMSCountry alloc] initWithISOCode:@"DK" centerLatitude:56.26392 centerLongitude:9.501785];
    [self.myDataStore.countryObjects addObject:country56];
    
    IMSCountry *country57 = [[IMSCountry alloc] initWithISOCode:@"DM" centerLatitude:15.414999 centerLongitude:-61.370976];
    [self.myDataStore.countryObjects addObject:country57];
    
    IMSCountry *country58 = [[IMSCountry alloc] initWithISOCode:@"DO" centerLatitude:18.735693 centerLongitude:-70.162651];
    [self.myDataStore.countryObjects addObject:country58];
    
    IMSCountry *country59 = [[IMSCountry alloc] initWithISOCode:@"DZ" centerLatitude:28.033886 centerLongitude:1.659626];
    [self.myDataStore.countryObjects addObject:country59];
    
    IMSCountry *country60 = [[IMSCountry alloc] initWithISOCode:@"EC" centerLatitude:-1.831239 centerLongitude:-78.183406];
    [self.myDataStore.countryObjects addObject:country60];
    
    
    
    IMSCountry *country61 = [[IMSCountry alloc] initWithISOCode:@"EE" centerLatitude:58.595272 centerLongitude:25.013607];
    [self.myDataStore.countryObjects addObject:country61];
    
    IMSCountry *country62 = [[IMSCountry alloc] initWithISOCode:@"EG" centerLatitude:26.820553 centerLongitude:30.802498];
    [self.myDataStore.countryObjects addObject:country62];
    
    IMSCountry *country63 = [[IMSCountry alloc] initWithISOCode:@"EH" centerLatitude:24.215527 centerLongitude:-12.885834];
    [self.myDataStore.countryObjects addObject:country63];
    
    IMSCountry *country64 = [[IMSCountry alloc] initWithISOCode:@"ER" centerLatitude:15.179384 centerLongitude:39.782334];
    [self.myDataStore.countryObjects addObject:country64];
    
    IMSCountry *country65 = [[IMSCountry alloc] initWithISOCode:@"ES" centerLatitude:40.463667 centerLongitude:-3.74922];
    [self.myDataStore.countryObjects addObject:country65];
    
    IMSCountry *country66 = [[IMSCountry alloc] initWithISOCode:@"ET" centerLatitude:9.145 centerLongitude:40.489673];
    [self.myDataStore.countryObjects addObject:country66];
    
    IMSCountry *country67 = [[IMSCountry alloc] initWithISOCode:@"FI" centerLatitude:61.92411 centerLongitude:25.748151];
    [self.myDataStore.countryObjects addObject:country67];
    
    IMSCountry *country68 = [[IMSCountry alloc] initWithISOCode:@"FJ" centerLatitude:-16.578193 centerLongitude:179.414413];
    [self.myDataStore.countryObjects addObject:country68];
    
    IMSCountry *country69 = [[IMSCountry alloc] initWithISOCode:@"FK" centerLatitude:-51.796253 centerLongitude:-59.523613];
    [self.myDataStore.countryObjects addObject:country69];
    
    IMSCountry *country70 = [[IMSCountry alloc] initWithISOCode:@"FM" centerLatitude:7.425554 centerLongitude:150.550812];
    [self.myDataStore.countryObjects addObject:country70];
    
    
    
    IMSCountry *country71 = [[IMSCountry alloc] initWithISOCode:@"FO" centerLatitude:61.892635 centerLongitude:-6.911806];
    [self.myDataStore.countryObjects addObject:country71];
    
    IMSCountry *country72 = [[IMSCountry alloc] initWithISOCode:@"FR" centerLatitude:46.227638 centerLongitude:2.213749];
    [self.myDataStore.countryObjects addObject:country72];
    
    IMSCountry *country73 = [[IMSCountry alloc] initWithISOCode:@"GA" centerLatitude:-0.803689 centerLongitude:11.609444];
    [self.myDataStore.countryObjects addObject:country73];
    
    IMSCountry *country74 = [[IMSCountry alloc] initWithISOCode:@"GB" centerLatitude:55.378051 centerLongitude:-3.435973];
    [self.myDataStore.countryObjects addObject:country74];
    
    IMSCountry *country75 = [[IMSCountry alloc] initWithISOCode:@"GD" centerLatitude:12.262776 centerLongitude:-61.604171];
    [self.myDataStore.countryObjects addObject:country75];
    
    IMSCountry *country76 = [[IMSCountry alloc] initWithISOCode:@"GE" centerLatitude:42.315407 centerLongitude:43.356892];
    [self.myDataStore.countryObjects addObject:country76];
    
    IMSCountry *country77 = [[IMSCountry alloc] initWithISOCode:@"GF" centerLatitude:3.933889 centerLongitude:-53.125782];
    [self.myDataStore.countryObjects addObject:country77];
    
    IMSCountry *country78 = [[IMSCountry alloc] initWithISOCode:@"GG" centerLatitude:49.465691 centerLongitude:-2.585278];
    [self.myDataStore.countryObjects addObject:country78];
    
    IMSCountry *country79 = [[IMSCountry alloc] initWithISOCode:@"GH" centerLatitude:7.946527 centerLongitude:-1.023194];
    [self.myDataStore.countryObjects addObject:country79];
    
    IMSCountry *country80 = [[IMSCountry alloc] initWithISOCode:@"GI" centerLatitude:36.137741 centerLongitude:-5.345374];
    [self.myDataStore.countryObjects addObject:country80];
    
    
    
    IMSCountry *country81 = [[IMSCountry alloc] initWithISOCode:@"GL" centerLatitude:71.706936 centerLongitude:-42.604303];
    [self.myDataStore.countryObjects addObject:country81];
    
    IMSCountry *country82 = [[IMSCountry alloc] initWithISOCode:@"GM" centerLatitude:13.443182 centerLongitude:-15.310139];
    [self.myDataStore.countryObjects addObject:country82];
    
    IMSCountry *country83 = [[IMSCountry alloc] initWithISOCode:@"GN" centerLatitude:9.945587 centerLongitude:-9.696645];
    [self.myDataStore.countryObjects addObject:country83];
    
    IMSCountry *country84 = [[IMSCountry alloc] initWithISOCode:@"GP" centerLatitude:16.995971 centerLongitude:-62.067641];
    [self.myDataStore.countryObjects addObject:country84];
    
    IMSCountry *country85 = [[IMSCountry alloc] initWithISOCode:@"GQ" centerLatitude:1.650801 centerLongitude:10.267895];
    [self.myDataStore.countryObjects addObject:country85];
    
    IMSCountry *country86 = [[IMSCountry alloc] initWithISOCode:@"GR" centerLatitude:39.074208 centerLongitude:21.824312];
    [self.myDataStore.countryObjects addObject:country86];
    
    IMSCountry *country87 = [[IMSCountry alloc] initWithISOCode:@"GS" centerLatitude:-54.429579 centerLongitude:-36.587909];
    [self.myDataStore.countryObjects addObject:country87];
    
    IMSCountry *country88 = [[IMSCountry alloc] initWithISOCode:@"GT" centerLatitude:15.783471 centerLongitude:-90.230759];
    [self.myDataStore.countryObjects addObject:country88];
    
    IMSCountry *country89 = [[IMSCountry alloc] initWithISOCode:@"GU" centerLatitude:13.444304 centerLongitude:144.793731];
    [self.myDataStore.countryObjects addObject:country89];
    
    IMSCountry *country90 = [[IMSCountry alloc] initWithISOCode:@"GW" centerLatitude:11.803749 centerLongitude:-15.180413];
    [self.myDataStore.countryObjects addObject:country90];
    
    
    
    IMSCountry *country91 = [[IMSCountry alloc] initWithISOCode:@"GY" centerLatitude:4.860416 centerLongitude:-58.93018];
    [self.myDataStore.countryObjects addObject:country91];
    
    IMSCountry *country92 = [[IMSCountry alloc] initWithISOCode:@"GZ" centerLatitude:31.354676 centerLongitude:34.308825];
    [self.myDataStore.countryObjects addObject:country92];
    
    IMSCountry *country93 = [[IMSCountry alloc] initWithISOCode:@"HK" centerLatitude:22.396428 centerLongitude:114.109497];
    [self.myDataStore.countryObjects addObject:country93];
    
    IMSCountry *country94 = [[IMSCountry alloc] initWithISOCode:@"HM" centerLatitude:-53.08181 centerLongitude:73.504158];
    [self.myDataStore.countryObjects addObject:country94];
    
    IMSCountry *country95 = [[IMSCountry alloc] initWithISOCode:@"HN" centerLatitude:15.199999 centerLongitude:-86.241905];
    [self.myDataStore.countryObjects addObject:country95];
    
    IMSCountry *country96 = [[IMSCountry alloc] initWithISOCode:@"HR" centerLatitude:45.1 centerLongitude:15.2];
    [self.myDataStore.countryObjects addObject:country96];
    
    IMSCountry *country97 = [[IMSCountry alloc] initWithISOCode:@"HT" centerLatitude:18.971187 centerLongitude:-72.285215];
    [self.myDataStore.countryObjects addObject:country97];
    
    IMSCountry *country98 = [[IMSCountry alloc] initWithISOCode:@"HU" centerLatitude:47.162494 centerLongitude:19.503304];
    [self.myDataStore.countryObjects addObject:country98];
    
    IMSCountry *country99 = [[IMSCountry alloc] initWithISOCode:@"ID" centerLatitude:-0.789275 centerLongitude:113.921327];
    [self.myDataStore.countryObjects addObject:country99];
    
    IMSCountry *country100 = [[IMSCountry alloc] initWithISOCode:@"IE" centerLatitude:53.41291 centerLongitude:-8.24389];
    [self.myDataStore.countryObjects addObject:country100];
    
    
    
    IMSCountry *country101 = [[IMSCountry alloc] initWithISOCode:@"IL" centerLatitude:31.046051 centerLongitude:34.851612];
    [self.myDataStore.countryObjects addObject:country101];
    
    IMSCountry *country102 = [[IMSCountry alloc] initWithISOCode:@"IM" centerLatitude:54.236107 centerLongitude:-4.548056];
    [self.myDataStore.countryObjects addObject:country102];
    
    IMSCountry *country103 = [[IMSCountry alloc] initWithISOCode:@"IN" centerLatitude:20.593684 centerLongitude:78.96288];
    [self.myDataStore.countryObjects addObject:country103];
    
    IMSCountry *country104 = [[IMSCountry alloc] initWithISOCode:@"IO" centerLatitude:-6.343194 centerLongitude:71.876519];
    [self.myDataStore.countryObjects addObject:country104];
    
    IMSCountry *country105 = [[IMSCountry alloc] initWithISOCode:@"IQ" centerLatitude:33.223191 centerLongitude:43.679291];
    [self.myDataStore.countryObjects addObject:country105];
    
    IMSCountry *country106 = [[IMSCountry alloc] initWithISOCode:@"IR" centerLatitude:32.427908 centerLongitude:53.688046];
    [self.myDataStore.countryObjects addObject:country106];
    
    IMSCountry *country107 = [[IMSCountry alloc] initWithISOCode:@"IS" centerLatitude:64.963051 centerLongitude:-19.020835];
    [self.myDataStore.countryObjects addObject:country107];
    
    IMSCountry *country108 = [[IMSCountry alloc] initWithISOCode:@"IT" centerLatitude:41.87194 centerLongitude:12.56738];
    [self.myDataStore.countryObjects addObject:country108];
    
    IMSCountry *country109 = [[IMSCountry alloc] initWithISOCode:@"JE" centerLatitude:49.214439 centerLongitude:-2.13125];
    [self.myDataStore.countryObjects addObject:country109];
    
    IMSCountry *country110 = [[IMSCountry alloc] initWithISOCode:@"JM" centerLatitude:18.109581 centerLongitude:-77.297508];
    [self.myDataStore.countryObjects addObject:country110];
    
    
    
    IMSCountry *country111 = [[IMSCountry alloc] initWithISOCode:@"JO" centerLatitude:30.585164 centerLongitude:36.238414];
    [self.myDataStore.countryObjects addObject:country111];
    
    IMSCountry *country112 = [[IMSCountry alloc] initWithISOCode:@"JP" centerLatitude:36.204824 centerLongitude:138.252924];
    [self.myDataStore.countryObjects addObject:country112];
    
    IMSCountry *country113 = [[IMSCountry alloc] initWithISOCode:@"KE" centerLatitude:-0.023559 centerLongitude:37.906193];
    [self.myDataStore.countryObjects addObject:country113];
    
    IMSCountry *country114 = [[IMSCountry alloc] initWithISOCode:@"KG" centerLatitude:41.20438 centerLongitude:74.766098];
    [self.myDataStore.countryObjects addObject:country114];
    
    IMSCountry *country115 = [[IMSCountry alloc] initWithISOCode:@"KH" centerLatitude:12.565679 centerLongitude:104.990963];
    [self.myDataStore.countryObjects addObject:country115];
    
    IMSCountry *country116 = [[IMSCountry alloc] initWithISOCode:@"KI" centerLatitude:-3.370417 centerLongitude:-168.734039];
    [self.myDataStore.countryObjects addObject:country116];
    
    IMSCountry *country117 = [[IMSCountry alloc] initWithISOCode:@"KM" centerLatitude:-11.875001 centerLongitude:43.872219];
    [self.myDataStore.countryObjects addObject:country117];
    
    IMSCountry *country118 = [[IMSCountry alloc] initWithISOCode:@"KN" centerLatitude:17.357822 centerLongitude:-62.782998];
    [self.myDataStore.countryObjects addObject:country118];
    
    IMSCountry *country119 = [[IMSCountry alloc] initWithISOCode:@"KP" centerLatitude:40.339852 centerLongitude:127.510093];
    [self.myDataStore.countryObjects addObject:country119];
    
    IMSCountry *country120 = [[IMSCountry alloc] initWithISOCode:@"KR" centerLatitude:35.907757 centerLongitude:127.766922];
    [self.myDataStore.countryObjects addObject:country120];
    
    
    
    IMSCountry *country121 = [[IMSCountry alloc] initWithISOCode:@"KW" centerLatitude:29.31166 centerLongitude:47.481766];
    [self.myDataStore.countryObjects addObject:country121];
    
    IMSCountry *country122 = [[IMSCountry alloc] initWithISOCode:@"KY" centerLatitude:19.513469 centerLongitude:-80.566956];
    [self.myDataStore.countryObjects addObject:country122];
    
    IMSCountry *country123 = [[IMSCountry alloc] initWithISOCode:@"KZ" centerLatitude:48.019573 centerLongitude:66.923684];
    [self.myDataStore.countryObjects addObject:country123];
    
    IMSCountry *country124 = [[IMSCountry alloc] initWithISOCode:@"LA" centerLatitude:19.85627 centerLongitude:102.495496];
    [self.myDataStore.countryObjects addObject:country124];
    
    IMSCountry *country125 = [[IMSCountry alloc] initWithISOCode:@"LB" centerLatitude:33.854721 centerLongitude:35.862285];
    [self.myDataStore.countryObjects addObject:country125];
    
    IMSCountry *country126 = [[IMSCountry alloc] initWithISOCode:@"LC" centerLatitude:13.909444 centerLongitude:-60.978893];
    [self.myDataStore.countryObjects addObject:country126];
    
    IMSCountry *country127 = [[IMSCountry alloc] initWithISOCode:@"LI" centerLatitude:47.166 centerLongitude:9.555373];
    [self.myDataStore.countryObjects addObject:country127];
    
    IMSCountry *country128 = [[IMSCountry alloc] initWithISOCode:@"LK" centerLatitude:7.873054 centerLongitude:80.771797];
    [self.myDataStore.countryObjects addObject:country128];
    
    IMSCountry *country129 = [[IMSCountry alloc] initWithISOCode:@"LR" centerLatitude:6.428055 centerLongitude:-9.429499];
    [self.myDataStore.countryObjects addObject:country129];
    
    IMSCountry *country130 = [[IMSCountry alloc] initWithISOCode:@"LS" centerLatitude:-29.609988 centerLongitude:28.233608];
    [self.myDataStore.countryObjects addObject:country130];
    
    
    
    IMSCountry *country131 = [[IMSCountry alloc] initWithISOCode:@"LT" centerLatitude:55.169438 centerLongitude:23.881275];
    [self.myDataStore.countryObjects addObject:country131];
    
    IMSCountry *country132 = [[IMSCountry alloc] initWithISOCode:@"LU" centerLatitude:49.815273 centerLongitude:6.129583];
    [self.myDataStore.countryObjects addObject:country132];
    
    IMSCountry *country133 = [[IMSCountry alloc] initWithISOCode:@"LV" centerLatitude:56.879635 centerLongitude:24.603189];
    [self.myDataStore.countryObjects addObject:country133];
    
    IMSCountry *country134 = [[IMSCountry alloc] initWithISOCode:@"LY" centerLatitude:26.3351 centerLongitude:17.228331];
    [self.myDataStore.countryObjects addObject:country134];
    
    IMSCountry *country135 = [[IMSCountry alloc] initWithISOCode:@"MA" centerLatitude:31.791702 centerLongitude:-7.09262];
    [self.myDataStore.countryObjects addObject:country135];
    
    IMSCountry *country136 = [[IMSCountry alloc] initWithISOCode:@"MC" centerLatitude:43.750298 centerLongitude:7.412841];
    [self.myDataStore.countryObjects addObject:country136];
    
    IMSCountry *country137 = [[IMSCountry alloc] initWithISOCode:@"MD" centerLatitude:47.411631 centerLongitude:28.369885];
    [self.myDataStore.countryObjects addObject:country137];
    
    IMSCountry *country138 = [[IMSCountry alloc] initWithISOCode:@"ME" centerLatitude:42.708678 centerLongitude:19.37439];
    [self.myDataStore.countryObjects addObject:country138];
    
    IMSCountry *country139 = [[IMSCountry alloc] initWithISOCode:@"MG" centerLatitude:-18.766947 centerLongitude:46.869107];
    [self.myDataStore.countryObjects addObject:country139];
    
    IMSCountry *country140 = [[IMSCountry alloc] initWithISOCode:@"MH" centerLatitude:7.131474 centerLongitude:171.184478];
    [self.myDataStore.countryObjects addObject:country140];
    
    
    
    IMSCountry *country141 = [[IMSCountry alloc] initWithISOCode:@"MK" centerLatitude:41.608635 centerLongitude:21.745275];
    [self.myDataStore.countryObjects addObject:country141];
    
    IMSCountry *country142 = [[IMSCountry alloc] initWithISOCode:@"ML" centerLatitude:17.570692 centerLongitude:-3.996166];
    [self.myDataStore.countryObjects addObject:country142];
    
    IMSCountry *country143 = [[IMSCountry alloc] initWithISOCode:@"MM" centerLatitude:21.913965 centerLongitude:95.956223];
    [self.myDataStore.countryObjects addObject:country143];
    
    IMSCountry *country144 = [[IMSCountry alloc] initWithISOCode:@"MN" centerLatitude:46.862496 centerLongitude:103.846656];
    [self.myDataStore.countryObjects addObject:country144];
    
    IMSCountry *country145 = [[IMSCountry alloc] initWithISOCode:@"MO" centerLatitude:22.198745 centerLongitude:113.543873];
    [self.myDataStore.countryObjects addObject:country145];
    
    IMSCountry *country146 = [[IMSCountry alloc] initWithISOCode:@"MP" centerLatitude:17.33083 centerLongitude:145.38469];
    [self.myDataStore.countryObjects addObject:country146];
    
    IMSCountry *country147 = [[IMSCountry alloc] initWithISOCode:@"MQ" centerLatitude:14.641528 centerLongitude:-61.024174];
    [self.myDataStore.countryObjects addObject:country147];
    
    IMSCountry *country148 = [[IMSCountry alloc] initWithISOCode:@"MR" centerLatitude:21.00789 centerLongitude:-10.940835];
    [self.myDataStore.countryObjects addObject:country148];
    
    IMSCountry *country149 = [[IMSCountry alloc] initWithISOCode:@"MS" centerLatitude:16.742498 centerLongitude:-62.187366];
    [self.myDataStore.countryObjects addObject:country149];
    
    IMSCountry *country150 = [[IMSCountry alloc] initWithISOCode:@"MT" centerLatitude:35.937496 centerLongitude:14.375416];
    [self.myDataStore.countryObjects addObject:country150];
    
    
    
    IMSCountry *country151 = [[IMSCountry alloc] initWithISOCode:@"MU" centerLatitude:-20.348404 centerLongitude:57.552152];
    [self.myDataStore.countryObjects addObject:country151];
    
    IMSCountry *country152 = [[IMSCountry alloc] initWithISOCode:@"MV" centerLatitude:3.202778 centerLongitude:73.22068];
    [self.myDataStore.countryObjects addObject:country152];
    
    IMSCountry *country153 = [[IMSCountry alloc] initWithISOCode:@"MW" centerLatitude:-13.254308 centerLongitude:34.301525];
    [self.myDataStore.countryObjects addObject:country153];
    
    IMSCountry *country154 = [[IMSCountry alloc] initWithISOCode:@"MX" centerLatitude:23.634501 centerLongitude:-102.552784];
    [self.myDataStore.countryObjects addObject:country154];
    
    IMSCountry *country155 = [[IMSCountry alloc] initWithISOCode:@"MY" centerLatitude:4.210484 centerLongitude:101.975766];
    [self.myDataStore.countryObjects addObject:country155];
    
    IMSCountry *country156 = [[IMSCountry alloc] initWithISOCode:@"MZ" centerLatitude:-18.665695 centerLongitude:35.529562];
    [self.myDataStore.countryObjects addObject:country156];
    
    IMSCountry *country157 = [[IMSCountry alloc] initWithISOCode:@"NA" centerLatitude:-22.95764 centerLongitude:18.49041];
    [self.myDataStore.countryObjects addObject:country157];
    
    IMSCountry *country158 = [[IMSCountry alloc] initWithISOCode:@"NC" centerLatitude:-20.904305 centerLongitude:165.618042];
    [self.myDataStore.countryObjects addObject:country158];
    
    IMSCountry *country159 = [[IMSCountry alloc] initWithISOCode:@"NE" centerLatitude:17.607789 centerLongitude:8.081666];
    [self.myDataStore.countryObjects addObject:country159];
    
    IMSCountry *country160 = [[IMSCountry alloc] initWithISOCode:@"NF" centerLatitude:-29.040835 centerLongitude:167.954712];
    [self.myDataStore.countryObjects addObject:country160];
    
    
    
    IMSCountry *country161 = [[IMSCountry alloc] initWithISOCode:@"NG" centerLatitude:9.081999 centerLongitude:8.675277];
    [self.myDataStore.countryObjects addObject:country161];
    
    IMSCountry *country162 = [[IMSCountry alloc] initWithISOCode:@"NI" centerLatitude:12.865416 centerLongitude:-85.207229];
    [self.myDataStore.countryObjects addObject:country162];
    
    IMSCountry *country163 = [[IMSCountry alloc] initWithISOCode:@"NL" centerLatitude:52.132633 centerLongitude:5.291266];
    [self.myDataStore.countryObjects addObject:country163];
    
    IMSCountry *country164 = [[IMSCountry alloc] initWithISOCode:@"NO" centerLatitude:60.472024 centerLongitude:8.468946];
    [self.myDataStore.countryObjects addObject:country164];
    
    IMSCountry *country165 = [[IMSCountry alloc] initWithISOCode:@"NP" centerLatitude:28.394857 centerLongitude:84.124008];
    [self.myDataStore.countryObjects addObject:country165];
    
    IMSCountry *country166 = [[IMSCountry alloc] initWithISOCode:@"NR" centerLatitude:-0.522778 centerLongitude:166.931503];
    [self.myDataStore.countryObjects addObject:country166];
    
    IMSCountry *country167 = [[IMSCountry alloc] initWithISOCode:@"NU" centerLatitude:-19.054445 centerLongitude:-169.867233];
    [self.myDataStore.countryObjects addObject:country167];
    
    IMSCountry *country168 = [[IMSCountry alloc] initWithISOCode:@"NZ" centerLatitude:-40.900557 centerLongitude:174.885971];
    [self.myDataStore.countryObjects addObject:country168];
    
    IMSCountry *country169 = [[IMSCountry alloc] initWithISOCode:@"OM" centerLatitude:21.512583 centerLongitude:55.923255];
    [self.myDataStore.countryObjects addObject:country169];
    
    IMSCountry *country170 = [[IMSCountry alloc] initWithISOCode:@"PA" centerLatitude:8.537981 centerLongitude:-80.782127];
    [self.myDataStore.countryObjects addObject:country170];
    
    
    
    IMSCountry *country171 = [[IMSCountry alloc] initWithISOCode:@"PE" centerLatitude:-9.189967 centerLongitude:-75.015152];
    [self.myDataStore.countryObjects addObject:country171];
    
    IMSCountry *country172 = [[IMSCountry alloc] initWithISOCode:@"PF" centerLatitude:-17.679742 centerLongitude:-149.406843];
    [self.myDataStore.countryObjects addObject:country172];
    
    IMSCountry *country173 = [[IMSCountry alloc] initWithISOCode:@"PG" centerLatitude:-6.314993 centerLongitude:143.95555];
    [self.myDataStore.countryObjects addObject:country173];
    
    IMSCountry *country174 = [[IMSCountry alloc] initWithISOCode:@"PH" centerLatitude:12.879721 centerLongitude:121.774017];
    [self.myDataStore.countryObjects addObject:country174];
    
    IMSCountry *country175 = [[IMSCountry alloc] initWithISOCode:@"PK" centerLatitude:30.375321 centerLongitude:69.345116];
    [self.myDataStore.countryObjects addObject:country175];
    
    IMSCountry *country176 = [[IMSCountry alloc] initWithISOCode:@"PL" centerLatitude:51.919438 centerLongitude:19.145136];
    [self.myDataStore.countryObjects addObject:country176];
    
    IMSCountry *country177 = [[IMSCountry alloc] initWithISOCode:@"PM" centerLatitude:46.941936 centerLongitude:-56.27111];
    [self.myDataStore.countryObjects addObject:country177];
    
    IMSCountry *country178 = [[IMSCountry alloc] initWithISOCode:@"PN" centerLatitude:-24.703615 centerLongitude:-127.439308];
    [self.myDataStore.countryObjects addObject:country178];
    
    IMSCountry *country179 = [[IMSCountry alloc] initWithISOCode:@"PR" centerLatitude:18.220833 centerLongitude:-66.590149];
    [self.myDataStore.countryObjects addObject:country179];
    
    IMSCountry *country180 = [[IMSCountry alloc] initWithISOCode:@"PS" centerLatitude:31.952162 centerLongitude:35.233154];
    [self.myDataStore.countryObjects addObject:country180];
    
    
    
    IMSCountry *country181 = [[IMSCountry alloc] initWithISOCode:@"PT" centerLatitude:39.399872 centerLongitude:-8.224454];
    [self.myDataStore.countryObjects addObject:country181];
    
    IMSCountry *country182 = [[IMSCountry alloc] initWithISOCode:@"PW" centerLatitude:7.51498 centerLongitude:134.58252];
    [self.myDataStore.countryObjects addObject:country182];
    
    IMSCountry *country183 = [[IMSCountry alloc] initWithISOCode:@"PY" centerLatitude:-23.442503 centerLongitude:-58.443832];
    [self.myDataStore.countryObjects addObject:country183];
    
    IMSCountry *country184 = [[IMSCountry alloc] initWithISOCode:@"QA" centerLatitude:25.354826 centerLongitude:51.183884];
    [self.myDataStore.countryObjects addObject:country184];
    
    IMSCountry *country185 = [[IMSCountry alloc] initWithISOCode:@"RE" centerLatitude:-21.115141 centerLongitude:55.536384];
    [self.myDataStore.countryObjects addObject:country185];
    
    IMSCountry *country186 = [[IMSCountry alloc] initWithISOCode:@"RO" centerLatitude:45.943161 centerLongitude:24.96676];
    [self.myDataStore.countryObjects addObject:country186];
    
    IMSCountry *country187 = [[IMSCountry alloc] initWithISOCode:@"RS" centerLatitude:44.016521 centerLongitude:21.005859];
    [self.myDataStore.countryObjects addObject:country187];
    
    IMSCountry *country188 = [[IMSCountry alloc] initWithISOCode:@"RU" centerLatitude:61.52401 centerLongitude:70];
    [self.myDataStore.countryObjects addObject:country188];
    
    IMSCountry *country189 = [[IMSCountry alloc] initWithISOCode:@"RW" centerLatitude:-1.940278 centerLongitude:29.873888];
    [self.myDataStore.countryObjects addObject:country189];
    
    IMSCountry *country190 = [[IMSCountry alloc] initWithISOCode:@"SA" centerLatitude:23.885942 centerLongitude:45.079162];
    [self.myDataStore.countryObjects addObject:country190];
    
    
    
    IMSCountry *country191 = [[IMSCountry alloc] initWithISOCode:@"SB" centerLatitude:-9.64571 centerLongitude:160.156194];
    [self.myDataStore.countryObjects addObject:country191];
    
    IMSCountry *country192 = [[IMSCountry alloc] initWithISOCode:@"SC" centerLatitude:-4.679574 centerLongitude:55.491977];
    [self.myDataStore.countryObjects addObject:country192];
    
    IMSCountry *country193 = [[IMSCountry alloc] initWithISOCode:@"SD" centerLatitude:12.862807 centerLongitude:30.217636];
    [self.myDataStore.countryObjects addObject:country193];
    
    IMSCountry *country194 = [[IMSCountry alloc] initWithISOCode:@"SE" centerLatitude:60.128161 centerLongitude:18.643501];
    [self.myDataStore.countryObjects addObject:country194];
    
    IMSCountry *country195 = [[IMSCountry alloc] initWithISOCode:@"SG" centerLatitude:1.352083 centerLongitude:103.819836];
    [self.myDataStore.countryObjects addObject:country195];
    
    IMSCountry *country196 = [[IMSCountry alloc] initWithISOCode:@"SH" centerLatitude:-24.143474 centerLongitude:-10.030696];
    [self.myDataStore.countryObjects addObject:country196];
    
    IMSCountry *country197 = [[IMSCountry alloc] initWithISOCode:@"SI" centerLatitude:46.151241 centerLongitude:14.995463];
    [self.myDataStore.countryObjects addObject:country197];
    
    IMSCountry *country198 = [[IMSCountry alloc] initWithISOCode:@"SJ" centerLatitude:77.553604 centerLongitude:23.670272];
    [self.myDataStore.countryObjects addObject:country198];
    
    IMSCountry *country199 = [[IMSCountry alloc] initWithISOCode:@"SK" centerLatitude:48.669026 centerLongitude:19.699024];
    [self.myDataStore.countryObjects addObject:country199];
    
    IMSCountry *country200 = [[IMSCountry alloc] initWithISOCode:@"SL" centerLatitude:8.460555 centerLongitude:-11.779889];
    [self.myDataStore.countryObjects addObject:country200];
    
    
    
    IMSCountry *country201 = [[IMSCountry alloc] initWithISOCode:@"SM" centerLatitude:43.94236 centerLongitude:12.457777];
    [self.myDataStore.countryObjects addObject:country201];
    
    IMSCountry *country202 = [[IMSCountry alloc] initWithISOCode:@"SN" centerLatitude:14.497401 centerLongitude:-14.452362];
    [self.myDataStore.countryObjects addObject:country202];
    
    IMSCountry *country203 = [[IMSCountry alloc] initWithISOCode:@"SO" centerLatitude:5.152149 centerLongitude:46.199616];
    [self.myDataStore.countryObjects addObject:country203];
    
    IMSCountry *country204 = [[IMSCountry alloc] initWithISOCode:@"SR" centerLatitude:3.919305 centerLongitude:-56.027783];
    [self.myDataStore.countryObjects addObject:country204];
    
    IMSCountry *country205 = [[IMSCountry alloc] initWithISOCode:@"ST" centerLatitude:0.18636 centerLongitude:6.613081];
    [self.myDataStore.countryObjects addObject:country205];
    
    IMSCountry *country206 = [[IMSCountry alloc] initWithISOCode:@"SV" centerLatitude:13.794185 centerLongitude:-88.89653];
    [self.myDataStore.countryObjects addObject:country206];
    
    IMSCountry *country207 = [[IMSCountry alloc] initWithISOCode:@"SY" centerLatitude:34.802075 centerLongitude:38.996815];
    [self.myDataStore.countryObjects addObject:country207];
    
    IMSCountry *country208 = [[IMSCountry alloc] initWithISOCode:@"SZ" centerLatitude:-26.522503 centerLongitude:31.465866];
    [self.myDataStore.countryObjects addObject:country208];
    
    IMSCountry *country209 = [[IMSCountry alloc] initWithISOCode:@"TC" centerLatitude:21.694025 centerLongitude:-71.797928];
    [self.myDataStore.countryObjects addObject:country209];
    
    IMSCountry *country210 = [[IMSCountry alloc] initWithISOCode:@"TD" centerLatitude:15.454166 centerLongitude:18.732207];
    [self.myDataStore.countryObjects addObject:country210];
    
    
    
    IMSCountry *country211 = [[IMSCountry alloc] initWithISOCode:@"TF" centerLatitude:-49.280366 centerLongitude:69.348557];
    [self.myDataStore.countryObjects addObject:country211];
    
    IMSCountry *country212 = [[IMSCountry alloc] initWithISOCode:@"TG" centerLatitude:8.619543 centerLongitude:0.824782];
    [self.myDataStore.countryObjects addObject:country212];
    
    IMSCountry *country213 = [[IMSCountry alloc] initWithISOCode:@"TH" centerLatitude:15.870032 centerLongitude:100.992541];
    [self.myDataStore.countryObjects addObject:country213];
    
    IMSCountry *country214 = [[IMSCountry alloc] initWithISOCode:@"TJ" centerLatitude:38.861034 centerLongitude:71.276093];
    [self.myDataStore.countryObjects addObject:country214];
    
    IMSCountry *country215 = [[IMSCountry alloc] initWithISOCode:@"TK" centerLatitude:-8.967363 centerLongitude:-171.855881];
    [self.myDataStore.countryObjects addObject:country215];
    
    IMSCountry *country216 = [[IMSCountry alloc] initWithISOCode:@"TL" centerLatitude:-8.874217 centerLongitude:125.727539];
    [self.myDataStore.countryObjects addObject:country216];
    
    IMSCountry *country217 = [[IMSCountry alloc] initWithISOCode:@"TM" centerLatitude:38.969719 centerLongitude:59.556278];
    [self.myDataStore.countryObjects addObject:country217];
    
    IMSCountry *country218 = [[IMSCountry alloc] initWithISOCode:@"TN" centerLatitude:33.886917 centerLongitude:9.537499];
    [self.myDataStore.countryObjects addObject:country218];
    
    IMSCountry *country219 = [[IMSCountry alloc] initWithISOCode:@"TO" centerLatitude:-21.178986 centerLongitude:-175.198242];
    [self.myDataStore.countryObjects addObject:country219];
    
    IMSCountry *country220 = [[IMSCountry alloc] initWithISOCode:@"TR" centerLatitude:38.963745 centerLongitude:35.243322];
    [self.myDataStore.countryObjects addObject:country220];
    
    
    
    IMSCountry *country221 = [[IMSCountry alloc] initWithISOCode:@"TT" centerLatitude:10.691803 centerLongitude:-61.222503];
    [self.myDataStore.countryObjects addObject:country221];
    
    IMSCountry *country222 = [[IMSCountry alloc] initWithISOCode:@"TV" centerLatitude:-7.109535 centerLongitude:177.64933];
    [self.myDataStore.countryObjects addObject:country222];
    
    IMSCountry *country223 = [[IMSCountry alloc] initWithISOCode:@"TW" centerLatitude:23.69781 centerLongitude:120.960515];
    [self.myDataStore.countryObjects addObject:country223];
    
    IMSCountry *country224 = [[IMSCountry alloc] initWithISOCode:@"TZ" centerLatitude:-6.369028 centerLongitude:34.888822];
    [self.myDataStore.countryObjects addObject:country224];
    
    IMSCountry *country225 = [[IMSCountry alloc] initWithISOCode:@"UA" centerLatitude:48.379433 centerLongitude:31.16558];
    [self.myDataStore.countryObjects addObject:country225];
    
    IMSCountry *country226 = [[IMSCountry alloc] initWithISOCode:@"UG" centerLatitude:1.373333 centerLongitude:32.290275];
    [self.myDataStore.countryObjects addObject:country226];
    
    IMSCountry *country227 = [[IMSCountry alloc] initWithISOCode:@"UM" centerLatitude:19.2823 centerLongitude:166.6470];
    [self.myDataStore.countryObjects addObject:country227];
    
    IMSCountry *country228 = [[IMSCountry alloc] initWithISOCode:@"US" centerLatitude:37.09024 centerLongitude:-95.712891];
    [self.myDataStore.countryObjects addObject:country228];
    
    IMSCountry *country229 = [[IMSCountry alloc] initWithISOCode:@"UY" centerLatitude:-32.522779 centerLongitude:-55.765835];
    [self.myDataStore.countryObjects addObject:country229];
    
    IMSCountry *country230 = [[IMSCountry alloc] initWithISOCode:@"UZ" centerLatitude:41.377491 centerLongitude:64.585262];
    [self.myDataStore.countryObjects addObject:country230];
    
    
    
    IMSCountry *country231 = [[IMSCountry alloc] initWithISOCode:@"VA" centerLatitude:41.902916 centerLongitude:12.453389];
    [self.myDataStore.countryObjects addObject:country231];
    
    IMSCountry *country232 = [[IMSCountry alloc] initWithISOCode:@"VC" centerLatitude:12.984305 centerLongitude:-61.287228];
    [self.myDataStore.countryObjects addObject:country232];
    
    IMSCountry *country233 = [[IMSCountry alloc] initWithISOCode:@"VE" centerLatitude:6.42375 centerLongitude:-66.58973];
    [self.myDataStore.countryObjects addObject:country233];
    
    IMSCountry *country234 = [[IMSCountry alloc] initWithISOCode:@"VG" centerLatitude:18.420695 centerLongitude:-64.639968];
    [self.myDataStore.countryObjects addObject:country234];
    
    IMSCountry *country235 = [[IMSCountry alloc] initWithISOCode:@"VI" centerLatitude:18.335765 centerLongitude:-64.896335];
    [self.myDataStore.countryObjects addObject:country235];
    
    IMSCountry *country236 = [[IMSCountry alloc] initWithISOCode:@"VN" centerLatitude:14.058324 centerLongitude:108.277199];
    [self.myDataStore.countryObjects addObject:country236];
    
    IMSCountry *country237 = [[IMSCountry alloc] initWithISOCode:@"VU" centerLatitude:-15.376706 centerLongitude:166.959158];
    [self.myDataStore.countryObjects addObject:country237];
    
    IMSCountry *country238 = [[IMSCountry alloc] initWithISOCode:@"WF" centerLatitude:-13.768752 centerLongitude:-177.156097];
    [self.myDataStore.countryObjects addObject:country238];
    
    IMSCountry *country239 = [[IMSCountry alloc] initWithISOCode:@"WS" centerLatitude:-13.759029 centerLongitude:-172.104629];
    [self.myDataStore.countryObjects addObject:country239];
    
    IMSCountry *country240 = [[IMSCountry alloc] initWithISOCode:@"XK" centerLatitude:42.602636 centerLongitude:20.902977];
    [self.myDataStore.countryObjects addObject:country240];
    
    
    
    IMSCountry *country241 = [[IMSCountry alloc] initWithISOCode:@"YE" centerLatitude:15.552727 centerLongitude:48.516388];
    [self.myDataStore.countryObjects addObject:country241];
    
    IMSCountry *country242 = [[IMSCountry alloc] initWithISOCode:@"YT" centerLatitude:-12.8275 centerLongitude:45.166244];
    [self.myDataStore.countryObjects addObject:country242];
    
    IMSCountry *country243 = [[IMSCountry alloc] initWithISOCode:@"ZA" centerLatitude:-30.559482 centerLongitude:22.937506];
    [self.myDataStore.countryObjects addObject:country243];
    
    IMSCountry *country244 = [[IMSCountry alloc] initWithISOCode:@"ZM" centerLatitude:-13.133897 centerLongitude:27.849332];
    [self.myDataStore.countryObjects addObject:country244];
    
    IMSCountry *country245 = [[IMSCountry alloc] initWithISOCode:@"ZW" centerLatitude:-19.015438 centerLongitude:29.154857];
    [self.myDataStore.countryObjects addObject:country245];
    
    
    
    // for me, when all sadnesses fall of the map
    NSDate *rightNow = [NSDate date]; // right now in absolute time
    NSTimeInterval timeIntervalSince1970 = [rightNow timeIntervalSince1970]; // in seconds
    NSLog(@"CURRENT DATE: %@", rightNow);
    NSLog(@"SECONDS SINCE 1970 FLOAT: %f", timeIntervalSince1970);
    NSLog(@"SECONDS SINCE 1970 NSUINT: %f", timeIntervalSince1970);
    
    // populating with a lot of fake people to see how map performs
    
    
//    for (NSUInteger i = 0; i < 240; i++) {
//        IMSCountry *aCountry = self.myDataStore.countryObjects[i];
//        
//        // random number for lat/long
//        CGFloat randomLatitude = ( arc4random() % 256 / 256.00000 );
//        CGFloat randomLongitude = ( arc4random() % 256 / 256.00000 );
//        
//        // Saving fake sadness
//        IMSSadness *fakeSadness = [IMSSadness new];
//        fakeSadness.sadnessID = @"QTVDOERERTItRjcxMy00RUU0LUJDN0YtM0QwQzY3NzlBQjBC";
//        fakeSadness.createdAtSec = timeIntervalSince1970 + i;
//        fakeSadness.createdAt = [NSString stringWithFormat:@"%@", rightNow];
//        fakeSadness.fromCity = @"Awesome City";
//        fakeSadness.fromCountry = @"Sunrise Country";
//        fakeSadness.fromCountryISOCode = aCountry.ISOCountryCode;
//        fakeSadness.toSadness = @"YXJuOmF3czpzbnM6dXMtZWFzdC0xOjUwOTM2NjkzNzczMjplbmRwb2ludC9BUE5TX1NBTkRCT1gvSW1TYWQwMS9hNTcxN2EwYi00NmQyLTMxOGItOWFkMC0wNDk2NmVkMGNjMzI=";
//        fakeSadness.gender = @"girl";
//        fakeSadness.latitude = aCountry.centerLatitude + randomLatitude;
//        fakeSadness.longitude = aCountry.centerLongitude + randomLongitude;
//        
////        NSLog(@"FAKE SADNESS SADNESS ID: %@", fakeSadness.sadnessID);
////        NSLog(@"FAKE SADNESS CREATED AT SEC: %lu", fakeSadness.createdAtSec);
////        NSLog(@"FAKE SADNESS CREATED AT: %@", fakeSadness.createdAt);
////        NSLog(@"FAKE SADNESS FROM CITY: %@", fakeSadness.fromCity);
////        NSLog(@"FAKE SADNESS FROM COUNTRY: %@", fakeSadness.fromCountry);
////        NSLog(@"FAKE SADNESS ISO: %@", fakeSadness.fromCountryISOCode);
////        NSLog(@"FAKE SADNESS TO SADNESS: %@", fakeSadness.toSadness);
////        NSLog(@"FAKE SADNESS SADNESS ID: %@", fakeSadness.sadnessID);
////        NSLog(@"FAKE SADNESS LATITUDE: %.12f", fakeSadness.latitude);
////        NSLog(@"FAKE SADNESS LONGITUDE: %.12f", fakeSadness.longitude);
//        
//        [DDBDynamoDBManager saveSadnessToDynamoDB:fakeSadness];
//        
//    }

    
}



@end



//
//  ViewController.h
//  ImSadApp
//
//  Created by Inga on 3/23/16.
//  Copyright © 2016 Inga. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KerningLabel.h"
#import <AVFoundation/AVFoundation.h>
#import "KerningTextView.h"
#import <AWSS3/AWSS3.h>
#import "IMSAnnotation.h"
#import "IMSCheerSadViewController.h"
#import "IMSIntroViewController.h"
#import "IMSSelectGenderViewController.h"
#import "IMSGiftViewController.h"
#import "IMSGiftInboxViewController.h"
#import "IMSDataStore.h"
#import <AdSupport/ASIdentifierManager.h>


@interface IMSIntroViewController : UIViewController

@property (nonatomic, strong) SKProductsRequest *productRequest;
@property (nonatomic, strong) NSArray *products;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (weak, nonatomic) IBOutlet UIImageView *faceAnimationView;
@property (nonatomic, strong) CAKeyframeAnimation *faceAnimation;
@property (nonatomic, strong) NSTimer *timer1;
@property (nonatomic, strong) NSTimer *timer2;
@property (nonatomic, strong) NSTimer *timer3;
@property (nonatomic, strong) NSTimer *timer4;
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet KerningLabel *buttonLabel;
@property (weak, nonatomic) IBOutlet KerningTextView *bodyCopy;
@property (weak, nonatomic) IBOutlet KerningLabel *connectingLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;


- (void)goToSelectGenderScreen;

- (void)goToHomeScreen;

- (void)goToInboxScreen;

- (void)goToHomeScreen:(NSNotification *)notification;

- (void)goToGiftViewFromIntroVC:(NSNotification *)notification;

- (void)goToThankyouViewFromIntroVC:(NSNotification *)notification;

- (void)setupConnectingState;

- (void)setupOnBoardingState:(NSNotification *)notification;

- (void)setupNoServerConnectionState:(NSNotification *)notification;

- (void)setUpAVAudioPlayerWithFileName:(NSString *)fileName;

- (void)playConnectingAnimation;

- (void)playNoConnectionAnimation;

- (void)playSuccessfullyConnectedAnimation;

- (void)downloadJSONFromAWSS3WithCompletion:(void (^)(NSData *myJsonData))completionBlock;

- (void)parseJsonWithData:(NSData *)data completion:(void (^)(BOOL success))completionBlock;

- (void)checkInternetConnection;

- (void)checkForUserExistenceAndGiftsThankyous;

- (void)checkIfUserExistsWithCompletion:(void (^)(NSString *userGender, BOOL success))completionBlock;


@end
















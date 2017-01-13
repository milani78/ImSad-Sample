//
//  IMS-Sad-Or-Cheer-ViewController.h
//  ImSadApp
//
//  Created by Inga on 4/6/16.
//  Copyright © 2016 Inga. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLAvailability.h>
#import <MapKit/MapKit.h>
#import <AWSDynamoDB/AWSDynamoDB.h>
#import "DDBDynamoDBManager.h"
#import <AVFoundation/AVFoundation.h>
#import "IMSSadness.h"
#import "IMSDataStore.h"
#import "IMSIntroViewController.h"
#import "IMSCheerMapViewController.h"
#import "IMSSelectGenderViewController.h"
#import "IMSCountry.h"
#import "IMSGiftViewController.h"
#import "KerningTextView.h"


@interface IMSCheerSadViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) IMSSadness *mySadness;
@property (weak, nonatomic) IBOutlet UIImageView *giftBoxView;
@property (nonatomic, strong) CAKeyframeAnimation *giftBoxAnimation;
@property (weak, nonatomic) IBOutlet UIImageView *sadFaceView;
@property (nonatomic, strong) CAKeyframeAnimation *sadFaceAnimation;
@property (weak, nonatomic) IBOutlet UIImageView *viewBackground;
@property (weak, nonatomic) IBOutlet UIButton *cheerButton;
@property (weak, nonatomic) IBOutlet UIButton *sadButton;
@property (weak, nonatomic) IBOutlet UIImageView *rainView;
@property (nonatomic, strong) CAKeyframeAnimation *rainAnimation;
@property (weak, nonatomic) IBOutlet KerningLabel *cheerLabel;
@property (weak, nonatomic) IBOutlet KerningLabel *imSadLabel;
@property (nonatomic) BOOL imsadGpsAlertIsDisplayed;
//menu:
@property (weak, nonatomic) IBOutlet UIImageView *menuTopBarImage;
@property (weak, nonatomic) IBOutlet UIButton *menuBtn1;
@property (weak, nonatomic) IBOutlet UILabel *menuBtn1Label;
@property (weak, nonatomic) IBOutlet UIImageView *menuBtn1BoxImage;
@property (weak, nonatomic) IBOutlet UIButton *menuBtn2;
@property (weak, nonatomic) IBOutlet UIImageView *menuBtn2Stars;
@property (weak, nonatomic) IBOutlet UIButton *menuBtn3;
@property (weak, nonatomic) IBOutlet UIButton *menuBtnOpinion;
@property (weak, nonatomic) IBOutlet UIButton *menuBtn4;
@property (weak, nonatomic) IBOutlet UIButton *menuBtn5;
@property (weak, nonatomic) IBOutlet UIButton *menuBtn6;
@property (weak, nonatomic) IBOutlet UIScrollView *menuScrollView;
@property (weak, nonatomic) IBOutlet UIButton *menuCloseBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *menuConstraint;
@property (weak, nonatomic) IBOutlet UIButton *menuIcon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *menuIconConstraint;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapGestureRecognizerCheerBtn;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapGestureRecognizerSadBtn;
//error view
@property (weak, nonatomic) IBOutlet UIView *errorView;
@property (weak, nonatomic) IBOutlet UIImageView *errorAnimationView;
@property (nonatomic, strong) CAKeyframeAnimation *errorAnimation;
@property (weak, nonatomic) IBOutlet UIImageView *errorAnimationBase;
@property (weak, nonatomic) IBOutlet KerningLabel *errorConnectingLabel;
@property (weak, nonatomic) IBOutlet KerningLabel *errorButtonLabel;
@property (weak, nonatomic) IBOutlet UIButton *errorButton;
@property (weak, nonatomic) IBOutlet UIImageView *errorBackground;
@property (nonatomic, strong) NSTimer *timer1;
@property (nonatomic, strong) NSTimer *timer2;
@property (nonatomic, strong) NSTimer *timer3;
//sad timer
@property (weak, nonatomic) IBOutlet UIImageView *sadFaceForTimer;
@property (weak, nonatomic) IBOutlet KerningLabel *sadLabelForTimer;
@property (weak, nonatomic) IBOutlet KerningLabel *timeCounterForTimer;
@property (nonatomic, strong) NSTimer *timerForCountUp;
@property (nonatomic) NSUInteger counter;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeCounterLabelBottomConstraint;
//cheer timer
@property (weak, nonatomic) IBOutlet KerningLabel *cheerLabelForTimer;
@property (weak, nonatomic) IBOutlet KerningLabel *cheerTimeCounterForTimer;
@property (nonatomic, strong) NSTimer *cheerTimerForCountDown;
@property (nonatomic) NSUInteger peopleCounter;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cheerTimeCounterLabelBottomConstraint; // -45
//sorry view
@property (weak, nonatomic) IBOutlet UIView *sorryView;
@property (weak, nonatomic) IBOutlet KerningTextView *sorryTextView1;
@property (weak, nonatomic) IBOutlet KerningTextView *sorryTextView2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sorryTextView1TopConstraint; // 34
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sorryTextView1BottomConstraint; // 6
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sorryTextView1WidthConstraint; // .8
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sorryTextView1HeightConstraint; // 90
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sorryTextView2WidthConstraint; // .8
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sorryTextView2HeightConstraint; // 300
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;


- (void)showImSadButton;

- (void)showCheerSomeoneButton;

- (void)show48HourTimer;

- (void)show3HourTimer;

- (void)hideCheerSomeoneButton;

- (void)countDownPeople;

- (void)countUp;

- (void)showSorryScreen;

- (void)updateUserInDynamoWithIsntSad;

- (IBAction)cheerButtonTapped:(UIButton *)sender;

- (IBAction)imSadButtonTapped:(UIButton *)sender;

- (IBAction)hamburgerButtonPressed:(UIButton *)sender;

- (IBAction)tryAgainButtonTapped:(UIButton *)sender;

- (IBAction)closeSorryViewButtonPressed:(UIButton *)sender;

- (IBAction)cheerButtonPressedInSorryView:(UIButton *)sender;

- (void)setupConnecting;

- (void)setupNoServerConnection;

- (void)switchToGiftIcon:(NSNotification *)notification;

- (void)goToGiftScreenWithCheer:(NSNotification *)notification;

- (void)goToGiftScreenWithThankyou:(NSNotification *)notification;

- (void)queryDynamoDBForCheerAndThankyous;

- (IBAction)backgroundWasTapped:(UITapGestureRecognizer *)sender;

- (IBAction)menuCloseButtonPressed:(UIButton *)sender;

- (void)closeMenu;

- (void)playGiftBoxAnimation;
    
- (void)playSadFaceAnimation;

- (void)playRainAnimation;

- (void)playConnectingAnimation;

- (void)playNoServerConnectionAnimation;

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag;

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender;

- (void)checkLocationPermissions;

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status;

- (void)scanAWSForAllSadnessesAndSaveLocallyWithCompletion:(void (^)(BOOL success))completionBlock;

- (void)goToCheerMap:(NSNotification *)notification;

- (void)goToSadMap:(NSNotification *)notification;

- (void)displayAppSettingsAlert;

- (void)displayLocationSettingsAlert;

- (void)getLocationDateCityCountryWithCompletion:(void (^)(BOOL success))completionBlock;

- (void)setUpAVAudioPlayerWithFileName:(NSString *)fileName;

- (void)checkConnection;

- (NSUInteger)getMinutesBetweenOriginalTimeAndNow:(NSUInteger)createdAtSec;

- (void)handleApplicationInBackground:(NSNotification *)notification;

- (void)cleanup;


@end








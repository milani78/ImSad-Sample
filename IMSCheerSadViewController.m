//
//  IMS-Sad-Or-Cheer-ViewController.m
//  ImSadApp
//
//  Created by Inga on 4/6/16.
//  Copyright © 2016 Inga. All rights reserved.
//

#import "IMSCheerSadViewController.h"


@interface IMSCheerSadViewController ()

@property (nonatomic, strong) IMSDataStore *myDataStore;

@end


@implementation IMSCheerSadViewController



- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:YES];
    
    NSLog(@"IN viewWillAppear CheerSad");
    
    self.errorView.hidden = YES;
    self.sadFaceView.hidden = YES;
    self.imSadLabel.hidden = YES;
    self.sadLabelForTimer.hidden = YES;
    self.sadLabelForTimer.hidden = YES;
    self.timeCounterForTimer.hidden = YES;
    self.cheerLabelForTimer.hidden = YES;
    self.cheerTimeCounterForTimer.hidden = YES;
    [self hideCheerSomeoneButton];

    
    self.myDataStore = [IMSDataStore sharedDataStore];
    
    self.imsadGpsAlertIsDisplayed = NO;
    
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{

        self.errorBackground.image = [UIImage imageNamed:@"02_Boy_Girl_connecting_bg.png"];
        [self.errorButton setBackgroundImage:[UIImage imageNamed:@"04_alert_btn_default.png"] forState:UIControlStateNormal];
        [self.errorButton setBackgroundImage:[UIImage imageNamed:@"04_alert_btn_hl.png"] forState:UIControlStateHighlighted];

        
        if (self.myDataStore.isiPhone5 == YES) {
            
            NSLog(@"iPhone 5 View");
            if ([self.sadLabelForTimer.text isEqualToString:@"You’ve been sad for"]) {
                // - 45 originally
                self.timeCounterLabelBottomConstraint.constant = -28;
                NSLog(@"aaa");
            }
            
        } else {
            NSLog(@"Not iPhone 5 View");
        }

        
        NSDate *currentDate = [NSDate date]; // also absolute time
        NSTimeInterval timeIntervalSince1970 = [currentDate timeIntervalSince1970]; // in seconds
        NSUInteger last48HoursInSeconds = timeIntervalSince1970 - 172800;
        NSUInteger last3HoursInSeconds = timeIntervalSince1970 - self.myDataStore.peopleTimerInterval;
        

        
        // Setting up poeple counter if the user has cheered up 5 people within the past 3 hours
        
        if (self.myDataStore.latestPeopleTimerStartedAtSec != 0 && self.myDataStore.latestPeopleTimerStartedAtSec > last3HoursInSeconds) {

            NSLog(@"SETTING UP PEOPLE COUNTER");
            
            if (self.myDataStore.isiPhone5 == YES) {
                self.cheerTimeCounterLabelBottomConstraint.constant = -75;
            } else {
                self.cheerTimeCounterLabelBottomConstraint.constant = -100;
            }

            self.peopleCounter = self.myDataStore.latestPeopleTimerStartedAtSec - last3HoursInSeconds;
            NSLog(@"self.peopleCounter = last 3 hours in seconds supposed to be < 10800. actual: %lu", self.peopleCounter);

            self.cheerTimerForCountDown = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDownPeople) userInfo:nil repeats:YES];
            
            [self hideCheerSomeoneButton];
            [self show3HourTimer];
    
        } else {
            
            [self showCheerSomeoneButton];
        }
        
        
        
        if ((self.myDataStore.existingUser != nil && self.myDataStore.existingUser.latestSadnessAnnouncedAtSec) ||
            (self.myDataStore.existingUser == nil && self.myDataStore.latestSadnessAnnouncedAtSec)) {
        
            // hide + disable i'm sad button
            self.sadFaceView.hidden = YES;
            self.imSadLabel.hidden = YES;
            self.sadButton.enabled = NO;
            
            NSLog(@"self.myDataStore.existingUser.latestSadnessAnnouncedAtSec before: %lu", self.myDataStore.existingUser.latestSadnessAnnouncedAtSec);
            
            NSUInteger minutesSinceUserAnnouncedSadness = [self getMinutesBetweenOriginalTimeAndNow:self.myDataStore.existingUser.latestSadnessAnnouncedAtSec];
            
            NSLog(@"minutesSinceUserAnnouncedSadness before * 60: %lu", minutesSinceUserAnnouncedSadness);
            
            NSLog(@"self.myDataStore.existingUser.latestSadnessAnnouncedAtSec: %lu", self.myDataStore.existingUser.latestSadnessAnnouncedAtSec);
            NSLog(@"self.myDataStore.existingUser.latestCheeredAtSec: %lu", self.myDataStore.existingUser.latestCheeredAtSec);
            NSLog(@"minutesSinceUserAnnouncedSadness: %lu", minutesSinceUserAnnouncedSadness);
            
            
            self.counter = timeIntervalSince1970 - self.myDataStore.existingUser.latestSadnessAnnouncedAtSec;
            NSLog(@"self.counter = minutesSinceUserAnnouncedSadness * 60: %lu", self.counter);
            
            
            if (minutesSinceUserAnnouncedSadness < 2880 && self.myDataStore.existingUser.latestCheeredAtSec &&
                self.myDataStore.existingUser.latestSadnessAnnouncedAtSec > self.myDataStore.existingUser.latestCheeredAtSec) {
                
                NSLog(@"1. existingUser EXIST + latestSadnessAnnouncedAtSec > latestCheeredAtSec");
                
                // Setting appropriate color for the face
                if (minutesSinceUserAnnouncedSadness >= 0 && minutesSinceUserAnnouncedSadness < 480) {
                    [self.sadFaceForTimer setImage:[UIImage imageNamed:@"big_sad_face_00-08_2x.png"]];
                }
                if (minutesSinceUserAnnouncedSadness >= 480 && minutesSinceUserAnnouncedSadness < 960) {
                    [self.sadFaceForTimer setImage:[UIImage imageNamed:@"big_sad_face_08-16_2x.png"]];
                }
                if (minutesSinceUserAnnouncedSadness >= 960 && minutesSinceUserAnnouncedSadness < 1440) {
                    [self.sadFaceForTimer setImage:[UIImage imageNamed:@"big_sad_face_16-24_2x.png"]];
                }
                if (minutesSinceUserAnnouncedSadness >= 1440 && minutesSinceUserAnnouncedSadness < 2160) {
                    [self.sadFaceForTimer setImage:[UIImage imageNamed:@"big_sad_face_24-36_2x.png"]];
                }
                if (minutesSinceUserAnnouncedSadness >= 2160 && minutesSinceUserAnnouncedSadness < 2880) {
                    [self.sadFaceForTimer setImage:[UIImage imageNamed:@"big_sad_face_36-48_2x.png"]];
                }
                
                self.timerForCountUp = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countUp) userInfo:nil repeats:YES];
                
                [self show48HourTimer];
        
            }
            
            if ((minutesSinceUserAnnouncedSadness < 2880 && self.myDataStore.existingUser.latestCheeredAtSec) &&
                (self.myDataStore.existingUser.latestSadnessAnnouncedAtSec < self.myDataStore.existingUser.latestCheeredAtSec)) {
                
                NSLog(@"2. existingUser EXIST + latestSadnessAnnouncedAtSec < latestCheeredAtSec");
                
                [self showImSadButton];
                
            }
            
            if (minutesSinceUserAnnouncedSadness < 2880 && !self.myDataStore.existingUser.latestCheeredAtSec) {
                // Setting appropriate color for the face
                
                NSLog(@"3. existingUser EXIST latestCheeredAtSec DOES NOT EXIST");
                
                if (minutesSinceUserAnnouncedSadness >= 0 && minutesSinceUserAnnouncedSadness < 480) {
                    [self.sadFaceForTimer setImage:[UIImage imageNamed:@"big_sad_face_00-08_2x.png"]];
                }
                if (minutesSinceUserAnnouncedSadness >= 480 && minutesSinceUserAnnouncedSadness < 960) {
                    [self.sadFaceForTimer setImage:[UIImage imageNamed:@"big_sad_face_08-16_2x.png"]];
                }
                if (minutesSinceUserAnnouncedSadness >= 960 && minutesSinceUserAnnouncedSadness < 1440) {
                    [self.sadFaceForTimer setImage:[UIImage imageNamed:@"big_sad_face_16-24_2x.png"]];
                }
                if (minutesSinceUserAnnouncedSadness >= 1440 && minutesSinceUserAnnouncedSadness < 2160) {
                    [self.sadFaceForTimer setImage:[UIImage imageNamed:@"big_sad_face_24-36_2x.png"]];
                }
                if (minutesSinceUserAnnouncedSadness >= 2160 && minutesSinceUserAnnouncedSadness < 2880) {
                    [self.sadFaceForTimer setImage:[UIImage imageNamed:@"big_sad_face_36-48_2x.png"]];
                }
                
                self.timerForCountUp = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countUp) userInfo:nil repeats:YES];
                
                [self show48HourTimer];
                
            }
            
            
            // when someone cheers you, they (the cheerer) update your user table with isSadNow = NO and latestCheeredAtSec
            
            // when app was closed
            // you fall off the map, nobody cheered you, your isSadNow is still = YES, which is not correct
            // we need to update isSadNow = NO  +  show you the sorry screen
            // latestSadnessAnnouncedAtSec   latestCheeredAtSec   isSadNow
            
            // if  latestSadnessAnnouncedAtSec > latestCheeredAtSec and isSadNow = YES
            // then show sorry screen and update the user
            
            if ((minutesSinceUserAnnouncedSadness > 2880 && !self.myDataStore.existingUser.latestCheeredAtSec) ||
                
                (minutesSinceUserAnnouncedSadness > 2880 &&
                 self.myDataStore.existingUser.latestSadnessAnnouncedAtSec > self.myDataStore.existingUser.latestCheeredAtSec &&
                 [self.myDataStore.isSadNow isEqualToString:@"yes"])) {
                    
                    NSLog(@"USER DID NOT GET A GIFT AND FELL OFF THE MAP AFTER 48 HOURS");
                    
                    // show sorry screen, update the user
                    [self showSorryScreen];
                    [self updateUserInDynamoWithIsntSad];
            }
            
            
        }
        
        if ((self.myDataStore.existingUser == nil && !self.myDataStore.latestSadnessAnnouncedAtSec) ||
            (self.myDataStore.existingUser != nil && !self.myDataStore.existingUser.latestSadnessAnnouncedAtSec) ||
            (self.myDataStore.existingUser != nil &&
            (self.myDataStore.existingUser.latestSadnessAnnouncedAtSec < last48HoursInSeconds))) {  // > 48 hrs
            
            NSLog(@"4. existingUser DOES NOT EXIST  or  existingUser EXISTS but latestSadnessAnnouncedAtSec DOES NOT EXIST   or   existingUser DOES NOT EXIST and latestSadnessAnnouncedAtSec > 48 hrs");
            
            [self showImSadButton];
                
        }
        
        
        
        
        
        [self.giftBoxView setImage:[UIImage imageNamed:@"04_01_gift_box_select_jump_2x.png"]];

        [self.cheerButton setBackgroundImage:[UIImage imageNamed:@"03_ImSad_Cheer_cheer_cta_default.png"] forState:UIControlStateNormal];
        [self.cheerButton setBackgroundImage:[UIImage imageNamed:@"03_ImSad_Cheer_cheer_cta_highlighted.png"] forState:UIControlStateHighlighted];        
        [self.viewBackground setImage:[UIImage imageNamed:@"02_Boy_Girl_bg.jpg"]];

        [self playRainAnimation];
        
        [self.menuBtn2Stars setImage:[UIImage imageNamed:@"04_menu_btn_stars.png"]];
        [self.menuBtn1BoxImage setImage:[UIImage imageNamed:@"26_inbox_box_icon.png"]];
        [self.menuTopBarImage setImage:[UIImage imageNamed:@"26_bg_top.png"]];
        self.menuBtn1Label.text = [NSString stringWithFormat:@"(%lu)", (unsigned long)self.myDataStore.inboxCount];
        
        if (self.myDataStore.inboxCount > 0) {
            
            [UIView animateWithDuration:.6 animations:^{
                // set gift icon
                [self.menuIcon setImage:[UIImage imageNamed:@"04_gift_icon.png"] forState:UIControlStateNormal];
                self.menuIconConstraint.constant = -6;
                [self.view setNeedsUpdateConstraints];
            }];
        }

        if (self.myDataStore.inboxCount == 0) {
            
            [UIView animateWithDuration:.6 animations:^{
                // set hamburger icon
                [self.menuIcon setImage:[UIImage imageNamed:@"25_hamburger_orange.png"] forState:UIControlStateNormal];
                self.menuIconConstraint.constant = -17;
                [self.view setNeedsUpdateConstraints];
            }];
        }

    }];
    
    
    [self setUpAVAudioPlayerWithFileName:@"select_im_sad"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToGiftScreenWithCheer:) name:@"cheerRecievedViaSNS" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToGiftScreenWithThankyou:) name:@"thankyouRecievedViaSNS" object:nil];    

}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    NSLog(@"IN viewDidLoad CheerSad");
    
    self.tapGestureRecognizerCheerBtn.cancelsTouchesInView = NO;
    self.tapGestureRecognizerSadBtn.cancelsTouchesInView = NO;
    
    self.menuScrollView.contentSize = CGSizeMake(self.menuScrollView.contentSize.width, 740);
    [self.view setNeedsUpdateConstraints];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationInBackground:) name:@"applicationDidEnterBackground" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(switchToGiftIcon:) name:@"giftOrThankyouRecievedViaSNSButUserTappedClose" object:nil];
    
    
    // Removing not needed views
    NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    //NSLog(@"cheer sad self.navigationController.viewControllers: %@", viewControllers);
    
    NSMutableArray *viewControllersToRemove = [NSMutableArray array];
    
    for (UIViewController *aViewController in viewControllers)  {
        NSLog(@"in view controllers to delete loop");
        
        if([aViewController isKindOfClass:[IMSSelectGenderViewController class]]) {
            
            [viewControllersToRemove addObject:aViewController];
            NSLog(@"in view controllers to delete method");
        }
    }
    
    [viewControllers removeObjectsInArray:viewControllersToRemove];
    self.navigationController.viewControllers = viewControllers;
    
    
}


- (void)showImSadButton {
    
    // hide counter and its face
    self.sadFaceForTimer.hidden = YES;
    self.sadLabelForTimer.hidden = YES;
    self.timeCounterForTimer.hidden = YES;
    
    // show i'm sad button
    [UIView animateWithDuration:.4 animations:^{
        self.sadButton.enabled = YES;
        [self.sadFaceView setImage:[UIImage imageNamed:@"05_01_animation_select_im_sad_2x.png"]];
        self.sadFaceView.hidden = NO;
        self.imSadLabel.hidden = NO;
    }];
    
}


- (void)showCheerSomeoneButton {
    
    [UIView animateWithDuration:.4 animations:^{
        // show cheer someone button
        self.cheerButton.enabled = YES;
        [self.giftBoxView setImage:[UIImage imageNamed:@"04_01_gift_box_select_jump_2x.png"]];
        self.giftBoxView.hidden = NO;
        self.cheerLabel.hidden = NO;
    }];

}

- (void)show48HourTimer {
    
    if (self.myDataStore.isiPhone5 == YES) {
        self.timeCounterLabelBottomConstraint.constant = -28;
    }
    self.sadLabelForTimer.text = @"You’ve been sad for";
    self.sadFaceForTimer.hidden = NO;
    self.sadLabelForTimer.hidden = NO;
    self.timeCounterForTimer.hidden = NO;
    
}


- (void)show3HourTimer {

    self.cheerLabelForTimer.text = @"Please wait to cheer more sad people";
    self.cheerLabelForTimer.hidden = NO;
    self.cheerTimeCounterForTimer.hidden = NO;

}


- (void)hideCheerSomeoneButton {
    
    self.cheerButton.enabled = NO;
    self.giftBoxView.hidden = YES;
    self.cheerLabel.hidden = YES;
    
}


- (void)countDownPeople {
    
    self.peopleCounter--;
    
    NSUInteger seconds = self.peopleCounter;
    NSUInteger minutes = seconds/60;
    NSUInteger hours = minutes/60;
    
    self.cheerTimeCounterForTimer.text = [NSString stringWithFormat:@"%02lu:%02lu:%02lu", hours%60, minutes%60, seconds%60];
    
    if (self.peopleCounter == 0) {
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [UIView animateWithDuration:.4 animations:^{
                // hide counter
                self.cheerLabelForTimer.hidden = YES;
                self.cheerTimeCounterForTimer.hidden = YES;
                [self.cheerTimerForCountDown invalidate];
            }];
            [UIView animateWithDuration:.4 animations:^{
                // show cheer someone button
                self.cheerButton.enabled = YES;
                [self.giftBoxView setImage:[UIImage imageNamed:@"04_01_gift_box_select_jump_2x.png"]];
                self.giftBoxView.hidden = NO;
                self.cheerLabel.hidden = NO;
            }];
        }];
    }
    
}


- (void)countUp {
    
    self.counter++;
    
    NSUInteger seconds = self.counter;
    NSUInteger minutes = seconds/60;
    NSUInteger hours = minutes/60;
    
    self.timeCounterForTimer.text = [NSString stringWithFormat:@"%02lu:%02lu:%02lu", hours%60, minutes%60, seconds%60];

    
    // when counter reaches 48 hrs, and nobody has sent you a gift,
    // show sorry overlay and update user table
    if (self.counter == 172800) {
        
        NSLog(@"YOU'VE BEEN SAD FOR 48 HOURS!!!!!");
        
        [self showSorryScreen];
        
        [self updateUserInDynamoWithIsntSad];
        
    }
    
}


- (void)showSorryScreen {
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        if (self.myDataStore.isiPhone5 == YES) {
            NSLog(@"iPhone 5 View");
            
            NSString *text1Copy = @"48 hours have passed and you are no longer on the sad map. If you are still feeling sad, please try again.";
            NSMutableAttributedString *attrString1 = [[NSMutableAttributedString alloc] initWithString:text1Copy];
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
            paragraphStyle.alignment = NSTextAlignmentCenter;
            [paragraphStyle setLineSpacing:3.6];
            
            [attrString1 beginEditing];
            
            [attrString1 addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Lato-Bold" size:15] range:NSMakeRange(0, text1Copy.length)];
            [attrString1 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, text1Copy.length)];
            [attrString1 addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:240.0f/255.0f green:86.0f/255.0f blue:83.0f/255.0f alpha:1.0f] range:NSMakeRange(0, text1Copy.length)];
            
            self.sorryTextView1.attributedText = attrString1;
            
            
            NSString *text2Copy = @"Some of the greatest people who have ever lived such as Mother Theresa, Gandhi and Martin Luther King gave of themselves to many without limit or earthly reward. Rather than being disappointed that you were overlooked this time, go forth and cheer. \nLift someone up and you may end up lifting yourself in the process.";
            NSMutableAttributedString *attrString2 = [[NSMutableAttributedString alloc] initWithString:text2Copy];
            NSMutableParagraphStyle *paragraphStyle2 = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
            paragraphStyle2.alignment = NSTextAlignmentCenter;
            paragraphStyle2.paragraphSpacing = 16;
            [paragraphStyle2 setLineSpacing:3.5];
            
            [attrString2 beginEditing];
            
            [attrString2 addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Lato-Regular" size:15] range:NSMakeRange(0, text2Copy.length)];
            [attrString2 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle2 range:NSMakeRange(0, text2Copy.length)];
            [attrString2 addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:240.0f/255.0f green:86.0f/255.0f blue:83.0f/255.0f alpha:1.0f] range:NSMakeRange(0, text2Copy.length)];
            
            self.sorryTextView2.attributedText = attrString2;
            
            self.sorryTextView1TopConstraint.constant = 8;
            self.sorryTextView1BottomConstraint.constant = 3;
            self.sorryTextView1HeightConstraint.constant = 80;
            self.sorryTextView1WidthConstraint.constant = 30;
            self.sorryTextView2WidthConstraint.constant = 20;
            
        } else {
            NSLog(@"Not iPhone 5 View");
            
            NSString *text1Copy = @"48 hours have passed and you are no longer on the sad map. If you are still feeling sad, please try again.";
            NSMutableAttributedString *attrString1 = [[NSMutableAttributedString alloc] initWithString:text1Copy];
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
            paragraphStyle.alignment = NSTextAlignmentCenter;
            [paragraphStyle setLineSpacing:6.3];
            
            [attrString1 beginEditing];
            
            [attrString1 addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Lato-Bold" size:15] range:NSMakeRange(0, text1Copy.length)];
            [attrString1 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, text1Copy.length)];
            [attrString1 addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:240.0f/255.0f green:86.0f/255.0f blue:83.0f/255.0f alpha:1.0f] range:NSMakeRange(0, text1Copy.length)];
            
            self.sorryTextView1.attributedText = attrString1;
        }
        
        
        [UIView animateWithDuration:.4 animations:^{
            // show sorry overlay here
            NSLog(@"show sorry overlay here");
            self.sorryView.hidden = NO;
        }];
        [UIView animateWithDuration:.4 animations:^{
            // hide counter and its face
            self.sadFaceForTimer.hidden = YES;
            self.sadLabelForTimer.hidden = YES;
            self.timeCounterForTimer.hidden = YES;
            [self.timerForCountUp invalidate];
        }];
        [UIView animateWithDuration:.4 animations:^{
            // show i'm sad button
            self.sadButton.enabled = YES;
            [self.sadFaceView setImage:[UIImage imageNamed:@"05_01_animation_select_im_sad_2x.png"]];
            self.sadFaceView.hidden = NO;
            self.imSadLabel.hidden = NO;
        }];
    }];
    
}


- (void)updateUserInDynamoWithIsntSad {
    
    
    if (![self.myDataStore.userID isEqualToString:self.myDataStore.developerSadnessID]) {
        self.myDataStore.isSadNow = @"no";
        
        if (self.myDataStore.existingUser != nil) {
            self.myDataStore.existingUser.isSadNow = @"no";
        }
    }
    if ([self.myDataStore.userID isEqualToString:self.myDataStore.developerSadnessID]) {
        self.myDataStore.isSadNow = @"yes";
        
        if (self.myDataStore.existingUser != nil) {
            self.myDataStore.existingUser.isSadNow = @"yes";
        }
    }
    
    
    // Updating user in DB with the latest sadness timestamp and their location
    if (self.myDataStore.existingUser.userID != nil &&
        ![self.myDataStore.userID isEqualToString:self.myDataStore.developerSadnessID]) {
        
        NSLog(@"THIS IS EXISTING USER, SAVING THEIR CURRENT LOCATION");
        
        // updating user in DB with the latest sadness timestamp and their location
        IMSUser *updatedUser = [IMSUser new];
        updatedUser.userID = self.myDataStore.existingUser.userID;
        updatedUser.dateJoined = self.myDataStore.existingUser.dateJoined;
        updatedUser.latestSadnessAnnouncedAtSec = self.myDataStore.latestSadnessAnnouncedAtSec;
        if (self.myDataStore.latestCheeredAtSec != 0) {
            updatedUser.latestCheeredAtSec = self.myDataStore.latestCheeredAtSec;
        }
        updatedUser.badgeNumber = self.myDataStore.inboxCount;
        if (![self.myDataStore.latestGiftName isEqualToString:@""]) {
            updatedUser.latestGiftName = self.myDataStore.latestGiftName;
        }
        updatedUser.numberOfShares = self.myDataStore.numberOfShares;
        updatedUser.gender = self.myDataStore.existingUser.gender;
        updatedUser.type = self.myDataStore.existingUser.type;
        updatedUser.fromCity = self.myDataStore.fromCity;
        updatedUser.fromCountry = self.myDataStore.fromCountry;
        updatedUser.isSadNow = @"no";
        if (self.myDataStore.latestPeopleTimerStartedAtSec != 0) {
            updatedUser.latestPeopleTimerStartedAtSec = self.myDataStore.latestPeopleTimerStartedAtSec;
        }
        if (self.myDataStore.numberOfPeopleCheered != 0) {
            updatedUser.numberOfPeopleCheered = self.myDataStore.numberOfPeopleCheered;
        }
        
//        NSLog(@"updatedUser.userID: %@", updatedUser.userID);
//        NSLog(@"updatedUser.dateJoined: %@", updatedUser.dateJoined);
//        NSLog(@"updatedUser.latestSadnessAnnouncedAtSec: %lu", updatedUser.latestSadnessAnnouncedAtSec);
//        NSLog(@"updatedUser.badgeNumber: %lu", updatedUser.badgeNumber);
//        NSLog(@"updatedUser.numberOfShares: %lu", updatedUser.numberOfShares);
//        NSLog(@"updatedUser.gender: %@", updatedUser.gender);
//        NSLog(@"updatedUser.type: %@", updatedUser.type);
//        NSLog(@"updatedUser.fromCity: %@", updatedUser.fromCity);
//        NSLog(@"updatedUser.fromCountry: %@", updatedUser.fromCountry);
        
        [DDBDynamoDBManager saveUserToDynamoDB:updatedUser];
    }
    
    if (self.myDataStore.existingUser.userID == nil &&
        ![self.myDataStore.userID isEqualToString:self.myDataStore.developerSadnessID]) {
        
        NSLog(@"USER DOES NOT EXIST YET");
        
        // updating user in DB with the latest sadness timestamp and their location
        IMSUser *updatedUser = [IMSUser new];
        updatedUser.userID = self.myDataStore.userID;
        updatedUser.dateJoined = self.myDataStore.dateJoined;
        updatedUser.latestSadnessAnnouncedAtSec = self.myDataStore.latestSadnessAnnouncedAtSec;
        if (self.myDataStore.latestCheeredAtSec != 0) {
            updatedUser.latestCheeredAtSec = self.myDataStore.latestCheeredAtSec;
        }
        updatedUser.badgeNumber = self.myDataStore.inboxCount;
        updatedUser.numberOfShares = self.myDataStore.numberOfShares;
        updatedUser.gender = self.myDataStore.gender;
        updatedUser.type = self.myDataStore.type;
        updatedUser.fromCity = self.myDataStore.fromCity;
        updatedUser.fromCountry = self.myDataStore.fromCountry;
        updatedUser.isSadNow = @"no";
        if (self.myDataStore.latestPeopleTimerStartedAtSec != 0) {
            updatedUser.latestPeopleTimerStartedAtSec = self.myDataStore.latestPeopleTimerStartedAtSec;
        }
        if (self.myDataStore.numberOfPeopleCheered != 0) {
            updatedUser.numberOfPeopleCheered = self.myDataStore.numberOfPeopleCheered;
        }
        
        [DDBDynamoDBManager saveUserToDynamoDB:updatedUser];
    }
    
}


- (IBAction)cheerButtonTapped:(UIButton *)sender {
    
    NSLog(@"CHEER BUTTON TAPPED!");
    
    self.myDataStore.mapColorState = @"yellow";
    
    self.cheerButton.enabled = false;
    
    [self setUpAVAudioPlayerWithFileName:@"select_cheer_someone"];
    [self.audioPlayer play];
    [self playGiftBoxAnimation];
    
    self.timer1 = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(checkConnection) userInfo:nil repeats:NO];
    self.timer3 = [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(setupConnecting) userInfo:nil repeats:NO];
    
}


- (IBAction)imSadButtonTapped:(UIButton *)sender {
    
    NSLog(@"I'M SAD BUTTON TAPPED!");
    
    self.sadButton.enabled = false;
    
    [self.audioPlayer play];
    [self playSadFaceAnimation];
    
    self.myDataStore.mapColorState = @"blue";
    
    // this is for removing extra 'you' cluster buttons
    self.myDataStore.userPressedImSadButton = YES;
    NSLog(@"self.myDataStore.userPressedImSadButton = YES");
    
    // this is for when user on the blue map gets and views a gift and comes back to map,
    // this ensures the sadness annotation does not set up again
    self.myDataStore.userPressedImSadButtonOnHomescreen = YES;
    NSLog(@"self.userPressedImSadButtonOnHomescreen = YES");
    
    
    self.timer1 = [NSTimer scheduledTimerWithTimeInterval:3.5 target:self selector:@selector(checkConnection) userInfo:nil repeats:NO];
    self.timer3 = [NSTimer scheduledTimerWithTimeInterval:3.1 target:self selector:@selector(setupConnecting) userInfo:nil repeats:NO];
    
}


- (IBAction)hamburgerButtonPressed:(UIButton *)sender {
    
    self.cheerButton.userInteractionEnabled = NO;
    self.sadButton.userInteractionEnabled = NO;
    
    [self queryDynamoDBForCheerAndThankyous];
    
    [UIView animateWithDuration:.4 animations:^{
        self.menuBtn1Label.text = [NSString stringWithFormat:@"(%lu)", (unsigned long)self.myDataStore.inboxCount];
        self.menuConstraint.constant = -20;
        [self.view layoutIfNeeded];
    }];
    
    
}


- (IBAction)tryAgainButtonTapped:(UIButton *)sender {
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupNoServerConnection) name:@"awsSadnessTableScanReturnedAnError" object:nil];
    
    [self setupConnecting];
    
    [self scanAWSForAllSadnessesAndSaveLocallyWithCompletion:^(BOOL success) {
        
        if (success) {
            NSLog(@"✅ SUCCESS! SADNESS TABLE SCANNED AND SAVED LOCALLY");
            [self goToCheerMap];
        }
    }];

}


- (IBAction)closeSorryViewButtonPressed:(UIButton *)sender {
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        [UIView animateWithDuration:.4 animations:^{
            // show sorry overlay here
            self.sorryView.hidden = YES;
        }];
    }];
    
}


- (IBAction)cheerButtonPressedInSorryView:(UIButton *)sender {
    
    NSLog(@"CHEER BUTTON TAPPED IN SORRY SCREEN!");
    
    self.myDataStore.mapColorState = @"yellow";
    
    self.cheerButton.enabled = false;
    
    [self setUpAVAudioPlayerWithFileName:@"select_cheer_someone"];
    [self.audioPlayer play];
    [self checkLocationPermissions];
    
    self.timer1 = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(checkConnection) userInfo:nil repeats:NO];
    self.timer3 = [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(setupConnecting) userInfo:nil repeats:NO];
    
}


- (void)setupConnecting {
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [UIView animateWithDuration:.6 animations:^{
            
            [self.errorAnimationView.layer removeAllAnimations];
            self.errorButton.hidden = YES;
            self.errorButtonLabel.hidden = YES;
            self.errorConnectingLabel.text = @"Connecting...";
            self.errorConnectingLabel.hidden = NO;
            self.errorView.hidden = NO;
            
            [self playConnectingAnimation];
        }];
    }];
    
}


- (void)setupNoServerConnection {
    
    NSLog(@"In setupNoServerConnection");
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [UIView animateWithDuration:.25 animations:^{
            
            [self.errorAnimationView.layer removeAllAnimations];
            self.errorConnectingLabel.hidden = NO;
            self.errorButton.hidden = NO;
            self.errorButtonLabel.hidden = NO;
            self.errorConnectingLabel.text = @"Unable to connect to server!";
            self.errorButtonLabel.text = @"Try again";
            self.errorView.hidden = NO;
            
            self.timer2 = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(playNoServerConnectionAnimation) userInfo:nil repeats:NO];
        }];
    }];
    
}


- (void)switchToGiftIcon:(NSNotification *)notification {
        
    [UIView animateWithDuration:.6 animations:^{
        // set gift icon
        [self.menuIcon setImage:[UIImage imageNamed:@"04_gift_icon.png"] forState:UIControlStateNormal];
        self.menuIconConstraint.constant = -6;
        [self.view setNeedsUpdateConstraints];
    }];
    
    
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"giftOrThankyouRecievedViaSNSButUserTappedClose" object:nil];
    
}


- (void)goToGiftScreenWithCheer:(NSNotification *)notification {
    
    __weak typeof(self) weakSelf = self;
    
    if ([weakSelf.navigationController.visibleViewController isKindOfClass:[IMSCheerSadViewController class]]) {
        NSLog(@"IN goToGiftScreenWithCheer CheerSad visibleVC class");
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            IMSGiftViewController *giftVC = [storyboard instantiateViewControllerWithIdentifier:@"giftVC"];
            [weakSelf.navigationController presentViewController:giftVC animated:YES completion:nil];
            
            NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
            [center postNotificationName:@"vcInitiatedGiftViewForTheFirstTimeViaSNSForCheer" object:nil];
        }];
        
        NSLog(@"CHEER SAD VC SENT OUT vcInitiatedGiftViewForTheFirstTimeViaSNSForCheer NOTIFICATION");
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"cheerRecievedViaSNS" object:nil];
    }
    
}


- (void)goToGiftScreenWithThankyou:(NSNotification *)notification {
    
    __weak typeof(self) weakSelf = self;
    
    if ([weakSelf.navigationController.visibleViewController isKindOfClass:[IMSCheerSadViewController class]]) {
        NSLog(@"IN goToGiftScreenWithThankyou CheerSad visibleVC class");

        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            IMSGiftViewController *giftVC = [storyboard instantiateViewControllerWithIdentifier:@"giftVC"];
            [weakSelf.navigationController presentViewController:giftVC animated:YES completion:nil];
            
            NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
            [center postNotificationName:@"vcInitiatedGiftViewForTheFirstTimeViaSNSForThankyou" object:nil];
        }];
        
        NSLog(@"CHEER SAD VC SENT OUT vcInitiatedGiftViewForTheFirstTimeViaSNSForThankyou NOTIFICATION");
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"thankyouRecievedViaSNS" object:nil];
    };
    
}


- (void)queryDynamoDBForCheerAndThankyous {
    
    // emptying inbox arrays to avoid doubles
    [self.myDataStore.gifts removeAllObjects];
    [self.myDataStore.thankyous removeAllObjects];
    
    [DDBDynamoDBManager queryDynamoDBCheerTableLSIForAllAttributesWithUserID:self.myDataStore.userID completion:^(NSArray *cheers, NSError *error) {
        if (cheers.count > 0) {
            self.myDataStore.gifts = [cheers mutableCopy]; // only need the newest cheer
            
            self.myDataStore.giftsCount = 1; // can only be one gift waiting at a time
            self.myDataStore.inboxCount = self.myDataStore.giftsCount;

            if (self.myDataStore.thankyousCount > 0) {
                self.myDataStore.inboxCount = self.myDataStore.inboxCount + self.myDataStore.thankyousCount;
            }
            NSLog(@"INBOX COUNT: %lu", (unsigned long)self.myDataStore.inboxCount);
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                self.menuBtn1Label.text = [NSString stringWithFormat:@"(%lu)", (unsigned long)self.myDataStore.inboxCount];
            }];

        }
    }];
    
    [DDBDynamoDBManager queryDynamoDBThankyouTableLSIForAllAttributesWithUserID:self.myDataStore.userID completion:^(NSArray *thankyous, NSError *error) {
        if (thankyous.count > 0) {
            
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
            self.myDataStore.inboxCount = self.myDataStore.thankyousCount;

            if (self.myDataStore.giftsCount > 0) {
                self.myDataStore.inboxCount++;
            }
            NSLog(@"INBOX COUNT: %lu", (unsigned long)self.myDataStore.inboxCount);
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                self.menuBtn1Label.text = [NSString stringWithFormat:@"(%lu)", (unsigned long)self.myDataStore.inboxCount];
            }];
            
        }
    }];
    
}


- (IBAction)backgroundWasTapped:(UITapGestureRecognizer *)sender {

    [self closeMenu];
    
}


- (IBAction)menuCloseButtonPressed:(UIButton *)sender {
    
    [self closeMenu];
    
}


- (void)closeMenu {
    
    self.cheerButton.userInteractionEnabled = YES;
    self.sadButton.userInteractionEnabled = YES;
    
    [UIView animateWithDuration:.4 animations:^{
        self.menuConstraint.constant = -400;
        [self.view layoutIfNeeded];
    }];

}


- (void)playGiftBoxAnimation {
    
    NSArray *giftBoxImages = @[@"04_01_gift_box_select_jump_2x.png",
                               @"04_02_gift_box_select_jump_2x.png",
                               @"04_03_gift_box_select_jump_2x.png",
                               @"04_04_gift_box_select_jump_2x.png",
                               @"04_05_gift_box_select_jump_2x.png"];
    
    
    NSMutableArray *images = [[NSMutableArray alloc] init];
    NSInteger animationImageCount = 5;
    for (int i = 0; i < giftBoxImages.count; i++) {
        [images addObject:(id)[UIImage imageNamed:[giftBoxImages objectAtIndex:i]].CGImage];
    }
    
    self.giftBoxAnimation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
    self.giftBoxAnimation.delegate = self;
    self.giftBoxAnimation.calculationMode = kCAAnimationDiscrete;
    self.giftBoxAnimation.duration = animationImageCount / 24.0; // 24 frames per second
    self.giftBoxAnimation.values = images;
    self.giftBoxAnimation.repeatCount = 1;
    self.giftBoxAnimation.removedOnCompletion = NO;
    self.giftBoxAnimation.fillMode = kCAFillModeForwards;
    [self.giftBoxView.layer addAnimation:self.giftBoxAnimation forKey:@"giftBoxAnimation"];
    
}


- (void)playSadFaceAnimation {
    
    NSArray *sadFaceImages = @[@"05_01_animation_select_im_sad_2x.png",
                               @"05_02_animation_select_im_sad_2x.png",
                               @"05_03_animation_select_im_sad_2x.png",
                               @"05_04_animation_select_im_sad_2x.png",
                               @"05_05_animation_select_im_sad_2x.png",
                               @"05_06_animation_select_im_sad_2x.png",
                               @"05_07_animation_select_im_sad_2x.png",
                               @"05_08_animation_select_im_sad_2x.png",
                               @"05_09_animation_select_im_sad_2x.png",
                               @"05_10_animation_select_im_sad_2x.png",
                               @"05_11_animation_select_im_sad_2x.png",
                               @"05_12_animation_select_im_sad_2x.png",
                               @"05_13_animation_select_im_sad_2x.png",
                               @"05_14_animation_select_im_sad_2x.png",
                               @"05_15_animation_select_im_sad_2x.png",
                               @"05_16_animation_select_im_sad_2x.png",
                               @"05_17_animation_select_im_sad_2x.png",
                               @"05_18_animation_select_im_sad_2x.png",
                               @"05_19_animation_select_im_sad_2x.png",
                               @"05_20_animation_select_im_sad_2x.png",
                               @"05_21_animation_select_im_sad_2x.png",
                               @"05_22_animation_select_im_sad_2x.png",
                               @"05_23_animation_select_im_sad_2x.png",
                               @"05_24_animation_select_im_sad_2x.png",
                               @"05_25_animation_select_im_sad_2x.png",
                               @"05_26_animation_select_im_sad_2x.png",
                               @"05_27_animation_select_im_sad_2x.png",
                               @"05_28_animation_select_im_sad_2x.png",
                               @"05_29_animation_select_im_sad_2x.png",
                               @"05_30_animation_select_im_sad_2x.png",
                               @"05_31_animation_select_im_sad_2x.png"];
    
    
    NSMutableArray *images = [[NSMutableArray alloc] init];
    NSInteger animationImageCount = 31;
    for (int i = 0; i < sadFaceImages.count; i++) {
        [images addObject:(id)[UIImage imageNamed:[sadFaceImages objectAtIndex:i]].CGImage];
    }
    
    self.sadFaceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
    self.sadFaceAnimation.delegate = self;
    self.sadFaceAnimation.calculationMode = kCAAnimationDiscrete;
    self.sadFaceAnimation.duration = animationImageCount / 24.0; // 24 frames per second
    self.sadFaceAnimation.values = images;
    self.sadFaceAnimation.repeatCount = 1;
    self.sadFaceAnimation.removedOnCompletion = NO;
    self.sadFaceAnimation.fillMode = kCAFillModeForwards;
    [self.sadFaceView.layer addAnimation:self.sadFaceAnimation forKey:@"sadFaceAnimation"];
    
}


- (void)playRainAnimation {
    
    NSArray *animationImages = @[@"16_01_ImSad_rain_2x.jpg",
                                 @"16_02_ImSad_rain_2x.jpg",
                                 @"16_03_ImSad_rain_2x.jpg",
                                 @"16_04_ImSad_rain_2x.jpg",
                                 @"16_05_ImSad_rain_2x.jpg",
                                 @"16_06_ImSad_rain_2x.jpg",
                                 @"16_07_ImSad_rain_2x.jpg",
                                 @"16_08_ImSad_rain_2x.jpg",
                                 @"16_09_ImSad_rain_2x.jpg",
                                 @"16_10_ImSad_rain_2x.jpg",
                                 @"16_11_ImSad_rain_2x.jpg",
                                 @"16_12_ImSad_rain_2x.jpg",
                                 @"16_13_ImSad_rain_2x.jpg",
                                 @"16_14_ImSad_rain_2x.jpg",
                                 @"16_15_ImSad_rain_2x.jpg",
                                 @"16_16_ImSad_rain_2x.jpg",
                                 @"16_17_ImSad_rain_2x.jpg",
                                 @"16_18_ImSad_rain_2x.jpg",
                                 @"16_19_ImSad_rain_2x.jpg",
                                 @"16_20_ImSad_rain_2x.jpg",
                                 @"16_21_ImSad_rain_2x.jpg",
                                 @"16_22_ImSad_rain_2x.jpg",
                                 @"16_23_ImSad_rain_2x.jpg",
                                 @"16_24_ImSad_rain_2x.jpg",
                                 @"16_25_ImSad_rain_2x.jpg",
                                 @"16_26_ImSad_rain_2x.jpg",
                                 @"16_27_ImSad_rain_2x.jpg",
                                 @"16_28_ImSad_rain_2x.jpg",
                                 @"16_29_ImSad_rain_2x.jpg"];
    
    
    NSMutableArray *images = [[NSMutableArray alloc] init];
    NSInteger animationImageCount = animationImages.count;
    for (int i = 0; i < animationImages.count; i++) {
        [images addObject:(id)[UIImage imageNamed:[animationImages objectAtIndex:i]].CGImage];
    }
    
    self.rainAnimation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
    self.rainAnimation.delegate = self;
    self.rainAnimation.calculationMode = kCAAnimationDiscrete;
    self.rainAnimation.duration = animationImageCount / 18.0; // 24 frames per second
    self.rainAnimation.values = images;
    self.rainAnimation.repeatCount = HUGE_VALF;
    self.rainAnimation.removedOnCompletion = NO;
    self.rainAnimation.fillMode = kCAFillModeForwards;
    [self.rainView.layer addAnimation:self.rainAnimation forKey:@"rainAnimation"];
    
}


- (void)playConnectingAnimation {
    
    NSArray *animationImages = @[@"06_01_animation_connecting.png",
                                 @"06_02_animation_connecting.png",
                                 @"06_03_animation_connecting.png",
                                 @"06_04_animation_connecting.png",
                                 @"06_05_animation_connecting.png",
                                 @"06_06_animation_connecting.png",
                                 @"06_07_animation_connecting.png",
                                 @"06_08_animation_connecting.png",
                                 @"06_09_animation_connecting.png",
                                 @"06_10_animation_connecting.png",
                                 @"06_11_animation_connecting.png",
                                 @"06_12_animation_connecting.png",
                                 @"06_13_animation_connecting.png",
                                 @"06_14_animation_connecting.png",
                                 @"06_15_animation_connecting.png"];
    
    NSMutableArray *images = [[NSMutableArray alloc] init];
    NSInteger animationImageCount = animationImages.count;
    for (int i = 0; i < animationImages.count; i++) {
        [images addObject:(id)[UIImage imageNamed:[animationImages objectAtIndex:i]].CGImage];
    }
    
    self.errorAnimation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
    self.errorAnimation.delegate = self;
    self.errorAnimation.calculationMode = kCAAnimationDiscrete;
    self.errorAnimation.duration = animationImageCount / 33.0; // 24 frames per second
    self.errorAnimation.values = images;
    self.errorAnimation.repeatCount = HUGE_VALF;  //  HUGE_VALF; // loops
    self.errorAnimation.removedOnCompletion = NO;
    self.errorAnimation.fillMode = kCAFillModeForwards;
    [self.errorAnimationView.layer addAnimation:self.errorAnimation forKey:@"animation"];
    
}


- (void)playNoServerConnectionAnimation {
    
    NSArray *animationImages = @[@"06_01_animation_no_connection.png",
                                 @"06_02_animation_no_connection.png",
                                 @"06_03_animation_no_connection.png",
                                 @"06_04_animation_no_connection.png",
                                 @"06_05_animation_no_connection.png",
                                 @"06_06_animation_no_connection.png",
                                 @"06_07_animation_no_connection.png",
                                 @"06_08_animation_no_connection.png",
                                 @"06_09_animation_no_connection.png",
                                 @"06_10_animation_no_connection.png",
                                 @"06_11_animation_no_connection.png",
                                 @"06_12_animation_no_connection.png",
                                 @"06_13_animation_no_connection.png",
                                 @"06_14_animation_no_connection.png",
                                 @"06_15_animation_no_connection.png",
                                 @"06_16_animation_no_connection.png",
                                 @"06_17_animation_no_connection.png",
                                 @"06_18_animation_no_connection.png"];
    
    NSMutableArray *images = [[NSMutableArray alloc] init];
    NSInteger animationImageCount = animationImages.count;
    for (int i = 0; i < animationImages.count; i++) {
        [images addObject:(id)[UIImage imageNamed:[animationImages objectAtIndex:i]].CGImage];
    }
    
    self.errorAnimation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
    self.errorAnimation.delegate = self;
    self.errorAnimation.calculationMode = kCAAnimationDiscrete;
    self.errorAnimation.duration = animationImageCount / 40.0; // 24 frames per second
    self.errorAnimation.values = images;
    self.errorAnimation.repeatCount = 1;  //  HUGE_VALF; // loops
    self.errorAnimation.removedOnCompletion = NO;
    self.errorAnimation.fillMode = kCAFillModeForwards;
    [self.errorAnimationView.layer addAnimation:self.errorAnimation forKey:@"animation"];
    
}


- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
    
    if (theAnimation == [self.sadFaceView.layer animationForKey:@"sadFaceAnimation"] ||
        theAnimation == [self.giftBoxView.layer animationForKey:@"giftBoxAnimation"]) {
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self checkLocationPermissions];
        }];
    }
    
}


- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {

    
    if ([identifier isEqualToString:@"inboxSegue2"]) {
        
        NSLog(@"IN shouldPerformSegueWithIdentifier Inbox segue");

        
        [UIView animateWithDuration:.4 animations:^{
            self.menuConstraint.constant = -400;
            [self.view layoutIfNeeded];
        }];
        
        return YES;
        
    }

    if ([identifier isEqualToString:@"reviewSegue2"] ||
        [identifier isEqualToString:@"contact2"] ||
        [identifier isEqualToString:@"opinion2"] ||
        [identifier isEqualToString:@"manage2"] ||
        [identifier isEqualToString:@"privacy2"] ||
        [identifier isEqualToString:@"about2"]) {
        
        NSLog(@"IN shouldPerformSegueWithIdentifier reviewSegue2, contact2, opinion2, manage2, privacy2, about2");
        
        
        [UIView animateWithDuration:.4 animations:^{
            self.menuConstraint.constant = -400;
            [self.view layoutIfNeeded];
        }];
        
        return YES;
    }

    else {
        NSLog(@"IN shouldPerformSegueWithIdentifier: NO!");
        return NO;
    }

    
    return NO;
    
}


- (void)checkLocationPermissions {
    
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    if ([CLLocationManager locationServicesEnabled]) {
        NSLog(@"In checkLocationPermissions LOCATION SERVICES ARE ENABLED");
        
        
        if (status == kCLAuthorizationStatusNotDetermined) {
            // if location auth status is undetermined.
            // requestWhenInUseAuthorization gets called only once by Apple when the status is undetermined.
            if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                NSLog(@"In checkLocationPermissions STATUS: UNDETERMINED. LOCATION MANAGER IS REQUESTING AUTORIZATION WHEN IN USE");
                
                // this brings up Apple's prompt
                [self.locationManager requestWhenInUseAuthorization];
            }

        }
        
        if (status == kCLAuthorizationStatusDenied) {
            NSLog(@"In checkLocationPermissions LOCATION AUTHORIZATION STATUS: DENIED, DISPLAYING APP LOCATION SETTINGS ALERT");
            // if user tapped I'm Sad
            // take them to app settings link or Disneyland
            if ([self.myDataStore.mapColorState isEqualToString:@"blue"]) {
                [self displayAppLocationSettingsAlert];
            }
        }
    }
    
    // if location services are disabled:
    // save user data in data store and don't go to the map view
    if (![CLLocationManager locationServicesEnabled]) {
        NSLog(@"❗️In checkLocationPermissions LOCATION SERVICES ARE DISABLED, DISPLAYING LOCATION SERVICES ALERT");
        [self displayLocationServicesAlert];
    }

}


- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    //NSLog(@"IN locationManager didChangeAuthorizationStatus. STATUS: %d", status); // 0 = undetermined. 2 = denied. 4 = when in use
    
    
    if (status == kCLAuthorizationStatusDenied) {
//        NSLog(@"IN locationManager didChangeAuthorizationStatus. STATUS: DENIED, SETTING UP DISNEYLAND");
        
        
        // for both I'm Sad and Cheer Somone buttons
        // we ask location permission
        
        //[self displayAppLocationSettingsAlert];
        
        
        if (self.imsadGpsAlertIsDisplayed == NO) {
            NSLog(@"IN locationManager didChangeAuthorizationStatus STATUS: DENIED and ImSad GPS alert is not displayed. SETTING UP DISNEYLAND");

            // Placing user near Disneyland
            
            float diff = 0.005 - (-0.005);
            CGFloat randomLatitude = (((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * diff) + 0.005;
            CGFloat randomLongitude = (((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * diff) + 0.005;
            NSLog(@"RAND LAT: %.13f", randomLatitude);
            NSLog(@"RAND LONG: %.13f", randomLongitude);
            
            
            self.myDataStore.latitude = 33.812029 + randomLatitude;
            self.myDataStore.longitude = -117.919972 + randomLongitude;
            self.myDataStore.fromCity = @"Anaheim";
            self.myDataStore.fromCountry = @"United States";
            self.myDataStore.fromCountryISOCode = @"US";
            
            
            if ([self.myDataStore.mapColorState isEqualToString:@"blue"]) {
                
                [self goToSadMap];
                
            } else {
                // if you tapped Cheer someone button:
                // after we have your location permission and if there are people on the map
                // we take you to the yellow map
                
                [self scanAWSForAllSadnessesAndSaveLocallyWithCompletion:^(BOOL success) {
                    
                    if (success) {
                        
                        [self goToCheerMap];
                        self.sorryView.hidden = YES;
                    }
                }];
            }

        }
        
        
    }
    
    
    if (status == kCLAuthorizationStatusNotDetermined) {
        NSLog(@"IN locationManager didChangeAuthorizationStatus. STATUS: UNDETERMINED. DOING NOTHING");
        
    }

    
    // save info in data store, save user, save sadness, go to the map view
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        NSLog(@"IN locationManager didChangeAuthorizationStatus. STATUS: WHEN IN USE. GOING TO BLUE OR YELLOW MAP");
        
        [manager startUpdatingLocation];
        
        [self getLocationDateCityCountryWithCompletion:^(BOOL success) {
            
            if (success) {
                
                // if you tapped I'm Sad button:
                // after we have your location permission
                // we take you to the blue map
                if ([self.myDataStore.mapColorState isEqualToString:@"blue"]) {
                    [self goToSadMap];
                    
                } else {
                    // if you tapped Cheer someone button:
                    // after we have your location permission and if there are people on the map
                    // we take you to the yellow map
                    
                    [self scanAWSForAllSadnessesAndSaveLocallyWithCompletion:^(BOOL success) {
                        
                        if (success) {
                            
                            [self goToCheerMap];
                            self.sorryView.hidden = YES;
                        }
                        
                    }];
                }
                
            }
        }];
    }
    

}


- (void)scanAWSForAllSadnessesAndSaveLocallyWithCompletion:(void (^)(BOOL success))completionBlock {
    
    NSLog(@"IN scanAWSForAllSadnessesAndSaveLocallyWithCompletion CheerSad");
    
    // comes in in the order of the database
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [DDBDynamoDBManager scanDynamoDBSadnessTableWithCompletion:^(NSArray *currentSadnesses, NSError *error) {
            
            if (currentSadnesses && !error) {
                
                NSLog(@"In CheerSad scan - AWS SADNESS OBJECTS COUNT: %lu", (unsigned long)currentSadnesses.count);
                
                self.myDataStore.sadnessObjects = [currentSadnesses mutableCopy];
                
                if (self.myDataStore.sadnessObjects.count == currentSadnesses.count) {
                    NSLog(@"✅ SUCCESS! In CheerSad scan - SCANNED SADNESS TABLE AND SAVED LOCALLY");
                    completionBlock(YES);
                }
            }
            
        }];
    });
    
}


- (void)goToCheerMap {
    
    NSLog(@" I'M IN THE goToCheerMap");
    
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        if (self.myDataStore.existingUser.userID != nil) {
            
            NSLog(@"THIS IS EXISTING USER, SAVING THEIR CURRENT LOCATION");
            
            // updating user with their location
            IMSUser *updatedUser = [IMSUser new];
            updatedUser.userID = self.myDataStore.existingUser.userID;
            updatedUser.dateJoined = self.myDataStore.existingUser.dateJoined;
            updatedUser.badgeNumber = self.myDataStore.inboxCount;
            if (self.myDataStore.latestCheeredAtSec != 0) {
                updatedUser.latestCheeredAtSec = self.myDataStore.latestCheeredAtSec;
            }
            updatedUser.latestSadnessAnnouncedAtSec = self.myDataStore.latestSadnessAnnouncedAtSec;
            if (![self.myDataStore.latestGiftName isEqualToString:@""]) {
                updatedUser.latestGiftName = self.myDataStore.latestGiftName;
            }
            updatedUser.numberOfShares = self.myDataStore.numberOfShares;
            updatedUser.gender = self.myDataStore.existingUser.gender;
            updatedUser.type = self.myDataStore.existingUser.type;
            updatedUser.fromCity = self.myDataStore.fromCity;
            updatedUser.fromCountry = self.myDataStore.fromCountry;
            updatedUser.isSadNow = self.myDataStore.isSadNow;
            if (self.myDataStore.latestPeopleTimerStartedAtSec != 0) {
                updatedUser.latestPeopleTimerStartedAtSec = self.myDataStore.latestPeopleTimerStartedAtSec;
            }
            if (self.myDataStore.numberOfPeopleCheered != 0) {
                updatedUser.numberOfPeopleCheered = self.myDataStore.numberOfPeopleCheered;
            }
            
            [DDBDynamoDBManager saveUserToDynamoDB:updatedUser];
        }
        
        if (self.myDataStore.existingUser.userID == nil) {
            NSLog(@"USER DOES NOT EXIST YET");
            
            // updating user with their location
            IMSUser *updatedUser = [IMSUser new];
            updatedUser.userID = self.myDataStore.userID;
            updatedUser.dateJoined = self.myDataStore.dateJoined;
            if (self.myDataStore.latestSadnessAnnouncedAtSec != 0) {
                updatedUser.latestSadnessAnnouncedAtSec = self.myDataStore.latestSadnessAnnouncedAtSec;
                NSLog(@"updatedUser.latestSadnessAnnouncedAtSec: %lu", updatedUser.latestSadnessAnnouncedAtSec);
            }
            if (self.myDataStore.latestCheeredAtSec != 0) {
                updatedUser.latestCheeredAtSec = self.myDataStore.latestCheeredAtSec;
                NSLog(@"updatedUser.latestCheeredAtSec: %lu", updatedUser.latestCheeredAtSec);
            }
            if (![self.myDataStore.latestGiftName isEqualToString:@""]) {
                updatedUser.latestGiftName = self.myDataStore.latestGiftName;
                NSLog(@"updatedUser.latestGiftName: %@", updatedUser.latestGiftName);
            }
            updatedUser.badgeNumber = self.myDataStore.inboxCount;
            updatedUser.numberOfShares = self.myDataStore.numberOfShares;
            updatedUser.gender = self.myDataStore.gender;
            updatedUser.type = self.myDataStore.type;
            updatedUser.fromCity = self.myDataStore.fromCity;
            updatedUser.fromCountry = self.myDataStore.fromCountry;
            updatedUser.isSadNow = self.myDataStore.isSadNow;
            if (self.myDataStore.latestPeopleTimerStartedAtSec != 0) {
                updatedUser.latestPeopleTimerStartedAtSec = self.myDataStore.latestPeopleTimerStartedAtSec;
            }
            if (self.myDataStore.numberOfPeopleCheered != 0) {
                updatedUser.numberOfPeopleCheered = self.myDataStore.numberOfPeopleCheered;
            }
            
            NSLog(@"updatedUser.userID: %@", updatedUser.userID);
            NSLog(@"updatedUser.dateJoined: %@", updatedUser.dateJoined);
            NSLog(@"updatedUser.badgeNumber: %lu", updatedUser.badgeNumber);
            NSLog(@"updatedUser.numberOfShares: %lu", updatedUser.numberOfShares);
            NSLog(@"updatedUser.gender: %@", updatedUser.gender);
            NSLog(@"updatedUser.type: %@", updatedUser.type);
            NSLog(@"updatedUser.fromCity: %@", updatedUser.fromCity);
            NSLog(@"updatedUser.fromCountry: %@", updatedUser.fromCountry);
            NSLog(@"updatedUser.isSadNow: %@", updatedUser.isSadNow);
            NSLog(@"updatedUser.latestPeopleTimerStartedAtSec: %lu", updatedUser.latestPeopleTimerStartedAtSec);
            
            [DDBDynamoDBManager saveUserToDynamoDB:updatedUser];
        }
        
        
        // go to map vc
        __weak typeof(self) weakSelf = self;

        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        IMSCheerMapViewController *mapVC = [storyboard instantiateViewControllerWithIdentifier:@"cheerMapViewController"];
        [weakSelf.navigationController showViewController:mapVC sender:weakSelf];
        
    }];

}


- (void)goToSadMap {
    
    __weak typeof(self) weakSelf = self;

    // Go to Map VC
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    IMSCheerMapViewController *mapVC = [storyboard instantiateViewControllerWithIdentifier:@"cheerMapViewController"];

    [weakSelf.navigationController showViewController:mapVC sender:weakSelf];

    [self updateUserAndSaveNewSadness];
    
}


- (void)updateUserAndSaveNewSadness {

    
    // Local 'you' and database 'you' need to match,
    // so I'm saving createdAt date to the data store to use it in the saveSadnessAndUpdateUserInDynamoDB method
    
    NSDate *currentDate = [NSDate date]; // in absolute time
    NSTimeInterval timeIntervalSince1970 = [currentDate timeIntervalSince1970]; // in seconds
    
    self.myDataStore.sadnessCreatedAtSec = timeIntervalSince1970; // capture date in Data Store
    self.myDataStore.sadnessCreatedAt = [NSString stringWithFormat:@"%@", currentDate]; // capture date in Data Store
    self.myDataStore.latestSadnessAnnouncedAtSec = timeIntervalSince1970;
    self.myDataStore.isSadNow = @"yes";

    if (self.myDataStore.existingUser != nil) {
        self.myDataStore.existingUser.latestSadnessAnnouncedAtSec = timeIntervalSince1970;
        self.myDataStore.existingUser.isSadNow = @"yes";
    }


    // Updating user in DB with the latest sadness timestamp and their location
    if (self.myDataStore.existingUser.userID != nil) {

        NSLog(@"THIS IS EXISTING USER, SAVING THEIR CURRENT LOCATION");

        // updating user in DB with the latest sadness timestamp and their location
        IMSUser *updatedUser = [IMSUser new];
        updatedUser.userID = self.myDataStore.existingUser.userID;
        updatedUser.dateJoined = self.myDataStore.existingUser.dateJoined;
        updatedUser.latestSadnessAnnouncedAtSec = timeIntervalSince1970;
        if (self.myDataStore.latestCheeredAtSec != 0) {
            updatedUser.latestCheeredAtSec = self.myDataStore.latestCheeredAtSec;
        }
        updatedUser.badgeNumber = self.myDataStore.inboxCount;
        if (![self.myDataStore.latestGiftName isEqualToString:@""]) {
            updatedUser.latestGiftName = self.myDataStore.latestGiftName;
        }
        updatedUser.numberOfShares = self.myDataStore.numberOfShares;
        updatedUser.gender = self.myDataStore.existingUser.gender;
        updatedUser.type = self.myDataStore.existingUser.type;
        updatedUser.fromCity = self.myDataStore.fromCity;
        updatedUser.fromCountry = self.myDataStore.fromCountry;
        updatedUser.isSadNow = @"yes";
        if (self.myDataStore.latestPeopleTimerStartedAtSec != 0) {
            updatedUser.latestPeopleTimerStartedAtSec = self.myDataStore.latestPeopleTimerStartedAtSec;
        }
        if (self.myDataStore.numberOfPeopleCheered != 0) {
            updatedUser.numberOfPeopleCheered = self.myDataStore.numberOfPeopleCheered;
        }

        [DDBDynamoDBManager saveUserToDynamoDB:updatedUser];


        // Saving sadness
        self.mySadness = [IMSSadness new];
        self.mySadness.sadnessID = self.myDataStore.existingUser.userID;
        self.mySadness.createdAtSec = timeIntervalSince1970;
        self.mySadness.createdAt = self.myDataStore.sadnessCreatedAt;
        self.mySadness.fromCity = self.myDataStore.fromCity;
        self.mySadness.fromCountry = self.myDataStore.fromCountry;
        self.mySadness.fromCountryISOCode = self.myDataStore.fromCountryISOCode;
        if ([self.myDataStore.toUser isEqualToString:@""]) { // if user denied push notifications
            self.mySadness.toSadness = @"notAvailable";
        }
        if (![self.myDataStore.toUser isEqualToString:@""]) {
            self.mySadness.toSadness = [[[NSString stringWithFormat:@"%@", self.myDataStore.toUser] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
        }
        self.mySadness.gender = self.myDataStore.existingUser.gender;
        self.mySadness.latitude = self.myDataStore.latitude;
        self.mySadness.longitude = self.myDataStore.longitude;


        NSLog(@"self.mySadness.sadnessID: %@", self.mySadness.sadnessID);
        NSLog(@"self.mySadness.sadnessID: %@", self.mySadness.sadnessID);
        NSLog(@"self.mySadness.createdAtSec: %lu", self.mySadness.createdAtSec);
        NSLog(@"self.mySadness.createdAt: %@", self.mySadness.createdAt);
        NSLog(@"self.mySadness.fromCity: %@", self.mySadness.fromCity);
        NSLog(@"self.mySadness.fromCountry: %@", self.mySadness.fromCountry);
        NSLog(@"self.mySadness.fromCountryISOCode: %@", self.mySadness.fromCountryISOCode);
        NSLog(@"self.mySadness.toSadness: %@", self.mySadness.toSadness);
        NSLog(@"self.mySadness.gender: %@", self.mySadness.gender);
        NSLog(@"self.mySadness.latitude: %.12f", self.mySadness.latitude);
        NSLog(@"self.mySadness.longitude: %.12f", self.mySadness.longitude);


        [DDBDynamoDBManager saveSadnessToDynamoDB:self.mySadness];

    }


    if (self.myDataStore.existingUser.userID == nil) {
        NSLog(@"USER DOES NOT EXIST YET");

        // updating user in DB with the latest sadness timestamp and their location
        IMSUser *updatedUser = [IMSUser new];
        updatedUser.userID = self.myDataStore.userID;
        updatedUser.dateJoined = self.myDataStore.dateJoined;
        updatedUser.latestSadnessAnnouncedAtSec = timeIntervalSince1970;
        if (self.myDataStore.latestCheeredAtSec != 0) {
            updatedUser.latestCheeredAtSec = self.myDataStore.latestCheeredAtSec;
            NSLog(@"updatedUser.latestCheeredAtSec: %lu", updatedUser.latestCheeredAtSec);
        }
        if (![self.myDataStore.latestGiftName isEqualToString:@""]) {
            updatedUser.latestGiftName = self.myDataStore.latestGiftName;
            NSLog(@"updatedUser.latestGiftName: %@", updatedUser.latestGiftName);
        }
        updatedUser.badgeNumber = self.myDataStore.inboxCount;
        updatedUser.numberOfShares = self.myDataStore.numberOfShares;
        updatedUser.gender = self.myDataStore.gender;
        updatedUser.type = self.myDataStore.type;
        updatedUser.fromCity = self.myDataStore.fromCity;
        updatedUser.fromCountry = self.myDataStore.fromCountry;
        updatedUser.isSadNow = @"yes";
        if (self.myDataStore.latestPeopleTimerStartedAtSec != 0) {
            updatedUser.latestPeopleTimerStartedAtSec = self.myDataStore.latestPeopleTimerStartedAtSec;
        }
        if (self.myDataStore.numberOfPeopleCheered != 0) {
            updatedUser.numberOfPeopleCheered = self.myDataStore.numberOfPeopleCheered;
        }

//                        NSLog(@"updatedUser.userID: %@", updatedUser.userID);
//                        NSLog(@"updatedUser.dateJoined: %@", updatedUser.dateJoined);
//                        NSLog(@"updatedUser.latestSadnessAnnouncedAtSec: %lu", updatedUser.latestSadnessAnnouncedAtSec);
//                        NSLog(@"updatedUser.badgeNumber: %lu", updatedUser.badgeNumber);
//                        NSLog(@"updatedUser.numberOfShares: %lu", updatedUser.numberOfShares);
//                        NSLog(@"updatedUser.gender: %@", updatedUser.gender);
//                        NSLog(@"updatedUser.type: %@", updatedUser.type);
//                        NSLog(@"updatedUser.fromCity: %@", updatedUser.fromCity);
//                        NSLog(@"updatedUser.fromCountry: %@", updatedUser.fromCountry);


        [DDBDynamoDBManager saveUserToDynamoDB:updatedUser];


        // Saving sadness
        self.mySadness = [IMSSadness new];
        self.mySadness.sadnessID = self.myDataStore.userID;
        self.mySadness.createdAtSec = timeIntervalSince1970;
        self.mySadness.createdAt = self.myDataStore.sadnessCreatedAt;
        self.mySadness.fromCity = self.myDataStore.fromCity;
        self.mySadness.fromCountry = self.myDataStore.fromCountry;
        self.mySadness.fromCountryISOCode = self.myDataStore.fromCountryISOCode;
        if ([self.myDataStore.toUser isEqualToString:@""]) { // if user denied push notifications
            self.mySadness.toSadness = @"notAvailable";
        }
        if (![self.myDataStore.toUser isEqualToString:@""]) {
            self.mySadness.toSadness = [[[NSString stringWithFormat:@"%@", self.myDataStore.toUser] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
        }
        self.mySadness.gender = self.myDataStore.gender;
        self.mySadness.latitude = self.myDataStore.latitude;
        self.mySadness.longitude = self.myDataStore.longitude;


        NSLog(@"self.mySadness.sadnessID: %@", self.mySadness.sadnessID);
        NSLog(@"self.mySadness.sadnessID: %@", self.mySadness.sadnessID);
        NSLog(@"self.mySadness.createdAtSec: %lu", self.mySadness.createdAtSec);
        NSLog(@"self.mySadness.createdAt: %@", self.mySadness.createdAt);
        NSLog(@"self.mySadness.fromCity: %@", self.mySadness.fromCity);
        NSLog(@"self.mySadness.fromCountry: %@", self.mySadness.fromCountry);
        NSLog(@"self.mySadness.fromCountryISOCode: %@", self.mySadness.fromCountryISOCode);
        NSLog(@"self.mySadness.toSadness: %@", self.mySadness.toSadness);
        NSLog(@"self.mySadness.gender: %@", self.mySadness.gender);
        NSLog(@"self.mySadness.latitude: %.12f", self.mySadness.latitude);
        NSLog(@"self.mySadness.longitude: %.12f", self.mySadness.longitude);
        
        
        [DDBDynamoDBManager saveSadnessToDynamoDB:self.mySadness];
        
    }

    
}


- (void)displayAppLocationSettingsAlert {
    
    NSLog(@"In displayAppLocationSettingsAlert");
    
    self.imsadGpsAlertIsDisplayed = YES;
    
    
    UIAlertController *alert = [UIAlertController
                               alertControllerWithTitle:@"GPS for ImSad is off"
                               message:@"Do you want ImSad to locate you accurately by turning on GPS?"
                               preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *buttonNo = [UIAlertAction
                                 actionWithTitle:@"No"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     // Placing user near Disneyland
                                     
                                     float diff = 0.005 - (-0.005);
                                     CGFloat randomLatitude = (((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * diff) + 0.005;
                                     CGFloat randomLongitude = (((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * diff) + 0.005;
                                     NSLog(@"RAND LAT: %.13f", randomLatitude);
                                     NSLog(@"RAND LONG: %.13f", randomLongitude);
                                     
                                     
                                     self.myDataStore.latitude = 33.812029 + randomLatitude;
                                     self.myDataStore.longitude = -117.919972 + randomLongitude;
                                     self.myDataStore.fromCity = @"Anaheim";
                                     self.myDataStore.fromCountry = @"United States";
                                     self.myDataStore.fromCountryISOCode = @"US";
                                     
                                     
                                     if ([self.myDataStore.mapColorState isEqualToString:@"blue"]) {
                                         
                                         // if user tapped I'm Sad button, we place them in Disneyland
                                         [self goToSadMap];
                                         
                                     } else {
                                         // if user tapped Cheer Someone button,a
                                         // we update your user profile location to Disneyland
                                         // and take you to the yellow map
                                         
                                         [self scanAWSForAllSadnessesAndSaveLocallyWithCompletion:^(BOOL success) {
                                             
                                             if (success) {
                                                 [self goToCheerMap];
                                                 self.sorryView.hidden = YES;
                                             }
                                         }];
                                     }

                                     self.imsadGpsAlertIsDisplayed = NO;
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                     
                                 }];

    UIAlertAction *buttonSure = [UIAlertAction
                             actionWithTitle:@"Sure!"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                // Go to App Settings
                                 
                                NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                [[UIApplication sharedApplication]openURL:settingsURL];
                                 
                                self.imsadGpsAlertIsDisplayed = NO;
                                [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    
    [alert addAction:buttonNo];
    [alert addAction:buttonSure];
    [self presentViewController:alert animated:YES completion:nil];
    
}


- (void)displayLocationServicesAlert {
    
    NSLog(@"In displayLocationServicesAlert");
    
    UIAlertController *alert = [UIAlertController
                               alertControllerWithTitle:@"Location Services are off"
                               message:@"In order to place you on the map, ImSad needs location services to be on. But ImSad will still work if you say no. Do you want ImSad to accurately locate you on the map?"
                               preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *buttonNo = [UIAlertAction
                               actionWithTitle:@"No"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action)
                               {
                                   // Placing user near Disneyland
                                   
                                   float diff = 0.005 - (-0.005);
                                   CGFloat randomLatitude = (((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * diff) + 0.005;
                                   CGFloat randomLongitude = (((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * diff) + 0.005;
                                   NSLog(@"RAND LAT: %.13f", randomLatitude);
                                   NSLog(@"RAND LONG: %.13f", randomLongitude);
                                   
                                   
                                   self.myDataStore.latitude = 33.812029 + randomLatitude;
                                   self.myDataStore.longitude = -117.919972 + randomLongitude;
                                   self.myDataStore.fromCity = @"Anaheim";
                                   self.myDataStore.fromCountry = @"United States";
                                   self.myDataStore.fromCountryISOCode = @"US";
                                   
                                   
                                   if ([self.myDataStore.mapColorState isEqualToString:@"blue"]) {
                                       
                                       // if user tapped I'm Sad button, we place them in Disneyland
                                       [self goToSadMap];
                                       
                                   } else {
                                       // if user tapped Cheer Someone button,a
                                       // we update your user profile location to Disneyland
                                       // and take you to the yellow map
                                       
                                       [self scanAWSForAllSadnessesAndSaveLocallyWithCompletion:^(BOOL success) {
                                           
                                           if (success) {
                                               [self goToCheerMap];
                                               self.sorryView.hidden = YES;
                                           }
                                       }];
                                   }
                                   
                                   self.imsadGpsAlertIsDisplayed = NO;
                                   [alert dismissViewControllerAnimated:YES completion:nil];
                                   
                               }];

    UIAlertAction *buttonYes = [UIAlertAction
                            actionWithTitle:@"Yes"
                            style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction * action)
                            {
                               // Open iOS Global Location Settings
                                
                               NSURL *locationSettingsURL = [NSURL URLWithString:@"prefs:root=Privacy&path=LOCATION"];
                               [[UIApplication sharedApplication]openURL:locationSettingsURL];
                                
                               [alert dismissViewControllerAnimated:YES completion:nil];
                           }];
    
    [alert addAction:buttonNo];
    [alert addAction:buttonYes];
    [self presentViewController:alert animated:YES completion:nil];
    
}


- (void)getLocationDateCityCountryWithCompletion:(void (^)(BOOL success))completionBlock {
    
    CLLocation *location = [self.locationManager location];
    CLLocationCoordinate2D coordinate = [location coordinate];
    self.myDataStore.coordinate = [location coordinate];
    NSLog(@"MY LOCATION: %@", location);
    
    self.myDataStore.location = location;
    self.myDataStore.latitude = coordinate.latitude;
    self.myDataStore.longitude = coordinate.longitude;
    
    // getting city + country + ISO country code
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:location
                   completionHandler:^(NSArray *placemarks, NSError *error) {   // NETWORK CALL ➡️
                       
           if (error == nil && [placemarks count] > 0) {
               [self.myDataStore.locations addObject:placemarks[0]];
               
               CLPlacemark *myPlacemark = [placemarks firstObject];
               
               self.myDataStore.fromCity = myPlacemark.locality; // city
               self.myDataStore.fromCountry = myPlacemark.country;
               self.myDataStore.fromCountryISOCode = myPlacemark.ISOcountryCode;
               
               completionBlock(YES);
               
               NSLog(@"In CheerSad get location - DATA STORE CITY: %@", self.myDataStore.fromCity);
               NSLog(@"In CheerSad get location - DATA STORE COUNTRY: %@", self.myDataStore.fromCountry);
           }
    }];
}


- (void)setUpAVAudioPlayerWithFileName:(NSString *)fileName {
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:fileName withExtension:@"mp3"];
    NSError *error = nil;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    if (!self.audioPlayer)
    {
        NSLog(@"Error in audioPlayer: %@",
              [error localizedDescription]);
    } else {
        [self.audioPlayer prepareToPlay];
    }
}


- (void)checkConnection {
    
    NSLog(@" In checkConnection");
    
    // check connection to a very small, fast loading site:
    NSURL *scriptUrl = [NSURL URLWithString:@"https://aws.amazon.com/contact-us"];
    
    @autoreleasepool {
        NSData *data = [NSData dataWithContentsOfURL:scriptUrl];
        if (data) {
            NSLog(@" Device is connected to the internet");
            
        } else {
            NSLog(@" Device is not connected to the internet");
            [self setupNoServerConnection];
        }
    }

}


- (NSUInteger)getMinutesBetweenOriginalTimeAndNow:(NSUInteger)createdAtSec {
    
    NSDate *currentDate = [NSDate date]; // also absolute time
    
    // calculate the difference between right now (currentDate) and sadness created date (createdAtSec)
    NSTimeInterval timeIntervalSince1970 = [currentDate timeIntervalSince1970]; // in seconds
    NSLog(@"timeIntervalSince1970 NSUInt: %f", timeIntervalSince1970);
    NSLog(@"timeIntervalSince1970 Float: %f", timeIntervalSince1970);
    
    //NSUInteger timeSad = timeIntervalSince1970 - createdAtSec;
    //NSLog(@"timeSad: %lu", timeSad);
    
    CGFloat timeSad = timeIntervalSince1970 - createdAtSec;     // 20 (1970)      40 got gift      45 now
    NSLog(@"timeSad: %f", timeSad);
    
    
    CGFloat minutesInAnHour = 60;
    //    CGFloat secondsInAnHour = 3600;
    NSUInteger minutesBetweenDates = timeSad / minutesInAnHour;
    //NSLog(@"minutesBetweenDates in getminutes: %lu", minutesBetweenDates);
    
    return minutesBetweenDates;
    
}


- (void)handleApplicationInBackground:(NSNotification *)notification {
    NSLog(@" I'M IN THE handleApplicationInBackground");
    
    [self.locationManager stopUpdatingLocation];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"applicationDidEnterBackground" object:nil];
    
}


- (void)viewDidDisappear:(BOOL)animated {
    NSLog(@"In cheer sad viewDidDisappear");
    
    [super viewDidDisappear:YES];
    
    // resetting connecting to server animation when user pressed cheer button...
    [self.errorAnimationView.layer removeAllAnimations];
    self.errorButton.hidden = YES;
    self.errorButtonLabel.hidden = YES;
    self.errorConnectingLabel.hidden = YES;
    self.errorView.hidden = YES;
    
    [self cleanup];
}


- (void)dealloc {
    NSLog(@"In cheer sad dealloc");
    
    [self cleanup];
}


- (void)didReceiveMemoryWarning {
    NSLog(@"❗️In cheer sad didReceiveMemoryWarning");
    
    [super didReceiveMemoryWarning];
    
    if(![self.navigationController.visibleViewController isKindOfClass:[IMSCheerSadViewController class]]) {
        
        [self cleanup];
        
        [self.viewBackground setImage:nil];
        [self.cheerButton setBackgroundImage:nil forState:UIControlStateNormal];
        [self.cheerButton setBackgroundImage:nil forState:UIControlStateHighlighted];
        [self.giftBoxView setImage:nil];
        [self.sadFaceView setImage:nil];
        [self.menuBtn2Stars setImage:nil];
        [self.menuBtn1BoxImage setImage:nil];
        [self.menuTopBarImage setImage:nil];
        [self.menuIcon setImage:nil forState:UIControlStateNormal];
    }
    
}


- (void)cleanup {
    NSLog(@"In cheer sad cleanup");
    
    
    [self.timerForCountUp invalidate];
    [self.cheerTimerForCountDown invalidate];
    [self.timer1 invalidate];
    [self.timer2 invalidate];
    [self.timer3 invalidate];
    
    self.cheerButton.enabled = true;
    self.sadButton.enabled = true;
    [self.sadFaceView.layer removeAllAnimations];
    [self.giftBoxView.layer removeAllAnimations];
    [self.rainView.layer removeAllAnimations];
    
    self.audioPlayer = nil;
    [self.locationManager stopUpdatingLocation];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"cheerRecievedViaSNS" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"thankyouRecievedViaSNS" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"applicationDidEnterBackground" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"giftOrThankyouRecievedViaSNSButUserTappedClose" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"awsSadnessTableScanReturnedAnError" object:nil];
        
}





// could be useful for moving around the map and populating sad faces:
//- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
//    
//}



@end



//
//  IMSUser.h
//  ImSadApp
//
//  Created by Inga on 4/8/16.
//  Copyright © 2016 Inga. All rights reserved.
//

#import "Constants.h"
#import <AWSDynamoDB/AWSDynamoDBObjectMapper.h>
#import "IMSSadness.h"

@interface IMSUser : AWSDynamoDBObjectModel <AWSDynamoDBModeling>

@property (nonatomic, strong) NSString *userID;  // hash key. seems like hash key and range key needs to be first for aws to save object
@property (nonatomic, strong) NSString *dateJoined;
@property (nonatomic) NSUInteger latestCheeredAtSec;
@property (nonatomic) NSUInteger latestSadnessAnnouncedAtSec;
@property (nonatomic) NSUInteger latestPeopleTimerStartedAtSec;
@property (nonatomic) NSUInteger numberOfPeopleCheered;
@property (nonatomic) NSUInteger badgeNumber;
@property (nonatomic, strong) NSString *latestGiftName;
@property (nonatomic, strong) NSString *gender;
@property (nonatomic, strong) NSString *fromCity;
@property (nonatomic, strong) NSString *fromCountry;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *isSadNow;
@property (nonatomic) NSUInteger numberOfShares;

- (instancetype)init;


@end

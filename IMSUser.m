//
//  IMSUser.m
//  ImSadApp
//
//  Created by Inga on 4/8/16.
//  Copyright © 2016 Inga. All rights reserved.
//

#import "IMSUser.h"

@implementation IMSUser


- (instancetype)init {
    
    self = [super init];
    return self;
}


+ (NSString *)dynamoDBTableName {
    return AWSDynamoDBTableName01;
}

+ (NSString *)hashKeyAttribute {
    return AWSHashKey01;
}


@end



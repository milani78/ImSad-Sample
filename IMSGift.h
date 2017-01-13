//
//  IMSGift.h
//  ImSad
//
//  Created by Inga on 10/31/16.
//  Copyright © 2016 Inga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface IMSGift : NSObject

@property (nonatomic, strong) NSString *bucketName;
@property (nonatomic, strong) NSString *zipName;
@property (nonatomic) CGFloat animationSpeed;
@property (nonatomic) NSUInteger loopFrameNumber;
@property (nonatomic) CGFloat loopAnimationSpeed;
@property (nonatomic, strong) NSArray *musicFileNames;
@property (nonatomic, strong) NSArray *backgroundFileNames;

- (instancetype)init;

@end

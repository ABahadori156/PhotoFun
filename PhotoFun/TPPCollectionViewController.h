//
//  TPPCollectionViewController.h
//  PhotoFun
//
//  Created by Pasha Bahadori on 8/6/16.
//  Copyright © 2016 Pelican. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SimpleAuth/SimpleAuth.h>
#import "PhotoController.h"
#import "DetailViewController.h"

// We're going to need to put the date and the format in lots of URLs across our app
// So we will create a constant that we can us eelsewhere so we're not repeating ourselves. AKA extern

extern NSString *const DATA_VERSION_DATE;
extern NSString *const DATA_FORMAT;

@interface TPPCollectionViewController : UICollectionViewController
@property (nonatomic) NSString *accessToken;
@property (nonatomic) NSArray *likedArray;
@property (nonatomic) NSMutableArray *venueArray;

@end

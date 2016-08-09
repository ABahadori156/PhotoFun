//
//  TPPUICollectionViewCell.h
//  PhotoFun
//
//  Created by Pasha Bahadori on 8/6/16.
//  Copyright © 2016 Pelican. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SAMCache/SAMCache.h>

@interface TPPUICollectionViewCell : UICollectionViewCell

@property (nonnull) IBOutlet UIImageView *photoView;
@property (nonnull, nonatomic) NSDictionary *photoData;

@end

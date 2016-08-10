//
//  DetailViewController.h
//  PhotoFun
//
//  Created by Pasha Bahadori on 8/8/16.
//  Copyright © 2016 Pelican. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPPCollectionViewController.h"

@interface DetailViewController : UIViewController
@property (nonatomic) NSDictionary *photo;
@property (nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic) IBOutlet UIView *backgroundView;
@property (nonatomic) IBOutlet UIView *centerView;
@property (nonatomic) IBOutlet UITextView *tipView;
@property (nonatomic) NSString *tipString;


@end

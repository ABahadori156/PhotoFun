//
//  TPPUICollectionViewCell.m
//  PhotoFun
//
//  Created by Pasha Bahadori on 8/6/16.
//  Copyright © 2016 Pelican. All rights reserved.
//

#import "TPPUICollectionViewCell.h"
#import "PhotoController.h"

@implementation TPPUICollectionViewCell

-(void)setPhotoData:(NSDictionary *)photoData{
    // first set our photoData equal to the argument we're passing in
    _photoData = photoData;
    
    [PhotoController imageForPhoto:photoData size:@"100x100" completion:^(UIImage *image){
        self.photoView.image = image;
    }];
}

@end

//
//  TPPUICollectionViewCell.m
//  PhotoFun
//
//  Created by Pasha Bahadori on 8/6/16.
//  Copyright © 2016 Pelican. All rights reserved.
//

#import "TPPUICollectionViewCell.h"

@implementation TPPUICollectionViewCell

-(void)setPhotoData:(NSDictionary *)photoData{
    // first set our photoData equal to the argument we're passing in
    _photoData = photoData;
    
    
    
    // The size is from the Foursquare API documentation
    NSString *size = @"100x100";
    
    // Next inside we create our URL string.
    // In the Foursquare docs, it tells us how to build up this URL
    // First thing we need is the photo prefix, then a size parameter, then finally the photo suffix
    NSString *urlString = [[NSString alloc] initWithFormat:@"%@%@%@", [photoData valueForKeyPath:@"response.venue.bestPhoto.prefix"], size, [photoData valueForKeyPath:@"response.venue.bestPhoto.suffix"]];
    
    
    //below we call our downloadPhotoWithURL method on our venuestring
    [self downloadPhotoWithURL:urlString];
    
}

-(void)downloadPhotoWithURL:(NSString *)urlString{
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        //Inside our completion block, we want to create a UIImage. We do this first by turning it into an NSData first
        NSData *data = [[NSData alloc] initWithContentsOfURL:location];
        
        UIImage *downloadedImage = [[UIImage alloc] initWithData:data];
        
        // One more thing we'll need to do is assign our UIImage to the actual UIImageView image property and to do that we need to make sure it happens back on the main thread
        
        // We use dispatch_async to do this
        dispatch_async(dispatch_get_main_queue(), ^{
            self.photoView.image = downloadedImage;
        });
        
        
        
    }];
    
    [task resume];
    
    
}



@end

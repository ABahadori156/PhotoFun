//
//  PhotoController.m
//  PhotoFun
//
//  Created by Pasha Bahadori on 8/8/16.
//  Copyright © 2016 Pelican. All rights reserved.
//

#import "PhotoController.h"


@implementation PhotoController

+(void)imageForPhoto:(NSDictionary*)photo size:(NSString*)size completion:(void(^)(UIImage *image))completion{
    
    // Let's do a check here to make sure that both the photo dictionary, the size, and the completion block are all here, if any of them are nil, the rest of this class method will not work
    if (photo == nil || size == nil || completion == nil) {
        NSLog(@"Missing arguement for imageForPhoto");
        return;
    }
    
    
    // This URLString will be used as a key for caching the photo
    NSString *urlString = [[NSString alloc] initWithFormat:@"%@%@%@", [photo valueForKeyPath:@"response.venue.bestPhoto.prefix"], size, [photo valueForKeyPath:@"response.venue.bestPhoto.suffix"]];

    //CACHING:
    // We're going to create a string key and save that along with our cached photo
    // We can pass the key urlString because in the setPhotoData we already setup the urlString with it's size, prefix, suffix
    
    NSString *key = urlString;
    UIImage *cachedPhoto = [[SAMCache sharedCache]imageForKey:key];
    
    // Here we're going to check to see if there's already an image with that key
    if(cachedPhoto) {
     
        // We change this to completion in parentheses cachedPhoto, so if it hits here it's just going to include that in the completion block and then return it
        completion(cachedPhoto);
        return;
    }
    
    // IF NO CACHED PHOTO, then ..
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSData *data = [[NSData alloc] initWithContentsOfURL:location];
        
        //*C: Once we get the image from our data ..
        UIImage *downloadedImage = [[UIImage alloc] initWithData:data];
        
        // *C: We're going to make sure to set it in our cache, so that it can be found next time around
        [[SAMCache sharedCache] setImage:downloadedImage forKey:key];
        
        // One more thing we'll need to do is assign our UIImage to the actual UIImageView image property and to do that we need to make sure it happens back on the main thread
        
        // We use dispatch_async to do this by setting the image on the imageView using main queue
        //*C:
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(downloadedImage);
        });
        
    }];
    
    [task resume];
    
}





@end

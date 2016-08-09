//
//  PhotoController.h
//  PhotoFun
//
//  Created by Pasha Bahadori on 8/8/16.
//  Copyright © 2016 Pelican. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <SAMCache/SAMCache.h>


// Now we will declare a Class Method. We're going to want this class method so we can act on the class itself and not on an instance of the class

@interface PhotoController : NSObject

// Class methods start with +
// This method takes 3 parameters: an NSDictionary, NSString, and a compleition handler
+(void)imageForPhoto:(NSDictionary*)photo size:(NSString*)size completion:(void(^)(UIImage *image))completion;


@end

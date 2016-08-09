//
//  DetailViewController.m
//  PhotoFun
//
//  Created by Pasha Bahadori on 8/8/16.
//  Copyright © 2016 Pelican. All rights reserved.
//

#import "DetailViewController.h"
#import "PhotoController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Here we setup our ImageView to the photo we transferred from the mainVC and use our PhotoController's class method to initialize it and set it to 300x300
    [PhotoController imageForPhoto:self.photo size:@"300x300" completion:^(UIImage *image) {
        self.imageView.image = image;
    }];
    
    
    // Below we add a UITapGestureRecognizer to our backgroundView so when we tap on the background, the view will be dismissed
    UITapGestureRecognizer *dismiss = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    [self.backgroundView addGestureRecognizer:dismiss];
    
    
    // Here we round the corners of our center View
    self.centerView.layer.cornerRadius = 10;
    
    [self downloadTips];
    
    
}

// Function for viewController dismissal
-(void)dismiss{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)downloadTips{
    // What information will you need to pass to the API to get our tips?
    // Access Token, API Version Date, Date Format, and VenueID
    // Since we're inside our DetailView, we can just use the venueID in our photoDictionary
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"];
    
    // You can figure out the key path by printing out the dictionary and looking at the structure of the response
    NSString *venueID = [self.photo valueForKeyPath:@"response.venue.id"];
    
    // Now we build up our URLstring which will have the access token, venueID, and other stuff
    
    NSString *urlString = [[NSString alloc] initWithFormat:@"https://api.foursquare.com/v2/venues/%@/tips/?oauth_token=%@&v=%@&m=%@", venueID, accessToken, DATA_VERSION_DATE, DATA_FORMAT];
    
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSData *data = [[NSData alloc] initWithContentsOfURL:location];
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        
        // Create an array that will hold all the different text of all the tips
        
        NSArray *tipsArray = [responseDict valueForKeyPath:@"response.tips.items.text"];
        NSLog(@"tipArray:%@", tipsArray);
        
        
    }];
    [task resume];
    
    
}

//Method to format the tips we retrieved from the API to make it look nice for the user
-(NSString *)formatTips:(NSArray*)tipsArray{
    NSMutableString *tipsString = [[NSMutableString alloc] initWithString:@"Tips:\n\n"];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

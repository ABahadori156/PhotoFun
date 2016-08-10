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
    
  
    
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeToDismiss)];
    
    // Here we added the swipe gesture to the entire view which means it will swipe anywhere you swipe on the view, not just on the backgroundView
    // which is obscured by the centerView
    [self.view addGestureRecognizer:swipe];
    
    // Here we round the corners of our center View
    self.centerView.layer.cornerRadius = 10;
    
    [self downloadTips];
    
    
}

-(void)swipeToDismiss{
    // This will move the view 400 points to the right and no points up or down, making it a horizontal slide
    
    [UIView animateWithDuration:.75 animations:^{self.view.transform = CGAffineTransformMakeTranslation(400, 0); }
                     completion:^(BOOL finished) {
                         [self dismissViewControllerAnimated:YES completion:nil];
                     }];
    
}

// Function for viewController dismissal
-(void)dismiss{
    
    // This is a custom animation to make the view shrink size
    // We lower the alpha so it fades out when dismissed
    
    // We'll leave the alpha here on this one, but we don't need a transform of any kind here
    [UIView animateWithDuration:.75 animations:^{self.view.transform = CGAffineTransformMakeScale(.01, .01); self.view.alpha = 0;}
                     completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:YES completion:nil];
     }];
}


-(void)dismissTips{
    // This will get rid of just the tipsView not the entire detailView
    [UIView animateWithDuration:.5 animations:^{self.tipView.alpha = 0;}
                     completion:^(BOOL finished) {
                         [self.tipView removeFromSuperview];
                     }];
    
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
        
        self.tipString = [self formatTips:tipsArray];
        
        
    }];
    [task resume];
    
    
}

//Method to format the tips we retrieved from the API to make it look nice for the user
-(NSString *)formatTips:(NSArray*)tipsArray{
    NSMutableString *tipString = [[NSMutableString alloc] initWithString:@"Tips:\n\n"];
    
    for (NSString *tip in tipsArray) {
        // Take the mutableString tipString and as you iterate, append the string to the mutableString
        [tipString appendString:[NSString stringWithFormat:@"*%@\n\n", tip]];
    }
    // Here we return the NSString version of our tipString
    return (NSString*)tipString;
}

-(IBAction)presentTipView{
    // Inside here we're going to alloc and init our tipView with the same frame as our centerView
    self.tipView = [[UITextView alloc]initWithFrame:self.centerView.frame];
    
    self.tipView.backgroundColor = [UIColor orangeColor];
    
    self.tipView.textColor = [UIColor whiteColor];
    
    // Here we'll round the corners of our textView cause it would look silly if it shows up on top with sharp corners
    self.tipView.layer.cornerRadius = 10;
    
    self.tipView.text = self.tipString;
    
    // Here we add a tapGesture to get rid of the tips text view when we tap on it
    // We add it here because tipView was created in this presentTipView method
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissTips)];
    [self.tipView addGestureRecognizer:tap];
    
    [self.view addSubview:self.tipView];
    
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

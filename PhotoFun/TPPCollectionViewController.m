//
//  TPPCollectionViewController.m
//  PhotoFun
//
//  Created by Pasha Bahadori on 8/6/16.
//  Copyright © 2016 Pelican. All rights reserved.
//

#import "TPPCollectionViewController.h"
#import "TPPUICollectionViewCell.h"

// DATA_VERSION_DATE has to be in the @"20160807" format otherwise it won't work
NSString *const DATA_VERSION_DATE = @"20160807";
NSString *const DATA_FORMAT = @"foursquare";

@interface TPPCollectionViewController ()

@end

@implementation TPPCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // With a collection view we don't change the view's color but the 'collectionView's' color
    
    // Register cell classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    self.navigationController.navigationBar.topItem.title = @"PhotoFun";
    
 
    
    
    // We create an instance of NSUserDefaults and inside of that instance, we're going to get the key called accessToken, grab the value associated with it, and set it equal to our accessToken property
    // We created the key @"accessToken" the one inside the defaults method.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.accessToken = [defaults stringForKey:@"accessToken"];
    
    if(self.accessToken == nil) {
        // get the token
        [SimpleAuth authorize:@"foursquare-web" completion:^(id responseObject, NSError *error) {
            NSLog(@"response: %@", responseObject);
            
            // the token is inside the 'credentials' dictionary, and the value we're looking for is associated with the 'token' key
            // We figure this out by looking at the API log from NSLog above
            NSString *token = responseObject[@"credentials"][@"token"];
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            
            //now we create the key-value pair.
            [defaults setObject:token forKey:@"accessToken"];
            
            //Then we synchronize the instance of NSUserDefaults otherwise it won't save
            [defaults synchronize];
            
            [self refreshFoursquare];
            
        }];
        
        
        
    } else {
        [self refreshFoursquare];
      
    }
}

-(void)refreshFoursquare{
    // use the token, get the venue data
    
    NSURLSession *session = [NSURLSession sharedSession];
    // Now we need our URL so we can request data from Fromsquare - We want a list of all the venues I've liked from Foursquare
    // How do we know what the URL is? CHECK API DOCUMENTATION
    
    // change USER_ID inside the url to self
    // We want to add 3 things: the data version date (version of the API data we're expecting), the format(either Foursquare or Swarm), and we also want the auth token
    // We're going to need to put the date and the format in lots of URLs across our app
    // So we will create a constant that we can us eelsewhere so we're not repeating ourselves. AKA extern
    
    // We add the /?oauth_token=%@&v=%@&m=%@ after the URL
    NSString *urlString = [[NSString alloc] initWithFormat:@"https://api.foursquare.com/v2/users/self/venuelikes/?oauth_token=%@&v=%@&m=%@", self.accessToken, DATA_VERSION_DATE, DATA_FORMAT];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    //Now we create the request
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url];
    
    //Then we'll create and use our download task using the downloadTaskWithRequest method
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        //            NSLog(@"Response: %@", response);
        
        //string below is text at our location. That location is the location on the disk where we've saved this.
        // This text below we will copy from the log and enter into jsonprettyprint.com to organize the JSON making it readable
        //            NSString *text = [[NSString alloc] initWithContentsOfURL:location encoding:NSUTF8StringEncoding error:nil];
        //            NSLog(@"Text: %@", text);
        
        
        // The location is the location on disk. We're using NSData to hold raw data and we're filling it with data that we saved at our location, called location
        //
        NSData *data = [[NSData alloc] initWithContentsOfURL:location];
        
        // Now we can turn our raw data into a dictionary and we do that with the method NSJSON Serialization
        NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        //            NSLog(@"ResponseDict: %@", responseDict);
        
        self.likedArray = [responseDict valueForKeyPath:@"response.venues.items.id"];
        
        // We initialize our mutable array to get it ready to store the contents of our venues in our for-loop
        self.venueArray = [[NSMutableArray alloc]init];
        
        for (NSString *venueID in self.likedArray) {
            NSString *urlStringVenue = [[NSString alloc] initWithFormat:@"https://api.foursquare.com/v2/venues/%@?oauth_token=%@&v=%@&m=%@", venueID, self.accessToken, DATA_VERSION_DATE, DATA_FORMAT];
            
            // Now we convert our urlString into a URL
            NSURL *urlVenue = [NSURL URLWithString:urlStringVenue];
            NSURLRequest *requestVenue = [[NSURLRequest alloc] initWithURL:urlVenue];
            
            
            NSURLSessionDownloadTask *taskVenue = [session downloadTaskWithRequest:requestVenue completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                //  Inside the completion block we're going to grab our NSData and we're going to populate that with data from our location
                NSData *dataVenue = [[NSData alloc] initWithContentsOfURL:location];
                
                // Then we use NSJSONSerialization again to output a dictionary
                NSDictionary *responseDictVenue = [NSJSONSerialization JSONObjectWithData:dataVenue options:kNilOptions error:nil];
                
                //Now everytime we get one of these response dictionaries about information from our venue, we want to make sure to add that to our array that we created - venueArray
                [self.venueArray addObject:responseDictVenue];
                
                // Here we make sure to reload the CollecionView AFTER we've added our data to the venueArray
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.collectionView reloadData];
                });
                
            }];
            
            [taskVenue resume];
        }
        
    }];
    
    [task resume];
    }



-(void)refreshPhotos{
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL *url = [NSURL URLWithString:@"https://swapi.co/api/people"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSString *responseText = [[NSString alloc] initWithContentsOfURL:location encoding:NSUTF8StringEncoding error:nil];
        NSLog(@"ResponseText: %@", responseText);
        
        
   
        
        
    }];
    
  
    
    [task resume];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"showDetail"]) {
        // What do we want to do?
        // If the segue.identifier is equal to string showdetail..
        
        // We create an indexPath here and set it equal to the collection view index path for selected items at 0
        
        NSIndexPath *selectedPath = [self.collectionView indexPathsForSelectedItems] [0];
        
        // Then were going to create a dictionary called photo and we'll populate it with the venue array contents at that selectedpath.row
        NSDictionary *photo = self.venueArray[selectedPath.row];
        
        DetailViewController *dvc = (DetailViewController *)segue.destinationViewController;
        
        dvc.photo = photo;
        
    }
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:@"showDetail" sender:self];
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {

    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return self.venueArray.count;
}



- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TPPUICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoPhunCell" forIndexPath:indexPath];
    
    cell.photoData = self.venueArray[indexPath.row];
    
    
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end

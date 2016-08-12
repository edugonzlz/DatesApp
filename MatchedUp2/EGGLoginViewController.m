//
//  EGGLoginViewController.m
//  MatchedUp2
//
//  Created by Edu González on 8/5/15.
//  Copyright (c) 2015 Edu González. All rights reserved.
//

#import "EGGLoginViewController.h"

@interface EGGLoginViewController ()

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) NSMutableData *imageData;

@end

@implementation EGGLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([FBSDKAccessToken currentAccessToken]) {
        [self updateUserInformation];
        [self performSegueWithIdentifier:@"loginToHomeViewControllerSegue" sender:self];
    }
}

//MEtodo de bitfountain para evitar el login cada vez que entramos. Yo lo he hecho en el viewDidLoad con un token
//-(void)viewDidAppear:(BOOL)animated{
//    
//    // Check if user is cached and linked to Facebook, if so, bypass login
//    if ([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
//        
//        [self updateUserInformation];
//        NSLog(@"the user is already signed in ");
//        
//        [self performSegueWithIdentifier:@"loginToTabBarSegue" sender:self];
//    }
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark IBActions

- (IBAction)loginWithFacebookButtonPressed:(UIButton *)sender {
    
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
        
    NSArray *permissionsArray = @[@"public_profile", @"email", @"user_friends", @"user_about_me", @"user_relationships", @"user_birthday", @"user_location", @"user_relationship_details"];

    
    [PFFacebookUtils logInInBackgroundWithReadPermissions:permissionsArray block:^(PFUser *user, NSError *error){
        
        [self.activityIndicator stopAnimating];
        self.activityIndicator.hidesWhenStopped = YES;
        
        if (!user) {
            
            if (!error) {
                
                UIAlertController *cancelAlert = [UIAlertController alertControllerWithTitle:@"Cancel" message:@"Login cancelado" preferredStyle:(UIAlertControllerStyleAlert)];
                
                UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault                                                                          handler:^(UIAlertAction *action) {}];
                
                [cancelAlert addAction:defaultAction];
                
                [self presentViewController:cancelAlert animated:YES completion:nil];
                
            } else {
                UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"Error" message:@"ha habido un error" preferredStyle:(UIAlertControllerStyleAlert)];
                
                UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault                                                                          handler:^(UIAlertAction *action) {}];
                
                [errorAlert addAction:defaultAction];
                
                [self presentViewController:errorAlert animated:YES completion:nil];
            }
        } else {
            NSLog(@"Login complete");
            [self updateUserInformation];
            [self performSegueWithIdentifier:@"loginToHomeViewControllerSegue" sender:self];
        }
    }];
}

-(void)updateUserInformation{
    
    // Send request to Facebook
    
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil];
    
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        
        //NSLog(@"%@",result);
        
        // handle response
        if (!error) {
            // Parse the data received
            NSDictionary *userDictionary = (NSDictionary *)result;
            
            NSString *facebookID = userDictionary[@"id"];
            
            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
            
            NSMutableDictionary *userProfile = [[NSMutableDictionary alloc] initWithCapacity:7];
            
            if (userDictionary[@"name"]) {
                userProfile[kCCUserProfileNameKey] = userDictionary[@"name"];
            }
            if (userDictionary[@"first_name"]) {
                userProfile[kCCUserProfileFirstNameKey] = userDictionary[@"first_name"];
            }
            if (userDictionary[@"location"][@"name"]) {
                userProfile[kCCUserProfileLocationKey] = userDictionary[@"location"][@"name"];
            }
            if (userDictionary[@"gender"]) {
                userProfile[kCCUserProfileGenderKey] = userDictionary[@"gender"];
            }
            if (userDictionary[@"birthday"]) {
                userProfile[kCCUserProfileBirthdayKey] = userDictionary[@"birthday"];
                
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                
                [formatter setDateStyle:NSDateFormatterShortStyle];
                
                NSDate *date = [formatter dateFromString:userDictionary[@"birthday"]];
                
                NSDate *now = [NSDate date];
                
                NSTimeInterval seconds = [now timeIntervalSinceDate: date];
                
                int age = seconds / 31536000;
                
                userProfile[kCCUserProfileAgeKey] = @(age);
            }
            if (userDictionary[@"relationship_status"]) {
                userProfile[kCCUserProfileRelationshipStatusKey] = userDictionary[@"relationship_status"];
            }
            if (userDictionary[@"interested_in"]) {
                userProfile[kCCUserProfileInterestedInKey] = userDictionary[@"interested_in"];
            }
            
            if ([pictureURL absoluteString]){
                userProfile[kCCUserProfilePictureURL] = [pictureURL absoluteString];
            }
            [[PFUser currentUser] setObject:userProfile forKey:@"profile"];
            [[PFUser currentUser] saveInBackground];
            
            [self requestImage];
            
            NSLog(@"actualizados los datos de parse,@%@", userProfile);
        }else {
            NSLog(@"Error in Facebook Request %@", error);
        }
    }];
}

- (void)uploadPFFileToParse:(UIImage *)image{
    
    NSLog(@"upload called");
    // JPEG to decrease file size and enable faster uploads & downloads
    NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
    if (!imageData) {
        NSLog(@"imageData no encontrado");
        return;
    }
    PFFile *photoFile = [PFFile fileWithData:imageData];
    [photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Photo uploaded successfully");
            PFObject *photo = [PFObject objectWithClassName:kCCPhotoClassKey];
            [photo setObject:[PFUser currentUser] forKey:kCCPhotoUserKey];
            [photo setObject:photoFile forKey:kCCPhotoPictureKey];
            [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                NSLog(@"photo saved");
            }];
        }
    }];
}

- (void)requestImage{
    
    PFQuery *query = [PFQuery queryWithClassName:kCCPhotoClassKey];
    
    [query whereKey:kCCPhotoUserKey equalTo:[PFUser currentUser]];
    
    //Use count instead
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        
        if (number == 0){
            PFUser *user = [PFUser currentUser];
            self.imageData = [[NSMutableData alloc] init];

            NSURL *profilePictureURL = [NSURL URLWithString:user[kCCUserProfileKey][kCCUserProfilePictureURL]];
            NSURLRequest *urlRequest = [NSURLRequest requestWithURL:profilePictureURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:4.0f];
            
            // Run network request asynchronously
            NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
            
            if (!urlConnection) {
                NSLog(@"Failed to download picture");
            }
        }
    }];
}

#pragma mark URLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    
    // As chuncks of the image are received, we build our data file
    [self.imageData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    
    // All data has been downloaded, now we can set the image in the header image view
    UIImage *profileImage = [UIImage imageWithData:self.imageData];
    
    [self uploadPFFileToParse:profileImage];
}

@end

//
//  EGGHomeViewController.m
//  MatchedUp2
//
//  Created by Edu González on 26/5/15.
//  Copyright (c) 2015 Edu González. All rights reserved.
//

#import "EGGHomeViewController.h"

@interface EGGHomeViewController ()

@property (strong, nonatomic) IBOutlet UIBarButtonItem *chatBarButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *settingsBarButton;
@property (strong, nonatomic) IBOutlet UIImageView *photoImageView;
@property (strong, nonatomic) IBOutlet UILabel *firstNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *ageLabel;
@property (strong, nonatomic) IBOutlet UILabel *tagLineLabel;
@property (strong, nonatomic) IBOutlet UIButton *likeButton;
@property (strong, nonatomic) IBOutlet UIButton *infoButton;
@property (strong, nonatomic) IBOutlet UIButton *dislikeButton;

@property (strong, nonatomic) NSArray *photos;
@property (strong, nonatomic) PFObject *photo;
@property (strong, nonatomic) NSMutableArray *activities;

@property (nonatomic) int currentPhotoIndex;
@property (nonatomic) BOOL isLikedByCurrentUser;
@property (nonatomic) BOOL isDislikedByCurrentUser;

@end

@implementation EGGHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //self.likeButton.enabled = NO;
    //self.dislikeButton.enabled = NO;
    self.infoButton.enabled = NO;
    
    self.currentPhotoIndex = 0;
    
    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
    [query includeKey:@"user"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error){
        self.photos = objects;
        [self queryForCurrentPhotoIndex];
        }else{
            NSLog(@"Error guardando las fotos");
        }
    }];
    
    [self queryForCurrentPhotoIndex];
}

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

- (IBAction)chatBarButtonPressed:(UIButton *)sender {
}
- (IBAction)settingsBarButtonPressed:(UIButton *)sender {
}
- (IBAction)likeButtonPressed:(UIButton *)sender {
    [self checkLike];
}
- (IBAction)dislikeButtonPressed:(UIButton *)sender {
    [self checkDislike];
}
- (IBAction)infoButtonPressed:(UIButton *)sender {
}

- (void)queryForCurrentPhotoIndex{
    
    if ([self.photos count] > 0) {
        
        self.photo = self.photos[self.currentPhotoIndex];
        
        PFFile *file = self.photo[@"image"];
        
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            
            UIImage *image = [UIImage imageWithData:data];
            
            self.photoImageView.image = image;
            
            [self updateView];
        }];
        
        PFQuery *queryForLike = [PFQuery queryWithClassName:@"Activity"];
        
        [queryForLike whereKey:@"type" equalTo:@"like"];
        
        [queryForLike whereKey:@"photo" equalTo:self.photo];
        
        [queryForLike whereKey:@"fromUser" equalTo:[PFUser currentUser]];
        
        PFQuery *queryForDislike = [PFQuery queryWithClassName:@"Activity"];
        
        [queryForDislike whereKey:@"type" equalTo:@"dislike"];
        
        [queryForDislike whereKey:@"photo" equalTo:self.photo];
        
        [queryForDislike whereKey:@"fromUser" equalTo:[PFUser currentUser]];
        
        PFQuery *likeAndDislikeQuery = [PFQuery orQueryWithSubqueries:@[queryForLike, queryForDislike]];
        
        [likeAndDislikeQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            if (!error){
                
                self.activities = [objects mutableCopy];
                
                if ([self.activities count] == 0) {
                    
                    self.isLikedByCurrentUser = NO;
                    
                    self.isDislikedByCurrentUser = NO;
                    
                } else {
                    
                    PFObject *activity = self.activities[0];
                    
                    if ([activity[@"type"] isEqualToString:@"like"]){
                        
                        self.isLikedByCurrentUser = YES;
                        
                        self.isDislikedByCurrentUser = NO;
                        
                    }
                    
                    else if ([activity[@"type"] isEqualToString:@"dislike"]){
                        
                        self.isLikedByCurrentUser = NO;
                        
                        self.isDislikedByCurrentUser = YES;
                        
                    }
                    
                    else {
                        
                        //Some other type of activity
                        
                    }
                    
                }
                
                self.likeButton.enabled = YES;
                
                self.dislikeButton.enabled = YES;
                
            }
            
        }];
        
        
    }
}

- (void)updateView{
    
    self.firstNameLabel.text = self.photo[@"user"][@"profile"][@"firstName"];
    
    self.ageLabel.text = [NSString stringWithFormat:@"%@", self.photo[@"user"][@"profile"][@"age"]];
    
    self.tagLineLabel.text = self.photo[@"user"][@"tagLine"];
}

-(void)setupNextPhoto{
    
    if (self.currentPhotoIndex + 1 <self.photos.count){
        
        self.currentPhotoIndex ++;
        [self queryForCurrentPhotoIndex];
        
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No More Users to View" message:@"Check Back Later for more People!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        
        [alert show];
    }
}

- (void)saveLike{
    
    PFObject *likeActivity = [PFObject objectWithClassName:@"Activity"];
    
    [likeActivity setObject:@"like" forKey:@"type"];
    
    [likeActivity setObject:[PFUser currentUser] forKey:@"fromUser"];
    
    [likeActivity setObject:[self.photo objectForKey:@"user"] forKey:@"toUser"];
    
    [likeActivity setObject:self.photo forKey:@"photo"];
    
    [likeActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        
        self.isLikedByCurrentUser = YES;
        
        self.isDislikedByCurrentUser = NO;
        
        [self.activities addObject: likeActivity];
        
        [self setupNextPhoto];
        
    }];
    
}

- (void)saveDislike{
    
    PFObject *dislikeActivity = [PFObject objectWithClassName:@"Activity"];
    
    [dislikeActivity setObject:@"dislike" forKey:@"type"];
    
    [dislikeActivity setObject:[PFUser currentUser] forKey:@"fromUser"];
    
    [dislikeActivity setObject:[self.photo objectForKey:@"user"] forKey:@"toUser"];
    
    [dislikeActivity setObject:self.photo forKey:@"photo"];
    
    [dislikeActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        self.isLikedByCurrentUser = NO;
        
        self.isDislikedByCurrentUser = YES;
        
        [self.activities addObject: dislikeActivity];
        
        [self setupNextPhoto];
        
    }];
}

- (void)checkLike

{
    if (self.isLikedByCurrentUser){
        
        [self setupNextPhoto];
        
        return;
    
    }else if (self.isDislikedByCurrentUser){
        
        for (PFObject *activity in self.activities) {
            
            [activity deleteInBackground];
        }
        
        [self.activities removeLastObject];
        
        [self saveLike];
        
    }else [self saveLike];
}

- (void)checkDislike

{
    if (self.isDislikedByCurrentUser){
        
        [self setupNextPhoto];
        
        return;
        
    }else if (self.isLikedByCurrentUser){
        
        for (PFObject *activity in self.activities) {
            
            [activity deleteInBackground];
        }
        
        [self.activities removeLastObject];
        
    }else{
        [self saveDislike];
    }
}

@end

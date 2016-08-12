//
//  EGGEditProfileViewController.m
//  MatchedUp2
//
//  Created by Edu González on 27/5/15.
//  Copyright (c) 2015 Edu González. All rights reserved.
//

#import "EGGEditProfileViewController.h"

@interface EGGEditProfileViewController ()

@property (strong, nonatomic) IBOutlet UITextView *tagLineTextView;
@property (strong, nonatomic) IBOutlet UIImageView *profilePictureTextView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveBarButton;

@end

@implementation EGGEditProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
- (IBAction)saveBarButtonPressed:(UIBarButtonItem *)sender {
}

@end

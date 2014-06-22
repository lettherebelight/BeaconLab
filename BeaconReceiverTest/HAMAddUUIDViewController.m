//
//  HAMAddUUIDViewController.m
//  BeaconReceiverTest
//
//  Created by Dai Yue on 14-5-13.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import "HAMAddUUIDViewController.h"
#import "HAMTools.h"
#import "HAMBeaconManager.h"

@interface HAMAddUUIDViewController ()

@property (weak, nonatomic) IBOutlet UITextField *uuidTextField;

- (IBAction)addUUIDClicked:(UIButton *)sender;

@end

@implementation HAMAddUUIDViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.uuidTextField) {
        [textField resignFirstResponder];
    }
    return YES;
}

- (IBAction)addUUIDClicked:(UIButton *)sender {
    NSString* uuidStringToAdd = self.uuidTextField.text;
    
    //UUID format check
    NSUUID* uuidToAdd = [[NSUUID alloc] initWithUUIDString:uuidStringToAdd];
    if (uuidToAdd == nil) {
        [HAMTools showAlert:@"这不是合法的UUID。" title:@"出错了!" delegate:self];
        return;
    }
    
    HAMBeaconManager* beaconManager = [HAMBeaconManager beaconManager];
    [beaconManager startRangingWithUUID:uuidStringToAdd];
    [HAMTools showAlert:@"UUID已经成功添加。" title:@"成功了!" delegate:self];
}
@end

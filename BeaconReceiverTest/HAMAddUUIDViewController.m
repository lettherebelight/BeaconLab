//
//  HAMAddUUIDViewController.m
//  BeaconReceiverTest
//
//  Created by Dai Yue on 14-5-13.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import "HAMAddUUIDViewController.h"

#import "SVProgressHUD.h"

#import "HAMBeaconManager.h"
#import "HAMAVOSManager.h"

#import "HAMTools.h"
#import "HAMLogTool.h"

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

#pragma mark - Add UUID

- (IBAction)addUUIDClicked:(UIButton *)sender {
    NSString* uuidStringToAdd = self.uuidTextField.text;
    
    //UUID format check
    NSUUID* uuidToAdd = [[NSUUID alloc] initWithUUIDString:uuidStringToAdd];
    if (uuidToAdd == nil) {
        [HAMTools showAlert:@"这不是合法的UUID。" title:@"出错了!" delegate:self];
        return;
    }
    
    //web state check
    if ([HAMTools isWebAvailable] == NO) {
        [SVProgressHUD showErrorWithStatus:@"无法连接到网络。"];
        return;
    }
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    
    [HAMAVOSManager saveBeaconUUID:[uuidToAdd UUIDString] description:@"未知iBeacon" withTarget:self callback:@selector(didSaveUUID:error:)];
    
    //TODO: may change to refresh UUID list in callback
    HAMBeaconManager* beaconManager = [HAMBeaconManager beaconManager];
    [beaconManager startRangingWithUUID:uuidStringToAdd];
}

- (void)didSaveUUID:(NSNumber *)result error:(NSError *)error{
    if (error != nil) {
        [SVProgressHUD showErrorWithStatus:@"保存UUID出错。"];
        [HAMLogTool error:[NSString stringWithFormat: @"error when save UUID:%@", error.userInfo]];
        return;
    }
    
    [SVProgressHUD showSuccessWithStatus:@"UUID已经成功添加。"];
}
@end

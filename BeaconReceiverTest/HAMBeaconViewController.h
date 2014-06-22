//
//  HAMBeaconViewController.h
//  BeaconReceiver
//
//  Created by Dai Yue on 14-2-20.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "HAMBeaconManager.h"

@interface HAMBeaconViewController : UIViewController <CLLocationManagerDelegate,HAMBeaconObserver>

@property (weak, nonatomic) IBOutlet UIButton *StartStopButton;
@property (weak, nonatomic) IBOutlet UITextView *UUIDTextView;
@property (weak, nonatomic) IBOutlet UILabel *MajorIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *MinorIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *AccuracyLabel;
@property (weak, nonatomic) IBOutlet UILabel *DistanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *recallLabel;

@property (strong, nonatomic) CLLocationManager *locationManager;

@property CLBeacon* beaconToReview;

@end

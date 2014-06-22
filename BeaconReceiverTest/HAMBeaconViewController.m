//
//  HAMBeaconViewController.m
//  BeaconReceiver
//
//  Created by Dai Yue on 14-2-20.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import "HAMBeaconViewController.h"

#import <AVOSCloud/AVOSCloud.h>

#import "HAMLogTool.h"
#import "HAMTools.h"
#import "HAMDBManager.h"

//NSString* const testUUID = @"B9407F30-F5F8-466E-AFF9-25556B57FE6D";  //estimote
//NSString* const testUUID = @"F62D3F65-2FCB-AB76-00AB-68186B10300D";
//NSString* const testUUID = @"74278BDA-B644-4520-8F0C-720EAF059935";
//NSString* const testUUID = @"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0";  //云子，四月兄弟
//NSString* const testUUID = @"2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6";
//NSString* const testUUID = @"3AE96580-33DB-458B-8024-2B3C63E0E920";

@interface HAMBeaconViewController ()
{
    int isTesting;
    int testCount;
    int testid;
//    int recallCount;
//    int missingCount;
    double actualDistance;
}

@property (weak, nonatomic) IBOutlet UITextField *actualDistanceTextField;
@property (weak, nonatomic) IBOutlet UITextField *noteTextField;

@property NSMutableArray* distanceData;
@property NSMutableArray* rssiData;

@property AVObject* testObject;

@end

@implementation HAMBeaconViewController

@synthesize StartStopButton;

@synthesize UUIDTextView;
@synthesize MajorIDLabel;
@synthesize MinorIDLabel;
@synthesize AccuracyLabel;
@synthesize DistanceLabel;
@synthesize recallLabel;

@synthesize locationManager;

@synthesize beaconToReview;

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
//    self.locationManager = [[CLLocationManager alloc] init];
//    self.locationManager.delegate = self;
//    [self initRegion];
    
//    testMajor = @1;
//    testMinor = @1;
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapedView:)];
    [self.view addGestureRecognizer:tapGesture];
}

- (void)viewWillAppear:(BOOL)animated{
    isTesting = 0;
//    recallCount = 0;
//    missingCount = 0;
    
    HAMDBManager* dbManager = [HAMDBManager dbManager];
    [dbManager initDatabase];
    
    HAMBeaconManager* beaconManager = [HAMBeaconManager beaconManager];
    NSString* uuid = [beaconToReview.proximityUUID UUIDString];
    [beaconManager registerObserver:self forUUID:uuid major:beaconToReview.major minor:beaconToReview.minor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didRangeBeacon:(CLBeacon*)beacon{
    [self recordBeacon:beacon];
}

/*- (BOOL)beacon:(CLBeacon *)beacon1 isCloserToAnotherBeacon:(CLBeacon *)beacon2
{
    if (beacon2 == nil) {
        return true;
    }
    else if (beacon1.proximity == CLProximityUnknown)
    {
        return false;
    }
    else if (beacon2.proximity == CLProximityUnknown)
    {
        return true;
    }
    else if (beacon1.proximity > beacon2.proximity)
    {
        return false;
    }
    else if (beacon1.proximity < beacon2.proximity)
    {
        return true;
    }
    else if (beacon1.accuracy < beacon2.accuracy)
    {
        return true;
    }
    else
    {
        return false;
    }
}*/

- (void)recordBeacon:(CLBeacon*)beacon{
    if (beacon == nil){
        return;
    }
    
    //update view
    self.UUIDTextView.text = beacon.proximityUUID.UUIDString;
    self.MajorIDLabel.text = [NSString stringWithFormat:@"%@", beacon.major];
    self.MinorIDLabel.text = [NSString stringWithFormat:@"%@", beacon.minor];
    self.DistanceLabel.text = [NSString stringWithFormat:@"%f", beacon.accuracy];
    self.AccuracyLabel.text = [NSString stringWithFormat:@"%d", beacon.rssi];
    
    //update recall rate
//    recallCount++;
    /*if (beacon.accuracy < 0) {
        missingCount++;
    }
    if (recallCount == 10) {
        self.recallLabel.text = [NSString stringWithFormat:@"%f",(recallCount - missingCount + 0.0f)/recallCount];
        recallCount = 0;
        missingCount = 0;
    }*/
    
    //record test data
    if (isTesting) {
//        HAMDBManager* dbManager = [HAMDBManager dbManager];
//        NSString* sql = [NSString stringWithFormat:@"INSERT INTO TESTDATA VALUES(%d,%lf,%d)", testid, beacon.accuracy, beaconOrder];
//        [dbManager runSQL: sql];
        
        if (++testCount >= 3600) {
            [self testStop];
        }
        self.recallLabel.text = [NSString stringWithFormat:@"%d", testCount];
        [self.distanceData addObject:[NSNumber numberWithDouble:beacon.accuracy]];
        [self.rssiData addObject:[NSNumber numberWithInt:beacon.rssi]];
    }
}

- (IBAction)testStart:(id)sender {
    if (isTesting) {
        [self testStop];
        return;
    }
    
    actualDistance = [self.actualDistanceTextField.text doubleValue];
    if (actualDistance <= 0) {
        [HAMTools showAlert:@"不合理的期待距离。" title:@"等等!" delegate:self];
        return;
    }
    
    [StartStopButton setTitle:@"结束实验" forState:UIControlStateNormal];
    
    isTesting = YES;
    testCount = 0;
    self.distanceData = [NSMutableArray array];
    self.rssiData = [NSMutableArray array];
    
    srandom((unsigned int)time(NULL));
    testid = random() % 65536;
}

- (void)testStop{
    isTesting = NO;
    [self showTestResult];
    [StartStopButton setTitle:@"开始实验" forState:UIControlStateNormal];
}

#pragma mark - Report

- (void)showTestResult{
    double averageDistance = [self averageDistance];
    double averageAccuracy = [self averageAccuracy];
    double maxError = [self maxError];
    double averageStandardDeviation = [self averageStandardDeviationWithAverage:averageDistance];
    double lostRate = [self lostRate];
    NSString* note = self.noteTextField.text;
    
    //upload data
    AVObject *testObject = [AVObject objectWithClassName:@"ReviewData"];
    
    [testObject setObject:[beaconToReview.proximityUUID UUIDString] forKey:@"proximityUUID"];
    [testObject setObject:beaconToReview.major forKey:@"major"];
    [testObject setObject:beaconToReview.minor forKey:@"minor"];
    
    [testObject setObject:[NSString stringWithFormat:@"%d",testid] forKey:@"testID"];
    [testObject setObject:[NSNumber numberWithInt:testCount] forKey:@"testCount"];
    [testObject setObject:note forKey:@"note"];
    
    NSMutableArray* rawDataArray = [NSMutableArray array];
    for (int i = 0; i < testCount; i++) {
        NSMutableDictionary* singleTestData = [NSMutableDictionary dictionary];
        [singleTestData setObject:self.distanceData[i] forKey:@"distance"];
        [singleTestData setObject:self.rssiData[i] forKey:@"rssi"];
        [rawDataArray addObject:singleTestData];
    }
    [testObject setObject:rawDataArray forKey:@"raw"];
    
    [testObject setObject:[NSNumber numberWithDouble:actualDistance] forKey:@"expectedDistance"];
    [testObject setObject:[NSNumber numberWithDouble:averageDistance] forKey:@"averageDistance"];
    [testObject setObject:[NSNumber numberWithDouble:averageAccuracy] forKey:@"accuracy"];
    [testObject setObject:[NSNumber numberWithDouble:maxError] forKey:@"maxDeviation"];
    [testObject setObject:[NSNumber numberWithDouble:averageStandardDeviation] forKey:@"standardDeviation"];
    [testObject setObject:[NSNumber numberWithDouble:lostRate] forKey:@"lostRate"];
    
    NSString* testObjectID = nil;
    if ([HAMTools isWebAvailable]) {
        [testObject save];
        testObjectID = testObject.objectId;
    }
    else{
        [testObject saveEventually];
    }
    
    //cache for turnToTestReport
    self.testObject = testObject;
    
    //show report
    NSString* lostRateString = [NSString stringWithFormat:@"%.2lf%%",lostRate * 100];
    NSString* result = [NSString stringWithFormat:@"平均距离: %lf\n平均误差: %lf\n最大误差: %lf\n标准偏差: %lf\n\n丢失率: %@\n\n实验备注：%@\n实验次数: %d",averageDistance,averageAccuracy,maxError,averageStandardDeviation,lostRateString,note,testCount];
    if (testObjectID != nil) {
        [HAMTools showAlert:result title:@"实验结果" buttonTitle:@"查看详细报告" delegate:self];
    }
    else{
        [HAMTools showAlert:result title:@"实验结果" delegate:self];
    }
}

-(void)turnToTestReport:(NSString*)testObjectID{
    NSString* urlString = [NSString stringWithFormat:@"http://beaconutils.qiniudn.com/beaconutils/index.html#/test/%@",testObjectID];
    NSURL* url = [[NSURL alloc] initWithString:urlString];
    [[UIApplication sharedApplication] openURL:url];
}

#pragma mark - Statistic Methods

-(double)averageDistance{
    int i;
    double sum = 0;
    int validTestCount = 0;
    for (i = 0; i < testCount; i++) {
        double distance = [[self.distanceData objectAtIndex:i] doubleValue];
        if (distance > 0) {
            sum += distance;
            validTestCount ++;
        }
    }
    
    if (validTestCount == 0) {
        validTestCount = 1;
    }
    return sum / validTestCount;
}

-(double)averageAccuracy{
    int i;
    double errorSum = 0;
    int validTestCount = 0;
    for (i = 0; i < testCount; i++) {
        double distance = [[self.distanceData objectAtIndex:i] doubleValue];
        if (distance > 0) {
            errorSum += ABS(distance - actualDistance);
            validTestCount ++;
        }
    }
    
    if (validTestCount == 0) {
        validTestCount = 1;
    }
    return errorSum / validTestCount;
}

-(double)maxError{
    int i;
    double maxError = 0;
    for (i = 0; i < testCount; i++) {
        double distance = [[self.distanceData objectAtIndex:i] doubleValue];
        if (distance > 0) {
            double error = [[self.distanceData objectAtIndex:i] doubleValue] - actualDistance;
            maxError = MAX(maxError,ABS(error));
        }
    }
    
    return maxError;
}

-(double)averageStandardDeviationWithAverage:(double)average{
    int i;
    double errorSquareSum = 0;
    int validTestCount = 0;
    for (i = 0; i < testCount; i++) {
        double distance = [[self.distanceData objectAtIndex:i] doubleValue];
        if (distance > 0) {
            double error = [[self.distanceData objectAtIndex:i] doubleValue] - average;
            errorSquareSum += error * error;
            validTestCount ++;
        }
    }
    
    if (validTestCount == 0) {
        validTestCount = 1;
    }
    return sqrt(errorSquareSum / validTestCount);
}

- (double)lostRate{
    int i;
    int lostCount = 0;
    for (i = 0; i < testCount; i++) {
        if ([self.distanceData[i] doubleValue] < 0) {
            lostCount++;
        }
    }
    return (lostCount + 0.0f)/testCount;
}

#pragma mark - UI Delegate

- (void)tapedView:(UITapGestureRecognizer *)gesture{
    [self.noteTextField resignFirstResponder];
    [self.actualDistanceTextField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
//    if (textField == self.actualDistanceTextField) {
        [textField resignFirstResponder];
//    }
    return YES;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self turnToTestReport:self.testObject.objectId];
    }
}

@end

//
//  HAMViewController.m
//  BeaconReceiver
//
//  Created by Dai Yue on 14-2-18.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import "HAMViewController.h"
#import "HAMBeaconViewController.h"
#import "HAMTools.h"
#import "SVProgressHUD.h"

@interface HAMViewController () 
{}


@property (weak, nonatomic) IBOutlet UIBarButtonItem *fetchUUIDListButton;
@property (weak, nonatomic) IBOutlet UITableView *beaconTableView;

@property NSMutableDictionary* beaconDictionaryCached;
@property NSMutableDictionary* beaconDictionary;
@property NSTimer* refreshTimer;

//for prepare segue
@property CLBeacon* beaconSelected;

//for didStartRanging
@property Boolean firstStartRanging;

- (IBAction)fetchUUIDListClicked:(id)sender;

@end

@implementation HAMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // pull table setup
//    self.beaconTableView.pullArrowImage = [UIImage imageNamed:@"blackArrow"];
//    self.beaconTableView.pullBackgroundColor = [UIColor whiteColor];
//    self.beaconTableView.pullTextColor = [UIColor blackColor];
    
    self.beaconDictionaryCached = [NSMutableDictionary dictionary];
    self.beaconDictionary = [NSMutableDictionary dictionary];
    
    HAMBeaconManager* beaconManager = [HAMBeaconManager beaconManager];
    self.firstStartRanging = YES;
    [beaconManager startRanging];
}

- (void)viewWillAppear:(BOOL)animated{
    HAMBeaconManager* beaconManager = [HAMBeaconManager beaconManager];
    [beaconManager registerObserverForAll:self];
    
    [self refreshTableView];
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(refreshTableView) userInfo:nil repeats:YES];
    [self.refreshTimer fire];
    
//    if(!self.beaconTableView.pullTableIsRefreshing) {
//        self.beaconTableView.pullTableIsRefreshing = YES;
//        [self performSelector:@selector(refreshTable) withObject:nil afterDelay:3];
//        [self refreshTable];
//    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Ranging Delegate

- (void)didStartRanging{
    if (! self.firstStartRanging) {
        [SVProgressHUD showSuccessWithStatus:@"更新完成。"];
        self.fetchUUIDListButton.enabled = YES;
    }
}

- (void)didRangeBeacons:(NSArray *)beacons ofUUID:(NSString *)uuid{
//    NSArray* oldBeacons = [self.beaconDictionary objectForKey:uuid];
//    if (oldBeacons == nil) {
        [self.beaconDictionary setObject:beacons forKey:uuid];
//        return;
//    }
    
    /*for (int i = 0; i < beacons.count; i++) {
        CLBeacon* beacon = beacons[i];
        if (beacon.accuracy < 0) {
            
        }
    }*/
}

- (void)didExitRegionOfUUID:(NSString *)uuid{
    [self.beaconDictionary removeObjectForKey:uuid];
}

- (IBAction)fetchUUIDListClicked:(id)sender {
    if (![HAMTools isWebAvailable]) {
        [SVProgressHUD showErrorWithStatus:@"无法连接到网络。"];
        return;
    }
    
    HAMBeaconManager* beaconManager = [HAMBeaconManager beaconManager];
    self.firstStartRanging = NO;
    self.fetchUUIDListButton.enabled = NO;
    [beaconManager startRanging];
}

#pragma mark - TableView Assist Methods

- (void)refreshTableView{
    self.beaconDictionaryCached = [self.beaconDictionary copy];
    [self.beaconTableView reloadData];
}

- (NSString*)uuidAtIndex:(NSInteger)index{
    NSArray* uuidArray = [self.beaconDictionaryCached allKeys];
    if (index < uuidArray.count) {
        return uuidArray[index];
    }
    return nil;
}

- (NSArray*)beaconArrayAtIndex:(NSInteger)index{
    NSString* uuid = [self uuidAtIndex:index];
    return [self.beaconDictionaryCached objectForKey:uuid];
}

- (CLBeacon*)beaconAtIndexPath:(NSIndexPath*)indexPath{
    int section = indexPath.section;
    NSArray* beaconArray = [self beaconArrayAtIndex:section];
    if (beaconArray == nil) {
        return nil;
    }
    
    int row = indexPath.row;
    if (row < beaconArray.count) {
        return beaconArray[row];
    }
    return nil;
}

#pragma mark - Table Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.beaconDictionaryCached.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString* uuid = [self uuidAtIndex:section];
    if (uuid == nil) {
        return @"";
    }
    
    HAMBeaconManager* beaconManager = [HAMBeaconManager beaconManager];
    NSString* description = [beaconManager descriptionOfUUID:uuid];
    return [NSString stringWithFormat:@"%@ : %@",description,uuid];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray* beaconArray = [self beaconArrayAtIndex:section];
    return beaconArray.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString* CellIdentifier = [NSString stringWithFormat:@"BeaconCell"];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

    
    CLBeacon* beacon = [self beaconAtIndexPath:indexPath];
    
    if (beacon == nil) {
        cell.textLabel.text = @"?";
        cell.detailTextLabel.text = @"Major: ?, Minor: ? 距离: ?";
        return cell;
    }
    
    NSString* uuid = [beacon.proximityUUID UUIDString];
    HAMBeaconManager* beaconManager = [HAMBeaconManager beaconManager];
    NSString* description = [beaconManager descriptionOfUUID:uuid];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@",description];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Major: %@, Minor: %@ 距离: %lf",beacon.major,beacon.minor,beacon.accuracy];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    CLBeacon* beaconSelected = [self beaconAtIndexPath:indexPath];
    if (beaconSelected == nil) {
        [HAMTools showAlert:@"选择的Beacon已离开范围。" title:@"抱歉……" delegate:self];
        return;
    }

    [self performSegueWithIdentifier:@"turnToReviewTest" sender:beaconSelected];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"turnToReviewTest"]) {
        CLBeacon* beaconSelected = sender;
        HAMBeaconViewController* beaconViewController = segue.destinationViewController;
        beaconViewController.beaconToReview = beaconSelected;
    }
}

/*
#pragma mark - Pull and Refresh

- (void)pullTableViewDidTriggerRefresh:(PullTableView *)pullTableView
{
//    [self performSelector:@selector(refreshTable) withObject:nil afterDelay:3.0f];
    [self refreshTable];
}

- (void)pullTableViewDidTriggerLoadMore:(PullTableView *)pullTableView
{
//    [self performSelector:@selector(loadMoreDataToTable) withObject:nil afterDelay:3.0f];
    NSLog(@"load more");
}

- (void)refreshTable{
    NSLog(@"refresh");
    self.beaconTableView.pullLastRefreshDate = [NSDate date];
    self.beaconTableView.pullTableIsRefreshing = NO;
}*/

@end

//
//  HAMViewController.h
//  BeaconReceiver
//
//  Created by Dai Yue on 14-2-18.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HAMBeaconManager.h"

@interface HAMViewController : UIViewController<UITableViewDataSource, UITableViewDelegate,HAMBeaconObserver>
{
}

@end

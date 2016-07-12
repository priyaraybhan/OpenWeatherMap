//
//  OpenWeatherMapViewController.h
//  OpenWeatherMap
//
//  Created by Priya Raybhan on 09/07/16.
//  Copyright © 2016 Priya Raybhan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OpenWeatherMapViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *cityName;
@property (weak, nonatomic) IBOutlet UILabel *currentTemp;
@property (weak, nonatomic) IBOutlet UICollectionView *forecastCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *currentTimestamp;
@property (weak, nonatomic) IBOutlet UILabel *weather;
@end

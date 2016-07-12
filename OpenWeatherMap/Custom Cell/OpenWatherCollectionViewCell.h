//
//  OpenWatherCollectionViewCell.h
//  OPM
//
//  Created by Priya Raybhan on 12/07/16.
//  Copyright © 2016 Priya Raybhan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OpenWatherCollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UIImageView *weatherIcon;
@property (strong, nonatomic) IBOutlet UILabel *lblDate;
@property (strong, nonatomic) IBOutlet UILabel *lblDayTemp;
@property (strong, nonatomic) IBOutlet UILabel *lblNightTemp;
@property (strong, nonatomic) IBOutlet UILabel *lblClouds;
@property (strong, nonatomic) IBOutlet UILabel *lblHumidity;
@property (strong, nonatomic) IBOutlet UILabel *lblPressure;
@property (strong, nonatomic) IBOutlet UILabel *lblSpeed;
@property (strong, nonatomic) IBOutlet UILabel *lblDeg;
@property (strong, nonatomic) IBOutlet UILabel *lblRain;

-(void)setAllValues:(NSDictionary*)dictForecast;
@end

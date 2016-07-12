//
//  OpenWatherCollectionViewself.m
//  OPM
//
//  Created by Priya Raybhan on 12/07/16.
//  Copyright © 2016 Priya Raybhan. All rights reserved.
//

#import "OpenWatherCollectionViewCell.h"
#import "UIImageView+WebCache.h"

@implementation OpenWatherCollectionViewCell

#pragma mark - Set all values


-(void)setAllValues:(NSDictionary*)forecastData {
    
    [self.weatherIcon sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://openweathermap.org/img/w/%@.png",forecastData[@"weather"][0][@"icon"]]] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    [self.lblDate setText:[self getUTCFormateDate:[NSString stringWithFormat:@"%@",forecastData[@"dt"]]]];
    
    
    [self.lblDate setText:[[self.lblDate.text stringByAppendingString:[NSString stringWithFormat:@"\n%@",forecastData[@"weather"][0][@"main"]]] uppercaseString]];
    [self.lblDayTemp setText:[NSString stringWithFormat:@"%.2f°",[forecastData[@"temp"][@"day"]doubleValue]]];
    [self.lblNightTemp setText:[NSString stringWithFormat:@"%.2f°",[forecastData[@"temp"][@"night"]doubleValue]]];
    [self.lblClouds setText:[NSString stringWithFormat:@"Clouds : %@",forecastData[@"clouds"]]];
    [self.lblDeg setText:[NSString stringWithFormat:@"Deg : %@",forecastData[@"deg"]]];
    [self.lblHumidity setText:[NSString stringWithFormat:@"Humidity : %@%%",forecastData[@"humidity"]]];
    [self.lblPressure setText:[NSString stringWithFormat:@"Pressure : %.2fmb",[forecastData[@"pressure"]doubleValue]]];
    [self.lblSpeed setText:[NSString stringWithFormat:@"Speed : %.2fkm/h",[forecastData[@"speed"]doubleValue]]];
    [self.lblRain setText:[NSString stringWithFormat:@"Rain : %.2f",[forecastData[@"rain"]doubleValue]]];
}

#pragma mark - Get date in proper format

-(NSString *)getUTCFormateDate:(NSString *)localDate
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZZ"];
    NSDate* utcTime = [dateFormatter dateFromString:localDate];
    NSLog(@"UTC time: %@", utcTime);
    
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    [dateFormatter setDateFormat:@"MMM dd yyyy"];
    NSString* localTime = [dateFormatter stringFromDate:utcTime];
    NSLog(@"localTime:%@", localTime);
    return localTime;
}
@end

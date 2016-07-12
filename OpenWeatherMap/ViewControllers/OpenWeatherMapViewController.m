

//  OpenWeatherMapViewController.m
//  OpenWeatherMap
//
//  Created by Priya Raybhan on 09/07/16.
//  Copyright © 2016 Priya Raybhan. All rights reserved.
//

#import "OpenWeatherMapViewController.h"
#import "OpenWeatherMapAPI.h"
#import "UIView+Toast.h"
#import "MBProgressHUD.h"
#import "OpenWatherCollectionViewCell.h"

#define kAPI_KEY  @"8c9ca9ca1f00fa37e6922027e6b23e86"


@interface OpenWeatherMapViewController () <CLLocationManagerDelegate,UITextFieldDelegate>
{
    OpenWeatherMapAPI *_weatherAPI;
    NSArray *_forecast;
    
    int downloadCount;
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
    
    IBOutlet UITextField *txtField;
    MBProgressHUD *hud;
    BOOL isLocationDetected;
    
}
@end

@implementation OpenWeatherMapViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self getCurrentLocation];
    
    _weatherAPI = [[OpenWeatherMapAPI alloc] initWithAPIKey:kAPI_KEY];
    
    // We want localized strings according to the prefered system language
    [_weatherAPI setLangWithPreferedLanguage];
    
    // We want the temperatures in celcius, you can also get them in farenheit.
    [_weatherAPI setTemperatureFormat:kOWMTempCelcius];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Get weather forcast for city

-(void)getWeatherForcastForCity :(NSString*)cityName {
    
    _forecast = @[];
    
    [self.forecastCollectionView performBatchUpdates:^{
        [self.forecastCollectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    } completion:^(BOOL finished) {}];
    
    [_weatherAPI dailyForecastWeatherByCityName:cityName withCount:16 andCallback:^(NSError *error, NSDictionary *result) {
        downloadCount++;
        
        [self hideProgress];
        
        if (downloadCount > 1)
            
            if (error) {
                // Handle the error;
                [self.navigationController.view makeToast:error.userInfo[@"NSLocalizedDescription"]];
                
                return;
            }
        
        _forecast = result[@"list"];
        [self.forecastCollectionView performBatchUpdates:^{
            [self.forecastCollectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
        } completion:^(BOOL finished) {}];
        
        
    }];
    
}

#pragma mark - MBProgressHUD methods

-(void)showProgress {
    hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.label.text = NSLocalizedString(@"Loading...", @"HUD loading title");
}

-(void)hideProgress {
    [hud hideAnimated:YES];
}

#pragma mark - IBAction

-(IBAction)btnSearchWeatherForcastPressed:(UIButton*)sender {
    
    [self showProgress];
    [txtField resignFirstResponder];
    isLocationDetected = NO;
    switch (sender.tag) {
        case 1:
            [self validateTextFiled];
            break;
            
        case 2:
            [locationManager startUpdatingLocation];
            break;
            
        default:
            break;
    }
    
}

#pragma validate textfield

-(void)validateTextFiled {
    if (txtField.text.length > 0) {
        [self getWeatherForcastForCity:txtField.text];
    }
    else
    {
        [self.navigationController.view makeToast:@"Please enter city name"];
        [self hideProgress];
        
    }
}

#pragma mark - get current location

-(void)getCurrentLocation
{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate=self;
    locationManager.desiredAccuracy=kCLLocationAccuracyBest;
    locationManager.distanceFilter=kCLDistanceFilterNone;
    [locationManager startMonitoringSignificantLocationChanges];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        [locationManager requestWhenInUseAuthorization];
    
}


#pragma mark - location manager delegate


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    currentLocation = [locations objectAtIndex:0];
    [locationManager stopUpdatingLocation];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error)
     {
         [self hideProgress];
         [txtField setText:@""];
         if (!(error))
         {
             CLPlacemark *placemark = [placemarks objectAtIndex:0];
             if (!isLocationDetected) {
                 isLocationDetected = YES;
                 [self getWeatherForcastForCity:placemark.addressDictionary[@"SubAdministrativeArea"]];
             }
             
         }
         else
         {
             [self.navigationController.view makeToast:@"Current Location Not Detected"];
             
         }
         
     }];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    [self.navigationController.view makeToast:@"Current Location Not Detected"];
    
    [self hideProgress];
    
}


#pragma mark - text filed delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [txtField resignFirstResponder];
    return YES;
}


#pragma mark -
#pragma mark UICollectionViewDataSource

-(NSInteger)numberOfSectionsInCollectionView:
(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView
    numberOfItemsInSection:(NSInteger)section
{
    return _forecast.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    OpenWatherCollectionViewCell *cell = [collectionView
                                          dequeueReusableCellWithReuseIdentifier:@"OpenWatherCollectionViewCell"
                                          forIndexPath:indexPath];
    [cell setAllValues:[_forecast objectAtIndex:indexPath.row]];
    
    return cell;
}

#pragma mark -
#pragma mark UICollectionViewFlowLayoutDelegate

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    return CGSizeMake(collectionView.bounds.size.width, 146);
}




/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end

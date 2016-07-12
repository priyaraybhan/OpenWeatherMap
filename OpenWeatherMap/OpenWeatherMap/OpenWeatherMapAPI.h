//
//  OpenWeatherMapAPI.h
//  OpenWeatherMap
//
//  Created by Priya Raybhan on 09/07/16.
//  Copyright © 2016 Priya Raybhan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef enum {
    kOWMTempKelvin,
    kOWMTempCelcius,
    kOWMTempFahrenheit
} OWMTemperature;


@interface OpenWeatherMapAPI : NSObject

- (instancetype) initWithAPIKey:(NSString *) apiKey;

- (void) setApiVersion:(NSString *) version;
- (NSString *) apiVersion;

- (void) setTemperatureFormat:(OWMTemperature) tempFormat;
- (OWMTemperature) temperatureFormat;

- (void) setLangWithPreferedLanguage;
- (void) setLang:(NSString *) lang;
- (NSString *) lang;

#pragma mark - current weather

-(void) currentWeatherByCityName:(NSString *) name
                    withCallback:( void (^)( NSError* error, NSDictionary *result ) )callback;



#pragma mark forcast - n days

-(void) dailyForecastWeatherByCityName:(NSString *) name
                             withCount:(int) count
                           andCallback:( void (^)( NSError* error, NSDictionary *result ) )callback;

@end

//
//  OpenWeatherMapAPI.m
//  OpenWeatherMap
//
//  Created by Priya Raybhan on 09/07/16.
//  Copyright © 2016 Priya Raybhan. All rights reserved.
//

#import "OpenWeatherMapAPI.h"


@interface OpenWeatherMapAPI () <NSURLSessionDelegate>{
    NSString *baseURL;
    NSString *apiKey;
    NSString *apiVersion;
    NSOperationQueue *weatherQueue;
    
    NSString *lang;
    
    OWMTemperature currentTemperatureFormat;
}

@end

@implementation OpenWeatherMapAPI
- (instancetype) initWithAPIKey:(NSString *) mapApiKey {
    self = [super init];
    if (self) {
        baseURL = @"http://api.openweathermap.org/data/";
        apiKey  = mapApiKey;
        apiVersion = @"2.5";
        
        weatherQueue = [[NSOperationQueue alloc] init];
        weatherQueue.name = @"OMWWeatherQueue";
        
        currentTemperatureFormat = kOWMTempCelcius;
        
    }
    return self;
}

#pragma mark - private parts

- (void) setTemperatureFormat:(OWMTemperature) tempFormat {
    currentTemperatureFormat = tempFormat;
}
- (OWMTemperature) temperatureFormat {
    return currentTemperatureFormat;
}

+ (NSNumber *) tempToCelcius:(NSNumber *) tempKelvin
{
    return @(tempKelvin.floatValue - 273.15);
}

+ (NSNumber *) tempToFahrenheit:(NSNumber *) tempKelvin
{
    return @((tempKelvin.floatValue * 9/5) - 459.67);
}


- (NSNumber *) convertTemp:(NSNumber *) temp {
    if (currentTemperatureFormat == kOWMTempCelcius) {
        return [OpenWeatherMapAPI tempToCelcius:temp];
    } else if (currentTemperatureFormat == kOWMTempFahrenheit) {
        return [OpenWeatherMapAPI tempToFahrenheit:temp];
    } else {
        return temp;
    }
}

- (NSDate *) convertToDate:(NSNumber *) num {
    return [NSDate dateWithTimeIntervalSince1970:num.intValue];
}

/**
 * Recursivly change temperatures in result data
 **/
- (NSDictionary *) convertResult:(NSDictionary *) res {
    
    NSMutableDictionary *dic = [res mutableCopy];
    
    NSMutableDictionary *main = [[dic objectForKey:@"main"] mutableCopy];
    if (main) {
        main[@"temp"] = [self convertTemp:main[@"temp"]];
        main[@"temp_min"] = [self convertTemp:main[@"temp_min"]];
        main[@"temp_max"] = [self convertTemp:main[@"temp_max"]];
        
        dic[@"main"] = [main copy];
        
    }
    
    NSMutableDictionary *temp = [[dic objectForKey:@"temp"] mutableCopy];
    if (temp) {
        temp[@"day"] = [self convertTemp:temp[@"day"]];
        temp[@"eve"] = [self convertTemp:temp[@"eve"]];
        temp[@"max"] = [self convertTemp:temp[@"max"]];
        temp[@"min"] = [self convertTemp:temp[@"min"]];
        temp[@"morn"] = [self convertTemp:temp[@"morn"]];
        temp[@"night"] = [self convertTemp:temp[@"night"]];
        
        dic[@"temp"] = [temp copy];
    }
    
    
    NSMutableDictionary *sys = [[dic objectForKey:@"sys"] mutableCopy];
    if (sys) {
        
        sys[@"sunrise"] = [self convertToDate: sys[@"sunrise"]];
        sys[@"sunset"] = [self convertToDate: sys[@"sunset"]];
        
        dic[@"sys"] = [sys copy];
    }
    
    
    NSMutableArray *list = [[dic objectForKey:@"list"] mutableCopy];
    if (list) {
        
        for (int i = 0; i < list.count; i++) {
            [list replaceObjectAtIndex:i withObject:[self convertResult: list[i]]];
        }
        
        dic[@"list"] = [list copy];
    }
    
    dic[@"dt"] = [self convertToDate:dic[@"dt"]];
    
    return [dic copy];
}

/**
 * Calls the web api, and converts the result. Then it calls the callback on the caller-queue
 **/
- (void) callMethod:(NSString *) method withCallback:( void (^)( NSError* error, NSDictionary *result ) )callback
{
    
    NSOperationQueue *callerQueue = [NSOperationQueue currentQueue];
    
    // build the lang paramter
    NSString *langString;
    if (lang && lang.length > 0) {
        langString = [NSString stringWithFormat:@"&lang=%@", lang];
    } else {
        langString = @"";
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@&APPID=%@%@", baseURL, apiVersion, method, apiKey, langString];
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    

    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: self delegateQueue: [NSOperationQueue mainQueue]];
    
    
    NSURLSessionDataTask * dataTask = [defaultSession dataTaskWithURL:url
                                                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                        if(error == nil)
                                                        {
                                                            NSDictionary *dictCategory = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                                                            NSDictionary *res = [self convertResult:dictCategory];
                                                            [callerQueue addOperationWithBlock:^{
                                                                callback(nil, res);
                                                            }];

                                                        }
                                                        else
                                                        {
                                                            [callerQueue addOperationWithBlock:^{
                                                                            callback(error, nil);
                                                                        }];
                                                        }
                                                        
                                                    }];
    
    [dataTask resume];
    
  
    

}

#pragma mark - public api

- (void) setApiVersion:(NSString *) version {
    apiVersion = version;
}

- (NSString *) apiVersion {
    return apiVersion;
}

- (void) setLangWithPreferedLanguage {
    NSString *preferredLang = [[NSLocale preferredLanguages] objectAtIndex:0];
    
    // look up, lang and convert it to the format that openweathermap.org accepts.
    NSDictionary *langCodes = @{
                                @"sv" : @"se",
                                @"es" : @"sp",
                                @"en-GB": @"en",
                                @"uk" : @"ua",
                                @"pt-PT" : @"pt",
                                @"zh-Hans" : @"zh_cn",
                                @"zh-Hant" : @"zh_tw",
                                };
    
    NSString *l = [langCodes objectForKey:preferredLang];
    if (l) {
        preferredLang = l;
    }
    
    
    [self setLang:preferredLang];
}

- (void) setLang:(NSString *) preferredLang {
    lang = preferredLang;
}

- (NSString *) lang {
    return lang;
}

#pragma mark current weather

-(void) currentWeatherByCityName:(NSString *) name
                    withCallback:( void (^)( NSError* error, NSDictionary *result ) )callback
{
    
    NSString *method = [NSString stringWithFormat:@"/weather?q=%@", name];
    [self callMethod:method withCallback:callback];
    
}

#pragma mark forcast - n days

-(void) dailyForecastWeatherByCityName:(NSString *) name
                             withCount:(int) count
                           andCallback:( void (^)( NSError* error, NSDictionary *result ) )callback
{
    
    NSString *method = [NSString stringWithFormat:@"/forecast/daily?q=%@&cnt=%d", name, count];
    [self callMethod:method withCallback:callback];
    
}


@end

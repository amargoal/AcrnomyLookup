//
//  ConnectionsManager.m
//  Acronym
//
//  Created by Amargoal1 on 4/19/16.
//  Copyright (c) 2016 com.demo. All rights reserved.
//

#import "ConnectionsManager.h"
#import "AppDelegate.h"
#import "AIConstants.h"

@interface ConnectionsManager ()

@property (nonatomic, strong) NSDictionary *response;

- (void) postToURL:(NSString *)url withParameters:(NSDictionary *)parameters delegate:(id<ServerResponseDelegate>)delegate;

@end

@implementation ConnectionsManager
// Singletone related

+ (instancetype)sharedManager {
    
    static ConnectionsManager *_sharedManager = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedManager = [[self alloc] initWithBaseURL:[NSURL URLWithString:AIBaseURL]];
    });
    
    return _sharedManager;
}

- (instancetype)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    
    if (self) {
        AFSecurityPolicy *policy = [[AFSecurityPolicy alloc] init];
        [policy setAllowInvalidCertificates:YES];
        
        [self setSecurityPolicy:policy];
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        self.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    return self;
}

- (void)success:(NSDictionary *)response
{
    
}

- (void)failure:(NSDictionary *)response
{
    
}

- (void) getToURL:(NSString *)url withParameters:(NSDictionary *)parameters delegate:(id<ServerResponseDelegate>)delegate
{
    NSString *urlString = AIBaseURL;
    //createGroup
    NSDictionary *tmpParameters = parameters;
    [self.requestSerializer setTimeoutInterval:12.0];
    
    [self GET:urlString parameters:tmpParameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject) {
            
            if(!responseObject || responseObject == nil)
            {
                responseObject = responseObject; //[responseObject objectForKey:@"responseBody"];
            }
            if (responseObject) {
            
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [delegate success:responseObject];
                });
            }
            else {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self showErrorMessage];
                });
            }
        }
        else {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self showErrorMessage];
            });
        }
    }
       failure:^(AFHTTPRequestOperation *operation, NSError *error) {
           
           dispatch_async(dispatch_get_main_queue(), ^{
               
               // If timeout then don't show the timeout error message.
               if (error.code != NSURLErrorTimedOut) {
                   
               }
               
               if (delegate && [delegate respondsToSelector:@selector(failure:)]) {
                   
                   [delegate failure:nil];
               }
           });
       }];
}

- (void)showErrorMessage {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"No server response." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
}

-(void)fetchMeaningsForAcronym:(NSDictionary *)params withdelegate:(id<ServerResponseDelegate>)delegate
{
    //update_physical_examination
    [self getToURL:nil withParameters:params delegate:delegate];
}


@end

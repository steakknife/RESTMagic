//
//  RMAPIManager.m
//  RESTMagic
//
//  Created by Jason Katzer on 7/7/12.
//  Copyright (c) 2012 Jason Katzer. All rights reserved.
//
//
// Do we want to cache all objects?
// Ship binaries with javascript frameworks downloaded?
// Download zipped packages with all reources, including templates?
// or maybe without templates?

#import "RMAPIManager.h"
#import "SynthesizeSingleton.h"

@implementation RMAPIManager
SYNTHESIZE_SINGLETON_FOR_CLASS_WITH_CUSTOM_METHOD(RMAPIManager, sharedAPIManager)

@synthesize baseURL;


-(id)init
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"RESTMagic" ofType:@"plist"];
    settings = [[NSDictionary alloc] initWithContentsOfFile:filePath];
    
    if ([settings objectForKey:@"BaseURL"]) {
        baseURL = [NSURL URLWithString:[settings objectForKey:@"BaseURL"]];
    }
    return self;
}

-(NSString *)nameForResourceAtPath:(NSString *)path
{
    return [path componentsSeparatedByString:@"/"][0];
}

-(NSString *)nameForResourceAtURL:(NSURL *)url
{
    return [[[[url path] componentsSeparatedByString:@"/"] lastObject] stringByReplacingOccurrencesOfString:@".json" withString:@""];
}

-(NSURL *)URLForResourceAtPath:(NSString *)path
{
    return [NSURL URLWithString:path relativeToURL:baseURL];
}


-(NSString *)urlForResourceAtPath:(NSString *)path
{
    return [[self URLForResourceAtPath:path] absoluteString];
}

-(NSString *)templateUrlForResourceAtUrl:(NSURL *)url
{
    //check for parts of the path that are actually unique identifiers
    
    NSString *lastPartOfPath = [[url pathComponents] lastObject];
    
    NSString *potentialId = [[lastPartOfPath componentsSeparatedByString:@"."] objectAtIndex:0];
    
    if ([potentialId intValue] != 0) {
        NSMutableArray *restOfPath = [NSMutableArray arrayWithArray:[[url path]componentsSeparatedByString:@"/"]];
        [restOfPath removeLastObject];
        
        NSString *pathBeforeId = [restOfPath componentsJoinedByString:@"/"];
        
        NSString *pathAfterId = [[lastPartOfPath componentsSeparatedByString:@"."] lastObject];
        return [NSString stringWithFormat:@"templates/%@%@/id.%@", [url host], pathBeforeId, pathAfterId];
    }
    
    return [NSString stringWithFormat:@"templates/%@%@", [url host], [url path]];
}


-(NSString *) potentialViewControllerNameForResourceNamed:(NSString *)resourceName
{
    return [NSString stringWithFormat:@"%@%@ViewController",[settings objectForKey:@"ProjectClassPrefix"],resourceName];
}

-(NSString *) resourceNameForResourceAtPath:(NSString *)path
{
    NSString* resourceName = [self nameForResourceAtPath:path];
    return [resourceName stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[resourceName substringToIndex:1] uppercaseString]];
}

-(RMViewController *)viewControllerForResourceAtPath:(NSString *)path
{
    id viewController = [[NSClassFromString([self potentialViewControllerNameForResourceNamed:[self resourceNameForResourceAtPath:path]]) alloc] initWithResourceAtUrl:[self urlForResourceAtPath:path] withTitle:[self nameForResourceAtPath:path]];
    
    if (viewController) {
        return viewController;
    }

    return [[RMViewController alloc] initWithResourceAtUrl:[self urlForResourceAtPath:path] withTitle:[self nameForResourceAtPath:path]];
}

-(RMViewController *)viewControllerForResourceAtURL:(NSURL *)url
{
    return [self viewControllerForResourceAtPath:[url absoluteString]];
}


-(BOOL)canOpenURL:(NSURL *)url {
    RMAPIManager *apiManager = [RMAPIManager sharedAPIManager];
    
    if ([[url host] isEqualToString:[apiManager.baseURL host]] || [[url host] isEqualToString:@"search.twitter.com"])
    {
        return YES;
    }
    
    return NO;
    
}

-(void)openURL:(NSURL *)URL withNavigationController:(UINavigationController*) navigationController{
    
    // look for native controller
    // make a new view controller
    // pass it to a navigation controller?
    
    RMAPIManager *apiManager = [RMAPIManager sharedAPIManager];
    
    if ([self canOpenURL:URL]) {
        RMViewController *aViewController = [apiManager viewControllerForResourceAtURL:URL];
        
        [navigationController pushViewController:aViewController animated:YES];
    } else {
        [[UIApplication sharedApplication] openURL:URL];
    }
    
    
}


@end
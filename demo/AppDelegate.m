//
//  AppDelegate.m
//  demo
//
//  Created by KudoCC on 16/5/11.
//  Copyright © 2016年 KudoCC. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeTableViewController.h"
#import "AnimationViewController.h"
#import "PerformanceViewController.h"
#import "Quartz2DViewController.h"
#import "ImageIOViewController.h"
#import "CoreImageViewController.h"
#import "UrlSessionViewController.h"
#import "AudioViewController.h"
#import "WebViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    HomeTableViewController *vc = [[HomeTableViewController alloc] init];
    vc.arrayTitle = @[@"Animation", @"Performance", @"Quartz 2D", @"Image I/O", @"Core Image", @"URLSession", @"WebView & WebCache", @"Audio"];
    vc.arrayClass = @[[AnimationViewController class],
                      [PerformanceViewController class],
                      [Quartz2DViewController class],
                      [ImageIOViewController class],
                      [CoreImageViewController class],
                      [UrlSessionViewController class],
                      [WebViewController class],
                      [AudioViewController class]];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    
    CGFloat scale = [UIScreen mainScreen].scale;
    CGPoint p = CGPointMake(10, 10);
    p = CGPointApplyAffineTransform(p, CGAffineTransformMakeScale(1/scale, 1/scale));
    NSLog(@"%@", NSStringFromCGPoint(p));
    p = CGPointApplyAffineTransform(p, CGAffineTransformMakeScale(1, -1));
    NSLog(@"%@", NSStringFromCGPoint(p));
    p = CGPointApplyAffineTransform(p, CGAffineTransformMakeTranslation(0, 100));
    NSLog(@"%@", NSStringFromCGPoint(p));
    
    
    p = CGPointMake(10, 10);
    CGAffineTransform transform = CGAffineTransformMakeScale(1/scale, 1/scale);
    transform = CGAffineTransformScale(transform, 1, -1);
    transform = CGAffineTransformTranslate(transform, 0, -200);
    p = CGPointApplyAffineTransform(p, transform);
    NSLog(@"%@", NSStringFromCGPoint(p));
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

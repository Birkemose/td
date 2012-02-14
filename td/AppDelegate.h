//
//  AppDelegate.h
//  terrainDemo
//
//  Created by Lars Birkemose on 03/02/12.
//  Copyright Protec Electronics 2012. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end

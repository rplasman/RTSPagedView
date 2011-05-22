//
//  PagedViewAppDelegate.h
//  PagedView
//
//  Created by Rits Plasman on 23-05-11.
//  Copyright 2011 Taplicity. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PagedViewViewController;

@interface PagedViewAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet PagedViewViewController *viewController;

@end

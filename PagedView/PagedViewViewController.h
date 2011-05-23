//
//  PagedViewViewController.h
//  PagedView
//
//  Created by Rits Plasman on 23-05-11.
//  Copyright 2011 Taplicity. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RTSPagedView;

@interface PagedViewViewController : UIViewController

@property (nonatomic, retain) IBOutlet RTSPagedView *pagedView;

@end
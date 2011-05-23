//
//  PagedViewViewController.m
//  PagedView
//
//  Created by Rits Plasman on 23-05-11.
//  Copyright 2011 Taplicity. All rights reserved.
//

#import "PagedViewViewController.h"
#import "RTSPagedView.h"
#import "JSONKit.h"
#import "DTLazyImageView.h"

@interface PagedViewViewController () <RTSPagedViewDelegate>

@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, retain) NSArray *items;

@end

@implementation PagedViewViewController

@synthesize pagedView		= _pagedView;
@synthesize receivedData	= _receivedData;
@synthesize items			= _items;

#pragma mark - Paged view delegate

- (NSInteger)numberOfPagesInPagedView:(RTSPagedView *)pagedView
{
	return [_items count];
}

- (UIView *)pagedView:(RTSPagedView *)pagedView viewForPageAtIndex:(NSInteger)index
{
	// Making use of Oliver Drobnik's DTLazyImageView for asynchronous image loading
	DTLazyImageView *imageView = (DTLazyImageView *) [pagedView dequeueReusableViewWithTag:0];
	
	if (imageView == nil) {
		imageView = [[[DTLazyImageView alloc] initWithFrame:CGRectInset(pagedView.bounds, 4.0, 4.0)] autorelease];
		imageView.contentMode = UIViewContentModeScaleAspectFit;
	}
	
	[imageView cancelLoading];
	
	NSDictionary *item = [_items objectAtIndex:index];
	imageView.image = nil;
	imageView.url = [NSURL URLWithString:[[item objectForKey:@"media"] objectForKey:@"m"]];
	
	return imageView;
}

- (void)pagedView:(RTSPagedView *)pagedView didScrollToPageAtIndex:(NSInteger)index
{
	// Optional
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// Endless scrolling
	_pagedView.continuous = YES;
	
	// Load Flickr feed
	self.receivedData = [NSMutableData data];
	
	NSURL *URL = [NSURL URLWithString:@"http://api.flickr.com/services/feeds/photos_public.gne?lang=en-us&format=json&nojsoncallback=1"];
	NSURLRequest *request = [NSURLRequest requestWithURL:URL];
	[NSURLConnection connectionWithRequest:request delegate:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// Rotation not supported yet
    return interfaceOrientation == UIInterfaceOrientationLandscapeRight;
}

- (void)dealloc
{
	[_pagedView release];
    [super dealloc];
}

#pragma mark - URL loading

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	self.receivedData = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[_receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSString *receivedString = [[NSString alloc] initWithData:_receivedData encoding:NSUTF8StringEncoding];
	
	// Flickr returns invalid JSON
	NSString *JSONString = [receivedString stringByReplacingOccurrencesOfString:@"\\'" withString:@"'"];
	
	// Parse using John Engelhart's JSONKit
	NSDictionary *dictionary = [JSONString objectFromJSONString];
	[receivedString release];
	
	// Set items
	self.items = [dictionary objectForKey:@"items"];
	
	// Reload paged view
	[_pagedView reloadData];
}

@end
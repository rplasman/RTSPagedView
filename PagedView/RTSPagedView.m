//
//  RTSPagedView.m
//  PagedView
//  http://github.com/rplasman/RTSPagedView
//
//  Created by Rits Plasman on 22-05-11.
//  Copyright 2011 Rits Plasman. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are
//  permitted provided that the following conditions are met:
//
//  1. Redistributions of source code must retain the above copyright notice, this list of
//  conditions and the following disclaimer.
//
//  2. Redistributions in binary form must reproduce the above copyright notice, this list
//  of conditions and the following disclaimer in the documentation and/or other materials
//  provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDER ``AS IS'' AND ANY EXPRESS OR IMPLIED
//  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//  FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
//  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//  ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  The views and conclusions contained in the software and documentation are those of the
//  authors and should not be interpreted as representing official policies, either expressed
//  or implied, of the copyright holder.

#import "RTSPagedView.h"

@interface RTSPagedView ()

@property (nonatomic, retain) NSMutableArray *views;
@property (nonatomic, retain) NSMutableDictionary *queues;
@property (nonatomic, readonly) NSInteger actualPage;
@property (nonatomic, readonly) NSUInteger numberOfActualPages;

- (void)setUp;
- (CGPoint)centerForViewForPageAtIndex:(NSInteger)index;
- (NSMutableArray *)queueWithTag:(NSInteger)tag;
- (void)queueView:(UIView *)view;
- (void)queueExistingViews;
- (void)loadNewViews;
- (void)correctContentOffset;

@end

@implementation RTSPagedView

#pragma mark - Properties

@synthesize views				= _views;
@synthesize queues				= _queues;
@synthesize currentPage			= _currentPage;
@synthesize actualPage			= _actualPage;
@synthesize numberOfPages		= _numberOfPages;
@synthesize continuous			= _continuous;
@synthesize numberOfActualPages	= _numberOfActualPages;

- (id <RTSPagedViewDelegate>)delegate
{
	return (id <RTSPagedViewDelegate>) [super delegate];
}

- (void)setDelegate:(id<RTSPagedViewDelegate>)delegate
{
	[super setDelegate:delegate];
}

- (void)setCurrentPage:(NSUInteger)currentPage
{
	if (_currentPage == currentPage) {
		return;
	}
	
	[self scrollToPageAtIndex:currentPage animated:NO];
}

#pragma mark - Object lifecycle

- (id)init
{
	self = [self initWithFrame:CGRectZero];
	return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		[self setUp];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self setUp];
	}
	return self;
}

- (void)setUp
{
	_actualPage = NSNotFound;
	_currentPage = NSNotFound;
	_numberOfPages = NSNotFound;
	_numberOfActualPages = NSNotFound;
	
	// Set default scrollview properties
	self.pagingEnabled = YES;
	self.showsHorizontalScrollIndicator = NO;
	self.showsVerticalScrollIndicator = NO;
	self.alwaysBounceHorizontal = YES;
	
	_views = [[NSMutableArray alloc] init];
	_queues = [[NSMutableDictionary alloc] init];
}

- (void)reloadData
{
	_actualPage = NSNotFound;
	_currentPage = NSNotFound;
	_numberOfPages = NSNotFound;
	_numberOfActualPages = NSNotFound;
	
	for (UIView *view in _views) {
		if ([view isKindOfClass:[UIView class]]) {
			[view removeFromSuperview];
		}
	}
	
	[_views removeAllObjects];
	[_queues removeAllObjects];
	
	self.contentOffset = CGPointZero;
	
	[self setNeedsLayout];
}

- (void)dealloc
{
	[_views release];
	[_queues release];
	[super dealloc];
}

#pragma mark - Queueing

- (NSMutableArray *)queueWithTag:(NSInteger)tag
{
	NSNumber *key = [NSNumber numberWithInt:tag];
	NSMutableArray *queue = [_queues objectForKey:key];
	
	// Create a queue if none exists
	if (!queue) {
		queue = [NSMutableArray array];
		[_queues setObject:queue forKey:key];
	}
	
	return queue;
}

- (UIView *)dequeueReusableViewWithTag:(NSInteger)tag
{
	NSMutableArray *queue = [self queueWithTag:tag];
	
	// No queued view available
	if ([queue count] == 0) {
		return nil;
	}
	
	// Remove view from queue and return it
	UIView *view = [[[queue objectAtIndex:0] retain] autorelease];
	[queue removeObjectAtIndex:0];
	
	return view;
}

- (void)queueView:(UIView *)view
{
	// Add view to queue
	NSMutableArray *queue = [self queueWithTag:view.tag];
	[queue addObject:view];
}

- (void)queueExistingViews
{
	// Create index set for visible views
	NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSetWithIndex:_currentPage];
	
	// Add index of view to the left
	NSInteger leftIndex = _currentPage - 1;
	if (leftIndex >= 0 || _continuous) {
		if (leftIndex < 0) {
			leftIndex += _numberOfPages;
		}
		[indexSet addIndex:leftIndex];
	}
	
	// Add index of view to the right
	NSInteger rightIndex = _currentPage + 1;
	if (rightIndex < _numberOfPages || _continuous) {
		if (rightIndex >= _numberOfPages) {
			rightIndex -= _numberOfPages;
		}
		[indexSet addIndex:rightIndex];
	}
	
	for (NSInteger i = 0; i < [_views count]; i++) {
		UIView *view = [_views objectAtIndex:i];
		
		// If this object is not a view, don't queue it
		if (![view isKindOfClass:[UIView class]]) {
			continue;
		}
		
		// If this is a visible view, don't queue it
		if ([indexSet containsIndex:i]) {
			continue;
		}
		
		// Remove view from superview and add it to queue for later reuse
		[view removeFromSuperview];
		[self queueView:view];
		[_views replaceObjectAtIndex:i withObject:[NSNull null]];
	}
}

#pragma mark - Subview handling

- (CGPoint)centerForViewForPageAtIndex:(NSInteger)index
{
	CGPoint point = CGPointMake((index + 0.5) * self.bounds.size.width, self.bounds.size.height / 2.0);
	return point;
}

- (UIView *)viewForPageAtIndex:(NSUInteger)index
{
	UIView *view = [_views objectAtIndex:index];
	
	// If no queued view available, return nil
	if (![view isKindOfClass:[UIView class]]) {
		return nil;
	}
	
	return view;
}

- (void)loadNewViews
{
	for (NSInteger i = _actualPage - 1; i < _actualPage + 2; i++) {
		NSInteger index = i;
		
		// Get correct view index for this page
		if (_continuous) {
			if (i < 0) {
				index += _numberOfPages;
			} else if (i >= _numberOfPages) {
				index -= _numberOfPages;
			}
		} else if (i < 0 || i >= _numberOfPages) {
			continue;
		}
		
		// No view for this index
		if (index >= [_views count]) {
			continue;
		}
		
		UIView *view = [_views objectAtIndex:index];
		
		// This view is already visible, reposition it and continue
		if ([view isKindOfClass:[UIView class]]) {
			view.center = [self centerForViewForPageAtIndex:i];
			continue;
		}
		
		// Get view for this page
		view = [self.delegate pagedView:self viewForPageAtIndex:index];
		view.center = [self centerForViewForPageAtIndex:i];
		[_views replaceObjectAtIndex:index withObject:view];
		[self addSubview:view];
	}
}

- (void)layoutSubviews
{
	
	if (_numberOfPages == NSNotFound) {
		// This is executed only once
		_numberOfPages = [self.delegate numberOfPagesInPagedView:self];
		_numberOfActualPages = _numberOfPages;
		
		if (_continuous) {
			_numberOfActualPages++;
		}
		
		// Prepopulate views array
		while ([_views count] < _numberOfPages) {
			[_views addObject:[NSNull null]];
		}
	}
	
	self.contentSize = CGSizeMake(self.bounds.size.width * _numberOfActualPages, self.bounds.size.height);
	
	[self correctContentOffset];
	
	NSInteger actualPage = round(self.contentOffset.x / self.bounds.size.width);
	
	// If page hasn't changed, nothing to do
	if (_actualPage == actualPage) {
		return;
	}
	
	_actualPage = actualPage;
	
	// Calculate current page when continuous scrolling is enabled
	NSInteger currentPage = actualPage;
	if (_continuous) {
		if (currentPage >= _numberOfPages) {
			currentPage -= _numberOfPages;
		} else if (currentPage < 0) {
			currentPage += _numberOfPages;
		}
	} else {
		currentPage = MIN(MAX(0, currentPage), _numberOfPages - 1);
	}
	
	// Only notify delegate if current page has changed
	BOOL notifyDelegate = NO;
	if (_currentPage != currentPage) {
		notifyDelegate = YES;
		_currentPage = currentPage;
	}
	
	[self queueExistingViews];
	[self loadNewViews];
	
	if (notifyDelegate && [self.delegate respondsToSelector:@selector(pagedView:didScrollToPageAtIndex:)]) {
		[self.delegate pagedView:self didScrollToPageAtIndex:_currentPage];
	}
}

- (NSUInteger)indexForView:(UIView *)view
{
	return [_views indexOfObject:view];
}

#pragma mark - Scrolling behavior

- (void)correctContentOffset
{
	// Correct content offset for continuous scrolling
	if (_continuous) {
		if (self.contentOffset.x >= _numberOfPages * self.bounds.size.width) {
			self.contentOffset = CGPointMake(self.contentOffset.x - (_numberOfPages * self.bounds.size.width), 0.0);
		} else if (self.contentOffset.x < 0.0) {
			self.contentOffset = CGPointMake(self.contentOffset.x + (_numberOfPages * self.bounds.size.width), 0.0);
		}
	}
}

- (void)scrollToPageAtIndex:(NSUInteger)index animated:(BOOL)animated
{
	CGPoint contentOffset = CGPointMake(index * self.bounds.size.width, 0.0);
	[self setContentOffset:contentOffset animated:animated];
}

@end
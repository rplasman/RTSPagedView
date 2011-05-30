//
//  RTSPagedView.h
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

#import <UIKit/UIKit.h>

@protocol RTSPagedViewDelegate;

@interface RTSPagedView : UIScrollView

@property (nonatomic, assign) IBOutlet id <RTSPagedViewDelegate> delegate;
@property (nonatomic, assign) NSUInteger currentPage;
@property (nonatomic, readonly) NSUInteger numberOfPages;
@property (nonatomic, assign) BOOL continuous;

- (UIView *)dequeueReusableViewWithTag:(NSInteger)tag;
- (UIView *)viewForPageAtIndex:(NSUInteger)index;
- (void)scrollToPageAtIndex:(NSUInteger)index animated:(BOOL)animated;
- (void)reloadData;
- (NSUInteger)indexForView:(UIView *)view;

@end

@protocol RTSPagedViewDelegate <UIScrollViewDelegate>

- (NSUInteger)numberOfPagesInPagedView:(RTSPagedView *)pagedView;
- (UIView *)pagedView:(RTSPagedView *)pagedView viewForPageAtIndex:(NSUInteger)index;

@optional

- (void)pagedView:(RTSPagedView *)pagedView didScrollToPageAtIndex:(NSUInteger)index;

@end
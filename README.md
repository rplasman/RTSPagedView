# RTSPagedView

RTSPagedView is a lazy-loading paging UIScrollView subclass with support for endless scrolling. It works in a way similar to UITableView. The sample project included loads a Flickr feed and displays the images lazily.

RTSPagedView gets its subviews from its delegate. The delegate should implement two methods:

- (NSUInteger)numberOfPagesInPagedView:(RTSPagedView *)pagedView;
- (UIView *)pagedView:(RTSPagedView *)pagedView viewForPageAtIndex:(NSUInteger)index;

Views are internally queued by RTSPagedView and are identified by their tag property. You can dequeue views using this method of RTSPagedView:

- (UIView *)dequeueReusableViewWithTag:(NSInteger)tag; 

RTSPagedView is licensed under the terms of the FreeBSD license. Copyright 2011, Rits Plasman.
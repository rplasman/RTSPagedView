//
//  DTLazyImageView.m
//  PagingTextScroller
//
//  Created by Oliver Drobnik on 5/20/11.
//  Copyright 2011 Cocoanetics. All rights reserved.
//
//
//  Copyright (c) 2011, Oliver Drobnik All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  - Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer. 
//
//  - Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
//  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
//  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
//  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
//  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
//  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "DTLazyImageView.h"


@implementation DTLazyImageView

- (void)dealloc
{
	self.image = nil;
	[_url release];
	
	[_receivedData release];
	[_connection cancel];
	[_connection release];
	
	[super dealloc];
}

- (void)loadImageAtURL:(NSURL *)url
{
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:10.0];

	_connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
	[_connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
	[_connection start];
	
	[request release];
}

- (void)didMoveToSuperview
{
	if (!self.image && _url && !_connection)
	{
		[self loadImageAtURL:_url];
	}	
}

- (void)cancelLoading
{
	[_connection cancel];
	[_connection release], _connection = nil;
	
	[_receivedData release], _receivedData = nil;
}

#pragma mark NSURL Loading

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	// every time we get an response it might be a forward, so we discard what data we have
	[_receivedData release], _receivedData = nil;
	
	// does not fire for local file URLs
	if ([response isKindOfClass:[NSHTTPURLResponse class]])
	{
		NSHTTPURLResponse *httpResponse = (id)response;
		
		if (![[httpResponse MIMEType] hasPrefix:@"image"])
		{
			[self cancelLoading];
		}
	}
	
	_receivedData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[_receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	if (_receivedData)
	{
		UIImage *image = [[UIImage alloc] initWithData:_receivedData];
		
		self.image = image;
		
		[image release];
		
		[_receivedData release], _receivedData = nil;
	}
	
	[_connection release], _connection = nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSLog(@"Failed to load image at %@, %@", _url, [error localizedDescription]);
	
	[_connection release], _connection = nil;
	[_receivedData release], _receivedData = nil;
}


#pragma mark Properties

@synthesize url = _url;

@end

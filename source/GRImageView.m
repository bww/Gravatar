// 
// Copyright (c) 2012 Wolter Group New York, Inc., All rights reserved.
// Gravatar Image View
// 
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
// 
//   * Redistributions of source code must retain the above copyright notice, this
//     list of conditions and the following disclaimer.
// 
//   * Redistributions in binary form must reproduce the above copyright notice,
//     this list of conditions and the following disclaimer in the documentation
//     and/or other materials provided with the distribution.
//     
//   * Neither the names of Brian William Wolter, Wolter Group New York, nor the
//     names of its contributors may be used to endorse or promote products derived
//     from this software without specific prior written permission.
//     
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
// IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
// INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
// BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
// DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
// LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
// OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
// OF THE POSSIBILITY OF SUCH DAMAGE.
// 

#import "GRImageView.h"

#include <CommonCrypto/CommonDigest.h>

static const UniChar kGRImageViewHexCharacters[] = {
  '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'
};

@interface GRImageView (Private)

-(NSString *)gravatarDigestForEmailAddress:(NSString *)emailAddress;
-(NSString *)imageCacheBasePath;

-(void)loadImageForGravatarDigest:(NSString *)digest;
-(UIImage *)loadCachedImageForGravatarDigest:(NSString *)digest;
-(void)loadRemoteImageForGravatarDigest:(NSString *)digest;

@end

@implementation GRImageView

@synthesize gravatarDigest = _gravatarDigest;
@synthesize allowImageCaching = _allowImageCaching;
@synthesize animated = _animated;

/**
 * Clean up
 */
-(void)dealloc {
  [_emailAddress release];
  [_placeholderImage release];
  [_gravatarImage release];
  [_gravatarDigest release];
  [_imageView release];
  [_workingConnection release];
  [_workingBuffer release];
  [super dealloc];
}

/**
 * Designated initializer
 */
-(id)initWithFrame:(CGRect)frame {
  return [self initWithFrame:frame imageView:[[[UIImageView alloc] initWithFrame:self.bounds] autorelease]];
}

/**
 * Initialize with a special image view. The provided view must respond
 * to the selector -(void)setImage:(UIImage *) and be a UIView subclass.
 */
-(id)initWithFrame:(CGRect)frame imageView:(UIView *)imageView {
  
  if(imageView == nil || ![imageView respondsToSelector:@selector(setImage:)]){
    NSLog(@"Custom image view provided is not suitable for use with GRImageView");
    [self release];
    return nil;
  }
  
  if((self = [super initWithFrame:frame]) != nil){
    _animated = TRUE;
    _imageView = [imageView retain];
    _imageView.frame = self.bounds;
    _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:_imageView];
  }
  
  return self;
}

/**
 * Obtain the email address for which the corresponding Gravatar is displayed
 * (or would have been displayed in case of an error).
 */
-(NSString *)emailAddress {
  return _emailAddress;
}

/**
 * Set the email address for which the corresponding Gravatar should be displayed.
 * The Gravatar image will be loaded immediately either from a local cache (if image
 * caching is enabled) or from the Gravatar service.
 */
-(void)setEmailAddress:(NSString *)email {
  if((email = [email lowercaseString]) != nil && [email length] > 0){
    if(_emailAddress == nil || ![_emailAddress isEqualToString:email]){
      NSString *digest;
      if((digest = [self gravatarDigestForEmailAddress:email]) != nil){
        [self loadImageForGravatarDigest:digest];
      }else{
        NSLog(@"Unable to compute MD5 digest of email address: %@", email);
      }
    }
  }
}

/**
 * Obtain the placeholder image. This image is displayed while the
 * Gravatar image is being downloaded.
 */
-(UIImage *)placeholderImage {
  return _placeholderImage;
}

/**
 * Set the placeholder image. Pass nil to clear an existing placeholder image.
 * This method has no effect if the Gravatar image has already been loaded.
 */
-(void)setPlaceholderImage:(UIImage *)image {
  [_placeholderImage release];
  if((_placeholderImage = [image retain]) != nil){
    if(_gravatarImage == nil) [(id)_imageView setImage:_placeholderImage];
  }else{
    if(_gravatarImage == nil) [(id)_imageView setImage:nil];
  }
}

/**
 * Obtain the Gravatar image.
 */
-(UIImage *)gravatarImage {
  return _gravatarImage;
}

/**
 * @internal
 * Compute a Gravatar digest for the provided email address. This method
 * expects the address to be already normalized (lowercase with leading and
 * trailing whitespace trimmed).
 */
-(NSString *)gravatarDigestForEmailAddress:(NSString *)emailAddress {
  
  if(emailAddress != nil){
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    const char *utf8 = [emailAddress UTF8String];
    
    if(CC_MD5(utf8, strlen(utf8), digest) != NULL){
      CFMutableStringRef buffer = CFStringCreateMutable(NULL, 0);
      CFIndex length = CC_MD5_DIGEST_LENGTH;
      UniChar c[2];
      
      for(CFIndex i = 0; i < length; i++){
        uint8_t byte = digest[i];
        c[0] = kGRImageViewHexCharacters[(byte >> 4) & 0x0f];
        c[1] = kGRImageViewHexCharacters[(byte >> 0) & 0x0f];
        CFStringAppendCharacters(buffer, c, 2);
      }
      
      return [(id)buffer autorelease];
    }
    
  }
  
  return nil;
}

/**
 * @internal
 * Obtain the base path for the image cache
 */
-(NSString *)imageCacheBasePath {
  NSArray *roots;
  if((roots = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, TRUE)) != nil && [roots count] > 0){
    return [[roots objectAtIndex:0] stringByAppendingPathComponent:@"net.woltergroup.Gravatar"];
  }else{
    return nil;
  }
}

/**
 * @internal
 * Load a Gravatar image
 */
-(void)loadImageForGravatarDigest:(NSString *)digest {
  
  // update the digest
  [_gravatarDigest release];
  _gravatarDigest = [digest retain];
  
  // if caching is allowed, first check our local cache for the image before we attempt
  // to load it from the network. we handle our own caching here (as opposed to just relying
  // on UIKit) to try and make sure Gravatar images are more likely to be available when the
  // network is not. to be fair, i'm not completely certain that is actually achieved by
  // storing them to the caches directory, which may be purged by the system at any time.
  
  UIImage *cachedImage;
  if(self.allowImageCaching && (cachedImage = [self loadCachedImageForGravatarDigest:digest]) != nil){
    [(id)_imageView setImage:cachedImage];
  }else{
    [self loadRemoteImageForGravatarDigest:digest];
  }
  
}

/**
 * @internal
 * Load a cached image, if possible.
 */
-(UIImage *)loadCachedImageForGravatarDigest:(NSString *)digest {
  UIImage *cachedImage = nil;
  
  NSString *base;
  if((base = [self imageCacheBasePath]) != nil){
    NSString *path;
    if((path = [base stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", digest]]) != nil){
      BOOL directory;
      if([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&directory] && !directory){
        cachedImage = [UIImage imageWithContentsOfFile:path];
      }
    }
  }
  
  return cachedImage;
}

/**
 * @internal
 * Load a remote image, if possible.
 */
-(void)loadRemoteImageForGravatarDigest:(NSString *)digest {
  NSURL *url;
  if((url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.gravatar.com/avatar/%@?d=404", digest]]) != nil){
    
    if(_workingConnection != nil){
      [_workingConnection cancel];
      [_workingConnection release];
      _workingConnection = nil;
    }
    
    if(_workingBuffer != nil){
      [_workingBuffer release];
      _workingBuffer = nil;
    }
    
    _workingBuffer = [[NSMutableData alloc] init];
    _workingExpectedContentLength = 0;
    _workingConnection = [[NSURLConnection alloc] initWithRequest:[NSURLRequest requestWithURL:url] delegate:self];
    
  }
}

#pragma mark - URL connection delegate

/**
 * Response received
 */
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
  if(connection == _workingConnection){
    _workingExpectedContentLength = response.expectedContentLength;
  }
}

/**
 * Data received
 */
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
  if(connection == _workingConnection){
    [_workingBuffer appendData:data];
  }
}

/**
 * Completed
 */
-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
  if(connection == _workingConnection){
    
    UIImage *image;
    if((image = [UIImage imageWithData:_workingBuffer]) != nil){
      
      void (^update)(void) = ^ {
        [(id)_imageView setImage:image];
      };
      
      if(self.animated){
        [UIView transitionWithView:self duration:0.25 options:UIViewAnimationOptionTransitionCrossDissolve animations:update completion:NULL];
      }else{
        update();
      }
      
      if(self.allowImageCaching){
        NSString *base;
        if((base = [self imageCacheBasePath]) != nil){
          NSError *error = nil;
          if([[NSFileManager defaultManager] createDirectoryAtPath:base withIntermediateDirectories:TRUE attributes:nil error:&error]){
            [UIImagePNGRepresentation(image) writeToFile:[base stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", self.gravatarDigest]] atomically:YES];
          }else{
            NSLog(@"Unable to create Gravatar cache directory at: %@", base);
          }
        }
      }
      
    }
    
    [_workingConnection release];
    _workingConnection = nil;
    [_workingBuffer release];
    _workingBuffer = nil;
    
  }
}

/**
 * Connection failed
 */
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
  if(connection == _workingConnection){
    NSLog(@"Unable to load Gravatar image: %@", [error localizedDescription]);
    [_workingConnection release];
    _workingConnection = nil;
    [_workingBuffer release];
    _workingBuffer = nil;
    _workingExpectedContentLength = 0;
  }
}

@end



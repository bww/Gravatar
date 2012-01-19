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

#import <UIKit/UIKit.h>

/**
 * A Gravatar image view.
 */
@interface GRImageView : UIView <NSURLConnectionDelegate> {
  
  NSString        * _emailAddress;
  NSString        * _gravatarDigest;
  UIImage         * _placeholderImage;
  UIImage         * _gravatarImage;
  UIView          * _imageView;
  NSURLConnection * _workingConnection;
  NSMutableData   * _workingBuffer;
  long long         _workingExpectedContentLength;
  BOOL              _allowImageCaching;
  BOOL              _animated;
  
}

-(id)initWithFrame:(CGRect)frame imageView:(UIView *)imageView;

@property (readwrite, retain) NSString  * emailAddress;
@property (readwrite, retain) UIImage   * placeholderImage;
@property (readonly) UIImage            * gravatarImage;
@property (readonly) NSString           * gravatarDigest;
@property (readwrite, assign) BOOL        allowImageCaching;
@property (readwrite, assign) BOOL        animated;

@end



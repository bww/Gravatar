Gravatar Image View
===================

A simple way to display Gravatar images using UIKit.

The Gist
--------

A Gravatar image view, ```GRImageView```, functions essentially like a ```UIImageView```, except
instead of providing it with an image to display, you provide it with the email address of the
user whose Gravatar image you want to display. ```GRImageView``` will automatically fetch the
image from the Gravatar service and display it without any additional work on your part.

There are a few options, such as whether or not Gravatar images are cached for offline use and
the placeholder image you want to display while an image is loading, but you can minimally get by
with just the following:

```objc
GRImageView *gravatarImage = [[GRImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
gravatarImage.emailAddress = @"some.user@gmail.com";
[someView addSubview:gravatarImage];
```

Animation
---------

By default, the transition from the placeholder image (if any) and the Gravatar image loaded
from the service is animated with a "cross-dissolve" fade.  You can turn this animation on or off
via the ```animated``` property.  Animation is on by default.

Caching
-------

You can also instruct ```GRImageView``` to cache images it fetches from the Gravatar service on
the device so they are available for later offline use.  Caching can be turned on or off via the
```allowImageCaching``` property.  Caching is off by default.

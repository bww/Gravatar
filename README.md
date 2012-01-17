Gravatar Image View
===================

A simple way to display Gravatar images using UIKit.

The Gist
--------

A Gravatar image view, ```GRImageView```, functions essentially like a ```UIImageView```, except
instead of providing it with an image to display, you provide it with the email address of the
user whose Gravatar image you want to display. ```GRImageView``` will automatically fetch the
image from the Gravatar service and display it without any additional work on your part.

Minimally, all you need to display a Gravatar image is the following:

```objc
GRImageView *gravatarImageView = [[GRImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
gravatarImageView.emailAddress = @"some.user@gmail.com";
[someView addSubview:gravatarImageView];
```

Animation
---------

By default, the transition from the placeholder image (if any) and the Gravatar image loaded
from the service is animated with a "cross-dissolve" fade.  You can turn this animation on or off
via the ```animated``` property.

Caching
-------

You can instruct ```GRImageView``` to cache images it fetches from the Gravatar service on the
device so they are available for later offline use.  Caching can be turned on or off via the
```allowImageCaching``` property.  Caching is off by default and is specific to each individual
instance of ```GRImageView```.  You can use caching for some instances and not for others if
you like.

Placeholder Image
-----------------

You can specify the image a ```GRImageView``` displays while it is loading a Gravatar image from
the service by setting the ```placeholderImage``` property.  By default no placeholder image is
displayed.

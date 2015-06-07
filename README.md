# README #

This README is for detailing how to play with Ice Tré, the image placement engine at [RappersOnThe.Rocks](http://www.rappersonthe.rocks/).

### Quick start ###

Have a Ruby environment ready to go, install [bundler](http://bundler.io/) if you need it, then run 'bundle install'.

If you don't have [Image Magick](http://www.imagemagick.org/) installed, you'll need that too.

From the project directory, run 'ruby ice_tre.rb' and go to localhost:4567 in your browser to see it.

If everything worked, you should be staring at a picture of Vanilla Ice.

### How do I use it? ###

You can just make a request to localhost:4567/help for a list of instructions. In brief:

The URL parameters are constructed as /rapper/width/height/color/percent/

* the options for rapper are ice_cube, ice_t, and vanilla_ice
* the options for width and height include any valid positive integer below 2560
* the options for color include any valid hex web color without the pound sign in front of it
* the options for percent include any positive integers up to 300
* An example of a valid URL is /vanilla_ice/1024/768/ffffff/
* Note: the trailing slash is optional

If you want to add more images, just drop a .png file with transparency into the images folder. Then use it in the URL arguments.

### Contribution guidelines ###

* clone it
* make a pull request

### Who do I talk to? ###

* Andrew Neely - @ravinglogic
= mvcoffee-rails

{Source}[https://github.com/kirkbowers/mvcoffee-rails]

{Home Page}[http://mvcoffee.org]

== Description

+mvcoffee-rails+ is a Rails gem that makes it easy to use the 
mvcoffee[https://github.com/kirkbowers/mvcoffee] client-side MVC framework in your
Rails project.

It does this in three ways:

* It includes the mvcoffee.js asset into your Rails project (with version number
matching the version of this gem)
* It defines an +MVCoffee+ class that provides an API for creating the json object
in the format the mvcoffee framework expects
* It provides a module that you can `include` in your `ApplicationController` to add
a some useful methods to all controllers for "rendering" the expected json to the 
client, testing the state of the client cache, and auto-magically instantiating an
+MVCoffee+ object

Why would you want to use the MVCoffee framework, especially since there are already
so many other Model-View-Controller frameworks?

Because MVCoffee is, to my knowledge, the only client-side CoffeeScript framework
built from scratch with specifically Rails 4 and Turbolinks in mind.  It does some
pretty nice things, such as:

* Rails-style validations and associations on client-side models, with a familiar
"macro-method-like" syntax for defining model attributes.  Although you have to Repeat
Yourself to define the client models, this pain is eased by the similar syntax, and
could conceivably be automated in the future.
* Only one or two lines of client code to make an input form auto-magically validate
against the associated model and submit to the server over ajax if valid.  This saves
you having to repeatedly make the same jQuery +.submit+ intercepts and ajax calls.
* Facilitates client-side caching while still allowing URL-based navigation of your
application.  In other words, you don't need to resort to a Single Page 
Application (SPA) on your client in order to keep the javascript state live.  You get
the convenience of bookmarkable pages in your application and the performance benefits
of cached data on the client.
* Fills in some holes in Turbolinks.  Turbolinks unobtrusively follows GET anchor
links via ajax, keeping the javascript session live and providing faster performance.
It does NOT, however, provide this same convenience for any kind of +form+ on the page
out of the box.  This means normally +button_to+ and +form_for+ elements, when clicked,
cause a full page load and restart of the javascript session (wiping out any cached
data).  MVCoffee provides a fix for this.
* Provides familiar Rails server-side functionality on the client, such as the flash,
session and errors array.
* Handles redirects on the client.  This ensures that the javascript session will 
remain live (preserving the cache), and even allows redirecting after a json request
over ajax.
* Automates refreshing potentially stale data.  Users frequently will be visiting your
app in multiple tabs, browsers or even devices at the same time.  MVCoffee detects 
when a page could be potentially out of date and fires the +refresh+ method on all
running controllers.  All you have to do is specify what should be refetched on a 
refresh.
* Normalizes browser behavior concerning pausing and resuming your application.
Desktop browers fire onblur and onfocus for the window and do not stop timers when
your window receives an onblur.  Safari on iOS, on the other hand, does stop times but
does not fire onblur and onfocus.  MVCoffee normalizes this and provides a +pause+ and
+resume+ life cycle for client-side controllers.  (Note: Android and Windows browers
have not been tested at this time!)
* Saves you typing in the usual convention over configuration way, condensing the 
whole +respond_to do |format|+ business into one terse +render_mvcoffee+ command.

== Usage

To use +mvcoffee-rails+, there are a few one-time set up steps that have to be done
manually.

First, include the gem in your Rails project's +Gemfile+:

    gem 'mvcoffee-rails'
    
It depends on jQuery, Turbolinks, and the jquery-turbolinks[https://github.com/kossnocorp/jquery.turbolinks] gem, so be sure to 
include those too:

    gem 'turbolinks'
    gem 'jquery-rails'
    gem 'jquery-turbolinks'

    
Require the javascript library in your +application.js+ file:

    //= require mvcoffee
    
It is recommended to require it after turbolinks and before all of your project's 
CoffeeScript and JavaScript files.  The recommended setup for your project looks like
this:

    ...
    //= require turbolinks
    //= require jquery.turbolinks
    //= require mvcoffee
    //= require_self
    //= require_directory ./templates
    //= require_directory ./models
    //= require_directory ./controllers
    //= require master

    this.MyNamespace || (this.MyNamespace = {});

These extra files and directories, such as +templates+ and +master+ are discussed in 
full on the {MVCoffee homepage}[http://mvcoffee.org].

In your +application_controller.rb+ file, +include+ the +MVCoffee+ module:

    class ApplicationController < ActionController::Base
      include MVCoffee

Then in any controller action you want handled by the MVCoffee framework, call
methods on the auto-magically provided +@mvcoffee+ instance variable to set any data
you want to send to the client, then end the method with +render_mvcoffee+ _instead of_
any usual +render+ or +redirect_to+ calls.

    def index
      @items = Items.all
      @mvcoffee.set_model_data 'item', @items
      render_mvcoffee
    end
    
And finally, add these lines inside the +body+ tag of your +application.html.erb+ file:

    <script id="mvcoffee_json" type="text/json">
      <%= raw @mvcoffee.to_json %>
    </script>

This ensures that the client-side code will receive the json it needs to populate and
manage the model store cache.  The MVCoffee runtime will always look for this 
+#mvcoffee_json+ tag on every +document.ready+ and process it for you.

== Developers/Contributing

Contributing to this project is of course welcome.  There are three areas in which I
could really use help:

* Testing:  I'm sure I'll get scolded for this, but all testing has been done "in the 
field".  This gem has been thoroughly put through its paces by the project for which it
was initially developed.  In order to be truly confident it is working as expected, it 
needs to be exercised in the context of a fully functioning Rails project.  How to test
it in isolation, and have that actually prove anything, strikes me as extremely
non-trivial and not straight forward.  If this type of thing is your specialty, I'd be
very grateful for guidance.
* Autogenerating routes:  A script that reads the +config/routes.rb+ file and 
autogenerates a javascript file defining globally scoped functions that mirror the 
route functions in Rails-land would be extremely beneficial.  Say, for example you have
a RESTful resource, "items", you'd be able to call the function +items_path+ inside
your +.erb+ or +.haml+ server-side templates to generate hyperlinks to the items index.
It would be nice to be able to do the exact same thing in client-side +.ejs+ templates
without having to hand-code the routes functions.
* Autogenerating model validations and associations:  The macro-method-like syntax for
defining models in MVCoffee eases the pain of Repeating Yourself on the client, but you
still have to manually Repeat Yourself.  Ideally, there would be a command-line utility
that inspects the Rails definitions of models and auto-generates the corresponding
MVCoffee definitions, guaranteeing they mirror each other accurately.

If you are interested, please feel free to contact me.

== License

+mvcoffee-rails+ is released under the MIT license.  


require 'mvcoffee/rails/engine'
require "mvcoffee/rails/version"
require "mvcoffee/rails/active_record"

require 'mvcoffee/mvcoffee'


# This probably doesn't belong in this file, but if I try to do it in a file called
# anything having to do with "action_controller", it confuses the whole Rails system
# and nothing works.  It works the way I want it to in this file, so I'm not messin'
# with it!  Not elegant, but if it ain't broke....
module ActionController
  class Base
    # Set up "around aliases".  Rename the render and redirect methods to something
    # that is guaranteed not to clash with anything.  I use these aliases below in the
    # render_mvcoffee method.
    alias :_mvcoffee_alias_render :render
    alias :_mvcoffee_alias_redirect_to :redirect_to
    
    # Call this class macro in your application_controller.rb file if you want to 
    # do the monkeypatch for the whole application.
    #
    # I could make it so this happens by default, but I think it should require an
    # affirmative action on the programmer's part to make a monkeypatch with 
    # potentially unintended consequences happen.  This is in keeping with the 
    # principle of Least Surprise.  If something goes wonky after you called this 
    # method, well, you know you called it, so you can comment it out (and probably 
    # curse me online)  Let's hope it never comes to that....
    def self.monkeypatch_mvcoffee
    
      # The really cool thing about monkeypatching this method is that it gets called
      # automagically in your controllers at the end of each action if the action falls
      # through.  So, with this in place, with no extra action required by the 
      # programmer, the MVCoffee thing will just happen.  This means you can do a
      # redirect even on a json request without even thinking about it!
      define_method :render do |action = nil, opts = {}|
        # Uncomment this is you want to prove it to yourself that it really is doing
        # the around alias.
        # puts "!!!!  Doing monkeypatched render !!!!!"
        render_mvcoffee action, opts
      end
      
      # And the cool thing about monkeypatching this method is that you can call it
      # indiscriminately without doing that format...do business checking for json
      # and avoiding redirecting if it is json.  Just go ahead and call redirect_to, 
      # and the client framework will do the right thing, handling the redirect AFTER
      # processing the json fetched over ajax.
      define_method :redirect_to do |action, opts = {}|
        # Uncomment this is you want to prove it to yourself that it really is doing
        # the around alias.
        # puts "!!!!  Doing monkeypatched redirect_to !!!!!"
        @mvcoffee.set_redirect action, opts
        render_mvcoffee
      end
    
    end

  end
end


# MVCoffee is a module that should be included at the top of your ApplicationController
# just below this line:
#     class ApplicationController < ActionController::Base
#
# It will add two methods to all controllers:
# 
# * is_full_page_load? which will return true if it detects a full page load has occurred,
# meaning the client-side MVCoffee data store has been wiped out.  Otherwise you can
# assume the client-side cache is still intact.
#
# * render_mvcoffee which should be called instead of `render` or `redirect_to` in any
# action that relies on MVCoffee to handle things on the client side (refresh the cache,
# handle a redirect on the client, or simply update via ajax).  It will handle doing the
# right thing whether the request is html or json (saving you that format verbosity).
#
# It will also declare an instance variable available to all controllers, `@mvcoffee`,
# an instance of an MVCoffee::MVCoffee object.  All controller actions that use 
# MVCoffee should make modifications to this object (using methods such as 
# `set_model_data` and `set_session`, etc.) before calling `render_mvcoffee`, then it
# will automatically be sent to the client as json.
# 
# Author:: Kirk Bowers (mailto:kirkbowers@yahoo.com)
# Copyright:: Copyright (c) 2014 Kirk Bowers
# License:: MIT License
module MVCoffee

  # Does it's best attempt at determining whether the incoming request happened over
  # explicit ajax, implicit ajax (via turbolinks), or if it is a full page load.
  # Returns true if it looks like the request is a full page load, meaning the client
  # side javascript session is going to be started over fresh and all cached data will
  # be wiped out. 
  def is_full_page_load?
    !request.xhr? and !request.headers["HTTP_X_XHR_REFERER"]
  end
    
  # Handles rendering for actions that rely on MVCoffee on the client.  It will send
  # the `@mvcoffee` object to the client serialized as json, and do the right thing
  # based on whether the request is html or json.
  #
  # If it is an html request, and there is a redirect issued in the `@mvcoffee` object,
  # this method will issue a hard redirect from the server (which will
  # wipe out the cache on the client).  This is desirable for actions that only want
  # to maintain the session when the request is over json.
  def render_mvcoffee(action = nil, opts = {})
    respond_to do |format|
      format.html { 
        if @mvcoffee.redirect
          if opts == {} and action.respond_to? :to_hash
            opts = action
          end

          _mvcoffee_alias_redirect_to @mvcoffee.redirect, @mvcoffee.flash.merge(opts)
        else
          _mvcoffee_alias_render action, opts 
        end
      }
      format.json { _mvcoffee_alias_render json: @mvcoffee.to_json }
    end  
  end
    
  
  # If this module is included into the application controller, this will fire for
  # all controllers and instantiate the `@mvcoffee` object.
  ::ActionController::Base::before_action do
    # We have to go back to the root with the leading :: since this module most likely
    # has been include'd into the controllers performing this before_action
    @mvcoffee = ::MVCoffee::MVCoffee.new  
  end

end


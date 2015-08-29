require 'mvcoffee/rails/engine'
require "mvcoffee/rails/version"

require 'mvcoffee/mvcoffee.rb'

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

          redirect_to @mvcoffee.redirect, @mvcoffee.flash.merge(opts)
        else
          render action, opts 
        end
      }
      format.json { render json: @mvcoffee.to_json }
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

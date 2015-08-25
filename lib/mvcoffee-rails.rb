require 'mvcoffee/rails/engine'
require "mvcoffee/rails/version"

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
  def render_mvcoffee(opts = {})
    respond_to do |format|
      format.html { 
        if @mvcoffee.redirect
          redirect_to @mvcoffee.redirect, @mvcoffee.flash.merge(opts)
        else
          render opts 
        end
      }
      format.json { render json: @mvcoffee.to_json }
    end  
  end
  
  # If this module is included into the application controller, this will fire for
  # all controllers and instantiate the `@mvcoffee` object.
  ::ActionController::Base::before_action do
    @mvcoffee = MVCoffee::MVCoffee.new  
  end

  module MVCoffee
    class MVCoffee
      def initialize
        @json = {
          mvcoffee_version: Mvcoffee::Rails::VERSION,
          flash: {},
          models: {},
          session: {}
        }
      end
      
      attr_reader :flash, :redirect

      # Instructs the client to perform a redirect to the path provided as the first 
      # argument.  This is preferable to issuing a redirect on the server because
      # 1. it is guaranteed to keep the client javascript session live (keeping the 
      # cache intact), and 2. it will perform redirects regardless of whether the 
      # incoming request was performed as a regular html request or an ajax request for
      # json (whereas the server can't issue a redirect with the format json).
      #
      # The optional hash parameters are added to the client-side flash.
      # For example:
      #     @mvcoffee.set_redirect some_path, notice: 'Everything is okey-dokey!'
      # will set the client flash['notice'] to the silly message.
      def set_redirect(path, opts = {})
        set_flash opts
        @json[:redirect] = path
      end
    
      # Set's the client-side flash.  Takes a hash of keys and values, and merges them
      # into the existing flash for this request.
      #
      # The flash on the client will cycle out after two requests.  In other words, it 
      # will persist after one redirect, but will take on new values after the next
      # request.
      def set_flash(opts = {})
        @json[:flash].merge! opts
        if opts[:errors]
          set_errors opts[:errors]
        end
      end
        
      # Takes an array of errors and sends them to the client.  Usually this should be
      # set as the array of errors on whatever model is being updated.  Since this 
      # framework makes validating on the client easy, it is rare that this will be 
      # needed.
      #
      # The client makes this array of errors available to all running controllers in
      # the same manner as errors from client-side validation.  In other words, your
      # client code needs only one method for displaying errors to the user and can be
      # agnostic as to whether the errors came from the client or the server.
      def set_errors(errors)
        @json[:errors] = errors
      end
    
      # Does the same thing as `set_errors` but will add to an existing array of errors
      # if one exists instead of replacing it.  This is what you should use if you 
      # are modifying more than one models and errors may come from multiple sources.
      def append_errors(errors)
        if @json[:errors]
          @json[:errors].concat!(errors)
        else
          @json[:errors] = errors
        end
      end
    
      # Sets data to be held in the client model store cache for the named model.
      # 
      # The `model_name` parameter should be a string in singular snake case.
      #
      # The `data` parameter should be either a single hash-like object, or an 
      # array-like object of hash-like objects.  Array-like means it responds to
      # `:collect`, which both true arrays and ActiveRecord collections do.  Hash-like
      # means it responds to `:to_hash`, or as a fallback `:to_json`.  Single ActiveRecord
      # records do respond to `:to_json` out of the box, but not `:to_hash`.  If you
      # provide a `to_hash` method in your model classes, you can explicitly set what 
      # data elements are sent to the client vs. which ones are excluded (eg. you 
      # probably don't want to send a password digest), and it allows you to send
      # calculated values as well.
      #
      # The model data is MERGED into the cache on the client.
      # 
      # It is appropriate to use this method when some subset of model entities have changed
      # but the client is still holding other entities that do not need to be reloaded.
      # This can save on bandwidth and load on the database.
      #
      def set_model_data(model_name, data)
        obj = @json[:models][model_name] || {}
        
        result = nil
        
        if data.respond_to? :collect
          if data.length > 0
            if data[0].respond_to? :to_hash
              result = data.collect {|a| a.to_hash }
            else
              result = data.collect {|a| a.as_json }
            end
          else
            result = []
          end
        elsif data.respond_to? :to_hash
          result = data.to_hash
        else
          result = data.as_json
        end
        
        obj[:data] = result
        # Reassign it back.  If we got a new hash, it isn't a reference from the @json
        # object, so it won't be associated unless we make it so manually.
        # If we did get a hash back on the first line, it is a reference, but since we
        # merged into it, it is safe to reassign it back.
        @json[:models][model_name] = obj
      end
    
      # This does the same thing as `set_model_data` (in fact it defers to that method
      # for converting the `data` parameter into the json format the client expects, so
      # please read that documentation too), but also instructs the client to clear out
      # a portion of the model store cache based on a set of foreign key values.
      # 
      # The `foreign_keys` parameter is a hash, mapping the names of foreign keys on
      # which to match with the corresponding values.  For example, if we wanted to 
      # replace all the items on the cache with the ones we fetched for a particular
      # user, we'd say:
      #     @mvcoffee.set_model_replace_on 'item', @items, user_id: @user.id
      #
      def set_model_replace_on(model_name, data, foreign_keys)
        obj = set_model_data(model_name, data)
        
        obj[:replace_on] = foreign_keys
        
        # Reassign it back.  If we got a new hash, it isn't a reference from the @json
        # object, so it won't be associated unless we make it so manually.
        # If we did get a hash back on the first line, it is a reference, but since we
        # merged into it, it is safe to reassign it back.
        @json[:models][model_name] = obj
      end
    
      # Instructs the client to delete certain records from the model store cache.  This
      # doesn't remove anything from the database, it just tells the cache to forget 
      # about some records.  Most likely, the time you'd want to use this is after
      # destroying records in the database to let the client know those records no longer
      # exist.
      #
      # The `model_name` parameter should be a string in singular snake case.
      # 
      # The `data` parameter is an array of the primary key id's for the records to be
      # removed.  Optionally, it can be just a single integer.
      def set_model_delete(model_name, data)
        obj = @json[:models][model_name] || {}

        obj[:delete] ||= []
        if data.respond_to? :to_a
          obj[:delete] += data.to_a
        else
          obj[:delete] << data
        end
        
        @json[:models][model_name] = obj        
      end      
    
      def set_session(opts)
        @json[:session].merge! opts
      end
      
      def to_json
        @json.to_json
      end

    end
  end
end

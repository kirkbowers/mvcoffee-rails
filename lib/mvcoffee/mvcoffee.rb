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
  
    def redirect
      @json[:redirect]
    end
  
    def flash
      @json[:flash]
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


    def set_session(opts)
      @json[:session].merge! opts
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
      @json[:errors] = errors.to_a
    end
  
    # Does the same thing as `set_errors` but will add to an existing array of errors
    # if one exists instead of replacing it.  This is what you should use if you 
    # are modifying more than one model and errors may come from multiple sources.
    def append_errors(errors)
      if @json[:errors]
        @json[:errors] = @json[:errors].concat(errors.to_a)
      else
        @json[:errors] = errors.to_a
      end
    end
  
    # Sets data to be held in the client model store cache for the named model.
    # 
    # The `model_name` parameter should be a string in singular snake case.
    #
    # The `data` parameter should be either a single hash-like object, or an 
    # array-like object of hash-like objects.  Array-like means it responds to
    # `:collect`, which both true arrays and ActiveRecord collections do.  Hash-like
    # means it responds to `:to_hash`, or as a fallback `:as_json`.  Single ActiveRecord
    # records do respond to `:as_json` out of the box, but not `:to_hash`.  If you
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
      
      # Pass the data through.  That was you can do an assignment on a fetch in 
      # one step
      data
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
      set_model_data(model_name, data)
      
      # This is guaranteed to be non-nil after set_model_data has been called.
      obj = @json[:models][model_name]
      
      obj[:replace_on] = foreign_keys
      
      # Reassign it back.  If we got a new hash, it isn't a reference from the @json
      # object, so it won't be associated unless we make it so manually.
      # If we did get a hash back on the first line, it is a reference, but since we
      # merged into it, it is safe to reassign it back.
      @json[:models][model_name] = obj
      
      # Pass the data through
      data
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
  
    #==============================================================================
    #
    # Convenience methods composed of the primitive methods above.
    # 
    # These methods not only package into one step some of the most common things
    # you're going to want to do, doing both the database action and the building of
    # the JSON for the client in one go.
    #
  
    # Finds and returns a model record identified by the primary key `id`.
    # It sets the into the client session the `id` of the current record, 
    # identified by the key `<table_name>_id`, where `table_name` is the singular
    # snake case name of the model.  It also sets the fetched record into the 
    # model data to be stored in the client Model Store cache.
    # 
    # `model` is the class of the model to be fetched.  For example, to fetch the 
    # Item with id = 42 and assign it to the instance variable `@item`, you'd say:
    #
    #     @item = @mvcoffee.find Item, 42
    #
    # This sets @item to the Active Record Item with id = 42 and sets the client
    # session key `"item_id"` to 42.
    #
    def find(model, id)
      table_name = model.table_name.singularize
      data = model.find id

      set_session "#{table_name}_id" => id
      
      set_model_data table_name, data
    end
  
    # Finds and returns all records of the given model.  It sets the fetched records 
    # into the model data to be stored in the client Model Store cache, replacing
    # all records for this Model.
    #
    # `model` is the class of the model to be fetched.  For example, to fetch all
    # of the Categories, you'd say:
    #
    #     @categories = @mvcoffee.all Category
    #
    def all(model)
      table_name = model.table_name.singularize
      data = model.all

      set_model_replace_on table_name, data, {}
    end

    # Fetches and returns all of the children records of the `entity` given following
    # the given `has_many_of` association.  
    # It sets the into the client session the `id` of the parent entity, 
    # identified by the key `<table_name>_id`, where `table_name` is the singular
    # snake case of the parent model.
    # It also sets the fetched records 
    # into the model data to be stored in the client Model Store cache, replacing
    # all records for this Model that have a foreign_key matching the `id` of `entity`.
    #
    # `entity` is an Active Record record.  `has_many_of` can be either a symbol or a
    # string, and may be either plural or singular.
    #
    # For example, if you have a model Department that has many Items, given a
    # department entity, you'd say:
    #
    #     @items = @mvcoffee.fetch_has_many @department, :items
    #
    # This sets `@items` to `@department.items` and sets the client session key
    # `"department_id"` to `@department.id`.
    #
    def fetch_has_many(entity, has_many_of)
      table_name = has_many_of.to_s.singularize
      method_call = table_name.pluralize.to_sym
      parent_table_name = entity.class.table_name.singularize
      foreign_key = "#{parent_table_name}_id"
      
      data = entity.send method_call
      
      replace_on = { foreign_key => entity.id }
      
      set_session replace_on

      set_model_replace_on table_name, data, replace_on
    end
      
    # Destroys the given `entity` and communicates to the client to remove this
    # record from the Data Store cache.  
    #
    # It ends in an exclamation mark to warn you,
    # **this really does delete the entity from the database**!
    #
    # `entity` is an Active Record record.  For example, if you had an Item record
    # stored in `@item`, this would call `destroy` on it and tell the client cache to
    # do the same:
    #
    #     @mvcoffee.delete! @item
    #
    def delete!(entity)
      table_name = entity.class.table_name.singularize
      
      entity.destroy
      
      set_model_delete table_name, entity.id
    end
  
    #==============================================================================
    #
    # Convert to JSON!
    #

    def to_json
      @json.to_json
    end

  end
end

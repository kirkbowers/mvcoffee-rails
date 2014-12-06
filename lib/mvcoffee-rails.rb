require 'mvcoffee/rails/engine'
require "mvcoffee/rails/version"


module MVCoffee

  def is_full_page_load?
    !request.xhr? and !request.headers["HTTP_X_XHR_REFERER"]
  end
    
  def render_mvcoffee(data, opts = {})
    respond_to do |format|
      format.html { 
        if data.redirect
          redirect_to data.redirect, data.flash.merge(opts)
        else
          render opts 
        end
      }
      format.json { render json: data.to_json }
    end  
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

      def set_redirect(path, opts = {})
        set_flash opts
        @json[:redirect] = path
      end
    
      def set_flash(opts = {})
        @json[:flash].merge! opts
        if opts[:errors]
          set_errors opts[:errors]
        end
      end
        
      def set_errors(errors)
        @json[:errors] = errors
      end
    
      def append_errors(errors)
        if @json[:errors]
          @json[:errors].concat!(errors)
        else
          @json[:errors] = errors
        end
      end
    
      def set_model_data(model_name, data)
        obj = @json[:models][model_name] || {}
        
        result = nil
        
        if data.respond_to? :collect
          if data.length > 0
            if data[0].respond_to? :to_hash
              result = data.collect {|a| a.to_hash }
            else
              result = data.collect {|a| a.to_json }
            end
          else
            result = []
          end
        elsif data.respond_to? :to_hash
          result = data.to_hash
        else
          result = data.to_json
        end
        
        obj[:data] = result
        # Reassign it back.  If we got a new hash, it isn't a reference from the @json
        # object, so it won't be associated unless we make it so manually.
        # If we did get a hash back on the first line, it is a reference, but since we
        # merged into it, it is safe to reassign it back.
        @json[:models][model_name] = obj
      end
    
      def set_model_replace_on(model_name, data, foreign_keys)
        obj = set_model_data(model_name, data)
        
        obj[:replace_on] = foreign_keys
        
        # Reassign it back.  If we got a new hash, it isn't a reference from the @json
        # object, so it won't be associated unless we make it so manually.
        # If we did get a hash back on the first line, it is a reference, but since we
        # merged into it, it is safe to reassign it back.
        @json[:models][model_name] = obj
      end
    
      def set_model_delete(model_name, data)
        obj = @json[:models][model_name] || {}

        ojb[:delete] ||= []
        if data.respond_to? :to_a
          obj += data.to_a
        else
          obj << data
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

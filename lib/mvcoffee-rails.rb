require 'mvcoffee/rails/engine'
require "mvcoffee/rails/version"

puts '!!!!!! mvcoffee-rails uber include file !!!!!!'


module MVCoffee

  def is_full_page_load?
    !request.xhr? and !request.headers["HTTP_X_XHR_REFERER"]
  end
    
  def render_mvcoffee(data)
    respond_to do |format|
      format.html
      format.json { render json: data.to_json }
    end  
  end

  module MVCoffee
    class MVCoffee
      def initialize
        @json = {
          flash: {},
          models: {},
          deletes: {}
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
    
      def set_models(opts)
        @json[:models].merge!(opts)
      end
    
      def set_deletes(model_name, data)
        @json[:deletes][model_name] ||= []
        if data.respond_to? :to_a
          @json[:deletes][model_name].concat data.to_a
        else
          @json[:deletes][model_name] << data
        end
      end      
    
      def set(opts)
        @json.merge! opts
      end
      
      def []=(key, value)
        @json[key] = value
      end
        
      def to_json
        @json.to_json
      end

      alias :set_model :set_models
      alias :set_delete :set_deletes
    end
  end
end

module ActiveRecord
  class Base
    def self.caches_via_mvcoffee(child)
      # This is a bunch of crazy metaprogramming!
      
      # Ideally this will work now matter how they supply the child name.
      # It could be a string or symbol, singular or plural.
      # We normalize it to a plural string here, because that's what we need.
      childs = child.to_s.pluralize
      
      # This is the name of the method we need to define on this class to be called
      # when a record of this model is created, and any time any child record is
      # changed in any way
      method = "#{childs}_updated!"
      
      define_method method do
        send "#{childs}_updated_at=", DateTime.now
        save!
      end
    
      after_create method
    
      # Okay, done changing this class, let's change the child class
      
      # I'm assuming that if this class is namespaced in a module, then the child
      # class should be namespaced the same.
      prefix_match = name.match /^.*::/
      prefix = ""
      if prefix_match
        prefix = prefix_match[0]
      end
      
      # Create a reference to the child class definition.
      # It doesn't have to be class_eval here, it could be regular eval, but I've read
      # this is safer from code injection.
      clazz = class_eval "::#{prefix}#{child.to_s.singularize.camelcase}"

      refresh_method = "refresh_#{childs}_updated_at"
      parent_name = table_name.singularize
      clazz.class_eval do
        define_method refresh_method do
          parent = send parent_name
          parent.send method
        end
        
        after_save refresh_method
        after_destroy refresh_method
      end
    end
  end
end
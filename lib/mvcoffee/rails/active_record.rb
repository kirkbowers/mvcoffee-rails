module ActiveRecord
  class Base
    def self.caches_via_mvcoffee(child, opts = {})
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
      # 
      # There are two cases here, the default, and if we are using :through.
      # In the default case, there is only one descendent, the child, and it
      # belongs_to this class, so its reference back to this class is through
      # a singular method call.
      #
      # In the through case, we have two classes to deal with, the through class
      # which is our direct descendent, and the "child" class we have many through
      # the join table.  In this case, the direct descendent should behave the way 
      # the child should in the usual case.  It has a belongs_to singular reference
      # back to this class.  The "child" class should have a has_many through back to
      # this class, so it will be a plural reference.
      
      direct_descendent = child
      if opts[:through]
        direct_descendent = opts[:through]
      end
      
      # Create a reference to the child class definition.
      # It doesn't have to be class_eval here, it could be regular eval, but I've read
      # this is safer from code injection.
      #
      # Plus, doing this as a class_eval puts us in the same namespace as the parent.
      clazz = class_eval "#{direct_descendent.to_s.singularize.camelcase}"

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
      
      # Now do the special case of a has_many through
      if opts[:through]
        clazz = class_eval "#{child.to_s.singularize.camelcase}"
        
        parents_name = table_name.pluralize
        clazz.class_eval do
          define_method refresh_method do
            parents = send parents_name
            parents.each { |parent| parent.send method }
          end
        
          after_save refresh_method
          # This may not be strictly necessary if delete cascade, but there's no harm
          # in being thorough
          after_destroy refresh_method
        end
      end
    end
  end
end
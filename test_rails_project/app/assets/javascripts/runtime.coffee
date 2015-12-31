count = 0

$(document).ready( ->
  count += 1
  
  $(".page-count").text(count)
  
  $("#menu").click( ->
    alert ("Pretend menu clicked.  Shouldn't be clientized.  Page count should remain the same.")
  )
)



# Instantiate the runtime
runtime = new MVCoffee.Runtime
  debug: true

# Register models by passing an object literal to the register_models method
# The object keys are the singular snake-cased model names
# The object values are the Model class definitions
runtime.register_models
  department: MyNamespace.Department
  item: MyNamespace.Item
  user: MyNamespace.User
  shopping_cart_item: MyNamespace.ShoppingCartItem

# Register controllers by passing an object literal to the register_controllers method
# For each pair the object key is an HTML element id that will appear on any page
#   for which the controller should be started
# The object values are the Controller class definitions
runtime.register_controllers
  department_form: MyNamespace.EditDepartmentController
  notice: MyNamespace.NoticeController
  department_index_table: MyNamespace.DepartmentIndexController
  item_form: MyNamespace.EditItemController
  item_index_table: MyNamespace.ItemIndexController
  user_form: MyNamespace.EditUserController
  shopping_cart: MyNamespace.ShoppingCartController
  
runtime.neverClientize '#menu'

# Start the runtime by calling the run method
runtime.run()

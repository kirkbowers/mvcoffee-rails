class MyNamespace.ItemIndexController extends MVCoffee.Controller
  onStart: ->
    @department = MyNamespace.Department.find(@getSession("department_id")) 
    @shopping_user = MyNamespace.User.find(@getSession("shopping_user_id"))

  render: ->
    selector = "#item_index_table"
    items = @department.items()
    
    $item_table = $(selector)
    
    $item_table.empty()
    for item in items
      $item_table.append(
        JST['templates/item_index_row']
          department: @department
          item: item
          shopping_user: @shopping_user
      ) 

    @reclientize selector
  
  refresh: ->
    @fetch department_items_path(@department.id)
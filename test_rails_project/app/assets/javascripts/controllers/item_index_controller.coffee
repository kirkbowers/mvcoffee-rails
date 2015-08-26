class MyNamespace.ItemIndexController extends MVCoffee.Controller
  onStart: ->
    @department = MyNamespace.Department.find(@getSession("department_id")) 

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
      ) 

    @reclientize selector
  
  refresh: ->
    @fetch department_items_path(@department.id)
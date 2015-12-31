class MyNamespace.ItemIndexController extends MVCoffee.Controller
  onStart: ->
    @department = MyNamespace.Department.find(@getSession("department_id")) 
    @shopping_user = MyNamespace.User.find(@getSession("shopping_user_id"))

  render: ->
    items = @department.items()

    @rerender
      selector: '#item_index_table'
      template: 'templates/item_index_row'
      collection: items
      as: 'item'
      locals:
        department: @department
        shopping_user: @shopping_user
  
  refresh: ->
    @fetch department_items_path(@department.id)
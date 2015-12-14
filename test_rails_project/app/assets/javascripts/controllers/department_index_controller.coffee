class MyNamespace.DepartmentIndexController extends MVCoffee.Controller
  onStart: ->
    @shopping_user = MyNamespace.User.find(@getSession("shopping_user_id"))

  render: ->
    departments = MyNamespace.Department.all()

    @rerender
      selector: "#department_index_table"
      template: 'templates/department_index_row'
      collection: departments
      as: 'department'
      locals:
        shopping_user: @shopping_user
  
  refresh: ->
    @fetch departments_path()
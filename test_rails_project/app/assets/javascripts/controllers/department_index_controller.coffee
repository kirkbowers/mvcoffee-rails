class MyNamespace.DepartmentIndexController extends MVCoffee.Controller
  onStart: ->
    @shopping_user = MyNamespace.User.find(@getSession("shopping_user_id"))

  render: ->
    selector = "#department_index_table"
    departments = MyNamespace.Department.all()
    
    $dept_table = $(selector)
    
    $dept_table.empty()
    for department in departments
      $dept_table.append(
        JST['templates/department_index_row']
          department: department
          shopping_user: @shopping_user
      ) 

    @reclientize selector
  
  refresh: ->
    @fetch departments_path()
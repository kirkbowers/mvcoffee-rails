class MyNamespace.DepartmentIndexController extends MVCoffee.Controller
  render: ->
    selector = "#department_index_table"
    departments = MyNamespace.Department.all()
    
    $dept_table = $(selector)
    
    $dept_table.empty()
    for department in departments
      $dept_table.append(
        JST['templates/department_index_row']
          department: department
      ) 

    @reclientize selector
  
  refresh: ->
    @fetch departments_path()
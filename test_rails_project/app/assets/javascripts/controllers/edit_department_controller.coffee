class MyNamespace.EditDepartmentController extends MVCoffee.Controller
  onStart: ->
    @department = new MyNamespace.Department
    @addClientizeCustomization
      selector: "#department_form"
      model: @department
      
  department_form_errors: (errors) ->
    $errors_list = $("#department_form_errors")
    $errors_list.empty()
    for error in errors
      $errors_list.append "<li>" + error + "</li>"
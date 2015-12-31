class MyNamespace.EditUserController extends MVCoffee.Controller
  onStart: ->
    @user = new MyNamespace.User
    @addClientizeCustomization
      selector: "#user_form"
      model: @user
      
  user_form_errors: (errors) ->
    console.log "user_form_errors called"
    $errors_list = $("#user_form_errors")
    $errors_list.empty()
    for error in errors
      console.log "Error = " + error
      $errors_list.append "<li>" + error + "</li>"
class MyNamespace.EditItemController extends MVCoffee.Controller
  onStart: ->
    @item = new MyNamespace.Item
    @addClientizeCustomization    
      selector: "#item_form"
      model: @item
      
  item_form_errors: (errors) ->
    $errors_list = $("#item_form_errors")
    $errors_list.empty()
    for error in errors
      $errors_list.append "<li>" + error + "</li>"

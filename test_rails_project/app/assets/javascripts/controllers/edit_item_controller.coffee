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

    self = this
    $("form .field").each (index, element) ->
      $label = $(element).find("label")
      $input = $(element).find("input")
      field = $input.attr("id")
      field = field.replace /^item_/, ""
      console.log "Found label for field " + field
      if self.item.errorsForField[field]
        $label.addClass("field_with_errors")
        $input.addClass("field_with_errors")
      else
        $label.removeClass("field_with_errors")
        $input.removeClass("field_with_errors")
        
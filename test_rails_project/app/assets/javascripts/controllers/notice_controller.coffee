class MyNamespace.NoticeController extends MVCoffee.Controller
  render: ->
    $("#notice").html(@getFlash("notice"))

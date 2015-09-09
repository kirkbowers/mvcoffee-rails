class MyNamespace.ShoppingCartController extends MVCoffee.Controller
  onStart: ->
    @$shopping_cart = $("#shopping_cart")
    @user = MyNamespace.User.find(@getSession('user_id'))
    @shopping_user = MyNamespace.User.find(@getSession("shopping_user_id"))
    
  render: ->
    @$shopping_cart.empty()
    for item in @user.items()
      @$shopping_cart.append(
        JST['templates/shopping_cart_row']
          item: item
          shopping_user: @shopping_user
      ) 

    @reclientize @$shopping_cart
      
      
  refresh: ->
    @fetch user_path(@user.id)
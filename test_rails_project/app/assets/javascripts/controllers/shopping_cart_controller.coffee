class MyNamespace.ShoppingCartController extends MVCoffee.Controller
  onStart: ->
    @user = MyNamespace.User.find(@getSession('user_id'))
    @shopping_user = MyNamespace.User.find(@getSession("shopping_user_id"))
    
  render: ->
    @rerender
      selector: "#shopping_cart"
      template: 'templates/shopping_cart_row'
      collection: @user.items()
      as: 'item'
      locals:
        shopping_user: @shopping_user

    # This little extra bit is silly
    # It's only here to prove that the rerender method works without a collection
    @rerender
      selector: "#current_user"
      template: 'templates/current_user'
      locals:
        user: @user
      
  refresh: ->
    @fetch user_path(@user.id)
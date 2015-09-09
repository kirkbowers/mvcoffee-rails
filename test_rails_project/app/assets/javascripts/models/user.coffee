it = class MyNamespace.User extends MVCoffee.Model

it.validates "name", test: "presence"

it.has_many "shopping_cart_item"
it.has_many "item", through: "shopping_cart_item"

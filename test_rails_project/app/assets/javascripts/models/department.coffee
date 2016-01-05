it = class MyNamespace.Department extends MVCoffee.Model

it.validates "name",
  test: "presence"

it.has_many "item"

# This creates the method inexpensive_items()
it.has_many "item", scope: 'inexpensive'
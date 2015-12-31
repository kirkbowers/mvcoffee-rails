it = class MyNamespace.Department extends MVCoffee.Model

it.validates "name",
  test: "presence"

it.has_many "item"

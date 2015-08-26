it = class MyNamespace.Item extends MVCoffee.Model

it.belongs_to "department"

it.validates "name", test: "presence"
it.validates "price",
  test: "numericality"
  greater_than_or_equal_to: 0
it.validates "sku",
  test: "numericality"
  only_integer: true
  greater_than: 0

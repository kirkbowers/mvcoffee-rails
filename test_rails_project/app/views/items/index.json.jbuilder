json.array!(@items) do |item|
  json.extract! item, :id, :name, :sku, :price, :department_id
  json.url item_url(item, format: :json)
end

module MvcoffeeHelper

  def mvcoffee_json_tag(mvcoffee)
    result = '  <script id="mvcoffee_json" type="text/json">'
    result += raw mvcoffee.to_json
    result += '  </script>'
    
    result.html_safe
  end


end
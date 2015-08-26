// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
//
// This file is auto-generated by js-rails-routes 0.1.0
//
// DO NOT EDIT BY HAND!!
//
   
// Generated by CoffeeScript 1.9.3
var link_to;

link_to = function(label, link, opts) {
  var key, ref, result, value;
  if (opts == null) {
    opts = {};
  }
  result = '<a href="' + link + '"';
  if (opts.id != null) {
    result += ' id="' + opts.id + '"';
  }
  if (opts["class"] != null) {
    result += ' class="' + opts["class"] + '"';
  }
  if (opts.method != null) {
    result += ' rel="nofollow" data-method="' + opts.method + '"';
  }
  if (opts.data != null) {
    ref = opts.data;
    for (key in ref) {
      value = ref[key];
      result += ' data-' + key + '="' + value + '"';
    }
  }
  result += '>' + label + '</a>';
  return result;
};

var department_items_path = function(department_id) {
  if (department_id instanceof Object) {
    return "/" + "departments" + "/" + department_id["department_id"] + "/" + "items";
  } else {
    return "/" + "departments" + "/" + department_id + "/" + "items";
  }
}

var new_department_item_path = function(department_id) {
  if (department_id instanceof Object) {
    return "/" + "departments" + "/" + department_id["department_id"] + "/" + "items" + "/" + "new";
  } else {
    return "/" + "departments" + "/" + department_id + "/" + "items" + "/" + "new";
  }
}

var edit_department_item_path = function(department_id, id) {
  if (department_id instanceof Object) {
    return "/" + "departments" + "/" + department_id["department_id"] + "/" + "items" + "/" + department_id["id"] + "/" + "edit";
  } else {
    return "/" + "departments" + "/" + department_id + "/" + "items" + "/" + id + "/" + "edit";
  }
}

var department_item_path = function(department_id, id) {
  if (department_id instanceof Object) {
    return "/" + "departments" + "/" + department_id["department_id"] + "/" + "items" + "/" + department_id["id"];
  } else {
    return "/" + "departments" + "/" + department_id + "/" + "items" + "/" + id;
  }
}

var departments_path = function() {
  return "/departments";
}

var new_department_path = function() {
  return "/departments/new";
}

var edit_department_path = function(id) {
  if (id instanceof Object) {
    return "/" + "departments" + "/" + id["id"] + "/" + "edit";
  } else {
    return "/" + "departments" + "/" + id + "/" + "edit";
  }
}

var department_path = function(id) {
  if (id instanceof Object) {
    return "/" + "departments" + "/" + id["id"];
  } else {
    return "/" + "departments" + "/" + id;
  }
}

var root_path = function() {
  return "/";
}

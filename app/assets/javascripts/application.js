// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//

//= require_tree ./global
//= require_tree .
//= require jquery.validate
//= require jquery-ui
//= require jquery.validate.additional-methods
//= require Chart.min
//= require_tree ./channels

$(document).ready(function(){
  // set the menu item to active
  routes = {
    '/': '#home',
    '/analytics': '.analytics',
    '/learners': '.index',
    '/curriculum': '.curriculum',
    '/support': '.support',
    '/learner': '.learner-profile',
    '/learner/ecosystem': '.learning-ecosystem',
    '/submissions': '.submission',
    '/surveys': '.survey',
    '/surveys-v2': '.survey',
    '/programs': '.programs',
    '/surveys-v2/setup': '.survey',
    '/pitch': '.pitch',
  };

  Object.keys(routes).forEach(function(key) {
    regexKey = key + '*'
    regex = RegExp(regexKey)
    
    if (regex.test(window.location.pathname)) {
      $(routes[key]).addClass('active');
      $(routes[key]).find('.link-icon').addClass('active')
    }
  });
});

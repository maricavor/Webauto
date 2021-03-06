// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.

//= require jquery
//= require jquery_ujs
//= require jquery.ui.all
//= require t-func
//= require bootstrap 
//= require bootstrap-datepicker
//= require bootstrap-datepicker/locales/bootstrap-datepicker.et.js
//= require bootstrap-datepicker/locales/bootstrap-datepicker.en-GB.js
//= require bootstrap-datepicker/locales/bootstrap-datepicker.ru.js
//= require spin
//= require loadingoverlay.min
//= require jquery-fileupload/basic
//= require jquery.capty.min
//= require jquery.raty.js
//= require_tree .
$(window).on('load', function(e) {
    if (window.location.hash == '#_=_') {
        window.location.hash = ''; // for older browsers, leaves a # behind
        history.pushState('', document.title, window.location.pathname); // nice and clean
        e.preventDefault(); // no page reload
    }
});
$(document).ready(function() {
    $('.js-activated').dropdownHover().dropdown();
    $('.add_fields').tooltip();
   
    
});

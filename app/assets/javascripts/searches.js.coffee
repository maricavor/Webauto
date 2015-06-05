# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
jQuery ->
  $('.toggle_alert').change ->
    al= if $(this).prop('checked') then "Alert" else "No Alert"
    $.ajax
      type: "POST"
      url: "/searches/"+$(this).attr('id').replace('toggle_alert_', '')
      data: {search:{alert_freq:al},_method:'put'}
      dataType: "script"
    return
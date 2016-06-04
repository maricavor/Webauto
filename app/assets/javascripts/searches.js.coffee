# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
jQuery ->
  $('.toggle_alert').change ->
    #al= if $(this).prop('checked') then "Alert" else "No Alert"
    if $(this).prop('checked')==true
      params={create_alert:1,alert_freq: "Alert"}
    else
      params={create_alert:0,alert_freq: "No Alert"}
    $.ajax
      type: "POST"
      dataType: "script"
      url: "/searches/"+$(this).attr('id').replace('toggle_alert_', '')
      data: {search: params,_method: 'put' } 
    return
# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
jQuery ->
  $('#photo_image').attr('name','photo[image]')
  $('#global_progress').hide()
  $('#fileupload1').fileupload
    dataType: "script"
    add:  (e, data) ->
      data.submit()
    start: (e, data) ->
      $('#global_progress .bar').css('width','0%')
      $('#global_progress').show()
    stop: (e, data) ->
      $('#global_progress').hide()
    progressall: (e, data) ->
      progress = parseInt(data.loaded / data.total * 100, 10)
      $('#global_progress .bar').css('width',progress + '%')
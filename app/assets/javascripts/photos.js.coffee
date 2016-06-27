# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
  $('#photo_image').attr('name','photo[image]')
  $('#global_progress').hide()
  $('#fileupload1').fileupload
    dataType: "script"
    
    add: (e, data) ->
      maxFileSize=3000000
      types = /(\.|\/)(gif|jpe?g|png)$/i
      file = data.files[0]
      #data.context = $(tmpl("template-upload", file).trim()) 
      if file.size<=maxFileSize
        if types.test(file.type) || types.test(file.name) 
          #$('#fileupload').append(data.context)
          $(".garage_item_image").LoadingOverlay("show")
          data.submit()
        else
          $.ajax
            url: "/photos/fail_upload"
            data: {file: file.name,error: t("file_is_not_image")}
            dataType: "script"
          #alert("#{file.name} is not a gif, jpeg, or png image file")
      else
        $.ajax
          url: "/photos/fail_upload"
          data: {file: file.name,error: t("big")}
          dataType: "script"
          #alert("#{file.name} is too big")

    
    done: (e, data) ->
      #data.context.remove()
      $(".garage_item_image").LoadingOverlay("hide", true)
    start: (e, data) ->
      $('#global_progress .bar').css('width','0%')
      $('#global_progress').show()
    stop: (e, data) ->
      $('#global_progress').hide()
    #progress: (e, data) ->
      #if data.context
        #progress = parseInt(data.loaded / data.total * 100, 10)
        #data.context.find('.bar').css('width',progress + '%')

    progressall: (e, data) ->
      progress = parseInt(data.loaded / data.total * 100, 10)
      $('#global_progress .bar').css('width',progress + '%')
	

    
    
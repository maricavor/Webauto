jQuery ->
  $('#global_progress').hide()
  $('#fileupload').fileupload
    dataType: "script"
    
    add: (e, data) ->
      maxFileSize=5000000
      types = /(\.|\/)(gif|jpe?g|png)$/i
      file = data.files[0]
      #data.context = $(tmpl("template-upload", file).trim()) 
      if file.size<=maxFileSize
        if types.test(file.type) || types.test(file.name) 
          #$('#fileupload').append(data.context)
          data.submit()
        else
          $.ajax
            url: "/pictures/fail_upload"
            data: {file: file.name,error: "the file is not a gif, jpeg, or png image!"}
            dataType: "script"
          #alert("#{file.name} is not a gif, jpeg, or png image file")
      else
        $.ajax
          url: "/pictures/fail_upload"
          data: {file: file.name,error: "the file is too big!"}
          dataType: "script"
          #alert("#{file.name} is too big")

    
    done: (e, data) ->
      #data.context.remove()
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
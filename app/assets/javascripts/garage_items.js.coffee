# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
Functions =
  updateCountdown: (id) ->
    help=$("#"+id+"_help")
    max_length  = help.data("maximum-length")
    help.text(max_length - $("#"+id).val().length)
    return
  isNotUndefined: (element, index, array) ->
    return element == undefined
jQuery ->
  $(document).ready ->
    $.fn.raty.defaults.starOn = 'star-on-big.png'
    $.fn.raty.defaults.starOff = 'star-off-big.png'
    $.fn.raty.defaults.starHalf = 'star-half-big.png'
    $.fn.raty.defaults.number = 5
    $.fn.raty.defaults.size = 24
    $('.overall_rating').raty 
      score: ->
        $(this).data("score")
      readOnly: true
      half: true
      precision: true
    $('.star').raty 
      targetKeep: true
      targetType: 'number'
      mouseover: (score, evt) ->
        id=$(this).attr('id')
        target = $('#'+id+'_target')
        hidden_field=$('#review_'+id)
        if score == null 
          target.html('0/5')
          hidden_field.val(null)
        else if score == undefined
          target.html('0/5')
          hidden_field.val(null)
        else
          target.html(score + '/5')
          hidden_field.val(score)
      click: (score, evt) ->
        score_array=[$('#performance').raty('score'),$('#practicality').raty('score'),$('#reliability').raty('score'),$('#running_costs').raty('score')]
        if score_array.some(Functions.isNotUndefined)==false
          sum = score_array.reduce((a,b) -> a + b)
          avg = sum / score_array.length
          s=Math.round(avg * 10) / 10
          $('#overall_rating').raty({score: s,readOnly: true, half: true, precision: true})
          $('#overall_rating_target').html(s+'/5')
          $('#review_overall').val(s)
	       
  $(document).on 'change',"#dontlikeRadio", (event) ->
    if $(this).is(':checked')
      $('.like_select').prop('selectedIndex',0)
    event.preventDefault()
  $(document).on 'change',".like_select", (event) ->
    $('#dontlikeRadio').prop('checked', false)
    event.preventDefault()
  $(document).on 'change',"#dontdislikeRadio", (event) ->
    if $(this).is(':checked')
      $('.dislike_select').prop('selectedIndex',0)
    event.preventDefault()
  $(document).on 'change',".dislike_select", (event) ->
    $('#dontdislikeRadio').prop('checked', false)
    event.preventDefault()
  $(document).on 'keyup',"#experience_text_et", (event) ->
    Functions.updateCountdown($(this).attr('id'))
    event.preventDefault()
  $(document).on 'keyup',"#experience_text_en", (event) ->
    Functions.updateCountdown($(this).attr('id'))
    event.preventDefault()
  $(document).on 'keyup',"#experience_text_ru", (event) ->
    Functions.updateCountdown($(this).attr('id'))
    event.preventDefault()
  $(document).on 'keyup',"#title_text", (event) ->
    Functions.updateCountdown($(this).attr('id'))
    event.preventDefault()
  
 
  
  
    

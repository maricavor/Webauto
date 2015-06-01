Models =
 show_cities: (val) ->
   if val != null
     if val=='8'
       $('#user_city_id_field').show() 
     else
       $('#user_city_id_field').hide()  
   else
     $('#user_city_id_field').hide()  

 toggle: (id1,id2) ->
   if $(id1).prop('checked')==true
     $(id2).show()
   else
     $(id2).hide()

jQuery ->
  $('#user_city_id_field').hide()
  $('fieldset.dealer_data').hide() 
  Models.show_cities($("#user_country_id").val())
  Models.toggle('#user_is_dealer','fieldset.dealer_data')
  $(document).on 'change',"#user_country_id", (event) ->
    Models.show_cities($(this).val())
    event.preventDefault() 
  $(document).on 'click',"#user_is_dealer", (event) ->
    Models.toggle('#user_is_dealer','fieldset.dealer_data')
    true 



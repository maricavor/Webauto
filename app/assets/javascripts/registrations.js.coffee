Models = 
 toggle: (id1,id2,bool) ->
   if $(id1).prop('checked')==bool
     $(id2).show()
   else
     $(id2).hide()

jQuery ->
  $('#vehicle_city_id_field').hide()
  $('#vehicle_state_id_field').hide()
  $('fieldset.dealer_data').hide() 
  Models.toggle('#user_is_dealer','fieldset.dealer_data')
  $(document).on 'click',"#user_is_dealer", (event) ->
    Models.toggle('#user_is_dealer','fieldset.dealer_data',true)
    Models.toggle('#user_is_dealer','#omniauth_links',false)
    true 



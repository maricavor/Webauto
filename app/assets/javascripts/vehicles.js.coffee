if gon
  grouped_models=gon.grouped_models 
  selected=gon.selected


Models =
  init: (gm,t) ->
    if t.val()!=""
      make=t.text()
      body=Models.option_tag(make,"","Select #{make} model")
      if gm
        for serie,models of gm[make] 
          match = /undefined/i.test(serie)
          if match
            body += Models.option_tag(make,models[1],models[0])
          else
            body += "<optgroup label='#{serie}'>"
            for m in models
              body += Models.option_tag(make,m[1],m[0])
            body += "</optgroup>"
        body +=Models.option_tag(make,0,"Other model (please specify)") 
        $('#vehicle_model_id').html(body) 
    else
      $('#vehicle_model_id').empty()
 
  update_form: ->
    if selected
      if selected["stgt"]!=null or selected["stlt"]!=null
        Models.toggle_more_options()
      if selected["bt"]
        $('#search_bt').selectpicker('val', selected["bt"].split(','))
        $('#search_bt').selectpicker('refresh')
      if selected["ft"]
        $('#search_ft').selectpicker('val', selected["ft"].split(','))
        $('#search_ft').selectpicker('refresh')
      if selected["tm"]
        $('#search_tm').selectpicker('val', selected["tm"].split(','))
        $('#search_tm').selectpicker('refresh')
      if selected["dt"]
        $('#search_dt').selectpicker('val', selected["dt"].split(','))
        $('#search_dt').selectpicker('refresh')
        Models.toggle_more_options()
      if selected["cl"]
        $('#search_cl').selectpicker('val', selected["cl"].split(','))
        $('#search_cl').selectpicker('refresh')
        Models.toggle_more_options()
      if selected["location"]
        $('#search_location').selectpicker('val', selected["location"].split(','))
        $('#search_location').selectpicker('refresh')
      if selected["doors"]
        $('#search_doors').selectpicker('val', selected["doors"].split(','))
        $('#search_doors').selectpicker('refresh')
        Models.toggle_more_options()
      if selected["features"]
        $('#search_features').selectpicker('val', selected["features"].split(','))
        $('#search_features').selectpicker('refresh')
        Models.toggle_more_options()
      if selected["vehicles"][2]!=null
        ss=selected["vehicles"][2]
        $("#vehicle_model_id option[value='#{ss}']").attr("selected", "selected")
    elements=$('.make_select')
    elements.each -> 
      attr_id=$(this).attr('id')
      if attr_id != undefined
        id = attr_id.match(/\d+/)
        $(this).selectpicker()
        Models.init_search(grouped_models,$('#search_fields_attributes_'+id+'_make_name option').filter(':selected'),$('#search_fields_attributes_'+id+'_model_name'))
        if selected
          if selected["vehicles"][0][1]!=null
            $('#search_fields_attributes_'+id+'_model_name').selectpicker('val', selected["vehicles"][0][1].split(',')) 
            $('#search_fields_attributes_'+id+'_model_name').selectpicker('refresh')
            selected["vehicles"].splice(0, 1)
    selected=null


  init_search: (gm,t1,t2) ->
    if t1.val()!=""
      make=t1.text()
      body=""
      if gm
        for serie,models of gm[make] 
          match = /undefined/i.test(serie)
          if match
            body += Models.option_tag(make,models[0],models[0])
          else
            body += Models.option_tag(make,serie,serie,false,true)
            for m,i in models
              body += Models.option_tag(make,m[0],m[0],true)
        t2.html(body) 
        t2.selectpicker({title: t("search.any")+" #{make} "+t("search.models")})
    else
      t2.empty()
      t2.selectpicker({title: t("search.model")})
    t2.selectpicker('refresh')

  
  include: (sv,make,model) ->
    if sv.length > 0
      if sv[0][0]==make && sv[0][1]==model
        sv.splice(0, 1)
        return true
    return false

  option_tag: (make,val,txt,offset=false,bold=false) ->
    text= if offset then "&nbsp&nbsp&nbsp&nbsp#{txt}" else "#{txt}"
    cls= if bold then "optgroup" else ""
    "<option class='#{cls}' value='#{val}'>"+text+"</option>"

  show_model_spec: (show,model_id=null) ->
    if show
      $('#model_spec').show()
    else
      if model_id=='0'
        $('#model_spec').show()
      else
        $('#model_spec').hide()
  
  show_states: (id) ->
    $.ajax
      url: "/vehicles/show_states"
      data: {country_id: id}
      dataType: "script"

  show_cities: (id) ->
    $.ajax
      url: "/vehicles/show_cities"
      data: {state_id: id}
      dataType: "script"

  update_states: (id) ->
    $.ajax
      url: "/vehicles/update_states"
      data: {city_id: id}
      dataType: "script"

  show_regions_in_search: ->
    val= $('#search_location').val()
    if val != null
      if "8" in val
        $.ajax
          url: "/vehicles/show_regions_in_search"
          data: {country_id: 8}
          dataType: "script"
      else
        $('#search_region').html("")
        $('#search_region').selectpicker('refresh')
    else
      $('#search_region').html("")
      $('#search_region').selectpicker('refresh')

  toggle: (id1,id2) ->
    if $(id1).prop('checked')==true
      $(id2).show()
    else
      $(id2+' input').removeAttr('checked')
      $(id2).val("")
      $(id2).hide()

  toggle_more_options: ->
    $('.hidden_field').selectpicker('show')
    $('.less_options').show()
    $('.more_options').hide()


  toggleLogo: ->
    i = 0
    images = [
      "/logo.jpg"
      "/logo.jpg"
    ]
    image = $("#logo")
    #Initial Background image setup
    image.css "background-image", "url('/logo.jpg')"
    #Change image at regular intervals
    setInterval (->
      image.fadeOut 1000, ->
        image.css "background-image", "url(" + images[i++] + ")"
        image.fadeIn 1000
        return
      i = 0  if i is images.length
      return
    ), 10000
    return

jQuery ->
  $(document).ready ->
    $('.selectpicker').selectpicker()
    $('.datepicker').datepicker({format: 'mm/yyyy',minViewMode: "months", maxViewMode: "years", language: window.locale})
    #$('#search_region').selectpicker('hide')
    $('.hidden_field').selectpicker('hide')
    $('.less_options').hide()
    $('.collapse_search').hide()
    $('#moreTab a[href="#similar"]').tab('show')
    $('#moreTabInSearch a[href="#viewed_by_you"]').tab('show')
    $('#commentTab a:first').tab('show')
    Models.update_form()
    Models.show_model_spec(false,$('#vehicle_model_id option').filter(':selected').val())
    return

  $('#blueimp-gallery').data('fullScreen', false)
  $('.tooltipped').tooltip()
  $('.spinner').spinedit()
  #$('#myTab a[href="#popular"]').tab('show')
  $(".decimal_spinner").spinedit
    minimum: 0
    maximum: 100
    step: 0.1
    value: 0
    numberOfDecimals: 1
  $(".5_spinner").spinedit
    minimum: 0
    maximum: 500
    step: 5
    value: 0
    numberOfDecimals: 0

  $(".sortable_pictures").sortable
    update: (event, data) ->
      id=$(this).attr('id').replace('pictures_', '')
      params=$(this).sortable('serialize')
      $.post("/vehicles/"+id+"/sort_photos", params).done ->
        #alert "Photos resorted "+params   
    items: "li:not(.ui-state-disabled)"

  $( ".sortable_pictures" ).disableSelection()

  if $('#vehicle_country_id').val()!="8"
    $('#vehicle_state_id').hide()  
    $('#vehicle_city_id').hide()  
  #Models.toggleLogo()
  Models.init(grouped_models,$('#vehicle_make_id option').filter(':selected')) 

  Models.toggle('#advert_vehicle_attributes_power_steering','#power_steering_details')
  Models.toggle('#advert_vehicle_attributes_anti_skidding','#anti_skidding_details')
  Models.toggle('#advert_vehicle_attributes_stability_control','#stability_control_details')
  Models.toggle('#advert_vehicle_attributes_braking_force_reg','#braking_force_reg_details')
  Models.toggle('#advert_vehicle_attributes_engine_preheating','#engine_preheating_details')
  Models.toggle('#advert_vehicle_attributes_central_locking','#with_remote')
  Models.toggle('#advert_vehicle_attributes_sunroof','#sunroof_details')
  Models.toggle('#advert_vehicle_attributes_alarm','#alarm_details')
  Models.toggle('#advert_vehicle_attributes_alarm','#with_tow_away_protection')
  Models.toggle('#advert_vehicle_attributes_alarm','#with_motion_sensor')
  Models.toggle('#advert_vehicle_attributes_alarm','#two_way_comm')
  Models.toggle('#advert_vehicle_attributes_extra_lights','#extra_lights_details')
  Models.toggle('#advert_vehicle_attributes_hands_free','#hands_free_details')
  Models.toggle('#advert_vehicle_attributes_fog_lights','#fog_lights_front')
  Models.toggle('#advert_vehicle_attributes_fog_lights','#fog_lights_rear')
  Models.toggle('#advert_vehicle_attributes_winter_tires','#all_season_tires')
  Models.toggle('#advert_vehicle_attributes_winter_tires','#spike_tires')
  Models.toggle('#advert_vehicle_attributes_winter_tires','#winter_tires_size')
  Models.toggle('#advert_vehicle_attributes_winter_tires','#winter_tires_details')
  Models.toggle('#advert_vehicle_attributes_summer_tires','#summer_tires_details')
  Models.toggle('#advert_vehicle_attributes_summer_tires','#summer_tires_size')
  Models.toggle('#advert_vehicle_attributes_light_alloy_wheels','#light_alloy_wheels_details')
  Models.toggle('#advert_vehicle_attributes_light_alloy_wheels','#light_alloy_wheels_size')
  Models.toggle('#advert_vehicle_attributes_steering_wheel_adjustment','#steering_wheel_height_and_depth')
  Models.toggle('#advert_vehicle_attributes_steering_wheel_adjustment','#steering_wheel_electrical')
  Models.toggle('#advert_vehicle_attributes_steering_wheel_adjustment','#steering_wheel_with_memory')
  Models.toggle('#advert_vehicle_attributes_car_stereo','#car_stereo_cd')
  Models.toggle('#advert_vehicle_attributes_car_stereo','#car_stereo_mp3')
  Models.toggle('#advert_vehicle_attributes_car_stereo','#car_stereo_details')
  Models.toggle('#advert_vehicle_attributes_car_stereo','#car_stereo_usb')
  Models.toggle('#advert_vehicle_attributes_car_stereo','#car_stereo_aux')
  Models.toggle('#advert_vehicle_attributes_car_stereo','#car_stereo_card')
  Models.toggle('#advert_vehicle_attributes_car_stereo','#car_stereo_original')
  Models.toggle('#advert_vehicle_attributes_car_stereo','#car_stereo_with_remote')
  Models.toggle('#advert_vehicle_attributes_car_stereo','#speakers_field')
  Models.toggle('#advert_vehicle_attributes_car_stereo','#subwoofer')
  Models.toggle('#advert_vehicle_attributes_car_stereo','#cd_changer')
  Models.toggle('#advert_vehicle_attributes_mats','#textile_mats')
  Models.toggle('#advert_vehicle_attributes_mats','#rubber_mats')
  Models.toggle('#advert_vehicle_attributes_mats','#velour_mats')
  Models.toggle('#advert_vehicle_attributes_electric_mirrors','#heated_mirrors')
  Models.toggle('#advert_vehicle_attributes_electric_mirrors','#folding_mirrors')
  Models.toggle('#advert_vehicle_attributes_electric_mirrors','#mirrors_with_memory')
  Models.toggle('#advert_vehicle_attributes_cruise_control','#distance_monitoring')
  Models.toggle('#advert_vehicle_attributes_parking_aid','#parking_aid_front')
  Models.toggle('#advert_vehicle_attributes_parking_aid','#parking_aid_rear')
  Models.toggle('#advert_vehicle_attributes_trim','#cloth_upholstery')
  Models.toggle('#advert_vehicle_attributes_trim','#vinyl_upholstery')
  Models.toggle('#advert_vehicle_attributes_trim','#faux_leather_upholstery')
  Models.toggle('#advert_vehicle_attributes_trim','#wood_grain')
  Models.toggle('#advert_vehicle_attributes_trim','#leather_upholstery')
  Models.toggle('#advert_vehicle_attributes_trim','#chrome')
  Models.toggle('#advert_vehicle_attributes_tow_hitch','#tow_hitch_removable')
  Models.toggle('#advert_vehicle_attributes_tow_hitch','#tow_hitch_electrical')
  Models.toggle('#advert_vehicle_attributes_xenon','#xenon_low_beam')
  Models.toggle('#advert_vehicle_attributes_xenon','#xenon_high_beam')
  Models.toggle('#advert_vehicle_attributes_textile_upholstery','#textile_upholstery_details')
  Models.toggle('#advert_vehicle_attributes_velour_padding','#velour_padding_details')
  Models.toggle('#advert_vehicle_attributes_half_leather_padding','#half_leather_padding_details')
  Models.toggle('#advert_vehicle_attributes_leather_interior','#leather_interior_details')
  $(document).on 'click',"#search_dealer", (event) ->
    $('#search_private').prop('checked',true) if $(this).prop('checked')== false && $('#search_private').prop('checked')==false
    true
  $(document).on 'click',"#search_private", (event) ->
    $('#search_dealer').prop('checked',true) if $(this).prop('checked')== false && $('#search_dealer').prop('checked')==false
    true
  $('#vehicle_make_id').change ->
    Models.init(grouped_models,$('#vehicle_make_id option').filter(':selected'))
  $(document).on 'change',".make_select", (event) ->
    id = $(this).attr('id').match(/\d+/)
    Models.init_search(grouped_models,$('#search_fields_attributes_'+id+'_make_name option').filter(':selected'),$('#search_fields_attributes_'+id+'_model_name'))
    event.preventDefault()  
  $('#vehicle_model_id').change ->
    Models.show_model_spec(false,$('#vehicle_model_id option').filter(':selected').val())
  $(document).on 'change',"#vehicle_country_id", (event) ->
    Models.show_states($('#vehicle_country_id').val())
    event.preventDefault()
  $(document).on 'change',"#vehicle_state_id", (event) ->
    Models.show_cities($('#vehicle_state_id').val())
    event.preventDefault()
  $(document).on 'change',"#vehicle_city_id", (event) ->
    Models.update_states($('#vehicle_city_id').val())
    event.preventDefault()
  if history && history.pushState 
    $(document).on 'click',".sort_link", (event) ->
      $div = $(this).parent().parent().parent()
      $('div.btn-group a.btn').html  $(this).text() + " <span class=\"caret\"></span>"
      $div.removeClass "open"
      #$.getScript this.href
      history.pushState null, document.title, this.href
      event.preventDefault()
    $(document).on 'click',".page_link", (event) ->
      #$.getScript this.href
      #$('html, body').scrollTop(0)
      history.pushState null, document.title, this.href
      event.preventDefault()
    $(window).on "popstate", (event) ->
      #alert("location: " + document.location + ", state: " + event.state)
      #history.pushState null, document.title, this.href
      #$.getScript location.href 
  $(document).on 'click',".alert_link", (event) ->
      $div = $(this).parent().parent().parent()
      $div.find('a.btn').html  $(this).text() + " <span class=\"caret\"></span>"
      $div.removeClass "open"
      event.preventDefault()
  $(document).on 'click', 'form .remove_fields', (event) ->
    $(this).closest("fieldset").fadeOut 500, ->
      $(this).remove()
      return
    event.preventDefault()
  $(document).on 'click', 'form .add_fields', (event) ->
    time = new Date().getTime()
    regexp = new RegExp($(this).data('id'), 'g')
    $(this).parent().before($(this).data('fields').replace(regexp, time))
    $('.model_select').selectpicker('refresh')
    $('.make_select').selectpicker('refresh')
    event.preventDefault()
  $(document).on 'click', '.expand_search', (event) ->
    $('.expandable').removeClass("hidden-phone")
    $('.collapse_search').show()
    $(this).hide()
    event.preventDefault()
  $(document).on 'click', '.collapse_search', (event) ->
    $('.expandable').addClass("hidden-phone")
    $(this).hide()
    $('.expand_search').show()
    event.preventDefault()
  $(document).on 'click', 'form .more_options', (event) ->
    Models.toggle_more_options()
    event.preventDefault()
  $(document).on 'click', 'form .less_options', (event) ->
    $('.hidden_field').selectpicker('hide')
    $(this).hide()
    $('.more_options').show()
    $('.hidden_field').val('')
    $('.hidden_field').selectpicker('render')
    event.preventDefault()
  $(document).on 'click', '.reset_search', (event) ->
    $('.selectpicker').val('')
    $('.selectpicker').selectpicker('render')
    $('.make_select').val('')
    $('.make_select').selectpicker('render')
    $('.model_select option').remove()
    $('.model_select').selectpicker({title: "Model (any)"})
    $('.model_select').selectpicker('refresh')
    $('fieldset.extra').remove()
    $('#search_dealer').prop('checked',true)
    $('#search_private').prop('checked',true)
    $('#search_keywords').val('')
    event.preventDefault() 
  $(document).on 'change',"#search_location", (event) ->
    Models.show_regions_in_search()
    event.preventDefault() 
  $(document).on 'change',".resetable", (event) ->
    val= $(this).val()
    if val != null
      $(".reset_field").show()
    event.preventDefault() 
  $(document).on 'click',"#advert_vehicle_attributes_leather_interior", (event) ->
    Models.toggle('#advert_vehicle_attributes_leather_interior','#leather_interior_details')
    true 
  $(document).on 'click',"#advert_vehicle_attributes_textile_upholstery", (event) ->
    Models.toggle('#advert_vehicle_attributes_textile_upholstery','#textile_upholstery_details')
    true 
  $(document).on 'click',"#advert_vehicle_attributes_velour_padding", (event) ->
    Models.toggle('#advert_vehicle_attributes_velour_padding','#velour_padding_details')
    true 
  $(document).on 'click',"#advert_vehicle_attributes_half_leather_padding", (event) ->
    Models.toggle('#advert_vehicle_attributes_half_leather_padding','#half_leather_padding_details')
    true 
  $(document).on 'click',"#advert_vehicle_attributes_power_steering", (event) ->
    Models.toggle('#advert_vehicle_attributes_power_steering','#power_steering_details')
    true 
  $(document).on 'click',"#advert_vehicle_attributes_central_locking", (event) ->
    Models.toggle('#advert_vehicle_attributes_central_locking','#with_remote')
    true 
  $(document).on 'click',"#advert_vehicle_attributes_anti_skidding", (event) ->
    Models.toggle('#advert_vehicle_attributes_anti_skidding','#anti_skidding_details')
    true 
  $(document).on 'click',"#advert_vehicle_attributes_stability_control", (event) ->
    Models.toggle('#advert_vehicle_attributes_stability_control','#stability_control_details')
    true 
  $(document).on 'click',"#advert_vehicle_attributes_braking_force_reg", (event) ->
    Models.toggle('#advert_vehicle_attributes_braking_force_reg','#braking_force_reg_details')
    true
  $(document).on 'click',"#advert_vehicle_attributes_traction_control", (event) ->
    Models.toggle('#advert_vehicle_attributes_traction_control','#traction_control_details')
    true
  $(document).on 'click',"#advert_vehicle_attributes_sunroof", (event) ->
    Models.toggle('#advert_vehicle_attributes_sunroof','#sunroof_details')
    true
  $(document).on 'click',"#advert_vehicle_attributes_engine_preheating", (event) ->
    Models.toggle('#advert_vehicle_attributes_engine_preheating','#engine_preheating_details')
    true
  $(document).on 'click',"#advert_vehicle_attributes_extra_lights", (event) ->
    Models.toggle('#advert_vehicle_attributes_extra_lights','#extra_lights_details')
    true
  $(document).on 'click',"#advert_vehicle_attributes_hands_free", (event) ->
    Models.toggle('#advert_vehicle_attributes_hands_free','#hands_free_details')
    true
  $(document).on 'click',"#advert_vehicle_attributes_alarm", (event) ->
    Models.toggle('#advert_vehicle_attributes_alarm','#with_tow_away_protection')
    Models.toggle('#advert_vehicle_attributes_alarm','#with_motion_sensor')
    Models.toggle('#advert_vehicle_attributes_alarm','#two_way_comm')
    Models.toggle('#advert_vehicle_attributes_alarm','#alarm_details')
    true 
  $(document).on 'click',"#advert_vehicle_attributes_fog_lights", (event) ->
    Models.toggle('#advert_vehicle_attributes_fog_lights','#fog_lights_front')
    Models.toggle('#advert_vehicle_attributes_fog_lights','#fog_lights_rear')
    true 
  $(document).on 'click',"#advert_vehicle_attributes_winter_tires", (event) ->
    Models.toggle('#advert_vehicle_attributes_winter_tires','#winter_tires_details')
    Models.toggle('#advert_vehicle_attributes_winter_tires','#all_season_tires')
    Models.toggle('#advert_vehicle_attributes_winter_tires','#spike_tires')
    Models.toggle('#advert_vehicle_attributes_winter_tires','#winter_tires_size')
    true 
  $(document).on 'click',"#advert_vehicle_attributes_summer_tires", (event) ->
    Models.toggle('#advert_vehicle_attributes_summer_tires','#summer_tires_details')
    Models.toggle('#advert_vehicle_attributes_summer_tires','#summer_tires_size')
    true 
  $(document).on 'click',"#advert_vehicle_attributes_light_alloy_wheels", (event) ->
    Models.toggle('#advert_vehicle_attributes_light_alloy_wheels','#light_alloy_wheels_details')
    Models.toggle('#advert_vehicle_attributes_light_alloy_wheels','#light_alloy_wheels_size')
    true 
  $(document).on 'click',"#advert_vehicle_attributes_tow_hitch", (event) ->
    Models.toggle('#advert_vehicle_attributes_tow_hitch','#tow_hitch_removable')
    Models.toggle('#advert_vehicle_attributes_tow_hitch','#tow_hitch_electrical')
    true 
  $(document).on 'click',"#advert_vehicle_attributes_steering_wheel_adjustment", (event) ->
    Models.toggle('#advert_vehicle_attributes_steering_wheel_adjustment','#steering_wheel_height_and_depth')
    Models.toggle('#advert_vehicle_attributes_steering_wheel_adjustment','#steering_wheel_electrical')
    Models.toggle('#advert_vehicle_attributes_steering_wheel_adjustment','#steering_wheel_with_memory')
    true 
  $(document).on 'click',"#advert_vehicle_attributes_car_stereo", (event) ->
    Models.toggle('#advert_vehicle_attributes_car_stereo','#car_stereo_details')
    Models.toggle('#advert_vehicle_attributes_car_stereo','#car_stereo_cd')
    Models.toggle('#advert_vehicle_attributes_car_stereo','#car_stereo_mp3')
    Models.toggle('#advert_vehicle_attributes_car_stereo','#car_stereo_usb')
    Models.toggle('#advert_vehicle_attributes_car_stereo','#car_stereo_aux')
    Models.toggle('#advert_vehicle_attributes_car_stereo','#car_stereo_card')
    Models.toggle('#advert_vehicle_attributes_car_stereo','#car_stereo_original')
    Models.toggle('#advert_vehicle_attributes_car_stereo','#car_stereo_with_remote')
    Models.toggle('#advert_vehicle_attributes_car_stereo','#speakers_field')
    Models.toggle('#advert_vehicle_attributes_car_stereo','#subwoofer')
    Models.toggle('#advert_vehicle_attributes_car_stereo','#cd_changer')
    true 
  $(document).on 'click',"#advert_vehicle_attributes_mats", (event) ->
    Models.toggle('#advert_vehicle_attributes_mats','#textile_mats')
    Models.toggle('#advert_vehicle_attributes_mats','#rubber_mats')
    Models.toggle('#advert_vehicle_attributes_mats','#velour_mats')
    true 
  $(document).on 'click',"#advert_vehicle_attributes_xenon", (event) ->
    Models.toggle('#advert_vehicle_attributes_xenon','#xenon_low_beam')
    Models.toggle('#advert_vehicle_attributes_xenon','#xenon_high_beam')
    true 
 
  $(document).on 'click',"#advert_vehicle_attributes_cruise_control", (event) ->
    Models.toggle('#advert_vehicle_attributes_cruise_control','#distance_monitoring')
    true
  $(document).on 'click',"#advert_vehicle_attributes_trim", (event) ->
    Models.toggle('#advert_vehicle_attributes_trim','#cloth_upholstery')
    Models.toggle('#advert_vehicle_attributes_trim','#vinyl_upholstery')
    Models.toggle('#advert_vehicle_attributes_trim','#faux_leather_upholstery')
    Models.toggle('#advert_vehicle_attributes_trim','#wood_grain')
    Models.toggle('#advert_vehicle_attributes_trim','#leather_upholstery')
    Models.toggle('#advert_vehicle_attributes_trim','#chrome')
    true 
  $(document).on 'click',"#advert_vehicle_attributes_electric_mirrors", (event) ->
    Models.toggle('#advert_vehicle_attributes_electric_mirrors','#heated_mirrors')
    Models.toggle('#advert_vehicle_attributes_electric_mirrors','#folding_mirrors')
    Models.toggle('#advert_vehicle_attributes_electric_mirrors','#mirrors_with_memory')
    true 
  $(document).on 'click',"#advert_vehicle_attributes_parking_aid", (event) ->
    Models.toggle('#advert_vehicle_attributes_parking_aid','#parking_aid_front')
    Models.toggle('#advert_vehicle_attributes_parking_aid','#parking_aid_rear')
    true 

  $(document).on 'click', '.find_details', (event) ->
    regmark=$("#vehicle_reg_nr").val()
    vin=$("#vehicle_vin").val()
    if regmark!=""
      $('.find_details').html('loading...')
      $('.find_details').addClass("disabled")
      $.post("/vehicles/find_details",{regmark: regmark, vin: vin})
        .done (data) ->
          $('.find_details').html('Find details')
          $('.find_details').removeClass("disabled")
          if (typeof data =='object')
            badge = if data.object.badge then data.object.badge else ""
            html="<strong>Vehicle details found: </strong>"
            date=new Date(data.object.registered_at)
            edit_href=location.href.replace('new',data.id+'/edit')
            details_href=location.href.replace('new',data.id+'/details')
            html+="#{data.object.make_model} #{badge} <br>"
            html+="Date of first registration: #{$.datepicker.formatDate('M yy', date)}<br>"
            #html+="<div>#{data.doc}</div>"
            $('.response').html(html)
            $('#vehicle_make_id').val(data.object.make_id)
            Models.init(grouped_models,$('#vehicle_make_id option').filter(':selected'))
            $('#vehicle_model_id').val(data.object.model_id)
            $('#vehicle_badge').val(badge)
            $('#vehicle_registered_at_2i').val(date.getMonth()+1)
            $('#vehicle_registered_at_1i').val(date.getFullYear())
          else
            html="<p>We were unable to identify your car's details. <br> Please select the missing details from the menus below.</p>"
            $('.response').html(html)
        .fail ->
          html="<p>We were unable to identify your car's details.<br> Please select the missing details from the menus below.</p>"
          $('.find_details').html('Find details')
          $('.find_details').removeClass("disabled")
          $('.response').html(html)
    else
      $('.response').html("Enter regmark!")
    event.preventDefault()

  $(document).on 'click',".expandcollapse", (event) ->
    if $(this).html() is "<i class=\"icon-white icon-plus-sign\"></i> Expand All"
      $(".collapse:not(.in)").each (index) ->
        $(this).collapse "toggle"
      $(this).html "<i class=\"icon-white icon-minus-sign\"></i> Collapse All"
    else
      $(".collapse.in").each (index) ->
        $(this).collapse "toggle"
      $(this).html "<i class=\"icon-white icon-plus-sign\"></i> Expand All"
    true


  $("#commentsModal").on "hidden", ->
    $('.comments-modal-message').html('')

  $("#contactModal").on "hidden", ->
    $("#thank_you").hide()
    $("#new_inquiry").show()
    $('.contact-modal-message').html('')
  
  $("#sendToFriendModal").on "hidden", ->
    $("#thank_you_friend").hide()
    $("#new_send_to_friend").show()
    $('.send-to-friend-modal-message').html('')
  
  $("#reportAdModal").on "hidden", ->
    $("#thank_you_friend").hide()
    $("#new_report").show()
    $('.report-modal-message').html('')

  $(document).on 'click',".save_search_btn", (event) ->
    $('form#save_search_form').trigger('submit.rails')
    true 
  $(document).on 'click',".send_to_friend_btn", (event) ->
    $('form#new_send_to_friend').trigger('submit.rails')
    true 
  $(document).on 'click',".send_enquiry_btn", (event) ->
    $('form#new_inquiry').trigger('submit.rails')
    true 
  $(document).on 'click',".send_report_btn", (event) ->
    $('form#new_report').trigger('submit.rails')
    true 
  $(document).on 'click',".cancel_reply_btn", (event) ->
    $(".reply_form").remove()
    true 
  $(document).on 'click',"#garage_item_picture", (event) ->
    $("#picture").click()
    false 
 
  $("#moreTab a[data-toggle=\"tab\"]").on "shown", (e) ->
    e.target # activated tab
    e.relatedTarget # previous tab
    hash=e.target.hash
    if hash=="#similar"
      $.get("/vehicles/"+e.target.className.substring(4)+"/show_similar")
    else if hash=="#more"
      $.get("/vehicles/"+e.target.className.substring(4)+"/show_interesting")
    else
      $.get("/vehicles/"+e.target.className.substring(4)+"/show_viewed")
    return

  $("#moreTabInSearch a[data-toggle=\"tab\"]").on "shown", (e) ->
    e.target # activated tab
    e.relatedTarget # previous tab
    hash=e.target.hash
    if hash=="#viewed_by_you"
      $.get("/vehicles/get_recently_viewed_vehicles")
    return




  
  

   

  
      




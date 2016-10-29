jQuery ->
  $(document).ready ->
    $('#review_how_well_other_field').hide() 
    $('#reviewAdsTab a:first').tab('show')
  $(document).on "change", '#review_how_well', (event) ->
    if $('#review_how_well option').filter(':selected').val()=='5'
      $('#review_how_well_other_field').show() 
    else
      $('#review_how_well_other_field').hide()
  $(document).on 'shown', '#reviewAdsTab a[data-toggle="tab"]', (e) ->
    e.target # activated tab
    e.relatedTarget # previous tab
    hash=e.target.hash
    if hash=="#review_ads"
      $.get("/reviews/"+e.target.className.substring(4)+"/ads")
    return

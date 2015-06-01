opts = {
  lines: 13, # The number of lines to draw
  length: 20, # The length of each line
  width: 10, # The line thickness
  radius: 30, # The radius of the inner circle
  corners: 1, # Corner roundness (0..1)
  rotate: 0, # The rotation offset
  direction: 1, # 1: clockwise, -1: counterclockwise
  color: '#000', # #rgb or #rrggbb or array of colors
  speed: 1, # Rounds per second
  trail: 60, # Afterglow percentage
  shadow: false, # Whether to render a shadow
  hwaccel: false, # Whether to use hardware acceleration
  className: 'preloader_spinner', # The CSS class to assign to the spinner
  zIndex: 2e9, # The z-index (defaults to 2000000000)
  top: '10%', # Top position relative to parent
  left: '50%' # Left position relative to parent
}
search_opts = {
  lines: 12, # The number of lines to draw
  length: 10, # The length of each line
  width: 5, # The line thickness
  radius: 15, # The radius of the inner circle
  corners: 1, # Corner roundness (0..1)
  rotate: 0, # The rotation offset
  color: '#000', # #rgb or #rrggbb
  speed: 1.1, # Rounds per second
  trail: 100, # Afterglow percentage
  shadow: false, # Whether to render a shadow
  hwaccel: false, # Whether to use hardware acceleration
  className: 'preloader_spinner', # The CSS class to assign to the spinner
  zIndex: 2e9, # The z-index (defaults to 2000000000)
  top: '10%', # Top position relative to parent in px
  left: '50%' # Left position relative to parent in px 'auto'
}
inquiry_opts = {
  lines: 12, # The number of lines to draw
  length: 10, # The length of each line
  width: 5, # The line thickness
  radius: 10, # The radius of the inner circle
  corners: 1, # Corner roundness (0..1)
  rotate: 0, # The rotation offset
  color: '#000', # #rgb or #rrggbb
  speed: 1.1, # Rounds per second
  trail: 100, # Afterglow percentage
  shadow: false, # Whether to render a shadow
  hwaccel: false, # Whether to use hardware acceleration
  className: 'preloader_spinner', # The CSS class to assign to the spinner
  zIndex: 2e9, # The z-index (defaults to 2000000000)
  top: '50%', # Top position relative to parent in px
  left: '50%' # Left position relative to parent in px 'auto'
}
# save the lastEvent type that was called
lastEvent = undefined
# the element where the spinner should appear
$n = undefined

spinner = new Spinner(opts)


# I can only pop the $n var when document is ready
$(document).ready ->
  $n = $('.preloader')
# get the event type, ex: a "page:change" will return only 'page'
eventType = (event) ->
  return false if not event
  type = event.type
  if type.indexOf(':') > -1
    type.split(':')[0]
  else
    type.match(/[A-Z]?[a-z]+|[0-9]+/g)[0]

# show the spinner
loadState = (event) ->
  lastEvent = eventType event
  if event.target.className != undefined
    if event.target.className.indexOf('link') > -1
      $n = $('.search_preloader')
      spinner = new Spinner(opts)
      spinner.spin()
      $n.html(spinner.el)
      #spinner=new Spinner(opts).spin($n)
      #$n.after(new Spinner(opts).spin().el)
      #$n.spin search_opts
    else if event.target.id == "new_inquiry"
      $n = $('.inquiry_preloader')
      spinner = new Spinner(inquiry_opts)
      spinner.spin()
      $n.html(spinner.el)
      #$n.spin opts
    else
      $n = $('.preloader')
      spinner = new Spinner(inquiry_opts)
      spinner.spin()
      $n.html(spinner.el)
      #$n.spin opts
  #if event.target.activeElement != undefined
    #if event.target.activeElement.className.indexOf('tab') > -1
      #$n = $('.search_preloader')
      #$n.spin inquiry_opts


# hide the spinner
doneState = (event) ->
  if eventType(event) == lastEvent
    lastEvent = undefined
    $n.html("")
    spinner.stop()
    #$n.spin false

# bind some states (will see if it is more needed)
$(document).on 'ajax:before ajaxStart page:fetch', (event) ->
  loadState event
$(document).on 'ajax:complete ajaxComplete page:change', (event) ->
  doneState event
$(function() {
  window.t = function(key) {
    var comp, keys;
    if (!key) {
      return 'N/A';
    }
    keys = key.split('.');
    comp = window.I18n;
    $(keys).each(function(_, value) {
      if (comp) {
        comp = comp[value];
      }
    });
    if (!comp && console) {
      console.debug('No translation found for key: ' + key);
      return 'N/A';
    }
    return comp;
  };
});
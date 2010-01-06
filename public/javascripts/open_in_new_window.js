(function($) {
  $.fn.openInNewWindow = function(options) {
    return $(this).each(function() {
      $(this).click(function() {
        window.open($(this).attr('href'));
        return false;
      });
    });
  };
}) (jQuery);

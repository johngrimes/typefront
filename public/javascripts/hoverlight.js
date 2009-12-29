(function($) {
  $.fn.hoverlight = function(options) {
    var defaults = {
        opacity: 0.95
      };
    var options = $.extend(defaults, options);

    return $(this).each(function() {
      $(this).mouseenter(function() {
        $(this).css('opacity', options.opacity)
      });

      $(this).mouseleave(function() {
        $(this).css('opacity', 1)
      });
    });

  };
}) (jQuery);

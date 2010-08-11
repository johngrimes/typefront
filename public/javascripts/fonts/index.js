var loadingCode = '<img class="loading" alt="Loading..." src="/images/loading.gif" width="16" height="11"/><span class="loading-message">Uploading and processing...</span>';

$(document).ready(function() {
  $('.font-inner').hover(
    function() {
      $(this).parent().addClass('highlight');
    },
    function() {
      $(this).parent().removeClass('highlight');
    }
  );
  $('.font .remove-font').hover(
    function() {
      $(this).css('opacity', 1);
    },
    function() {
      $(this).css('opacity', 0.7);
    }
  );
  $.localScroll({ duration: 100 });
  $('.submit').hoverlight();
  $('#new-font-form').submit(function() {
    $(this).find('.submit').replaceWith(loadingCode);
    return true;
  });
});

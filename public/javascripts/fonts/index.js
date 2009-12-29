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
  $('.submit').hoverlight();
});

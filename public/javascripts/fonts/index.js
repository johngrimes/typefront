$(document).ready(function() {
  $('.font-inner').hover(
    function() {
      $(this).parent().addClass('highlight');
    },
    function() {
      $(this).parent().removeClass('highlight');
    }
  );
});

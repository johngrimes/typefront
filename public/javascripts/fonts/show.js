$(document).ready(function() {
  $('.toggle-font-info').click(function() {
    $('#font-attributes').toggle('blind', 800);
    $('.toggle-font-info').html() == 'Show font info' ? 
      $('.toggle-font-info').removeClass('show-font-info').addClass('hide-font-info').html('Hide font info') :
      $('.toggle-font-info').removeClass('hide-font-info').addClass('show-font-info').html('Show font info'); 
  });
});

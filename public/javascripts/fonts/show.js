$(document).ready(function() {
  $('.toggle-font-info').click(function() {
    $('#font-attributes').toggle('blind', 800);
    $('.toggle-font-info').text() == 'Show font info' ? 
      $('.toggle-font-info').text('Hide font info') :
      $('.toggle-font-info').text('Show font info'); 
  });
});

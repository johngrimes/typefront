$(document).ready(function() {
  $('.toggle-font-info').click(function() {
    $('#font-attributes').toggle('blind', 800);
    $('.toggle-font-info').html() == 'Show font info<div class="icon icon-add"></div>' ? 
      $('.toggle-font-info').html('Hide font info<div class="icon icon-subtract"></div>') :
      $('.toggle-font-info').html('Show font info<div class="icon icon-add"></div>'); 
  });
});

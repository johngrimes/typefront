$(document).ready(function() {
  $('.toggle-font-info').click(function() {
    $('#font-attributes').toggle('blind', 800);
    $('.toggle-font-info').html() == 'Show font info' ? 
      $('.toggle-font-info').removeClass('show-font-info').addClass('hide-font-info').html('Hide font info') :
      $('.toggle-font-info').removeClass('hide-font-info').addClass('show-font-info').html('Show font info'); 
  });

  $('#format-selector input').change(updateCodeFormats);
  updateCodeFormats();

  $('.submit').hoverlight();
  $('#font-attributes a').openInNewWindow();
});

function updateCodeFormats() {
  if ($('#eot').is(':checked')) {
    $('.eot-code').show();
  } else {
    $('.eot-code').hide();
  }

  if ($('#woff').is(':checked') || $('#otf').is(':checked')) {
    $('.otf-woff-code').show();
  } else {
    $('.otf-woff-code').hide();
  }

  if ($('#eot').is(':checked') && ($('#woff').is(':checked') || $('#otf').is(':checked'))) {
    $('.eot-woffotf-separator').show();
  } else {
    $('.eot-woffotf-separator').hide();
  }

  if ($('#woff').is(':checked')) {
    $('.woff-code').show();
  } else {
    $('.woff-code').hide();
  }

  if ($('#otf').is(':checked')) {
    $('.otf-code').show();
  } else {
    $('.otf-code').hide();
  }

  if ($('#woff').is(':checked') && $('#otf').is(':checked')) {
    $('.woff-otf-separator').show();
  } else {
    $('.woff-otf-separator').hide();
  }

  if ($('#style').is(':checked')) {
    $('.style-descriptors').show();
  } else {
    $('.style-descriptors').hide();
  }
}

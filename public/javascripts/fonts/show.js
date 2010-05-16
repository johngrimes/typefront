$(document).ready(function() {
  $('.toggle-font-info').click(function() {
    $('#font-attributes').toggle('blind', 800);
    $('.toggle-font-info').html() == 'Show font info' ? 
      $('.toggle-font-info').removeClass('show-font-info').addClass('hide-font-info').html('Hide font info') :
      $('.toggle-font-info').removeClass('hide-font-info').addClass('show-font-info').html('Show font info'); 
  });

  $('#ttf').change(function() {
    if ($('#otf').is(':checked')) { $('#otf').removeAttr('checked'); }
    return true;
  });
  $('#otf').change(function() {
    if ($('#ttf').is(':checked')) { $('#ttf').removeAttr('checked'); }
    return true;
  });
  $('#format-selector input').change(updateCodeFormats);
  updateCodeFormats();

  $('.submit').hoverlight();
  $('#font-attributes a').openInNewWindow();
});

function updateCodeFormats() {
  eot = $('#eot').is(':checked');
  woff = $('#woff').is(':checked');
  ttf = $('#ttf').is(':checked');
  otf = $('#otf').is(':checked');
  svg = $('#svg').is(':checked');

  if (eot) {
    $('.eot-code').show();
  } else {
    $('.eot-code').hide();
  }

  if (woff || ttf || otf || svg) {
    $('.noneot-code').show();
  } else {
    $('.noneot-code').hide();
  }

  if (woff) {
    $('.woff-code').show();
  } else {
    $('.woff-code').hide();
  }

  if (woff && (ttf || otf || svg)) {
    $('.woff-ttf-separator').show();
  } else {
    $('.woff-ttf-separator').hide();
  }

  if (ttf) {
    $('.ttf-code').show();
  } else {
    $('.ttf-code').hide();
  }

  if (ttf && (otf || svg)) {
    $('.ttf-otf-separator').show();
  } else {
    $('.ttf-otf-separator').hide();
  }

  if (otf) {
    $('.otf-code').show();
  } else {
    $('.otf-code').hide();
  }

  if (otf && svg) {
    $('.otf-svg-separator').show();
  } else {
    $('.otf-svg-separator').hide();
  }

  if (svg) {
    $('.svg-code').show();
  } else {
    $('.svg-code').hide();
  }

  if ($('#style').is(':checked')) {
    $('.style-descriptors').show();
  } else {
    $('.style-descriptors').hide();
  }
}

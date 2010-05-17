$(document).ready(function() {
  window.clipboardCode = $('#clipboard-code').html();

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

  code = $('<pre class="code" id="clipboard-code">' + window.clipboardCode + '</pre>');
  $('#clipboard-code').replaceWith(code);

  if (!eot) {
    $('.eot-code').remove();
  }

  if (!(woff || ttf || otf || svg)) {
    $('.noneot-code').remove();
  }

  if (!woff) {
    $('.woff-code').remove();
  }

  if (!(woff && (ttf || otf || svg))) {
    $('.woff-ttf-separator').remove();
  }

  if (!ttf) {
    $('.ttf-code').remove();
  }

  if (!(ttf && (otf || svg))) {
    $('.ttf-otf-separator').remove();
  }

  if (!otf) {
    $('.otf-code').remove();
  }

  if (!(otf && svg)) {
    $('.otf-svg-separator').remove();
  }

  if (!svg) {
    $('.svg-code').remove();
  }

  if (!($('#style').is(':checked'))) {
    $('.style-descriptors').remove();
  }
}

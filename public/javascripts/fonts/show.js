$(document).ready(function() {
  initFontInformationTab();
  addBehaviourToTabs();
});

function addBehaviourToTabs() {
  $('#font-tabs a').click(function() { changeTab(this); return false; });
}

function changeTab(tab) {
  $(tab).siblings().removeClass('current');
  $(tab).addClass('current');
  $('#font-tab-content').html('<img alt="Loading..." src="/images/loading.gif" width="16" height="11"/>');
  tabName = $(tab).attr('id');
  tabName = tabName.substr(tabName.length - 4, tabName.length - 1);
  url = $(tab).attr('href') + '.js';
  $.get(url, null, null, 'script');
}

function initFontInformationTab() {
  $('#font-attributes a').openInNewWindow();
}

function initExampleCodeTab() {
  $('#format-selector').show();
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
}

function initAllowedDomainsTab() {
  $('.submit').hoverlight();
}

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

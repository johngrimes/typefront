var loadingCode = '<img class="loading" alt="Loading..." src="/images/loading.gif" width="16" height="11"/>';

$(document).ready(function() {
  currentTab = $('#font-tabs .current').attr('id');
  if (currentTab == 'information-tab') {
    initFontInformationTab();
  } else if (currentTab == 'example-code-tab') {
    initExampleCodeTab();
  } else if (currentTab == 'allowed-domains-tab') {
    initAllowedDomainsTab();
  }
  addBehaviourToTabs();
});

function addBehaviourToTabs() {
  $('#information-tab').click(function() {
    changeTab(this, initFontInformationTab);
    return false;
  });
  $('#example-code-tab').click(function() {
    changeTab(this, initExampleCodeTab);
    return false;
  });
  $('#allowed-domains-tab').click(function() {
    changeTab(this, initAllowedDomainsTab);
    return false;
  });
}

function changeTab(tab, callback) {
  $(tab).siblings().removeClass('current');
  $(tab).addClass('current');
  $('#font-tab-content').html(loadingCode);
  tabName = $(tab).attr('id');
  tabName = tabName.substr(tabName.length - 4, tabName.length - 1);
  url = $(tab).attr('href') + '.js';
  $.get(url, null, callback, 'script');
}

function initFontInformationTab() {
  $('#font-attributes a').openInNewWindow();
  $('.format-action form').submit(function() {
    $.post($(this).attr('action'), $(this).serialize(), initFontInformationTab, 'script');
    _kmq.push(['record', 'Changed enabled formats']);
    $(this).replaceWith(loadingCode);
    return false;
  });
}

function initExampleCodeTab() {
  window.clipboardCode = $('#clipboard-code').html();
  $('#ttf').change(function() {
    if ($('#otf').is(':checked')) { $('#otf').removeAttr('checked'); }
    return true;
  });
  $('#otf').change(function() {
    if ($('#ttf').is(':checked')) { $('#ttf').removeAttr('checked'); }
    return true;
  });
  $('#format-selector input').change(updateCodeFormats);
  $('#format-selector-wrapper').show();
}

function initAllowedDomainsTab() {
  $('#new-domain-form .submit').hoverlight();
  $('#new-domain-form').submit(function() {
    $.post($(this).attr('action'), $(this).serialize(), initAllowedDomainsTab, 'script');
    _kmq.push(['record', 'Changed allowed domains']);
    $('#new-domain-form .submit').replaceWith(loadingCode);
    return false;
  });
  $('.domain form').submit(function() {
    $.post($(this).attr('action'), $(this).serialize(), initAllowedDomainsTab, 'script');
    _kmq.push(['record', 'Changed allowed domains']);
    $(this).find('.submit').replaceWith(loadingCode);
    return false;
  });
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
  _kmq.push(['record', 'Used the CSS builder options']);
}

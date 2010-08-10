var loadingCode = '<img class="loading" alt="Loading..." src="/images/loading.gif" width="16" height="11"/><span class="loading-message">Setting up your account...</span>';

$(document).ready(function() {
  $('.accept-terms a').openInNewWindow();
  $('#new-user-form').submit(function() {
    $(this).find('.submit').replaceWith(loadingCode);
    return true;
  });
});

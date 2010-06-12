var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
try {
  var pageTracker = _gat._getTracker("UA-3880720-4");
  pageTracker._setDomainName("none");
  pageTracker._setAllowLinker(true);
  pageTracker._trackPageview();
} catch(err) {}
$('a').each(function() {
  if ($(this).attr('href').indexOf('https') > 0) {
    $(this).click(function() {
      pageTracker._link(this.href);
      return false;
    });
  });
});

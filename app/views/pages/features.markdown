Title: Features

# Features

## All the formats you need

When you upload your font file to TypeFront, it automatically gets
converted into **five** different web-optimized file formats for you:

* [TrueType][truetype]
* [OpenType][opentype]
* [Extended OpenType (EOT)][eot]
* [Web Open Font Format (WOFF)][woff]
* [Scalable Vector Graphics (SVG)][svg]

Including these formats into your site CSS will ensure that your font is
viewable on Firefox, Safari, Chrome, iPhone and Internet Explorer
versions all the way back to 6. This represents over 95% of the [current
browser market share][marketshare].

## Domain checking

We use a combination of HTTP referer checking and an implementation of
the [Cross-Origin Resource Sharing][cors] specification to check that
the domains that your font is being requested from correspond to only
those sites that you have allowed through your TypeFront dashboard.

## Minimise font requests

Because you can use a single TypeFront font over multiple sites, and
because of the fact that we set [far-future cache expiration
headers][cacheexpiration] on our responses, your visitors may only ever
need to download a particular font once over all your sites.

## Predictive font selectors

TypeFront is smart enough to guess what [font
descriptors][fontdescriptors] you will need to include in your
@font-face declarations, based on the metadata of the fonts that you
upload. This makes it very easy to include multiple fonts from the same
family into your site.

## Browse font information

Your TypeFront dashboard makes it easy to check out all the
[metadata][metadata] about the fonts you have uploaded, including vendor
and licence information.

[![Get started](/images/strangers/home/get-started.png)](/pricing)
{: .get-started}

[truetype]: http://en.wikipedia.org/wiki/TrueType
[opentype]: http://en.wikipedia.org/wiki/OpenType
[eot]: http://www.w3.org/Submission/EOT/
[woff]: http://people.mozilla.com/~jkew/woff/woff-spec-latest.html
[svg]: http://www.w3.org/TR/SVG/fonts.html
[marketshare]: http://marketshare.hitslink.com/browser-market-share.aspx?qprid=0
[cors]: http://www.w3.org/TR/cors/
[cacheexpiration]: http://developer.yahoo.net/blog/archives/2007/05/high_performanc_2.html
[fontdescriptors]: http://www.w3.org/TR/css3-fonts/#font-resources
[metadata]: http://www.microsoft.com/typography/otspec/name.htm

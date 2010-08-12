Title: Developer API Documentation

# Developer API

The TypeFront Application Programming Interface is simply another way to
manage your fonts - one that makes it easy for third-party and custom
tools to programatically access and interact with the service.  The API
follows the [REST][rest] style, and this guide should provide everything
you need to implement software that works with TypeFront.

You can use any tool such as [cURL][curl] to interact with the TypeFront
API, and libraries are available for the following programming languages
(watch this space for more to come):

* Ruby and Ruby on Rails ([typefront-ruby][typefront-ruby])

## Authentication

TypeFront uses a combination of [HTTP Basic Authentication][basic-auth]
and [SSL][ssl] to ensure that only authorised users can interact with
your account, and to ensure that your password is safe from
eavesdropping.

## Resources and URIs

If you’ve used the TypeFront web site, the URIs in the TypeFront API
will look familiar. That’s because both views of the application use the
same URIs. In the REST model, URIs are considered identifiers for
resources, and each resource can have several representations - such as
the standard HTML view and a [JSON][json] version. Here are the JSON
versions of the URIs available in the API:

List fonts
:   **URI**: https://typefront.com/fonts.json

    **Method**: GET
  
    **Example cURL command**:

    <p class="code">curl --user john@somebody.com:password https://typefront.com/fonts.json</p>

    **Example response**:

        [{"font": 
          {"font_family": "Droid Sans", 
          "font_subfamily": "Regular", 
          "id": 101}}, 
        {"font": 
          {"font_family": "Droid Serif", 
          "font_subfamily": "Bold", 
          "id": 102}}, 
        {"font": 
          {"font_family": "Graublau Web", 
          "font_subfamily": "Regular", 
          "id": 103}}]

Get font details
:   **URI**: https://typefront.com/fonts/*\[id\]*.json

    **Method**: GET

    **Required parameters**: id
  
    **Example cURL command**:

    <p class="code">curl --user john@somebody.com:password https://typefront.com/fonts/101.json</p>

    **Example response**:

        {"font": 
          {"id": 101,
          "font_family": "Droid Sans", 
          "font_subfamily": "Regular",
          "copyright": "Digitized data copyright  2007, Google Corporation.", 
          "manufacturer": "Ascender Corporation", 
          "trademark": "Droid is a trademark of Google and may be registered in certain jurisdictions.", 
          "license": "Licensed under the Apache License, Version 2.0",
          "license_url": "http://www.apache.org/licenses/LICENSE-2.0", 
          "description": "Droid Sans is a humanist sans serif typeface designed for user interfaces and electronic communication.", 
          "version": "Version 1.00", 
          "vendor_url": "http://www.ascendercorp.com/",
          "designer_url": "http://www.ascendercorp.com/typedesigners.html", 
          "example_include_code": "@font-face {\n  font-family: \"Droid Sans\";\n  src: url(http://typefront.com/fonts/41.eot);\n  font-weight: normal;\n  font-style: normal;\n}\n\n@font-face {\n  font-family: \"Droid Sans\";\n  src: url(http://typefront.com/fonts/41.woff) format(\"woff\"),\n       url(http://typefront.com/fonts/41.otf) format(\"opentype\");\n  font-weight: normal;\n  font-style: normal;\n}", 
          "compatible_full": "Droid Sans",
          "allowed_domains": 
            [{"domain": "http://www.crazypartyhats.com", "id": 201}, 
            {"domain": "http://johnsmith.com", "id": 202}]
          "access_urls": 
            [{"id": 301, 
              "format": "Extended OpenType", 
              "url": "http://typefront.com/fonts/41.eot", 
              "active": false}, 
            {"id": 302, 
              "format": "OpenType", 
              "url": "http://typefront.com/fonts/41.otf", 
              "active": true}, 
            {"id": 303, 
              "format": "TrueType", 
              "url": "http://typefront.com/fonts/41.ttf", 
              "active": true}, 
            {"id": 304, 
              "format": "Scalable Vector Graphics", 
              "url": "http://typefront.com/fonts/41.svg", 
              "active": true}, 
            {"id": 305, 
              "format": "Web Open Font Format", 
              "url": "http://typefront.com/fonts/41.woff", 
              "active": true}]}}

Upload new font
:   **URI**: https://typefront.com/fonts.json

    **Method**: POST

    **Required parameters**: font\[original\]
  
    **Example cURL command**:

    <p class="code">curl --user john@somebody.com:password --form font[original]=@font.ttf http://typefront.local:3000/fonts.json</p>

    **Example response**:

        {"notice": "Successfully created font.",
          "font": 
            {"id": 101,
            "font_family": "Droid Sans", 
            "font_subfamily": "Regular",
            "copyright": "Digitized data copyright  2007, Google Corporation.", 
            "manufacturer": "Ascender Corporation", 
            "trademark": "Droid is a trademark of Google and may be registered in certain jurisdictions.", 
            "license": "Licensed under the Apache License, Version 2.0",
            "license_url": "http://www.apache.org/licenses/LICENSE-2.0", 
            "description": "Droid Sans is a humanist sans serif typeface designed for user interfaces and electronic communication.", 
            "version": "Version 1.00", 
            "vendor_url": "http://www.ascendercorp.com/",
            "designer_url": "http://www.ascendercorp.com/typedesigners.html", 
            "example_include_code": "@font-face {\n  font-family: \"Droid Sans\";\n  src: url(http://typefront.com/fonts/41.eot);\n  font-weight: normal;\n  font-style: normal;\n}\n\n@font-face {\n  font-family: \"Droid Sans\";\n  src: url(http://typefront.com/fonts/41.woff) format(\"woff\"),\n       url(http://typefront.com/fonts/41.otf) format(\"opentype\");\n  font-weight: normal;\n  font-style: normal;\n}", 
            "compatible_full": "Droid Sans",
            "allowed_domains": 
              [{"domain": "http://www.crazypartyhats.com", "id": 201}, 
              {"domain": "http://johnsmith.com", "id": 202}]
            "access_urls": 
              [{"id": 301, 
                "format": "Extended OpenType", 
                "url": "http://typefront.com/fonts/41.eot", 
                "active": false}, 
              {"id": 302, 
                "format": "OpenType", 
                "url": "http://typefront.com/fonts/41.otf", 
                "active": false}, 
              {"id": 303, 
                "format": "TrueType", 
                "url": "http://typefront.com/fonts/41.ttf", 
                "active": false}, 
              {"id": 304, 
                "format": "Scalable Vector Graphics", 
                "url": "http://typefront.com/fonts/41.svg", 
                "active": false}, 
              {"id": 305, 
                "format": "Web Open Font Format", 
                "url": "http://typefront.com/fonts/41.woff", 
                "active": false}]}}

Remove font
:   **URI**: https://typefront.com/fonts/*\[id\]*.json

    **Method**: DELETE

    **Required parameters**: id
  
    **Example cURL command**:

    <p class="code">curl --user john@somebody.com:password --request DELETE https://typefront.com/fonts/103.json</p>

    **Example response**:

        {"notice": "Successfully removed font."}

Activate / disable font format
:   **URI**: https://typefront.com/fonts/*\[id\]*/formats/*\[format_id\]*.json

    **Method**: PUT

    **Required parameters**: id, format_id, font_format\[active\]
  
    **Example cURL command**:

    <p class="code">curl --user john@somebody.com:password --form font_format[active]=true --request PUT https://typefront.com/fonts/101/formats/301.json</p>

    **Example response**:

        {"notice": "Successfully updated active status of font format.",
          "font": 
            {"id": 101,
            "font_family": "Droid Sans", 
            "font_subfamily": "Regular",
            "copyright": "Digitized data copyright  2007, Google Corporation.", 
            "manufacturer": "Ascender Corporation", 
            "trademark": "Droid is a trademark of Google and may be registered in certain jurisdictions.", 
            "license": "Licensed under the Apache License, Version 2.0",
            "license_url": "http://www.apache.org/licenses/LICENSE-2.0", 
            "description": "Droid Sans is a humanist sans serif typeface designed for user interfaces and electronic communication.", 
            "version": "Version 1.00", 
            "vendor_url": "http://www.ascendercorp.com/",
            "designer_url": "http://www.ascendercorp.com/typedesigners.html", 
            "example_include_code": "@font-face {\n  font-family: \"Droid Sans\";\n  src: url(http://typefront.com/fonts/41.eot);\n  font-weight: normal;\n  font-style: normal;\n}\n\n@font-face {\n  font-family: \"Droid Sans\";\n  src: url(http://typefront.com/fonts/41.woff) format(\"woff\"),\n       url(http://typefront.com/fonts/41.otf) format(\"opentype\");\n  font-weight: normal;\n  font-style: normal;\n}", 
            "compatible_full": "Droid Sans",
            "allowed_domains": 
              [{"domain": "http://www.crazypartyhats.com", "id": 201}, 
              {"domain": "http://johnsmith.com", "id": 202}]
            "access_urls": 
              [{"id": 301, 
                "format": "Extended OpenType", 
                "url": "http://typefront.com/fonts/41.eot", 
                "active": true}, 
              {"id": 302, 
                "format": "OpenType", 
                "url": "http://typefront.com/fonts/41.otf", 
                "active": true}, 
              {"id": 303, 
                "format": "TrueType", 
                "url": "http://typefront.com/fonts/41.ttf", 
                "active": true}, 
              {"id": 304, 
                "format": "Scalable Vector Graphics", 
                "url": "http://typefront.com/fonts/41.svg", 
                "active": true}, 
              {"id": 305, 
                "format": "Web Open Font Format", 
                "url": "http://typefront.com/fonts/41.woff", 
                "active": true}]}}

Add new allowed domain
:   **URI**: https://typefront.com/fonts/*\[id\]*/domains.json

    **Method**: POST

    **Required parameters**: id, domain\[domain\]
  
    **Example cURL command**:

    <p class="code">curl --user john@somebody.com:password --data "domain[domain]=http://www.fingerpuppetz.com" https://typefront.com/fonts/102/domains.json</p>

    **Example response**:

        {"notice": "Successfully added allowed domain to font.", 
          "domain": 
            {"font_id": 102, 
            "domain": "http://www.fingerpuppetz.com", 
            "id": 203}}

Remove allowed domain
:   **URI**: https://typefront.com/fonts/*\[id\]*/domains/*\[domain_id\]*.json

    **Method**: DELETE

    **Required parameters**: id, domain_id
  
    **Example cURL command**:

    <p class="code">curl --user john@somebody.com:password --request DELETE https://typefront.com/fonts/101/domains/201.json</p>

    **Example response**:

        {"notice": "Successfully removed domain from allowed list."}

[rest]: http://en.wikipedia.org/wiki/Representational_State_Transfer
[curl]: http://curl.haxx.se/
[typefront-ruby]: http://github.com/smallspark/typefront-ruby
[basic-auth]: http://en.wikipedia.org/wiki/Basic_access_authentication
[ssl]: http://en.wikipedia.org/wiki/Transport_Layer_Security
[json]: http://en.wikipedia.org/wiki/JSON

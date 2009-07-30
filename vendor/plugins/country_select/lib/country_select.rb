module ActionView
  module Helpers
    module FormOptionsHelper
      def country_options_for_select(selected = nil, priority_countries = nil)
        country_file = IO.read(COUNTRIES_JSON)
	country_list = ActiveSupport::JSON.decode(country_file)

        country_options = ''
        country_options += selected ? "<option value=\"\"></option>\n" :
                                      "<option value=\"\" selected=\"selected\"></option>\n"

        # If there are priority countries, add them at the start of the
        # list with a separator and remove those countries from the main
        # list
        if priority_countries
          country_list.reject! { |x| priority_countries.include?(x['name']) }
          country_options += options_for_select(priority_countries, selected)
          country_options += "<option value=\"\" disabled=\"disabled\">-------------</option>\n"
        end

	country_list.collect! { |x| x['name'] }
        return country_options + options_for_select(country_list, selected)
      end

      def country_select(object, method, priority_countries, options = {}, html_options = {})
        InstanceTag.new(object, method, self, options.delete(:object)).to_country_select_tag(priority_countries, options, html_options)
      end
    end

    class InstanceTag
      def to_country_select_tag(priority_countries, options, html_options)
        html_options = html_options.stringify_keys
        add_default_name_and_id(html_options)
        value = value(object)
        content_tag("select", add_options(country_options_for_select(value, priority_countries), options, value), html_options)
      end
    end

    class FormBuilder
      def country_select(method, priority_countries, options = {}, html_options = {})
        @template.country_select(@object_name, method, priority_countries, objectify_options(options), @default_options.merge(html_options))
      end
    end
  end
end

raw_config = File.read(Rails.root.to_s + '/config/analytics_config.yml')
ANALYTICS_CONFIG = YAML.load(raw_config)[Rails.env].symbolize_keys

require 'km'
options = ANALYTICS_CONFIG
key = options.delete(:key)
options.merge!(:log_dir => File.join(RAILS_ROOT, 'log'))
puts options.inspect
KM.init(key, options)

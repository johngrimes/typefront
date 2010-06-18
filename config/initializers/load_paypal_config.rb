raw_config = File.read(Rails.root.to_s + '/config/paypal_config.yml')
PAYPAL_CONFIG = YAML.load(raw_config)[Rails.env].symbolize_keys

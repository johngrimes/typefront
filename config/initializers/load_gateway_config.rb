raw_config = File.read(Rails.root.to_s + '/config/gateway_config.yml')
GATEWAY_CONFIG = YAML.load(raw_config)[Rails.env].symbolize_keys

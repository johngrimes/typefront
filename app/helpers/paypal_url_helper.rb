module PaypalUrlHelper
  def paypal_signup_url(user)
    custom = {  :user => user.id }
    values = {  :cmd => '_s-xclick',
                :hosted_button_id => PAYPAL_CONFIG[:signup_button_id][user.subscription_name.downcase],
                :custom => Base64.encode64(custom.to_query) }
    PAYPAL_CONFIG[:url] + '?' + values.to_query
  end

  def paypal_modify_subscription_url(user, subscription_level)
    custom = {  :user => user.id,
                :subscription_level => subscription_level }
    values = {  :cmd => '_s-xclick',
                :hosted_button_id => PAYPAL_CONFIG[:modify_button_id][User::PLANS[subscription_level][:name].downcase],
                :custom => Base64.encode64(custom.to_query) }
    PAYPAL_CONFIG[:url] + '?' + values.to_query
  end

  def paypal_cancel_subscription_url(user)
    custom = {  :user => user.id }
    values = {  :cmd => '_subscr-find',
                :alias => PAYPAL_CONFIG[:merchant_id],
                :custom => Base64.encode64(custom.to_query) }
    PAYPAL_CONFIG[:url] + '?' + values.to_query
  end
end

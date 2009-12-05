module PaypalUrlHelper
  def paypal_signup_url(user)
    values = {  :cmd => '_s-xclick',
                :hosted_button_id => PAYPAL_CONFIG[:signup_button_id][user.subscription_name.downcase],
                :custom => user.id }
    PAYPAL_CONFIG[:url] + '?' + values.to_query
  end

  def paypal_modify_subscription_url(user, subscription_level)
    values = {  :cmd => '_s-xclick',
                :hosted_button_id => PAYPAL_CONFIG[:modify_button_id][User::PLANS[subscription_level][:name].downcase],
                :custom => user.id }
    PAYPAL_CONFIG[:url] + '?' + values.to_query
  end

  def paypal_cancel_subscription_url(user)
    values = {  :cmd => '_subscr-find',
                :alias => PAYPAL_CONFIG[:merchant_id],
                :custom => user.id }
    PAYPAL_CONFIG[:url] + '?' + values.to_query
  end
end

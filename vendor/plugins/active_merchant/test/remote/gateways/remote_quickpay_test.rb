require File.dirname(__FILE__) + '/../../test_helper'

if false #Set to true to see traffic against Quickpay on stdout
  module ActiveMerchant
    module PostsData
      def ssl_post_with_logging(url, data, headers = {})
        print "REQUEST", "\n", data, "\n"
        result = ssl_post_without_logging(url, data, headers)
        print "RESPONSE", "\n", result, "\n"

        result
      end

      alias_method :ssl_post_without_logging, :ssl_post
      alias_method :ssl_post, :ssl_post_with_logging
    end
  end
end

class RemoteQuickpayTest < Test::Unit::TestCase
  def setup  
    @gateway = QuickpayGateway.new(fixtures(:quickpay))

    @amount = 100
    @options = { 
      :order_id => generate_unique_id, 
      :billing_address => address
    }
    
    @visa_no_cvv2   = credit_card('4000300011112220', :verification_value => nil)
    @visa           = credit_card('4000100011112224')
    @dankort        = credit_card('5019717010103742')
    @visa_dankort   = credit_card('4571100000000000')
    @electron_dk    = credit_card('4175001000000000')
    @diners_club    = credit_card('30401000000000')
    @diners_club_dk = credit_card('36148010000000')
    @maestro        = credit_card('5020100000000000')
    @maestro_dk     = credit_card('6769271000000000')
    @mastercard_dk  = credit_card('5413031000000000')
    @amex_dk        = credit_card('3747100000000000')
    @amex           = credit_card('3700100000000000')
    
    # forbrugsforeningen doesn't use a verification value
    @forbrugsforeningen = credit_card('6007221000000000', :verification_value => nil)
  end

  #The active merchant generate_order_id in the test_helper generates id's that in cases are more than
  #the 20 char maximum defined by Quickpay
  def generate_order_id
    (Time.now.to_f * 10000).to_i
  end
    
  def test_status
    assert response = @gateway.status
    assert_equal 'PBS status OK', response.message    
  end  
  
  def test_successful_purchase
    assert response = @gateway.purchase(@amount, @visa, @options)
    assert_equal 'OK', response.message
    assert_equal 'DKK', response.params['currency']
    assert_success response
    assert !response.authorization.blank?
  end
  
  def test_successful_usd_purchase
    assert response = @gateway.purchase(@amount, @visa, @options.update(:currency => 'USD'))
    assert_equal 'OK', response.message
    assert_equal 'USD', response.params['currency']
    assert_success response
    assert !response.authorization.blank?
  end
  
  def test_successful_dankort_authorization
    assert response = @gateway.authorize(@amount, @dankort, @options)
    assert_success response
    assert !response.authorization.blank?
    assert_equal 'Dankort', response.params['cardtype']
  end
  
  def test_successful_visa_dankort_authorization
    assert response = @gateway.authorize(@amount, @visa_dankort, @options)
    assert_success response
    assert !response.authorization.blank?
    assert_equal 'Visa-Dankort', response.params['cardtype']
  end
  
  def test_successful_visa_electron_authorization
    assert response = @gateway.authorize(@amount, @electron_dk, @options)
    assert_success response
    assert !response.authorization.blank?
    assert_equal 'Visa-Electron-DK', response.params['cardtype']
  end
  
  def test_successful_diners_club_authorization
    assert response = @gateway.authorize(@amount, @diners_club, @options)
    assert_success response
    assert !response.authorization.blank?
    assert_equal 'Diners', response.params['cardtype']
  end
  
  def test_successful_diners_club_dk_authorization
    assert response = @gateway.authorize(@amount, @diners_club_dk, @options)
    assert_success response
    assert !response.authorization.blank?
    assert_equal 'Diners', response.params['cardtype']
  end
  
  def test_successful_maestro_authorization
    assert response = @gateway.authorize(@amount, @maestro, @options)
    assert_success response
    assert !response.authorization.blank?
    assert_equal 'Maestro', response.params['cardtype']
  end
  
  def test_successful_maestro_dk_authorization
    assert response = @gateway.authorize(@amount, @maestro_dk, @options)
    assert_success response
    assert !response.authorization.blank?
    assert_equal 'Maestro', response.params['cardtype']
  end
  
  def test_successful_mastercard_dk_authorization
    assert response = @gateway.authorize(@amount, @mastercard_dk, @options)
    assert_success response
    assert !response.authorization.blank?
    assert_equal 'MasterCard-DK', response.params['cardtype']
  end
  
  def test_successful_american_express_dk_authorization
    assert response = @gateway.authorize(@amount, @amex_dk, @options)
    assert_success response
    assert !response.authorization.blank?
    assert_equal 'AmericanExpress-DK', response.params['cardtype']
  end

  def test_successful_american_express_authorization
    assert response = @gateway.authorize(@amount, @amex, @options)
    assert_success response
    assert !response.authorization.blank?
    assert_equal 'AmericanExpress', response.params['cardtype']
  end
  
  def test_successful_forbrugsforeningen_authorization
    assert response = @gateway.authorize(@amount, @forbrugsforeningen, @options)
    assert_success response
    assert !response.authorization.blank?
    assert_equal 'FBG-1886', response.params['cardtype']
  end
  
  def test_unsuccessful_purchase_with_missing_cvv2
    assert response = @gateway.purchase(@amount, @visa_no_cvv2, @options)
    assert_equal 'Missing/error in card verification data', response.message
    assert_failure response
    assert response.authorization.blank?
  end

  def test_successful_authorize_and_capture
    assert auth = @gateway.authorize(@amount, @visa, @options)
    assert_success auth
    assert_equal 'OK', auth.message
    assert auth.authorization
    assert capture = @gateway.capture(@amount, auth.authorization)
    assert_success capture
    assert_equal 'OK', capture.message
  end

  def test_failed_capture
    assert response = @gateway.capture(@amount, '')
    assert_failure response
    assert_equal 'Missing/error in transaction number', response.message
  end
  
  def test_successful_purchase_and_void
    assert auth = @gateway.authorize(@amount, @visa, @options)
    assert_success auth
    assert_equal 'OK', auth.message
    assert auth.authorization
    assert void = @gateway.void(auth.authorization)
    assert_success void
    assert_equal 'OK', void.message
  end
  
  def test_successful_authorization_capture_and_credit
    assert auth = @gateway.authorize(@amount, @visa, @options)
    assert_success auth
    assert capture = @gateway.capture(@amount, auth.authorization)
    assert_success capture
    assert credit = @gateway.credit(@amount, auth.authorization)
    assert_success credit
    assert_equal 'OK', credit.message
  end
  
  def test_successful_purchase_and_credit
    assert purchase = @gateway.purchase(@amount, @visa, @options)
    assert_success purchase
    assert credit = @gateway.credit(@amount, purchase.authorization)
    assert_success credit
  end

  def test_invalid_login
    gateway = QuickpayGateway.new(
        :login => '',
        :password => ''
    )
    assert response = gateway.purchase(@amount, @visa, @options)
    assert_equal 'Missing/error in merchant', response.message
    assert_failure response
  end
  
  def test_store
    order_id = generate_order_id
    amount   = @amount
  
    assert init = @gateway.store(@visa_dankort, { :description => 'Some description', :order_id => order_id })
    assert init.success?
    assert_equal 'OK', init.message
    assert init.authorization
  
    assert auth = @gateway.authorize(amount, init.authorization, { :order_id => order_id + 1 })
    assert auth.success?
    assert_equal 'OK', auth.message
    assert auth.authorization
  
    assert capture = @gateway.capture(amount, auth.authorization)
    assert capture.success?
    assert_equal 'OK', capture.message  
  
    assert release = @gateway.void(init.authorization)
    assert release.success?
    assert_equal 'OK', release.message
  
    #Now that the release method has been executed, authorize must fail
    assert auth2 = @gateway.authorize(amount, init.authorization, { :order_id => order_id + 2 })
    assert !auth2.success?
    assert_equal 'Transaction not found', auth2.message    
  
    assert capt2 = @gateway.capture(amount, auth2.authorization)
    assert !capt2.success?
    assert_equal 'Missing/error in transaction number', capt2.message      
  end  
  
  def test_purchase_by_stored_billing_id
    order_id = generate_order_id
    amount   = @amount
  
    assert init = @gateway.store(@visa_dankort, { :description => 'Some description', :order_id => order_id })
    assert init.success?
    assert_equal 'OK', init.message
    assert init.authorization
  
    assert purchase = @gateway.purchase(amount, init.authorization, { :order_id => order_id + 1 })
    assert purchase.success?
    assert_equal 'OK', purchase.message
  end
  
  def test_unsuccessful_purchase_by_stored_billing_id
    order_id = generate_order_id
    amount   = @amount
  
    assert init = @gateway.store(@visa_dankort, { :description => 'Some description', :order_id => order_id })
    assert init.success?
    assert_equal 'OK', init.message
    assert init.authorization
  
    assert purchase = @gateway.purchase(amount, 'invalid_billing_id', { :order_id => order_id + 1 })
    assert !purchase.success?
    assert_equal 'Missing/error in transaction number', purchase.message
  end
    
end

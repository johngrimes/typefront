Factory.define :user do |user|
  user.email 'test@test.com'
  user.password 'password'
  user.password_confirmation 'password'
  user.first_name 'Barry'
  user.last_name 'Bloggs'
  user.address_1 '50 Abalone Avenue'
  user.city 'Gold Coast'
  user.state 'Queensland'
  user.postcode '4216'
  user.country 'Australia'
  user.card_type 'visa'
  user.card_name 'Mr Barry B Bloggs'
  user.card_number '4564621016895669'
  user.card_cvv '376'
  user.card_expiry Time.now
  user.terms '1'
end

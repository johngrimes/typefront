class StrangersController < ApplicationController
  layout 'blank'

  caches_page :all

  def home
    redirect_to '/end'
  end

  def pricing
    redirect_to '/end'
  end

  def terms
  end
end

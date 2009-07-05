class DomainsController < ApplicationController
  def destroy
    @domain = Domain.find(params[:id])
    @font = Font.find(params[:font_id])
    @domain.destroy
    flash[:notice] = "Successfully removed domain from allowed list."
    redirect_to @font
  end
end

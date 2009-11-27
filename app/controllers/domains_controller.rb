class DomainsController < ApplicationController
  def create
    @font = Font.find(params[:font_id])
    @domain = Domain.new(params[:domain])
    @domain.font = @font
    if @domain.save
      flash[:notice] = "Successfully added allowed domain to font."
      respond_to do |format|
        format.json { render :json => { :notice => flash[:notice] }.to_json }
      end
    else
      respond_to do |format|
        format.json { render :json => @domain.errors.to_json, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @domain = Domain.find(params[:id])
    @font = Font.find(params[:font_id])
    @domain.destroy
    flash[:notice] = "Successfully removed domain from allowed list."
    respond_to do |format|
      format.html { redirect_to @font }
      format.json { render :json => { :notice => flash[:notice] }.to_json }
    end
  end
end

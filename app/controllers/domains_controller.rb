class DomainsController < FontsController
  before_filter :require_user

  def create
    @font = current_user.fonts.find(params[:font_id])
    @domain = Domain.new(params[:domain])
    @domain.font = @font
    if @domain.save
      flash[:notice] = "Successfully added allowed domain to font."
      respond_to do |format|
        format.json { render :template => 'domains/show.json.erb' }
      end
    else
      respond_to do |format|
        format.json { render :json => @domain.errors.to_json, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @domain = Domain.find(params[:id])
    @font = current_user.fonts.find(params[:font_id])
    if @font.domains.include?(@domain)
      @domain.destroy
      flash[:notice] = "Successfully removed domain from allowed list."
      respond_to do |format|
        format.html { redirect_to @font }
        format.js do
          get_notices
          render :template => 'fonts/update.js.erb'
        end
        format.json { render :json => { :notice => flash[:notice] }.to_json }
      end
    else
      raise PermissionDenied, 'You do not have permission to perform that action'
    end
  end
end

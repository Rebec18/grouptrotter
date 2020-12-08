class TravelersController < ApplicationController
  def create
    @traveler = Traveler.new(traveler_params)
    @group = Group.find(params[:group_id])
    @traveler.group = @group
    # if @traveler.save
    #   redirect_to group_path(@group)
    # else
    #   render "groups/show"
    # end
    respond_to do |format|
      if @group.save
        # format.html { redirect_to "/pages/home", notice: 'Group was successfully created.' }
        format.js
      else
        format.html { render :new }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def traveler_params
    params.require(:traveler).permit(:name, :fly_from, :price_from, :price_to, :date_from, :date_to)
  end
end

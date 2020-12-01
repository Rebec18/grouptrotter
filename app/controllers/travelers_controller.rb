class TravelersController < ApplicationController

def create
  @traveler = Traveler.new(traveler_params)
  @group = Group.find(params[:group_id])
  @traveler.group = @group
end

private

  def traveler_params
     params.require(:traveler).permit(:name, :fly_from, :price_from, :price_to)
  end

end

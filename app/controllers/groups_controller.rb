class GroupsController < ApplicationController
  
  def new
    @group = Group.new
  end

  def show
    @group = Group.find(params[:id])
    @traveler = Traveler.new
  end

  def create
    @group = Group.new(group_params)
    if @group.save
      redirect_to group_path(@group)
      # on ne sait pas vers où rediriger, on pense qu'il faut en fabriquer une
    else
      render "new"
    end
  end

  private

  def group_params
    params.require(:group).permit(:date_from, :date_to, :fly_to)
  end
end

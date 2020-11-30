class GroupsController < ApplicationController

def show

end

def create
  @group = Group.new(group_params)
  if @group.save
    redirect_to
    #on ne sait pas vers où rediriger, on pense qu'il faut en fabriquer une
  else
    render :root
  end
end

private

  def group_params
     params.require(:group).permit(:date_from, :date_to, :fly_to)
  end

end

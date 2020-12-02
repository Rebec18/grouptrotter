class GroupsController < ApplicationController
  require 'rest-client'
  require 'json'

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
    else
      render "new"
    end
  end

  def search
    @group = Group.find(params[:id])
    response = RestClient.get "https://api.skypicker.com/flights?fly_from=#{@group.travelers.first.fly_from}&fly_to=#{@group.fly_to}&date_from=#{@group.travelers.first.date_from.strftime('%d/%m/%Y')}&date_to=#{@group.travelers.first.date_to.strftime('%d/%m/%Y')}&partner=grouptrottergrouptrotter&v=3&price_from=1&price_to=#{@group.travelers.first.price_to}&curr=EUR"
    @search = JSON.parse(response)["data"]
  end

  private

  def group_params
    params.require(:group).permit(:fly_to)
  end
end

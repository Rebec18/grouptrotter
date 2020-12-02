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

#méthode de recherche de vol
  def search
    @group = Group.find(params[:id])

    @search = []
    #itère sur les différents travelers pour passer en multi recherches
    @group.travelers.each do |traveler|
       #parse des infos de vols
      reponse = RestClient.get "https://api.skypicker.com/flights?fly_from=#{traveler.fly_from}&fly_to=#{@group.fly_to}&date_from=#{@group.date_from.strftime("%d/%m/%Y")}&date_to=#{@group.date_from.strftime("%d/%m/%Y")}&flight_type=return&return_from=#{@group.date_to.strftime("%d/%m/%Y")}&return_to=#{@group.date_to.strftime("%d/%m/%Y")}&price_from=1&price_to=#{traveler.price_to}&direct_flights=1&partner=grouptrottergrouptrotter&v=3&curr=EUR"
      @search << JSON.parse(reponse)["data"]
    end

    #LA BONNE URL https://api.skypicker.com/flights?fly_from=#{@group.travelers.first.fly_from}&fly_to=#{@group.fly_to}&date_from=#{@group.date_from.strftime("%d/%m/%Y")}&date_to=#{@group.date_from.strftime("%d/%m/%Y")}&flight_type=return&return_from=#{@group.date_to.strftime("%d/%m/%Y")}&return_to=#{@group.date_to.strftime("%d/%m/%Y")}&price_from=1&price_to=#{@group.travelers.first.price_to}&direct_flights=1&partner=grouptrottergrouptrotter&v=3&curr=EUR
    # test = RestClient.get "https://api.skypicker.com/flights?fly_from=MRS&fly_to=ORY&date_from=12/12/2020&date_to=12/12/2020&flight_type=return&return_from=14/12/2020&return_to=14/12/2020&price_from=1&price_to=300&direct_flights=1&partner=grouptrottergrouptrotter&v=3&curr=EUR"
  end

  private

  def group_params
    params.require(:group).permit(:fly_to)
  end
end

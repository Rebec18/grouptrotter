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
    #création d'un tableau avec l'ensemble des données des voyageurs
    #itère sur les différents travelers pour passer en multi recherches

    @travelers_ar = {}

    @group.travelers.each do |traveler|
      @search_a = []
      @search_r = []

       #parse des infos de vols
        aller = RestClient.get "https://api.skypicker.com/flights?fly_from=#{traveler.fly_from}&fly_to=#{@group.fly_to}&date_from=#{traveler.date_from.strftime("%d/%m/%Y")}&date_to=#{traveler.date_from.strftime("%d/%m/%Y")}&price_from=1&price_to=#{traveler.price_to}&direct_flights=1&partner=grouptrottergrouptrotter&v=3&curr=EUR"
        @search_a << JSON.parse(aller)["data"]

        @search_a.first.each do |hash|
          retour = RestClient.get "https://api.skypicker.com/flights?fly_from=#{hash["flyTo"]}&fly_to=#{traveler.fly_from}&date_from=#{traveler.date_to.strftime("%d/%m/%Y")}&date_to=#{traveler.date_to.strftime("%d/%m/%Y")}&price_from=1&price_to=#{traveler.price_to}&direct_flights=1&partner=grouptrottergrouptrotter&v=3&curr=EUR"
          bertrand = JSON.parse(retour)["data"]
          @search_r << bertrand unless bertrand == []
        end

        search_r_desti = []
        @search_r.each do |hash|
          search_r_desti << hash.first["cityFrom"]
        end

      @search_a = @search_a[0].select { |hash| search_r_desti.include?(hash["cityTo"]) }

      @travelers_ar[traveler.id] = [@search_a, @search_r]
    end

    #test avec la bonne url "https://tequila-api.kiwi.com/v2/search?apikey=dA_ZyNbfWwC6tB6h1iwevDVUybsLVp4U&fly_from=MRS&fly_to=europe&date_from=12/12/2020&date_to=12/12/2020&flight_type=round&return_from=14/12/2020&return_to=14/12/2020&price_from=1&price_to=300&direct_flights=1&partner=grouptrottergrouptrotter&v=3&curr=EUR"
    #LA BONNE URL "https://api.skypicker.com/flights?fly_from=#{traveler.fly_from}&fly_to=#{@group.fly_to}&date_from=#{traveler.date_from.strftime("%d/%m/%Y")}&date_to=#{traveler.date_from.strftime("%d/%m/%Y")}&flight_type=return&return_from=#{traveler.date_to.strftime("%d/%m/%Y")}&return_to=#{traveler.date_to.strftime("%d/%m/%Y")}&price_from=1&price_to=#{traveler.price_to}&direct_flights=1&partner=grouptrottergrouptrotter&v=3&curr=EUR"
    # test = RestClient.get "https://api.skypicker.com/flights?fly_from=MRS&fly_to=ORY&date_from=12/12/2020&date_to=12/12/2020&flight_type=return&return_from=14/12/2020&return_to=14/12/2020&price_from=1&price_to=300&direct_flights=1&partner=grouptrottergrouptrotter&v=3&curr=EUR"
  end

  private

  def group_params
    params.require(:group).permit(:fly_to)
  end
end

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

  # méthode de recherche de vol

  def search
    @group = Group.find(params[:id])
    # création d'un tableau avec l'ensemble des données des voyageurs
    # itère sur les différents travelers pour passer en multi recherches

    @big_hash = {}

    @group.travelers.each do |traveler|
      @search_a = []
      @search_r = []

      # parse des infos de vols
      aller = RestClient.get "https://api.skypicker.com/flights?fly_from=#{traveler.fly_from}&fly_to=#{@group.fly_to}&date_from=#{traveler.date_from.strftime('%d/%m/%Y')}&date_to=#{traveler.date_from.strftime('%d/%m/%Y')}&price_from=1&price_to=#{traveler.price_to}&direct_flights=1&partner=grouptrottergrouptrotter&v=3&curr=EUR"
      robert = JSON.parse(aller)["data"]
      robert.each do |hash|
        subhash = {}
        subhash["cityFrom"] = hash["cityFrom"]
        subhash["cityTo"] = hash["cityTo"]
        # flyFrom et flyTo sont les codes IATA
        subhash["flyFrom"] = hash["flyFrom"]
        subhash["flyTo"] = hash["flyTo"]
        # subhash["price"] = hash["price"]
        # subhash["dTime"] = hash["dTime"]
        # subhash["aTime"] = hash["aTime"]
        # subhash["airlines"] = hash["airlines"]
        # subhash["latFrom"] = hash["route"].first["latFrom"]
        # subhash["latTo"] = hash["route"].first["latTo"]
        @search_a << subhash
      end
      # end
      # robert est l'aller, bertrand le retour
      @search_a.each do |subhash|
        retour = RestClient.get "https://api.skypicker.com/flights?fly_from=#{subhash['flyTo']}&fly_to=#{traveler.fly_from}&date_from=#{traveler.date_to.strftime('%d/%m/%Y')}&date_to=#{traveler.date_to.strftime('%d/%m/%Y')}&price_from=1&price_to=#{traveler.price_to}&direct_flights=1&partner=grouptrottergrouptrotter&v=3&curr=EUR"
        # bertrand est un array contenant tous les hash de résultats
        bertrand = JSON.parse(retour)["data"]
        # on fait un sous hash avec les données dont on a besoin
        # next unless bertrand != []
        bertrand.each do |hash|
          subhash = {}
          subhash["cityFrom"] = hash["cityFrom"]
          subhash["cityTo"] = hash["cityTo"]
          # subhash["flyFrom"] = hash["flyFrom"]
          # subhash["flyTo"] = hash["flyTo"]
          # subhash["price"] = hash["price"]
          # subhash["dTime"] = hash["dTime"]
          # subhash["aTime"] = hash["aTime"]
          # subhash["airlines"] = hash["airlines"]
          # subhash["latFrom"] = hash["route"].first["latFrom"]
          # subhash["latTo"] = hash["route"].first["latTo"]
          @search_r << subhash
        end
      end

      search_r_desti = []
      @search_r.each do |hash|
        search_r_desti << hash["cityFrom"]
      end

      @search_a = @search_a.select { |hash| search_r_desti.include?(hash["cityTo"]) }

      @big_hash[traveler.id] = [@search_a, @search_r]
    end

    # test avec la bonne url "https://tequila-api.kiwi.com/v2/search?apikey=dA_ZyNbfWwC6tB6h1iwevDVUybsLVp4U&fly_from=MRS&fly_to=europe&date_from=12/12/2020&date_to=12/12/2020&flight_type=round&return_from=14/12/2020&return_to=14/12/2020&price_from=1&price_to=300&direct_flights=1&partner=grouptrottergrouptrotter&v=3&curr=EUR"
    # LA BONNE URL "https://api.skypicker.com/flights?fly_from=#{traveler.fly_from}&fly_to=#{@group.fly_to}&date_from=#{traveler.date_from.strftime("%d/%m/%Y")}&date_to=#{traveler.date_from.strftime("%d/%m/%Y")}&flight_type=return&return_from=#{traveler.date_to.strftime("%d/%m/%Y")}&return_to=#{traveler.date_to.strftime("%d/%m/%Y")}&price_from=1&price_to=#{traveler.price_to}&direct_flights=1&partner=grouptrottergrouptrotter&v=3&curr=EUR"
    # test = RestClient.get "https://api.skypicker.com/flights?fly_from=MRS&fly_to=ORY&date_from=12/12/2020&date_to=12/12/2020&flight_type=return&return_from=14/12/2020&return_to=14/12/2020&price_from=1&price_to=300&direct_flights=1&partner=grouptrottergrouptrotter&v=3&curr=EUR"
  end

  private

  def group_params
    params.require(:group).permit(:fly_to)
  end
end

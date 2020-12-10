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

  # LE SEARCH AVEC LE SEED
  def searchLEVRAI
    @final_hash = JSON.parse(File.read("unseed.json"))
  end

  # LE VRAI SEARCH QU'ON REMETTRA APRES
  def search
    @group = Group.find(params[:id])
    fill_trips(@group)
  end

  # on ajoute une route vers les tickets
  def tickets
    @group = Group.find(params[:id])
    fat_hash = {}
    fill_trips_tickets(@group)
    #  if @trips.nil?
    # @group.cities.each do |_city|
    #   @group.travelers.each do |traveler|
    #     bertrand = []
    #     allerretour = RestClient.get "https://api.skypicker.com/flights?fly_from=#{traveler.fly_from.gsub(/.+\((\w{3})\)$/, '\1')}&fly_to=#{@trips.values.first[_city][0][0][:flyTo]}&date_from=#{traveler.date_from.strftime('%d/%m/%Y')}&date_to=#{traveler.date_from.strftime('%d/%m/%Y')}&return_from=#{traveler.date_to.strftime('%d/%m/%Y')}&return_to=#{traveler.date_to.strftime('%d/%m/%Y')}&price_from=1&price_to=#{traveler.price_to}&direct_flights=1&partner=grouptrottergrouptrotter&v=3&curr=EUR&flight_type=return"
    #     big_bertrand = JSON.parse(allerretour)["data"]
    #     big_bertrand.each do |hash|
    #       # ici le hash est un hash d'un vol
    #       subhash = {}
    #       subhash[:cityFrom] = hash["cityFrom"]
    #       subhash[:cityTo] = hash["cityTo"]
    #       subhash[:flyFrom] = hash["flyFrom"]
    #       subhash[:flyTo] = hash["flyTo"]
    #       subhash[:price] = hash["price"]
    #       subhash[:dTime] = hash["dTime"]
    #       subhash[:aTime] = hash["aTime"]
    #       subhash[:airlines] = hash["airlines"]
    #       subhash[:latFrom] = hash["route"].first["latFrom"]
    #       subhash[:latTo] = hash["route"].first["latTo"]
    #       subhash[:url] = hash["deep_link"]
    #       subhash[:country] = hash["countryTo"]["name"]
    #       bertrand << subhash
    #     end
    #     fat_hash[traveler] = bertrand
      # end
      # On a rempli fat_hash avec tous les travelers pour une city
    # end
    # On l'a rempli avec toutes les cities
  end

  
  private


  def group_params
    params.require(:group).permit(:fly_to, :cities)
  end



  def fill_trips(_group)
    @final_hash = {}
    @semitraveler_count = 0
    _group.travelers.each do |traveler|
      bertrand = []
      full_user = {}
      if _group.fly_to == "\u{1F30D} Toutes destinations"
        destination_point = ""
      else
        destination_point = _group.fly_to.gsub(/.+\((\w{3})\)$/, '\1')
      end
      allerjson = RestClient.get "https://api.skypicker.com/flights?fly_from=#{traveler.fly_from.gsub(/.+\((\w{3})\)$/, '\1')}&fly_to=#{destination_point}&date_from=#{traveler.date_from.strftime('%d/%m/%Y')}&date_to=#{traveler.date_from.strftime('%d/%m/%Y')}&price_from=1&price_to=#{traveler.price_to}&direct_flights=1&partner=grouptrottergrouptrotter&v=3&curr=EUR"
      big_bertrand = JSON.parse(allerjson)["data"]
      break if big_bertrand == []
      @semitraveler_count += 1
      big_bertrand.each do |hash|
        subhash = {}
        subhash[:cityFrom] = hash["cityFrom"]
        subhash[:cityTo] = hash["cityTo"]
        subhash[:flyFrom] = hash["flyFrom"]
        subhash[:flyTo] = hash["flyTo"]
        subhash[:price] = hash["price"]
        subhash[:dTime] = hash["dTime"]
        subhash[:aTime] = hash["aTime"]
        subhash[:airlines] = hash["airlines"]
        subhash[:latFrom] = hash["route"].first["latFrom"]
        subhash[:latTo] = hash["route"].first["latTo"]
        subhash[:url] = hash["deep_link"]
        subhash[:country] = hash["countryTo"]["name"]
        bertrand << subhash
      end
      bertrand_cities = []
      convertisseur_city_iata_le_truc_que_farouk_et_claire_voulaient_pas_faire = {}
      bertrand.each do |aller|
        unless bertrand_cities.include?(aller[:cityTo])
          bertrand_cities << aller[:cityTo]
          convertisseur_city_iata_le_truc_que_farouk_et_claire_voulaient_pas_faire[aller[:cityTo]] = aller[:flyTo]
        end
      end
      bertrand_cities.each do |city|
        if @final_hash.keys.count > 0
          first_cities = @final_hash.values.last.keys
          next unless first_cities.include?(city)
        end
        robert = []
        retours = RestClient.get "https://api.skypicker.com/flights?fly_from=#{convertisseur_city_iata_le_truc_que_farouk_et_claire_voulaient_pas_faire[city]}&fly_to=#{traveler.fly_from.gsub(/.+\((\w{3})\)$/, '\1')}&date_from=#{traveler.date_to.strftime('%d/%m/%Y')}&date_to=#{traveler.date_to.strftime('%d/%m/%Y')}&price_from=1&price_to=#{traveler.price_to}&direct_flights=1&partner=grouptrottergrouptrotter&v=3&curr=EUR"
        big_robert = JSON.parse(retours)["data"]
        big_robert.each do |hash|
          subhash = {}
          subhash[:cityFrom] = hash["cityFrom"]
          subhash[:cityTo] = hash["cityTo"]
          subhash[:flyFrom] = hash["flyFrom"]
          subhash[:flyTo] = hash["flyTo"]
          subhash[:price] = hash["price"]
          subhash[:dTime] = hash["dTime"]
          subhash[:aTime] = hash["aTime"]
          subhash[:airlines] = hash["airlines"]
          subhash[:latFrom] = hash["route"].first["latFrom"]
          subhash[:latTo] = hash["route"].first["latTo"]
          subhash[:url] = hash["deep_link"]
          subhash[:country] = hash["countryTo"]["name"]
          robert << subhash
        end
        next unless robert != []
        array_allers_for_city = []
        bertrand.each do |aller|
          array_allers_for_city << aller if aller[:cityTo] == city
        end
        noemie = [array_allers_for_city, robert]
        full_user[city] = noemie unless noemie.nil?
      end
      break if full_user == {}
      @final_hash[traveler] = full_user
      @semitraveler_count += 1
    end
    if @final_hash.keys.count > 1
      @common_cities = @final_hash[_group.travelers.last].keys
      @final_hash.each_value do |fulluser|
        fulluser.each_key do |ville|
          fulluser.delete(ville) unless @common_cities.include?(ville)
        end
      end
    end
    @trips = @final_hash
    @travelers = @trips.keys
    _group.cities = @trips.values.first.keys
  end



  def fill_trips_tickets(_group)
    @fat_hash = {}
    @traveler_count = 0
    _group.travelers.each do |traveler|
      bertrand = []
      full_user = {}
      destination_point = params["airport"]
      allerretour = RestClient.get "https://api.skypicker.com/flights?fly_from=#{traveler.fly_from.gsub(/.+\((\w{3})\)$/, '\1')}&fly_to=#{destination_point}&date_from=#{traveler.date_from.strftime('%d/%m/%Y')}&date_to=#{traveler.date_from.strftime('%d/%m/%Y')}&return_from=#{traveler.date_to.strftime('%d/%m/%Y')}&return_to=#{traveler.date_to.strftime('%d/%m/%Y')}&price_from=1&price_to=#{traveler.price_to}&direct_flights=1&partner=grouptrottergrouptrotter&v=3&curr=EUR&flight_type=return"
      big_bertrand = JSON.parse(allerretour)["data"]
      break if big_bertrand == []
      @traveler_count += 1
      big_bertrand.each do |hash|
        subhash = {}
        subhash[:cityFrom] = hash["cityFrom"]
        subhash[:cityTo] = hash["cityTo"]
        subhash[:flyFrom] = hash["flyFrom"]
        subhash[:flyTo] = hash["flyTo"]
        subhash[:price] = hash["price"]
        subhash[:dTime] = hash["route"].first["dTime"]
        subhash[:aTime] = hash["route"].first["aTime"]
        subhash[:dTimeReturn] = hash["route"].last["dTime"]
        subhash[:aTimeReturn] = hash["route"].last["aTime"]
        subhash[:airlines] = hash["airlines"]
        subhash[:latFrom] = hash["route"].first["latFrom"]
        subhash[:latTo] = hash["route"].first["latTo"]
        subhash[:latFromReturn] = hash["route"].last["latFrom"]
        subhash[:latToReturn] = hash["route"].last["latTo"]
        subhash[:url] = hash["deep_link"]
        subhash[:country] = hash["countryTo"]["name"]
        subhash[:fly_duration] = hash["fly_duration"]
        subhash[:return_duration] = hash["return_duration"]
        bertrand << subhash
      end
      @fat_hash[traveler] = bertrand
    end
    
  end
end

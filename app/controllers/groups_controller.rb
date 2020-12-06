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
    #création d'un tableau avec l'ensemble des données des voyageurs
    #itère sur les différents travelers pour passer en multi recherches

    @final_hash = {}
    @semitraveler_count = 0

    @group.travelers.each do |traveler|
      @bertrand = []
      @full_user = {}

      # parse des infos de vols
      allerjson = RestClient.get "https://api.skypicker.com/flights?fly_from=#{traveler.fly_from}&fly_to=#{@group.fly_to}&date_from=#{traveler.date_from.strftime('%d/%m/%Y')}&date_to=#{traveler.date_from.strftime('%d/%m/%Y')}&price_from=1&price_to=#{traveler.price_to}&direct_flights=1&partner=grouptrottergrouptrotter&v=3&curr=EUR"
      big_bertrand = JSON.parse(allerjson)["data"]
      # big_bertrand est l'array des allers parsés
      if big_bertrand == []
        break
      end
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
        # bertrand c'est bébé big_bertrand (big_bertrand mais qu'avec infos utiles)
        # c'est un array contenant les allers
        @bertrand << subhash
      end
      

      bertrand_cities = []
      convertisseur_city_iata_le_truc_que_farouk_et_claire_voulaient_pas_faire = {}

      @bertrand.each do |aller|
        unless bertrand_cities.include?(aller[:cityTo])
        bertrand_cities << aller[:cityTo]
        convertisseur_city_iata_le_truc_que_farouk_et_claire_voulaient_pas_faire[aller[:cityTo]] = aller[:flyTo]
        end
      end

            # pour chaque ville de destination :
      bertrand_cities.each do |city|

        # on vérifie d'abord si la city est bien dans la liste des cities de traveler1
        # pour éviter des parsing superflus
        if @final_hash.keys.count > 0
          first_cities = @final_hash.values.first.keys
          ii = 1
          while ii < @final_hash.keys.count
            first_cities = first_cities & @final_hash.values[ii].keys
            ii += 1
          end
          # ici on obetient la liste de destinations communes à tous les travelers
          unless first_cities.include?(city)
            next
          end
        end
        # fin de la vérification

        @robert = []
        retours = RestClient.get "https://api.skypicker.com/flights?fly_from=#{convertisseur_city_iata_le_truc_que_farouk_et_claire_voulaient_pas_faire[city]}&fly_to=#{traveler.fly_from}&date_from=#{traveler.date_to.strftime('%d/%m/%Y')}&date_to=#{traveler.date_to.strftime('%d/%m/%Y')}&price_from=1&price_to=#{traveler.price_to}&direct_flights=1&partner=grouptrottergrouptrotter&v=3&curr=EUR"
        # big_robert est un array contenant tous les hash de résultats
        big_robert = JSON.parse(retours)["data"]
        
        # on fait un sous hash avec les données dont on a besoin
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
          @robert << subhash
        end
        
      # on a un robert propre qui est un array de retours(hashes)
        if @robert != []

          # si robert n'est pas vide alors on a des retours et donc
          # on va créer un array (noemie) avec en premier élément l'array des allers pour city
          # et en deuxième l'array des retours depuis city

          # d'abord on construit l'array des allers pour la city
          array_allers_for_city = []
          @bertrand.each do |aller|
            array_allers_for_city << aller if aller[:cityTo] == city
          end

          noemie = [array_allers_for_city, @robert]

        # on a un array (noemie) : allers, retours 
        # pour chaque ville
        # on le fout dans @full_user avec la key city
        @full_user[city] = noemie unless noemie == nil
        end


      end
      # ON SORT DE LA BOUCLE SUR CITY
      # on a rempli le full@user pour le traveler

      # on raccourcit bertrand_cities si jamais y en a sans vol
      # reducing = []
      # @full_user.each do |bignoemie|
      #   reducing << bignoemie.keys.first
      # end
      # bertrand_cities = bertrand_cities & reducing
      
      # on vérifie si full_user n'est pas vide (sinon faudra dire que la recherche a échoué)
      @semitraveler_count += 1 if @full_user.keys.count != 0


      # on veut ajouter au final_hash la key value : traveler => @full_user
      @final_hash[traveler] = @full_user unless @full_user == {}
    
    end
    # FIN DE LA BOUCLE SUR LE TRAVELER

    # maintenant on cherche les villes communes
    # sachant que par construction c'est le dernier traveler
    # qui aura en keys les villes communes
    # il reste à supprimer des travelers les noemies qui sont dans des cities pas communes
     
    if @final_hash.keys.count > 1
      @common_cities = @final_hash[@group.travelers.last].keys

      @final_hash.each_value do |fulluser|
        fulluser.each_key do |ville|
          fulluser.delete(ville) unless @common_cities.include?(ville)
        end
      end

    end
      # on a le final hash bon
raise

      # les données qu'on peut récupérer :
      # liste des villes communes :
      # @final_hash.values.last.keys
      # l'array des allers, retours du traveler i pour la ville city :
      # @final_hash[@group.travelers[i]][city]
      # = [ [aller1, aller2, ...], [retour1, ...]]



    #test avec la bonne url "https://tequila-api.kiwi.com/v2/search?apikey=dA_ZyNbfWwC6tB6h1iwevDVUybsLVp4U&fly_from=MRS&fly_to=europe&date_from=12/12/2020&date_to=12/12/2020&flight_type=round&return_from=14/12/2020&return_to=14/12/2020&price_from=1&price_to=300&direct_flights=1&partner=grouptrottergrouptrotter&v=3&curr=EUR"
    #LA BONNE URL "https://api.skypicker.com/flights?fly_from=#{traveler.fly_from}&fly_to=#{@group.fly_to}&date_from=#{traveler.date_from.strftime("%d/%m/%Y")}&date_to=#{traveler.date_from.strftime("%d/%m/%Y")}&flight_type=return&return_from=#{traveler.date_to.strftime("%d/%m/%Y")}&return_to=#{traveler.date_to.strftime("%d/%m/%Y")}&price_from=1&price_to=#{traveler.price_to}&direct_flights=1&partner=grouptrottergrouptrotter&v=3&curr=EUR"
    # test = RestClient.get "https://api.skypicker.com/flights?fly_from=MRS&fly_to=ORY&date_from=12/12/2020&date_to=12/12/2020&flight_type=return&return_from=14/12/2020&return_to=14/12/2020&price_from=1&price_to=300&direct_flights=1&partner=grouptrottergrouptrotter&v=3&curr=EUR"
  end

#on ajoute une route vers les tickets
  def tickets

  end

  private

  def group_params
    params.require(:group).permit(:fly_to)
  end
end

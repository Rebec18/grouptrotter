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
    fill_trips(@group) if @trips.nil?
    @group.cities.each do |_city|
      @group.travelers.each do |traveler|
        bertrand = []
        allerretour = RestClient.get "https://api.skypicker.com/flights?fly_from=#{traveler.fly_from.gsub(/.+\((\w{3})\)$/, '\1')}&fly_to=#{@trips.values.first[_city][0][0][:flyTo]}&date_from=#{traveler.date_from.strftime('%d/%m/%Y')}&date_to=#{traveler.date_from.strftime('%d/%m/%Y')}&return_from=#{traveler.date_to.strftime('%d/%m/%Y')}&return_to=#{traveler.date_to.strftime('%d/%m/%Y')}&price_from=1&price_to=#{traveler.price_to}&direct_flights=1&partner=grouptrottergrouptrotter&v=3&curr=EUR&flight_type=return"
        big_bertrand = JSON.parse(allerretour)["data"]
        big_bertrand.each do |hash|
          # ici le hash est un hash d'un vol
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
        fat_hash = {}
        fat_hash[traveler] = bertrand
      end
      # On a rempli fat_hash avec tous les travelers pour une city
    end
    # On l'a rempli avec toutes les cities
  end

  private

  def group_params
    params.require(:group).permit(:fly_to, :cities)
  end

  def fill_trips(_group)
    # création d'un tableau avec l'ensemble des données des voyageurs
    # itère sur les différents travelers pour passer en multi recherches

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

      # parse des infos de vols
      allerjson = RestClient.get "https://api.skypicker.com/flights?fly_from=#{traveler.fly_from.gsub(/.+\((\w{3})\)$/, '\1')}&fly_to=#{destination_point}&date_from=#{traveler.date_from.strftime('%d/%m/%Y')}&date_to=#{traveler.date_from.strftime('%d/%m/%Y')}&price_from=1&price_to=#{traveler.price_to}&direct_flights=1&partner=grouptrottergrouptrotter&v=3&curr=EUR"
      big_bertrand = JSON.parse(allerjson)["data"]
      # big_bertrand est l'array des allers parsés (les allers sont des hashs).

      # S'il est vide alors pas de vol et donc on stoppe tout !!!
      break if big_bertrand == []

      # S'il n'est pas vide alors ok on a passé une étape. On augmente notre compteur
      # qui va nous permettre de savoir à la fin si toutes les étapes ont été passées.
      @semitraveler_count += 1

      # On rétrécit big_bertrand il est trop gros.
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
      # Super, on a bertrand qui contient tous les allers mais qu'avec les infos utiles.

      # On récupère la liste des villes de destination dans bertrand.
      bertrand_cities = []
      convertisseur_city_iata_le_truc_que_farouk_et_claire_voulaient_pas_faire = {}

      bertrand.each do |aller|
        # Le unless ci-dessous sert à ne pas remplir l'array plusieurs fois avec la même ville
        # car dans bertrand il y a plusieurs vols pour la même destination.
        unless bertrand_cities.include?(aller[:cityTo])
          bertrand_cities << aller[:cityTo]
          convertisseur_city_iata_le_truc_que_farouk_et_claire_voulaient_pas_faire[aller[:cityTo]] = aller[:flyTo]
        end
      end
      # Ok, on a un array avec les villes de destination : bertrand_cities

      # On va maintenant itérer sur les villes de destination. Cette boucle va être longue.
      # Garder en tête durant la suite (tant qu'on sort pas de la boucle des villes)
      # que nous sommes dans le cas où on a une city en particulier. Par exemple Madrid.
      bertrand_cities.each do |city|
        # Avant de parser on veut surtout pas parser pour rien.
        # Le if suivant permet vérifier si la city qu'on va parser
        # est potentiellement une city commune ou pas.
        # Si par exemple on a déjà un traveler parsé et que dans
        # sa liste de villes de destination on n'a PAS Madrid, alors Madrid ne sera pas
        # une ville qu'on veut parser ! Car elle ne sera pas une ville commune.
        if @final_hash.keys.count > 0
          # (Dans le cas où on a déjà parsé au moins un traveler)

          # On récupère l'array des villes du dernier traveler parsé.
          first_cities = @final_hash.values.last.keys

          # Et si jamais la city (Madrid) n'est pas dedans, on NEXT la boucle car ce sera jamais une ville commune.
          # On ne veut surtout pas passer au parsing, on veut NEXT la boucle pour passer à la prochaine city.
          # Donc on next, sauf si Madrid est dans l'array des villes du dernier traveler.
          next unless first_cities.include?(city)

        end
        # Fin de la vérification. On ne va parser que ce qui est utile.

        # On initialise un array robert qu'on replira des vols retours depuis la city (Madrid).
        robert = []
        # On parse les retours.
        retours = RestClient.get "https://api.skypicker.com/flights?fly_from=#{convertisseur_city_iata_le_truc_que_farouk_et_claire_voulaient_pas_faire[city]}&fly_to=#{traveler.fly_from.gsub(/.+\((\w{3})\)$/, '\1')}&date_from=#{traveler.date_to.strftime('%d/%m/%Y')}&date_to=#{traveler.date_to.strftime('%d/%m/%Y')}&price_from=1&price_to=#{traveler.price_to}&direct_flights=1&partner=grouptrottergrouptrotter&v=3&curr=EUR"
        big_robert = JSON.parse(retours)["data"]
        # On obtient big_robert qui contient tous les retours... mais avec trop d'infos !
        # On le réduit pour pas se le trimballer inutilement.
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
        # On a un robert clean. C'est un array des retours (hashes) depuis Madrid.

        # Il arrive qu'il n'y ait pas de retours. Et alors on fait rien de spécial, on veut pas remplir le final_hash.
        # Par contre s'il y a des retours on veut remplir le final_hash.
        next unless robert != []

        # On va créer un array (noemie) qui contiendra les allers et les retours.
        # noemie = [ [ allers pour Madrid (hashes)], [ retours de Madrid (hashes)]]
        # Sachant qu'on a déjà la liste des retours, c'est robert.
        # Donc on veut surtout récupérer la liste des allers pour Madrid.

        array_allers_for_city = []
        bertrand.each do |aller|
          # Rappel : bertrand contient tous les allers, toute ville confondue
          # et on veut seulement les allers pour Madrid.

          array_allers_for_city << aller if aller[:cityTo] == city
          # On remplit l'array avec les allers de bertrand seulement sur leur cityTo est bien Madrid.
        end

        # C'est bon on peut remplir noemie avec les [allers, retours] pour Madrid.
        noemie = [array_allers_for_city, robert]

        # On a noemie avec les allers retours pour Madrid.
        # C'est bon, on la fout dans le hash full_user avec comme clé : Madrid (city).
        full_user[city] = noemie unless noemie.nil?
        # (Sauf si noemie est vide, car ça arrive...)

        # Super, on a une nouvelle entrée dans full_user :
        # Madrid => [ [allers], [retours] ]

        # On va faire pareil pour chaque ville. Sortons de la boucle.
      end
      # ===== ON SORT DE LA BOUCLE DES VILLES =====

      #  On a tout fait pour chaque ville !
      # Ainsi on a rempli le hash full_user avec toutes les villes en clés.
      # Et en valeurs les [allers, retours] pour la ville en clé. On a :

      # full_user = { "Madrid" => [allers, retours] , "London" => [allers, retours] , ... }

      # On a le enfin full_user pour le premier traveler.
      # On se dépêche de remplir le final_hash avec la key-value : traveler => full_user.

      # Mais avant attention, il se peut que le full_user soit vide ! (je crois ???)
      # Dans le cas où il est vide ça veut dire que le user n'a aucun vol.
      # Et alors le trip échoue ! Et il faut absolument sortir de cette boucle infernale.
      # ON BREAK LA BOUCLE SUR LES TRAVELERS DE SUITE !
      break if full_user == {}

      # Si ça n'a pas break c'est bon on remplit tranquillement le final_hash avec le full_user.
      @final_hash[traveler] = full_user

      # On a passé une étape décisive, on augmente le compteur qui nous dira à la fin si on a bien
      # passé toutes les étapes et donc que le trip n'a pas échoué.
      @semitraveler_count += 1
    end
    # ===== FIN DE LA BOUCLE SUR LE TRAVELER =====

    # Dernier soucis, c'est que lorsqu'on a construit les full_user
    # des premiers travelers (avec les villes et aller-retous), on ne savait
    # pas encore quelles seraient les villes de destination communes à tout le monde...
    # Donc les premiers travelers ont des villes EN TROP.
    # Il faut immédiatement trouver les villes communes pour supprimer les vols en trop.

    # Facile, le dernier traveler les connait !
    # Car à chaque nouveau traveler on ne gardait que les villes communes
    # avec le traveler précédent... le dernier traveler n'a donc que les villes communes à tous !
    # On les récupère dans les clés de son full_user :

    # (Le if pour pas que ça fasse une ERREUR si le final_hash n'a pas été rempli (dans le cas où le trip a échoué).)
    if @final_hash.keys.count > 1

      @common_cities = @final_hash[_group.travelers.last].keys
      # On obtient les villes de destination communes.

      # On veut virer des full_user les vols qui ne sont pas en direction de ces villes.
      @final_hash.each_value do |fulluser|
        # (On itère sur chaque valeur du final_hash, donc sur chaque full_user.)

        fulluser.each_key do |ville|
          # (Et maintenant on itère sur chaque clé du full_user, donc chaque ville.)

          fulluser.delete(ville) unless @common_cities.include?(ville)
          # BAM, ça jarte ! (sauf si la ville est bien dans les destinations communes)
        end
      end

    end

    # On a épuré le final_hash. Il est maintenant complet et sans vols en trop.

    # pour créer le seed
    # File.open("unseed.json", "wb") do |file|
    #   file.write(JSON.pretty_generate(@final_hash))
    # end

    # Remarque :

    # Pour récupérer la liste des villes communes :
    # @final_hash.values.last.keys

    # Pour récupérer l'array des allers-retours du traveler i pour la ville city :
    # @final_hash[_group.travelers[i]][city]
    # = [ [aller1, aller2, ...], [retour1, ...] ]

    # CES TESTS CI-DESSOUS C'EST A QUI ???? VIREZ-LE SVP MDRRRRR
    # test avec la bonne url "https://tequila-api.kiwi.com/v2/search?apikey=dA_ZyNbfWwC6tB6h1iwevDVUybsLVp4U&fly_from=MRS&fly_to=europe&date_from=12/12/2020&date_to=12/12/2020&flight_type=round&return_from=14/12/2020&return_to=14/12/2020&price_from=1&price_to=300&direct_flights=1&partner=grouptrottergrouptrotter&v=3&curr=EUR"
    # LA BONNE URL "https://api.skypicker.com/flights?fly_from=#{traveler.fly_from}&fly_to=#{@group.fly_to}&date_from=#{traveler.date_from.strftime("%d/%m/%Y")}&date_to=#{traveler.date_from.strftime("%d/%m/%Y")}&flight_type=return&return_from=#{traveler.date_to.strftime("%d/%m/%Y")}&return_to=#{traveler.date_to.strftime("%d/%m/%Y")}&price_from=1&price_to=#{traveler.price_to}&direct_flights=1&partner=grouptrottergrouptrotter&v=3&curr=EUR"
    # test = RestClient.get "https://api.skypicker.com/flights?fly_from=MRS&fly_to=ORY&date_from=12/12/2020&date_to=12/12/2020&flight_type=return&return_from=14/12/2020&return_to=14/12/2020&price_from=1&price_to=300&direct_flights=1&partner=grouptrottergrouptrotter&v=3&curr=EUR"
    @trips = @final_hash
    @travelers = @trips.keys
    # @cities = @trips.values.first.keys
    _group.cities = @trips.values.first.keys
  end
end

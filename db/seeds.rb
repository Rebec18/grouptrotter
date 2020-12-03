# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
require 'date'
require 'json'
require 'rest-client'


Traveler.destroy_all
Group.destroy_all

depart = DateTime.new(2020, 12, 12).strftime("%d/%m/%Y")
arrivee = DateTime.new(2020, 12, 21).strftime("%d/%m/%Y")
depart1 = DateTime.new(2021, 2, 8).strftime("%d/%m/%Y")
arrivee1 = DateTime.new(2021, 2, 14).strftime("%d/%m/%Y")

group_friends = Group.create!(fly_to: "Mykonos")
group_family = Group.create!(fly_to: "Toutes destinations")

claire = Traveler.create!(name:"Claire", fly_from: "Rennes", price_from: 1, price_to: 3000, group: group_friends, date_from: depart, date_to: arrivee)
farouk = Traveler.create!(name:"Farouk", fly_from: "Nice", price_from: 1, price_to: 500, group: group_friends, date_from: depart, date_to: arrivee)
mateo = Traveler.create!(name:"Matéo", fly_from: "Marseille", price_from: 1, price_to: 200, group: group_friends, date_from: depart, date_to: arrivee)
rebec = Traveler.create!(name:"Rebecca", fly_from: "Marseille", price_from: 1, price_to: 1500, group: group_friends, date_from: depart, date_to: arrivee)

marie_jo = Traveler.create!(name:"Marie-Jo", fly_from: "Lyon", price_from: 1, price_to: 600, group: group_family, date_from: depart1, date_to: arrivee1)
michel = Traveler.create!(name:"Michel", fly_from: "Paris", price_from: 1, price_to: 300, group: group_family, date_from: depart1, date_to: arrivee1)


# url = ("https://api.skypicker.com/flights?fly_from=CDG&date_from=10/12/2020&date_to=30/12/2020&price_from=1&price_to1400&direct_flights=1&partner=grouptrottergrouptrotter&v=3&curr=EUR")
search = RestClient.get "https://api.skypicker.com/flights?fly_from=CDG&date_from=10/12/2020&date_to=30/12/2020&price_from=1&price_to1400&direct_flights=1&partner=grouptrottergrouptrotter&v=3&curr=EUR"
search1 = JSON.parse(search)

searchb = RestClient.get "https://api.skypicker.com/flights?fly_from=SFO&date_from=10/12/2020&date_to=30/12/2020&price_from=1&price_to1400&direct_flights=1&partner=grouptrottergrouptrotter&v=3&curr=EUR"
search2 = JSON.parse(searchb)


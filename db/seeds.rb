# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
require 'date'

Traveler.destroy_all
Group.destroy_all

depart = DateTime.new(2020, 12, 12).strftime("%d/%m/%Y")
arrivee = DateTime.new(2020, 12, 21).strftime("%d/%m/%Y")
depart1 = DateTime.new(2021, 2, 8).strftime("%d/%m/%Y")
arrivee1 = DateTime.new(2021, 2, 14).strftime("%d/%m/%Y")

group_friends = Group.create!(date_from: depart, date_to: arrivee, fly_to: "Mykonos")
group_family = Group.create!(date_from: depart1, date_to: arrivee1)

claire = Traveler.create!(name:"Claire", fly_from: "Rennes", price_from: 1, price_to: 3000, group: group_friends)
farouk = Traveler.create!(name:"Farouk", fly_from: "Nice", price_from: 1, price_to: 500, group: group_friends)
mateo = Traveler.create!(name:"Matéo", fly_from: "Marseille", price_from: 1, price_to: 200, group: group_friends)
rebec = Traveler.create!(name:"Rebecca", fly_from: "Marseille", price_from: 1, price_to: 1500, group: group_friends)

marie_jo = Traveler.create!(name:"Marie-Jo", fly_from: "Lyon", price_from: 1, price_to: 600, group: group_family)
michel = Traveler.create!(name:"Michel", fly_from: "Paris", price_from: 1, price_to: 300, group: group_family)

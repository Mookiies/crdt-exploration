# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
inspection1 = Inspection.create(name: 'Seed1', tombstone: false)
inspection2 = Inspection.create(name: 'Seed2', tombstone: false)

area1 = Area.create(name: 'Area 1', position: 2, inspection: inspection1, tombstone: false)
area2 = Area.create(name: 'Area 2', position: 1, inspection: inspection1, tombstone: false)

item1 = Item.create(name: 'Item 1', note: 'Here note', flagged: false, area: area1, tombstone: false)
item2 = Item.create(name: 'Item 2', note: 'Here note2', flagged: false, area: area1, tombstone: false)

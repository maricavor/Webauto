# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

1000.times do |n|
  name  = Faker::Name.name
  email = "example#{n+1}@webauto.ee"
  encrypted_password = User.new(:password=>"password").encrypted_password
  user=User.new
  user.name=name
  user.email=email
  user.encrypted_password=encrypted_password
  user.is_dealer=false
  user.tos_agreement=true

  user.save
  
  
end
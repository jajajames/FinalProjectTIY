# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Create Quests
quests = { "happyness"  => "Become happier with daily smile practice",
           "confidence" => "Become more confident with daily power poses",
           "freedom"    => "You choose the challenge" }
quests.each { |g, d| Quest.create(grail: g, description: d) } if Quest.count < 1

# Create User
user = User.find_by(name: "james")
unless user
  user = User.create(name: "james", email: "james@example.com",
                     contact_pref: "phone", phone: "555-555-5555",
                     password: "123123", password_confirmation: "123123")
end

# Create Journey
user.quests << Quest.find_by(grail: "happyness") if user.quests.count < 1
journey = user.journeys.last
journey.current = true
journey.save!

# Create Reports
report = journey.reports.find_or_initialize_by(created_at: Time.new(2016, 5, 1, 12, 1, 0))
report.image = File.open("lib/seed_imgs/may1.jpeg")
report.survey = 4
report.save!

report = journey.reports.find_or_initialize_by(created_at: Time.new(2016, 5, 2, 12, 1, 0))
report.image = File.open("lib/seed_imgs/may2.jpeg")
report.survey = 5
report.save!

report = journey.reports.find_or_initialize_by(created_at: Time.new(2016, 5, 3, 12, 1, 0))
report.image = File.open("lib/seed_imgs/may3.jpeg")
report.survey = 6
report.save!

report = journey.reports.find_or_initialize_by(created_at: Time.new(2016, 5, 4, 12, 1, 0))
report.image = File.open("lib/seed_imgs/may4.jpeg")
report.survey = 6
report.save!

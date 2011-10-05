# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

def random_policy_text(number_of_paragraphs=3)
  @policy_data ||= File.read(File.expand_path("../seed_policy_bodies.txt", __FILE__)).split("\n")
  @policy_data.shuffle[0...number_of_paragraphs].join("\n\n")
end

higher_education = Topic.create!(name: "Higher Education")
student_finance = Topic.create!(name: "Student Finance")
sustainable_development = Topic.create!(name: "Sustainable Development")

alice = User.create!(name: "Alice Anderson")
bob = User.create!(name: "Bob Bailey")
clive = User.create!(name: "Clive Custer")

# Draft policies
alice.editions.create! title: "Free cats for pensioners", body: random_policy_text, submitted: false, document: Policy.new
bob.editions.create! title: "Decriminalise beards", body: random_policy_text(5), submitted: false, document: Policy.new

# Submitted policies
alice.editions.create! title: "Less gravity on Sundays", body: random_policy_text, submitted: true, document: Policy.new
clive.editions.create! title: "Ducks pulling chariots of fire", body: random_policy_text(4), submitted: true, document: Policy.new

# Published policies
clive.editions.create! title: "No more supernanny", body: random_policy_text, state: 'published', document: Policy.new
alice.editions.create! title: "Laser eyes for millionaires", body: random_policy_text, state: 'published', document: Policy.new
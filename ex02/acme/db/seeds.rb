# Seed data — idempotent so it can be re-run safely (db:seed).

# The one account required by the exercise story.
User.find_or_create_by!(email: "admin@gmail.com") do |user|
  user.name = "admin"
  user.bio = FFaker::HipsterIpsum.paragraph
  user.password = "password"
  user.password_confirmation = "password"
end

puts "Seeded #{User.count} user(s)."

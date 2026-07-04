# Seed data — idempotent so it can be re-run safely (db:seed).

# --- Users & roles (rolification) -------------------------------------------
# One administrator, some moderators, the rest are regular users. Counts match
# the final subject target (1 admin + 5 moderators, 20 users total) and are
# overridable, e.g. SEED_MODERATORS=1 SEED_USERS=5.
moderator_count = Integer(ENV.fetch("SEED_MODERATORS", 5))
user_total = Integer(ENV.fetch("SEED_USERS", 20))

admin = User.find_or_create_by!(email: "admin@gmail.com") do |user|
  user.name = "admin"
  user.bio = FFaker::HipsterIpsum.paragraph
  user.password = "password"
  user.password_confirmation = "password"
end
admin.add_role(:administrator) unless admin.has_role?(:administrator)

moderator_count.times do |i|
  moderator = User.find_or_create_by!(email: "moderator#{i + 1}@gmail.com") do |user|
    user.name = "moderator#{i + 1}"
    user.bio = FFaker::HipsterIpsum.paragraph
    user.password = "password"
    user.password_confirmation = "password"
  end
  moderator.add_role(:moderator) unless moderator.has_role?(:moderator)
end

# Fill up to the desired total with plain registered users (no role).
[user_total - 1 - moderator_count, 0].max.times do |i|
  User.find_or_create_by!(email: "user#{i + 1}@gmail.com") do |user|
    user.name = FFaker::Name.first_name
    user.bio = FFaker::HipsterIpsum.paragraph
    user.password = "password"
    user.password_confirmation = "password"
  end
end

# --- Catalog ----------------------------------------------------------------
# Brands, each with products. Images upload to Cloudinary via CarrierWave's
# remote_*_url (Ruby 3 removed Kernel#open for URLs). Defaults to the subject's
# 50 x 50 (= 2500 products); shrink with SEED_BRANDS / SEED_PRODUCTS_PER_BRAND.
brand_count = Integer(ENV.fetch("SEED_BRANDS", 50))
products_per_brand = Integer(ENV.fetch("SEED_PRODUCTS_PER_BRAND", 50))

if Brand.none?
  brand_count.times do
    brand = Brand.create!(
      name: FFaker::Product.brand,
      remote_avatar_url: FFaker::Avatar.image
    )

    products_per_brand.times do
      Product.create!(
        name: FFaker::Product.product,
        remote_pict_url: FFaker::Avatar.image,
        description: FFaker::HipsterIpsum.paragraph,
        brand: brand,
        price: rand(1.0..100.0).round(2)
      )
    end
  end
end

puts "Seeded #{User.count} user(s) " \
     "(#{User.with_role(:administrator).count} admin, #{User.with_role(:moderator).count} moderator), " \
     "#{Brand.count} brand(s), #{Product.count} product(s)."

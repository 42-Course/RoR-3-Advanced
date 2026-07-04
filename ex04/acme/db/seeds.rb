# Seed data — idempotent so it can be re-run safely (db:seed).

# The admin account (from ex01).
User.find_or_create_by!(email: "admin@gmail.com") do |user|
  user.name = "admin"
  user.bio = FFaker::HipsterIpsum.paragraph
  user.password = "password"
  user.password_confirmation = "password"
end

# Catalog: brands, each with products. Images are uploaded to Cloudinary via
# CarrierWave's remote_*_url (Ruby 3 removed Kernel#open for URLs).
# Counts default to the subject's 50 x 50 (= 2500 products) but can be shrunk
# for quick local runs, e.g. SEED_BRANDS=2 SEED_PRODUCTS_PER_BRAND=2.
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

puts "Seeded #{User.count} user(s), #{Brand.count} brand(s), #{Product.count} product(s)."

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

# --- Catalog (fast seed) ----------------------------------------------------
# The slow part of seeding is NOT FFaker — it's uploading a unique image to
# Cloudinary for every record (thousands of network round-trips). Instead we
# upload a small POOL of images to Cloudinary once and reuse their stored
# identifiers, then bulk-insert brands/products with insert_all. Names come
# from a bounded name pool + a random suffix so every record stays unique.
brand_count = Integer(ENV.fetch("SEED_BRANDS", 50))
products_per_brand = Integer(ENV.fetch("SEED_PRODUCTS_PER_BRAND", 50))
image_pool_size = Integer(ENV.fetch("SEED_IMAGE_POOL", 20))

if Brand.count < brand_count || Product.count < brand_count * products_per_brand
  # 1) Image pool: a handful of real Cloudinary uploads. We capture each stored
  #    identifier, then `delete` (not `destroy`) the scratch rows so the row is
  #    gone but the Cloudinary image is kept and can be shared by many records.
  avatar_pool = []
  pict_pool = []
  image_pool_size.times do
    scratch_brand = Brand.create!(name: "POOL-#{SecureRandom.hex(6)}", remote_avatar_url: FFaker::Avatar.image)
    scratch_product = Product.create!(name: "POOL-#{SecureRandom.hex(6)}",
                                      remote_pict_url: FFaker::Avatar.image,
                                      brand: scratch_brand, price: 1.0)
    avatar_pool << scratch_brand.read_attribute(:avatar)
    pict_pool << scratch_product.read_attribute(:pict)
    scratch_product.delete
    scratch_brand.delete
  end

  # 2) Bounded FFaker name pools (called a few hundred times, not 2500+).
  brand_names = Array.new(100) { FFaker::Product.brand }
  product_names = Array.new(300) { FFaker::Product.product }
  descriptions = Array.new(30) { FFaker::HipsterIpsum.paragraph }
  now = Time.current

  # 3) Bulk-insert the missing brands (pooled avatar, unique name).
  missing_brands = brand_count - Brand.count
  if missing_brands.positive?
    Brand.insert_all(Array.new(missing_brands) do
      {
        name: "#{brand_names.sample} #{SecureRandom.alphanumeric(5)}",
        avatar: avatar_pool.sample,
        created_at: now, updated_at: now
      }
    end)
  end

  # 4) Bulk-insert products, topping each brand up to products_per_brand.
  product_rows = []
  Brand.find_each do |brand|
    (products_per_brand - brand.products.count).times do
      product_rows << {
        name: "#{product_names.sample} #{SecureRandom.alphanumeric(5)}",
        description: descriptions.sample,
        price: rand(1.0..100.0).round(2),
        brand_id: brand.id,
        pict: pict_pool.sample,
        created_at: now, updated_at: now
      }
    end
  end
  product_rows.each_slice(1000) { |slice| Product.insert_all(slice) }
end

puts "Seeded #{User.count} user(s) " \
     "(#{User.with_role(:administrator).count} admin, #{User.with_role(:moderator).count} moderator), " \
     "#{Brand.count} brand(s), #{Product.count} product(s)."

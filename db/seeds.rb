# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create admin user
if Rails.env.production?
  admin_email = "admin@gmail.com"
  admin_password = "123456"

  admin_user = User.find_or_create_by(email: admin_email) do |user|
    user.password = admin_password
    user.password_confirmation = admin_password
  end

  puts "Admin user created: #{admin_user.email}" if admin_user.persisted?
end

# Example:
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

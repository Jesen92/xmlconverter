# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.scss, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )

Rails.application.config.assets.precompile += %w( login.css )
Rails.application.config.assets.precompile += %w( OPZ-STAT-1.pdf )
Rails.application.config.assets.precompile += %w( Sablona_za_nenaplacena_potrazivanja.xlsx )
Rails.application.config.assets.precompile += %w( Sablona_za_nenaplacena_potrazivanja_primjer-1.xlsx )
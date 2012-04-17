# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_lembic_session',
  :secret      => '21362c486f244c533444bb7fe1cb7e56953656c99f9ec33ccfef3fea65a817f310dbb906c417920e0848582d03887786d45664d059833ae3f6656fdc3b55fa6e'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store

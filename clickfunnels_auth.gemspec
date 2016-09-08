$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "clickfunnels_auth/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "clickfunnels_auth"
  s.version     = ClickfunnelsAuth::VERSION
  s.authors     = ["Jeremy Green"]
  s.email       = ["jeremy@octolabs.com"]
  s.homepage    = "https://github.com/SuccessEtcllc/clickfunnels_auth"
  s.summary     = "A gem that allows a Rails app to be an OAuth client of Clickfunnels."
  s.description = "A gem that allows a Rails app to be an OAuth client of Clickfunnels."

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", ">= 4.0.4"
  s.add_dependency 'omniauth', "~> 1.2.1"
  s.add_dependency 'omniauth-oauth2', "~> 1.4.0"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency 'rspec-rails', '~> 2.14.2'
  s.add_development_dependency 'cucumber-rails', '~> 1.4.0'
  s.add_development_dependency 'database_cleaner', '~> 1.2.0'


end

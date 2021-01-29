source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.0'

gem 'rails', '~> 6.1.1'
gem 'pg', '~> 1.1'
gem 'puma', '~> 5.0'
gem 'bootsnap', '>= 1.4.4', require: false

gem 'bcrypt', '~> 3.1.7'
gem 'jwt', '~> 2.2', '>= 2.2.2'
gem 'rack-cors', '~> 1.1', '>= 1.1.1'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end
group :development do
  gem 'listen', '~> 3.3'
  gem 'spring'
end
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

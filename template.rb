# rspec
if yes?("use rspec?(yes or no)")
  gem_group :development, :test do
    gem 'rspec-rails'
    gem 'factory_girl_rails'
  end

  run_bundle
  remove_dir 'test'
  generate 'rspec:install'
end

# travis
if yes?("use travisCI?(yes or no)")
  #curl .travis.yml
  #curl database.travis.yml

  #ruby_version = ask("tell me your ruby version")
  #yml.ruby = ruby_version

  git add: "."
  git commit: %Q{ -m 'auto commit by rails-template' }
end

require 'yaml'

run 'rake db:create'

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

# devise
if yes?("use devise?(yes or no)")
  gem 'devise'
  run_bundle
  generate 'devise:install'
  generate 'devise:views'
  generate 'devise User'
  run 'rake db:migrate'

  # Add is_admin column to User Migration
  # omniauthable
  # Devise API
end

# rails_admin
if yes?("use rails_admin?(yes or no)")
  gem 'rails_admin'
  run_bundle
  generate 'rails_admin:install'
  # delete # referring devise and cancancan in initializer/rails_admin
end

# cancancan
if yes?("use cancancan?(yes or no)")
  gem 'cancancan'
  run_bundle
  generate 'cancan:ability'

  if yes?("integrate cancancan, devise and rails_admin?")
    run 'curl https://raw.githubusercontent.com/taigak/rails-template/master/.travis.yml -o .travis.yml'

  end
  # if user && user.is_admin?
  #    can :manage, :all
  #  end
end

# seed
# add admin_user auto

# travis
if yes?("use travisCI?(yes or no)")
  git add: "."
  git commit: %Q{ -m 'auto commit by rails-template' }
  run 'git push origin master'

  github_name = ask("Tell me your Github Account Name(Lower Case)")
  github_repo = ask("Tell me This Project's Github Repository Name")
  run 'gem install travis'
  run 'travis sync'
  run "travis enable -r #{github_name}/#{github_repo}"
  run 'curl https://raw.githubusercontent.com/taigak/rails-template/master/.travis.yml -o .travis.yml'
  run 'curl https://raw.githubusercontent.com/taigak/rails-template/master/database.travis.yml -o config/database.travis.yml'

  require 'yaml'
  travis = YAML.load_file(".travis.yml")
  travis["rvm"] = ask("Tell me your ruby version(example:2.0.0)")
  open(".travis.yml","w") do |f|
    YAML.dump(travis,f)
  end

  # travis Notification
  if yes?("Do you Wanna Send Notification to Slack?(yes or no)")
    say "If you have not Set TravisCI integration in Slack yet, please Set Now!"
    slack_account = ask("Tell me your Slack Account.")
    slack_token   = ask("Tell me your Slack Token")
    run "travis encrypt -r #{github_name}/#{github_repo} '#{slack_account}:#{slack_token}' --add notifications.slack"
  end

  # deploy heroku
  if yes?("Do you Wanna Deploy into Heroku?(yes or no)")
    if yes?("Create Heroku App Now?(yes or no)")
      app_name = ask("input heroku app name")
      run "heroku create #{app_name}"
    end
    run "travis setup heroku -r #{github_name}/#{github_repo}"

    travis = YAML.load_file(".travis.yml")
    obj = {
      "provider"=>travis["deploy"]["provider"],
      "api_key"=>travis["deploy"]["api_key"],
      "run"=>"rake db:migrate",
      "app"=>travis["deploy"]["app"],
      true=>travis["deploy"][true]
    }
    travis["deploy"] = obj

    open(".travis.yml","w") do |f|
      YAML.dump(travis,f)
    end

  end

  git add: "."
  git commit: %Q{ -m 'auto commit by rails-template' }

end

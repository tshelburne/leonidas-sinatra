# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "leonidas"
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Tim Shelburne"]
  s.date = "2014-04-25"
  s.description = ""
  s.email = "shelburt02@gmail.com"
  s.extra_rdoc_files = ["CHANGELOG", "LICENSE", "README.md", "lib/leonidas-sinatra.rb", "lib/leonidas-sinatra/routes/console.rb", "lib/leonidas-sinatra/routes/sync.rb", "lib/leonidas-sinatra/views/application.haml", "lib/leonidas-sinatra/views/client.haml", "lib/leonidas-sinatra/views/dashboard.haml", "lib/leonidas-sinatra/views/layout.haml", "lib/leonidas-sinatra/views/partials/close_form.haml", "lib/leonidas-sinatra/views/public/images/apple-touch-icon-114x114.png", "lib/leonidas-sinatra/views/public/images/apple-touch-icon-72x72.png", "lib/leonidas-sinatra/views/public/images/apple-touch-icon.png", "lib/leonidas-sinatra/views/public/images/favicon.ico", "lib/leonidas-sinatra/views/public/stylesheets/base.css", "lib/leonidas-sinatra/views/public/stylesheets/layout.css", "lib/leonidas-sinatra/views/public/stylesheets/skeleton.css", "lib/leonidas-sinatra/views/public/stylesheets/styles.css"]
  s.files = ["CHANGELOG", "Gemfile", "Gemfile.lock", "LICENSE", "Manifest", "README.md", "Rakefile", "leonidas.gemspec", "lib/leonidas-sinatra.rb", "lib/leonidas-sinatra/routes/console.rb", "lib/leonidas-sinatra/routes/sync.rb", "lib/leonidas-sinatra/views/application.haml", "lib/leonidas-sinatra/views/client.haml", "lib/leonidas-sinatra/views/dashboard.haml", "lib/leonidas-sinatra/views/layout.haml", "lib/leonidas-sinatra/views/partials/close_form.haml", "lib/leonidas-sinatra/views/public/images/apple-touch-icon-114x114.png", "lib/leonidas-sinatra/views/public/images/apple-touch-icon-72x72.png", "lib/leonidas-sinatra/views/public/images/apple-touch-icon.png", "lib/leonidas-sinatra/views/public/images/favicon.ico", "lib/leonidas-sinatra/views/public/stylesheets/base.css", "lib/leonidas-sinatra/views/public/stylesheets/layout.css", "lib/leonidas-sinatra/views/public/stylesheets/skeleton.css", "lib/leonidas-sinatra/views/public/stylesheets/styles.css", "spec/spec_helper.rb", "spec/support/classes/app.rb", "spec/support/mocks/sync_requests.rb", "spec/support/objects.rb", "spec/unit/routes/sync_get_spec.rb", "spec/unit/routes/sync_post_spec.rb", "spec/unit/routes/sync_reconcile_spec.rb"]
  s.homepage = "https://github.com/tshelburne/leonidas-rb"
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Leonidas", "--main", "README.md"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "leonidas"
  s.rubygems_version = "1.8.23"
  s.summary = ""

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end

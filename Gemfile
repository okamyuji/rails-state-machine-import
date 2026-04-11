source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.1.3"
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"
# Use sqlite3 as the database for Active Record
gem "sqlite3", ">= 2.1"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[windows jruby]

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

group :development, :test do
  # デバッグ用の標準ゲムです。
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"

  # 既知の脆弱性を持つgemを検出します。
  gem "bundler-audit", require: false

  # Railsアプリの静的セキュリティ解析を行います。
  gem "brakeman", require: false

  # RailsチームによるRuboCopの推奨設定です。
  gem "rubocop-rails-omakase", require: false

  # syntax_treeはRubyのフォーマッタおよび構文解析ツールです。
  gem "syntax_tree", require: false

  # RSpecによるBDDスタイルのテスト基盤です。
  gem "rspec-rails", "~> 8.0"

  # Sorbetによる漸進的な型検査です。
  gem "sorbet", require: false
  gem "sorbet-runtime"
  gem "tapioca", require: false
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
end

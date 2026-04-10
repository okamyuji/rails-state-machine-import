require "test_helper"
require "capybara/rails"
require "capybara/minitest"

# JavaScriptを使わない遷移はrack_testドライバで十分に検証できます。
# ブラウザ依存を持ち込まないためヘッドレスChromeではなくrack_testを採用しています。
class ApplicationSystemTestCase < ActionDispatch::IntegrationTest
  include Capybara::DSL
  include Capybara::Minitest::Assertions

  Capybara.default_driver = :rack_test
  Capybara.app = Rails.application

  teardown do
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end
end

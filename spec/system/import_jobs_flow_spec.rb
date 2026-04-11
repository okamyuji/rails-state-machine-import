require "rails_helper"
require "capybara/rspec"

RSpec.describe "インポートジョブの画面操作", type: :feature do
  before do
    Capybara.default_driver = :rack_test
    Capybara.app = Rails.application
  end

  it "新規登録からインポート開始までのハッピーパスが動作する" do
    visit root_path
    click_link "新規登録"

    fill_in "ジョブ名", with: "E2E顧客取込"
    fill_in "対象行数", with: "300"
    click_button "登録"

    expect(page).to have_selector(".badge", text: "registered")
    expect(page).to have_selector(".modal", text: "登録が完了しました")

    within(".modal") { click_button "インポート開始" }

    expect(page).to have_selector(".badge", text: "importing_modal_queued")
    expect(page).to have_selector(".overlay", text: "インポート中")
    expect(page).to have_text("登録完了モーダルはオーバーレイの背面に控えています")
  end

  it "モーダルを閉じてから進捗と完了を進めるとcompletedに到達する" do
    visit root_path
    click_link "新規登録"
    fill_in "ジョブ名", with: "E2E商品取込"
    fill_in "対象行数", with: "5"
    click_button "登録"

    within(".modal") { click_button "インポート開始" }
    click_button "DISMISS_MODAL"
    expect(page).to have_selector(".badge", text: "importing")

    click_button "COMPLETE"
    expect(page).to have_selector(".badge", text: "completed")
    expect(page).not_to have_selector(".overlay")
    expect(page).not_to have_selector(".modal")
  end

  it "登録直後のモーダルで閉じるを選ぶとidleに戻る" do
    visit root_path
    click_link "新規登録"
    fill_in "ジョブ名", with: "E2Eキャンセル"
    fill_in "対象行数", with: "10"
    click_button "登録"

    within(".modal") { click_button "閉じる" }
    expect(page).to have_selector(".badge", text: "idle")
    expect(page).not_to have_selector(".modal")
  end

  it "状態遷移マトリクスがトップ画面に表示される" do
    visit root_path
    expect(page).to have_text("状態遷移マトリクス")
    expect(page).to have_selector("table.matrix thead", text: "SUBMIT")
    expect(page).to have_selector("table.matrix tbody th", text: "importing_modal_queued")
  end
end

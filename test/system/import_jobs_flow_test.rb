require "application_system_test_case"

class ImportJobsFlowTest < ApplicationSystemTestCase
  # 画面を通した一連のユーザー操作が状態遷移テーブルに従って進むかを検証します。
  # 登録後のモーダル表示と、インポート開始によるオーバーレイへの切り替えを重視しています。

  test "新規登録からインポート開始までのハッピーパスが動作する" do
    visit root_path
    click_link "新規登録"

    fill_in "ジョブ名", with: "E2E顧客取込"
    fill_in "対象行数", with: "300"
    click_button "登録"

    # 登録直後はregistered状態でモーダルが前面に出る想定です。
    assert_selector ".badge", text: "registered"
    assert_selector ".modal", text: "登録が完了しました"

    # モーダル内のインポート開始ボタンでSTART_IMPORTを送ります。
    within(".modal") { click_button "インポート開始" }

    # 直後の状態はimporting_modal_queuedでオーバーレイが優先表示されます。
    assert_selector ".badge", text: "importing_modal_queued"
    assert_selector ".overlay", text: "インポート中"
    assert_text "登録完了モーダルはオーバーレイの背面に控えています"
  end

  test "モーダルを閉じてから進捗と完了を進めるとcompletedに到達する" do
    visit root_path
    click_link "新規登録"
    fill_in "ジョブ名", with: "E2E商品取込"
    fill_in "対象行数", with: "5"
    click_button "登録"

    within(".modal") { click_button "インポート開始" }
    # 複合状態からDISMISS_MODALを送るとimportingだけが残ります。
    click_button "DISMISS_MODAL"
    assert_selector ".badge", text: "importing"
    assert_selector ".overlay"

    # 進捗をCOMPLETEまで進めて完了状態を確認します。
    click_button "COMPLETE"
    assert_selector ".badge", text: "completed"
    assert_no_selector ".overlay"
    assert_no_selector ".modal"
  end

  test "登録直後のモーダルで閉じるを選ぶとidleに戻る" do
    visit root_path
    click_link "新規登録"
    fill_in "ジョブ名", with: "E2Eキャンセル"
    fill_in "対象行数", with: "10"
    click_button "登録"

    within(".modal") { click_button "閉じる" }
    assert_selector ".badge", text: "idle"
    assert_no_selector ".modal"
    assert_no_selector ".overlay"
  end

  test "状態遷移マトリクスがトップ画面に表示される" do
    visit root_path
    assert_text "状態遷移マトリクス"
    assert_selector "table.matrix thead", text: "SUBMIT"
    assert_selector "table.matrix tbody th", text: "importing_modal_queued"
  end
end

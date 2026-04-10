Rails.application.routes.draw do
  # ヘルスチェック用のエンドポイントです。
  get "up" => "rails/health#show", as: :rails_health_check

  # トップ画面はインポートジョブの一覧と状態遷移マトリクスを表示します。
  root "import_jobs#index"

  resources :import_jobs, only: [:index, :show, :create, :new] do
    member do
      post "events/:event", to: "import_jobs#event", as: :event
    end
  end

  namespace :api do
    resources :import_jobs, only: [:index, :show, :create] do
      member do
        post "events/:event", to: "import_jobs#event", as: :event
      end
    end
  end
end

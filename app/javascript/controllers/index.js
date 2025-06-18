// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
import SearchableSelectController from "./searchable_select_controller"

// コントローラーの登録
application.register("searchable-select", SearchableSelectController)

// その他のコントローラーの読み込み
eagerLoadControllersFrom("controllers", application)

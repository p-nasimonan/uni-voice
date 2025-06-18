/**
 * @fileoverview 検索可能なセレクトボックスのコントローラー
 * @description 大学選択用の検索可能なセレクトボックスを実装します
 */

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "list", "selected", "button"]
  static values = {
    items: Array,
    placeholder: String,
    addUrl: String
  }

  connect() {
    this.filteredItems = this.itemsValue
    this.renderList()
    this.closeOnClickOutside = this.closeOnClickOutside.bind(this)
    document.addEventListener('click', this.closeOnClickOutside)
  }

  disconnect() {
    document.removeEventListener('click', this.closeOnClickOutside)
  }

  /**
   * 検索入力時の処理
   * @param {Event} event - 入力イベント
   */
  search(event) {
    event.stopPropagation()
    const query = event.target.value.toLowerCase()
    this.filteredItems = this.itemsValue.filter(item => 
      item[0].toLowerCase().includes(query)
    )
    this.renderList()
    this.listTarget.classList.remove("hidden")
  }

  /**
   * アイテム選択時の処理
   * @param {Event} event - クリックイベント
   */
  select(event) {
    event.stopPropagation()
    const value = event.target.dataset.value
    const text = event.target.textContent.trim()
    this.selectedTarget.value = value
    this.inputTarget.value = text
    this.listTarget.classList.add("hidden")
  }

  /**
   * リストの表示/非表示を切り替え
   * @param {Event} event - クリックイベント
   */
  toggleList(event) {
    event.stopPropagation()
    const isHidden = this.listTarget.classList.contains("hidden")
    this.listTarget.classList.toggle("hidden")
    if (isHidden) {
      this.inputTarget.focus()
      this.search({ target: this.inputTarget, stopPropagation: () => {} })
    }
  }

  /**
   * リストの描画
   */
  renderList() {
    const query = this.inputTarget.value.toLowerCase()
    const hasResults = this.filteredItems.length > 0
    const showAddButton = query.length > 0 && !hasResults

    let html = ""
    
    if (hasResults) {
      html = this.filteredItems
        .map(item => `
          <div class="px-4 py-2 hover:bg-gray-100 cursor-pointer" 
               data-value="${item[1]}"
               data-action="click->searchable-select#select">
            ${item[0]}
          </div>
        `)
        .join("")
    }

    if (showAddButton) {
      html += `
        <div class="border-t border-gray-200">
          <a href="${this.addUrlValue}?name=${encodeURIComponent(query)}" 
             class="block px-4 py-2 text-blue-600 hover:bg-blue-50">
            <div class="flex items-center">
              <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"/>
              </svg>
              "${query}" を追加する
            </div>
          </a>
        </div>
      `
    }

    this.listTarget.innerHTML = html
  }

  /**
   * リスト外クリック時の処理
   * @param {Event} event - クリックイベント
   */
  closeOnClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.listTarget.classList.add("hidden")
    }
  }
} 
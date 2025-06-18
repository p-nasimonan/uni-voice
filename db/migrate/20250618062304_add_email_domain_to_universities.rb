class AddEmailDomainToUniversities < ActiveRecord::Migration[8.0]
  def change
    add_column :universities, :email_domain, :string, null: false
    add_index :universities, :email_domain, unique: true
  end
end

class AddDayPeriodToSyllabuses < ActiveRecord::Migration[8.0]
  def change
    add_column :syllabuses, :day_period, :string
  end
end

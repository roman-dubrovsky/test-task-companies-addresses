class CreateCompanies < ActiveRecord::Migration[8.0]
  def change
    create_table :companies do |t|
      t.string :name
      t.integer :registration_number

      t.timestamps
    end

    add_index :companies, :registration_number, unique: true
  end
end

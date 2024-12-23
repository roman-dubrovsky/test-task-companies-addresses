class CreateAddresses < ActiveRecord::Migration[8.0]
  def change
    create_table :addresses do |t|
      t.references :company, null: false, index: true
      t.string :street
      t.string :city
      t.string :postal_code
      t.string :country

      t.timestamps
    end
  end
end

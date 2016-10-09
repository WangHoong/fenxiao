class CreateFxTaxRates < ActiveRecord::Migration
  def change
    create_table :fx_tax_rates do |t|
      t.integer "user_id"
      t.decimal "total_amount",precision: 10, scale: 2, default: 0.0
      t.decimal "amount",precision: 10, scale: 2, default: 0.0
      t.string  "date"
      t.integer :state,default: 0
      t.timestamps
    end
  end
end

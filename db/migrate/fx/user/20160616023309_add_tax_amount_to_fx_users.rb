class AddTaxAmountToFxUsers < ActiveRecord::Migration
  def change
    add_column  "fx_users","tax_amount",:decimal,precision: 10, scale: 2, default: 0.0  #总税金
  end
end

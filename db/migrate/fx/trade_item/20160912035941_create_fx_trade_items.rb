class CreateFxTradeItems < ActiveRecord::Migration
  def change
    create_table :fx_trade_items do |t|
      t.integer :user_id 
      t.integer :trade_id #分销订单id
      t.string :sku
      t.integer :count, default: 1, null: false  
      t.decimal :jprice, precision: 10, scale: 2, default: 0.0 #京东价
      t.decimal :price, precision: 10, scale: 2, default: 0.0 #协议
      t.decimal :fanli_amount, precision: 10, scale: 2, default: 0.0 #获利
      t.integer :fanli_type, default: 0, null: false
      t.integer :sort , default: 0, null: false   #0正常 -1退货
      t.decimal :self_fanli, precision: 10, scale: 2, default: 0.0 #
      t.timestamps null: false
    end
  end
end

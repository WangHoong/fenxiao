class CreateFxTradeRebates < ActiveRecord::Migration
  def change
    create_table :fx_trade_rebates do |t|
      t.string :name #返利消费
      t.integer :user_id 
      t.string :number #分销订单id
      t.integer :sort , default: 0, null: false   #0正常 -1退货
      t.decimal :amount, precision: 10, scale: 2, default: 0.0 
      t.timestamps null: false
    end
  end
end

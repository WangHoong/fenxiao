class AddTotalPriceToFxTradeItems < ActiveRecord::Migration
  def change
    add_column :fx_trade_items,:total_price,:decimal,precision: 10, scale: 2, default: 0.0 
    add_column :fx_trade_items,:total_self_fanli,:decimal,precision: 10, scale: 2, default: 0.0 
  end
end

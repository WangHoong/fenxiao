class AddRefundAmountToFxTrades < ActiveRecord::Migration
  def change
       add_column :fx_trades,:refund_amount,:decimal,precision: 10, scale: 2, default: 0.0 
  end
end

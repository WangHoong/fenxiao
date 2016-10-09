class AddTradeRebateIdToFxTransations < ActiveRecord::Migration
  def change
     add_column :fx_transations,:trade_rebate_id,:integer
  end
end

class Fx::TradeItem < ActiveRecord::Base
  
  self.table_name = "fx_trade_items"
  belongs_to :trade
  belongs_to :user,class_name: "::Fx::User",foreign_key: "user_id"
  scope :recent, -> { order('created_at DESC') }
end

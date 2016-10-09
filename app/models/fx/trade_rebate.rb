class Fx::TradeRebate < ActiveRecord::Base
  self.table_name = "fx_trade_rebates"
  belongs_to :user,class_name: "::Fx::User",foreign_key: "user_id"
   
  validates_presence_of :number, :message => "请输入需求编号"
  validates_uniqueness_of :number, :message => '需求编号已经存在'
end

class Fx::Trade < ActiveRecord::Base
  self.table_name = "fx_trades"
  has_many :transations
  has_many :trade_items
  belongs_to :user
  scope :active, -> { where :active => true }
  scope :recent, -> { order('created_at DESC') }
  validates_presence_of :number, :message => "请输入需求编号"
  validates_uniqueness_of :number, :message => '需求编号已经存在'

  OPTYPE_NAME={
    1 => "在线招标",
    2 => "商城",
    3 => "脉脉圈",
    4 => "所得税",
    5 => "培训费"
  }

  #  after_create do
  #    pay!
  #  end

  def optype_name
    OPTYPE_NAME[optype]
  end
  
  def refund!(refund1_amount,refund2_amount)
    #分给自己
    dealer_amount = refund_amount*-1 
    self.transations.create!(user_id: user.id, amount: dealer_amount,sort: -1,subject: "扣除个人消费返利")
    user.info.update!({amount: user.info.amount + dealer_amount})
    user.update!(total_amount: user.total_amount + dealer_amount,cost_amount: user.cost_amount + dealer_amount)
    #一级分销利润分配
    prev_dealer = user.prev_dealer
    if  prev_dealer && refund1_amount.present?
      dealer1_amount =  refund1_amount.to_f*-1
      self.transations.create!(user_id: prev_dealer.id, amount: dealer1_amount, dealer_level: 1, sort: -1,subject: "扣除一级分销返利")
      prev_dealer.info.update!({amount1: prev_dealer.info.amount1 + dealer1_amount})
      prev_dealer.update!({total_amount: prev_dealer.total_amount + dealer1_amount})
    end  
    #二级分销利润分配
    prev2_dealer=prev_dealer.try(:prev_dealer)
    if prev2_dealer && refund2_amount.present?
      dealer2_amount = refund2_amount.to_f*-1
      self.transations.create!(user_id: prev2_dealer.id, amount: dealer2_amount, dealer_level: 2, sort: -1,subject: "扣除二级分销返利")
      prev2_dealer.info.update!({amount2: prev2_dealer.info.amount2 + dealer2_amount})
      prev2_dealer.update!({total_amount: prev2_dealer.total_amount + dealer2_amount})
    end
  end
  
  #分配分销获利todo移除实时余额获利
  def pay!
    #个人订单消费累计
    user.update!(cost_amount: user.cost_amount+amount)
    #分给自己
    self.transations.create!(user_id: user.id, amount: amount,sort: 1,subject: "个人消费返利")
    user.info.update!({amount: user.info.amount + amount})
    user.update!(total_amount: user.total_amount + amount)
    # #二级分销利润分配
    if prev_dealer = user.prev_dealer
      dealer1_percent = employee_percent(prev_dealer, prev_dealer.level.send(:dealer1_percent))
      if rebate?  #是否包含自定义返利
        reamount =  trade_items.where(fanli_type: 0).sum(:total_price) #正常返利
        self_fanli = trade_items.where(fanli_type: 1).sum(:total_price) #自定义返利
        dealer1_amount =  self_fanli + reamount*dealer1_percent
      else
        dealer1_amount = amount*dealer1_percent
      end 
      self.transations.create!(user_id: prev_dealer.id, amount: dealer1_amount, dealer_level: 1, sort: 1,subject: "一级分销返利")
      prev_dealer.info.update!({amount1: prev_dealer.info.amount1 + dealer1_amount})
      prev_dealer.update!({total_amount: prev_dealer.total_amount + dealer1_amount})
      # prev_dealer.income!(dealer1_amount)
      if prev2_dealer=prev_dealer.prev_dealer
        dealer2_percent=employee_percent(prev2_dealer, prev2_dealer.level.send(:dealer2_percent))
        if rebate?  
          reamount2 =  trade_items.where(fanli_type: 0).sum(:total_price) #正常返利总数
          self_fanli2 = trade_items.where(fanli_type: 1).sum(:total_price) #自定义返利总数
          dealer2_amount =  self_fanli2 + reamount2*dealer2_percent
        else
          dealer2_amount = amount*dealer2_percent
        end 
        self.transations.create!(user_id: prev2_dealer.id, amount: dealer2_amount, dealer_level: 2, sort: 1,subject: "二级分销返利")
        prev2_dealer.info.update!({amount2: prev2_dealer.info.amount2.to_f + dealer2_amount})
        prev2_dealer.update!({total_amount: prev2_dealer.total_amount + dealer2_amount})
    
      end
    end
  end

  #内部员工新增获利
  def employee_percent(dealer, percent)
    if employee=dealer.is_employee
      percent+=employee.percent
    end
    percent/100.00
  end
  
  def rebate?
    return true if self.rebate > 0
    return false
  end


end

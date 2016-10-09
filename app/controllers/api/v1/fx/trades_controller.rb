class Api::V1::Fx::TradesController < Api::V1::ApplicationController

  before_action :authenticate_user!
  before_action :active_user_hfbpay,:only=>[:create]

  def index
    @trades = @current_user.trades.page params[:page]
  end

  def create
    trade = Fx::Trade.find_by_number(params[:trade][:number])
    if trade.present?
      return api_error(status: 422,errors: "分销订单已创建")
    end
    @trade = Fx::Trade.new trade_params
    if @trade.save
      @success=database_transaction do
        create_trade_items
        @trade.pay!
      end
      render json: { success: '创建成功'}
    else
      head status: 500
    end
  end


  def show
    @trade = @current_user.trades.find(params[:id])
    # 提示当前订单的状态
    callback_params = params.except(*request.path_parameters.keys)
    if callback_params.any? && Alipay::Sign.verify?(callback_params)
      flash[:notice] = '支付完成'
    end
  end
  
    
  def rebate_consume
    current_month_amount = @current_user.info.try(:current_month_amount)
    amount = params[:amount].to_f
    if current_month_amount < amount
      api_error(status: 422, errors: "余额不足")
      return false
    end
    @trade_rebate = @current_user.trade_rebates.new(name: "rebate",number: params[:number],amount: params[:amount])
    @success=database_transaction do
      @trade_rebate.save!
      @current_amount =  current_month_amount-amount
      @current_user.info.update(:current_month_amount=>@current_amount) 
      
      @current_user.transations.create!(trade_rebate_id: @trade_rebate.id,amount: amount*-1,sort: 2,subject: '返利消费')
    end
    if @success
      render(json: {errors: 'success',amount: @current_amount})
    else
      render(json: {errors: 'fail'})
    end
  end
  
  
  private
  def trade_params
    params.require(:trade).permit(["number","name", "total_amount", "amount", "optype", "user_id","rebate"] )
  end
  
  def active_user_hfbpay
    unless @current_user.account.try(:hfbpay)
      hfbpay = @current_user.account.build_hfbpay(current_amount: 0)
      hfbpay.save!
    end
  end

  def create_trade_items
    if params['trade']['order_list'].present?
      items = JSON.parse(params['trade']['order_list'])
      items.each do |item|
        if item['fanli_type'].to_i == 0
          total_price =  item['product_count'].to_i * item['product_fanli'].to_f  #正常返利总数
        else
          total_price =  item['product_count'].to_i * item['self_fanli'].to_f  #自定义返利总数
        end
        @trade.trade_items.create!(user_id: @trade.user_id,sku: item['product_sku'],total_price: total_price,
          count: item['product_count'],jprice: item['product_price'],price: item['product_agreement_price'],
          fanli_amount: item['product_fanli'],fanli_type: item['fanli_type'],self_fanli: item['self_fanli'])  
      end
    end
  end

end

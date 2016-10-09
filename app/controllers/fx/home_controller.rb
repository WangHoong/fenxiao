class Fx::HomeController < ApplicationController
  skip_before_action :login_filter,:only=>[:download,:qrcode]
  before_action :fx_login_user_filter,:except=>[:download,:qrcode]
  
  def index
    @posters=Fx::Setting.find_by(key: "poster").value
    if params[:page] == 'index'
      @re_url = 'http://mall.eventnation.com.cn/mobile'
    else
      @re_url = 'http://mall.eventnation.com.cn/customer/account'
    end
  end
  
  def return_amount
    case params[:type]
    when 'my'
      @title = '本人消费返利详情'
      dealer_level = nil
    when 'partner'
      @title = '创业伙伴消费返利详情'
      dealer_level = 1
    when 'shoper'  
      @title = '顾客消费返利详情'
      dealer_level = 2
    else
      @title = '返利总额详情'
    end
    options = {}
    options["dealer_level"] = dealer_level  if params[:type].present?  
     
    transations = @user.transations.includes(:trade).recent.where(options).where.not(sort: 2) 
    @transations =  transations.page params[:page]
    @amount = transations.sum(:amount)
  end
  
  def trade_rebates
    transations = @user.transations.recent.where("created_at <=? and created_at >?",Time.now.to_s(:db),date_moth) 
    @transations =  transations.page params[:page]
    @amount = transations.sum(:amount)
  end
 
 
  def tax_rates
    @tax_rates = @user.tax_rates.order("date desc").page params[:page]
  end
  
 
  def qrcode
    @user = Fx::User.find(params[:id])
    unless @user
      return render :js => "hzb.redirect('/login','用户不存在',2000);"
    end
    @qr = RQRCode::QRCode.new(@user.invitation_url, :size => 6, :level => :l)
  end
  
  def download
  end
  
  def note
    @relations =  @user.relations.recent
  end
 
  def verify
    
  end
  
  private
   
  def fx_login_user_filter
    @user =  Fx::User.where(:id=>current_user.id).first if current_user
    if @user.blank? or current_user.try(:hfbpay).blank?
      render :action => 'apply'  
    end
  end
   
  def date_moth
    date = Time.now - (Time.now.day).day
    date.to_s(:db)
  end
 
  
end

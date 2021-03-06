class ReportsController < ApplicationController
  before_action :require_user
  before_action :find_day
  before_action :correct_user_id, except: [:create_from_sms]
  skip_before_filter :verify_authenticity_token, :require_cellphone, :require_quest, :require_email_confirmation, only: [:create_from_sms]
  rescue_from ActiveRecord::RecordNotFound, with: :dude_wheres_my_record

  def new
  end

  def create
    if @report.update_attributes(report_params)
      redirect_to current_user
    else
      render :create
    end
  end

  def update
    if @report.update_attributes(report_params)
      redirect_to current_user
    else
      render :update
    end
  end

  def create_from_sms
    @client = Twilio::REST::Client.new ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']
    @twilio_number = ENV['TWILIO_NUMBER']
    img = params['MediaUrl0']
    txt = Report.parse_text(params["Body"])
    @report.image = open(img, allow_redirections: :all) if img
    @report.survey = txt[:pre] if txt[:pre]
    @report.postsurvey = txt[:post] if txt[:post]

    if @report.save
      @client.messages.create(
        from: @twilio_number,
        to: current_user.cellphone,
        body: "We got the:\n#{'- img' if img}\n#{'- survey' if txt[:pre]}\n#{'- postsurvey' if txt[:post]}"
      )
    else
      @client.messages.create(
        from: @twilio_number,
        to: current_user.cellphone,
        body: "Didn't get that."
      )
    end
    render nothing: true
  end

  private

  def report_params
    params.require(:report).permit(:survey, :image, :postsurvey)
  end

  def find_day
    @report = current_user.current_report
  end
end

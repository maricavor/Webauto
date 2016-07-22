
class Notifier < ActionMailer::Base
  default from: "info@webauto.ee"
  #layout 'notifier'

  add_template_helper(ApplicationHelper)
  def comment_updated(comment, user)
    @comment = comment
    @user= user
    mail(to: user.email, subject: "Webauto.ee - #{comment.vehicle.name}")
  end
  def vehicle_price_updated(vehicle,user)
    @vehicle = vehicle
    @user= user
    mail(to: user.email, subject: "Webauto.ee - #{vehicle.name}")
  end
  def vehicle_status_sold(vehicle,user,delete_id)
    @vehicle = vehicle
    @user= user
    @delete_reason_id=delete_id
    mail(to: user.email, subject: "Webauto.ee - #{vehicle.name}")
  end
  def adverts_created(search_alert)
    @search_alert=search_alert
    @search=search_alert.search
    @results=search_alert.results.split(',')
    @user=search_alert.user
    mail(to: @user.email,subject: t("latest_adverts"))
  end
def contact_seller_submitted(inquiry,vehicle)
    @vehicle=vehicle
    @inquiry=inquiry
    mail(to: vehicle.user.email,from: %("#{inquiry.name}" <#{inquiry.email}>), subject: "#{t('contact_user_subject')} - #{vehicle.name}")
  end
  def contact_dealer_submitted(inquiry,dealer)
      @dealer=dealer
      @inquiry=inquiry
      mail(to: dealer.email,from: %("#{inquiry.name}" <#{inquiry.email}>), subject: "#{t('contact_dealer_subject')}")
    end
  def inquiry_submitted(inquiry,vehicle)
    @vehicle=vehicle
    @inquiry=inquiry
    #mail(to: @vehicle.user.email,from: %("#{inquiry.name}" <#{inquiry.email}>), reply_to: inquiry.email, subject: "Vehicle inquiry")
  end

def send_to_friend_submitted(inquiry,vehicle)
                                           @vehicle=vehicle
                                           @inquiry=inquiry
                                                 mail(to: inquiry.friend_email, reply_to: %("#{inquiry.name}" <#{inquiry.email}>), subject: "#{t("check_this_car")} #{@vehicle.name} #{@vehicle.engine_name}")
                                                                                      end
  def report_submitted(inquiry,vehicle)
                                                                                        @vehicle=vehicle
                                                                                        @inquiry=inquiry
                                                                                        mail(to: "info@webauto.ee", reply_to: %("#{inquiry.name}" <#{inquiry.email}>), subject: "Report Ad")
                                                                                      end

  end
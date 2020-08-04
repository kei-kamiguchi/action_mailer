class ContactMailer < ApplicationMailer
  def contact_mail
    @contact = params[:contact]
    mail to: params[:contact].email, subject: "お問い合わせの確認メール"
  end
end

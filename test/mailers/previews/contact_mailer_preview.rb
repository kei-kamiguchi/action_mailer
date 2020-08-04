# Preview all emails at http://localhost:3000/rails/mailers/contact_mailer
class ContactMailerPreview < ActionMailer::Preview
  def contact_mail
    ContactMailer.with(contact: Contact.find(2)).contact_mail
  end
end

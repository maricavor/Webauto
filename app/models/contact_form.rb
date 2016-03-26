class ContactForm < MailForm::Base

  attributes :type,  :validate => ["General feedback", "Problem","Feature request","Question"]
  attribute :email,     :validate => /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i
  attribute :message,   :validate => { :presence => true }
  attribute :nickname,  :captcha  => true

  # Declare the e-mail headers. It accepts anything the mail method
  # in ActionMailer accepts.
  def headers
    {
      :subject => "#{type}",
      :to => "support@webauto.ee",
      :from => "#{email}"
    }
  end
end

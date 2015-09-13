class ContactFormsController < ApplicationController
    def new
      @contact_form = ContactForm.new
    end

    def create
      begin
        @contact_form = ContactForm.new(params[:contact_form])
        @contact_form.request = request
        if @contact_form.deliver
          flash.now[:notice] = 'Thank you for your message!'
        else
          flash.now[:alert] = @contact_form.errors.full_messages.join(', ')
          render :new
        end
      rescue ScriptError
        flash[:error] = 'Sorry, this message appears to be spam and was not delivered.'
      end
    end
end

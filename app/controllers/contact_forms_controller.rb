class ContactFormsController < ApplicationController
 
    def new
      @title="Contact Us - Webauto.ee"
      @contact_form = ContactForm.new
    end

    def create
      begin
        @contact_form = ContactForm.new(params[:contact_form])
        @contact_form.request = request
        if @contact_form.deliver
          flash.now[:notice] = t("contact_forms.thank_you")
        else
          flash.now[:alert] = @contact_form.errors.full_messages.join(', ')
          render :new
        end
      rescue ScriptError
        flash[:error] = t("contact_forms.failure")
      end
    end
end

class ContactFormsController < ApplicationController
 
    def new
      @title=t("contact_forms.title")
      @contact_form = ContactForm.new
    end

    def create
      begin
        @contact_form = ContactForm.new(params[:contact_form])
        @contact_form.request = request
        if @contact_form.deliver
          flash.now[:notice] = t("contact_forms.thankyou")
        else
          flash.now[:alert] = @contact_form.errors.full_messages.first
          render :new
        end
      rescue ScriptError
        flash[:error] = t("contact_forms.failure")
      end
    end
end

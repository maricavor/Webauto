class VehicleFormBuilder < ActionView::Helpers::FormBuilder
  delegate :content_tag, :tag, to: :@template
  ##
  %w[text_field password_field collection_select select grouped_collection_select].each do |method_name|
    define_method(method_name) do |name,*args|
      options=args.extract_options!
      if options[:type]=="datepicker"
      field=datepicker(name,*args,super(name,*args,:class=>"span9"))
      else
        if options[:value].present?
          field=super(name,*args,:id=>options[:id],:class=>"#{options[:type]} span12",:value=>options[:value])
        else
      field=super(name,*args,:id=>options[:id],:class=>"#{options[:type]} span12",:placeholder=>options[:placeholder],:disabled=>options[:disabled],:autocomplete=>options[:autocomplete],:autofocus=>options[:autofocus],:hint=>options[:hint])
    end
      end
      content_tag :div, class: "field",id:(options[:id] ? options[:id]+"_field" : "") do
        if options[:label]
          field_label(name,options)+field
        else
          field
        end
      end
    end
  end

   def text_area(name,*args)
      options=args.extract_options!
      field=super(name,*args,:id=>options[:id],:class=>"span12",:placeholder=>options[:placeholder],rows: (options[:rows] if options[:rows]))
      content_tag :div, class: "field",id:(options[:id] ? options[:id]+"_field" : "") do
        if options[:label]
          field_label(name,options)+field
        else
          field
        end
    end
  end



  def date_select(name,*args)
    options=args.extract_options!
    if options[:label]
      field_label(name,options)+super(name,*args)
    else
      super(name,*args)
    end

  end


  def bootstrap_date_select(name,*args)
  options=args.extract_options!
  content_tag :div, class: "field",id:(options[:id] ? options[:id]+"_field" : "") do
    field_label(name,options)+datepicker(name,options)
  end
  end 


  def check_box(name,*args)
    options=args.extract_options!
    content_tag :label, class: "checkbox #{options[:type]}", id: options[:id] do
      super+ " "+options[:label]
    end
  end

  def error_messages
    if object.errors.full_messages.any?
      content_tag(:div, :class => "error_messages") do
        content_tag(:h2,"Invalid Fields") +
        content_tag(:ul) do
          object.errors.full_messages.map do |msg|
            content_tag(:li, msg)
          end.join.html_safe
        end
      end
    end
  end

  private
  def datepicker(name,*args,super_text_field)
   content_tag :div, :class=> "input-append date datepicker" do
     content = super_text_field
     content << content_tag(:span,content_tag(:i,'',class: "icon-calendar"),class: "add-on") 
     content.html_safe
    end
  end

  def field_label(name,options)
    if options[:required].present?
      required=options[:required]
    else
    required = object.class.validators_on(name).any? {|v| v.kind_of? ActiveModel::Validations::PresenceValidator}
  end
    label(name,options[:label],class: ("required" if required))
  end

  def objectify_options(options)
    super.except(:label)
  end
end
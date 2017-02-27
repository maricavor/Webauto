# encoding: UTF-8
module ApplicationHelper
  def vehicle_form_for(object, options ={}, &block)
    options[:builder]= VehicleFormBuilder
    form_for(object,options,&block)
  end
  def display_base_errors resource
    return '' if (resource.errors.empty?) or (resource.errors[:base].empty?)
    messages = resource.errors[:base].map { |msg| content_tag(:p, msg) }.join
    html = <<-HTML
    <div class="alert alert-error alert-block">
    <button type="button" class="close" data-dismiss="alert">&#215;</button>
    #{messages}
    </div>
    HTML
    html.html_safe
  end
  def http_url(url)
  unless url=~/^http?:\/\//
    "http://#{url}"
  else
    url
  end
  end
  def current_translations
    @translations ||= I18n.backend.send(:translations)
    @translations[I18n.locale].with_indifferent_access
  end

  def currency(c)
    if c
      number_to_currency(c, unit: "€", separator: ",", delimiter: ",", format: "%u%n",precision: (c.round == c) ? 0 : 2)
    end
  end
  def percent(a,b)
    a.to_f / b.to_f * 100.0
  end

  def locale_select(locale,text,params)
    _params=params
    _params[:locale]=locale
    if I18n.locale==locale
      _text="<strong>"+text+"</strong>"
    else
      _text=text
    end
    link_to _text.html_safe,_params

  end
  def type_select(id,text,url)
    if session[:type_id]==id
      _text="<i class='icon-ok check-mark'></i> "+text
    else
      _text=text
    end
    link_to _text.html_safe,url,:role=>"menuitem",:tabindex=>"-1"
  end
  #   <%= page_entries_info @posts, :entry_name => 'item' %>
  #   #-> Displaying items 6 - 10 of 26 in total
  def page_entries_info(collection, options = {})
    entry_name = options[:entry_name] || collection.entry_name
    entry_name = entry_name.pluralize unless collection.total_count == 1
    if collection.total_pages < 2
      t('helpers.page_entries_info.one_page.display_entries', :entry_name => entry_name, :count => collection.total_count)
    else
      first = collection.offset_value + 1
      last = collection.last_page? ? collection.total_count : collection.offset_value + collection.limit_value
      t('helpers.page_entries_info.more_pages.display_entries', :entry_name => entry_name, :first => first, :last => last, :total => collection.total_count)
    end.html_safe
  end
  def admin_page_entries_info(collection, options = {})
    entry_name = options[:entry_name] || collection.entry_name
    entry_name = entry_name.pluralize unless collection.total_count == 1
    if collection.total_pages < 2
      
      t('helpers.admin_page_entries_info.one_page.display_entries', :entry_name => entry_name, :count => collection.total_count)
    else
      first = collection.offset_value + 1
      last = collection.last_page? ? collection.total_count : collection.offset_value + collection.limit_value
      t('helpers.admin_page_entries_info.more_pages.display_entries', :entry_name => entry_name, :first => first, :last => last, :total => collection.total_count)
    end.html_safe
  end
  def sortable_th(column, title=nil)
    title ||= column.titleize
    css_class = (column == sort_column) ? "sorting #{sort_direction}" : "sorting"
    direction = (column == sort_column && sort_direction == "asc") ? "desc" : "asc"
    content_tag :th, class: css_class do 
    link_to title, {:sort => column, :direction => direction},{:class=>"_link",:remote=>true}
    end
  end
end
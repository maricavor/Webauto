module SearchesHelper
  def link_to_search(s)
    s.name.nil? ? name=s.slug : name=s.name
    link_to name, send("search_#{s.type.name.underscore.pluralize}_path",s,:sort=>s.sort) if s
  end
end
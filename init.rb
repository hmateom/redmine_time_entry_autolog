Redmine::Plugin.register :redmine_time_entry_autolog do
  name 'Redmine Time Entry Autolog plugin'
  author 'hmateo'
  description 'Redmine Plugin for automatic time entry logging'
  version '0.0.1'
  author_url 'http://www.emergya.es'

  settings :default => {}, :partial => 'settings/time_entry_autolog'

  menu :top_menu, :time_entry_autolog, {:controller => :autolog_time_entries, :action => :index},
    :caption => :'time_entry_autolog.label_autolog_time_entries', :if => Proc.new{Setting.plugin_redmine_time_entry_autolog['authorized_users'].present? and Setting.plugin_redmine_time_entry_autolog['authorized_users'].include?(User.current.id.to_s)}
end

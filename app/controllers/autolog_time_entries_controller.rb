class AutologTimeEntriesController < ApplicationController
	layout 'base'
	before_filter :get_users, :only => [:index]

	def index
	end

	def save
		if request.post?
			begin
		  		@unsaved_entries = {}
		  		@saved_entries = {}
			  	te = {}
			  		
			  	if (params[:time_entry_autolog][:start_date].to_date <= params[:time_entry_autolog][:end_date].to_date)
			  		user = User.find(params[:time_entry_autolog][:user_id])
			  		issue = Issue.find(params[:time_entry_autolog][:issue_id])
			  		if (user.present? and issue.present?)
				  		start_date = params[:time_entry_autolog][:start_date].to_date
				  		end_date = params[:time_entry_autolog][:end_date].to_date
				  		hours = params[:time_entry_autolog][:hours].to_f
				  		number_of_days = weekdays_in_date_range(start_date..end_date)

				  		if (params[:time_entry_autolog][:mode] == 'winter' and Setting.plugin_redmine_time_entry_autolog['winter_workday_hours'].present?)
				  			remaining_hours = hours

				  			(start_date..end_date).each do |d|
				  				if d.cwday < 6 and Setting.plugin_redmine_time_entry_autolog['winter_workday_hours'][d.cwday.to_s].present?
				  					remaining_hours -= (Setting.plugin_redmine_time_entry_autolog['winter_workday_hours'][d.cwday.to_s]).to_f
				  				end
				  			end

				  			workday_hours = remaining_hours/number_of_days

			  			elsif (params[:time_entry_autolog][:mode] == 'equitable')
			  				workday_hours = hours/number_of_days
			  			end

				  		(start_date..end_date).each do |d|
				  			if d.cwday < 6
				  				te[:user] = user
						  		te[:issue] = issue
						  		te[:spent_on] = d
						  		if (params[:time_entry_autolog][:mode] == 'winter' and Setting.plugin_redmine_time_entry_autolog['winter_workday_hours'][d.cwday.to_s].present?)
						  			te[:hours] = workday_hours + Setting.plugin_redmine_time_entry_autolog['winter_workday_hours'][d.cwday.to_s].to_f
						  		else
						  			te[:hours] = workday_hours
						  		end
					  			time_entry = TimeEntry.create(te)

					  			if time_entry.new_record?
					        		@unsaved_entries[d] = time_entry
						      	else
						        	@saved_entries[d] = time_entry
						       	end
				  			end
				    	end
				    end
			  	end

			  	if @unsaved_entries.present?
			  		flash[:error] = l(:notice_import_finished_with_errors, :count => @unsaved_entries.count, :total => (@unsaved_entries.count + @saved_entries.count))
			  	else
			  		flash[:notice] = l(:notice_import_finished, :count => @saved_entries.count)
			  	end
			rescue
                flash[:error] = l(:'time_entry_autolog.error_autolog_failed')
            end
		  	
			respond_to do |format|
				format.js {}
			end

			redirect_to action: "index"
		end
	end

	def get_users
		@users = User.all.order(:login)
        @name_field = 'login'
	end

	protected
  	def weekdays_in_date_range(range)
    	range.select { |d| (1..5).include?(d.wday) }.size
  	end

end
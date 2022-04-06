class AutologTimeEntriesController < ApplicationController
	layout 'base'
	before_filter :get_users, :only => [:index]

	def index
	end

	def save
		if request.post?
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
			  		workday_hours = hours/number_of_days

			  		(start_date..end_date).each do |d|
			  			if d.cwday < 6
			  				te[:user] = user
					  		te[:issue] = issue
					  		te[:spent_on] = d
					  		te[:hours] = workday_hours
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

		  	flash[:notice] = @saved_entries
		  	flash[:error] = @unsaved_entries
		  	
			respond_to do |format|
				format.js {}
			end

			redirect_to synch_relations_path
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
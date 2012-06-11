require 'csv_importer'

class EditorController < ApplicationController
  autocomplete :variable, :name
  
  TIME_EXTRACTOR = /(?<from_hour>\d{1,2})\s*-\s*(?<to_hour>\d{1,2})/
  DATE_EXTRACTOR = /(?<month>\d{2})\/(?<day>\d{2})\/(?<year>\d+)/
  
  def select
    @models = Model.find(session[:model_id])
  end
  
  def equations
    model_id = session[:model_id]
    new_equation = params[:new_equation]
    if !new_equation.nil?
      begin
        Variable.create_from_form(new_equation, model_id)
      rescue Exception => e
        flash.now[:variable_error] = e.message.split("^^^")[1] || e.message
      else
        flash.now[:variable_success] = 'Your variable was successfully saved.'
      end
    else
      new_constant_array = params[:new_constant_array]
      if !new_constant_array.nil?
        begin
          Variable.create_constant_array(new_constant_array, model_id)
        rescue Exception => e
          flash.now[:variable_error] = e.message.split("^^^")[1] || e.message
        else
          flash.now[:variable_success] = 'Your variable was successfully saved.'
        end
      end
    end
    @variables = Variable.where(:model_id => model_id).order(:name)
    render 'equations'
  end
  
  def create_events
    create_events_hash = params[:create_events]
    if !create_events_hash.nil?
      event_name = create_events_hash[:name]
      if !event_name.nil?
        description = create_events_hash[:description]
        time_range = create_events_hash[:time_range]
        time_range_match = TIME_EXTRACTOR.match(time_range)
        if !time_range_match.nil?
          from_hour = time_range_match[:from_hour].to_i
          to_hour = time_range_match[:to_hour].to_i
          if from_hour <= to_hour
            from_date_string = create_events_hash[:from_date]
            from_date = parse_date_string(from_date_string)
            to_date_string = create_events_hash[:to_date]
            to_date = parse_date_string(to_date_string)
            week = create_events_hash[:week].collect {|repeats_on| repeats_on == '1'}
            curr_date = from_date
            from_dates = []
            to_dates = []
            while curr_date <= to_date
              curr_from = curr_date + from_hour.hours
              from_dates << curr_from.strftime('%Y_%m_%d_%H_%M_%S')
              curr_to = curr_date + to_hour.hours
              to_dates << curr_to.strftime('%Y_%m_%d_%H_%M_%S')
              curr_date += 1.day
            end
            from_expression_string = '[i | ' + from_dates.join(', ') + ']'
            to_expression_string = '[i | ' + to_dates.join(', ') + ']'
            from_variable = Variable.new(:name => event_name + '_from', :array => 1, :description => description, :model_id => session[:model_id],
                                         :variable_type => 3, :expression_string => from_expression_string)
            to_variable = Variable.new(:name => event_name + '_to', :array => 1, :description => description, :model_id => session[:model_id],
                                       :variable_type => 3, :expression_string => to_expression_string)
            Variable.transaction do
              from_variable.save!
              to_variable.save!
              IndexName.create_from_declaration("#{from_variable.name}[#{CsvImporter::INDEX}]", from_variable.id)
              IndexName.create_from_declaration("#{to_variable.name}[#{CsvImporter::INDEX}]", to_variable.id)
            end
          end
        end
      end
    end
    redirect_to :back
  end
  
  def parse_date_string(date_string)
    date_match = DATE_EXTRACTOR.match(date_string)
    if date_match.nil?
      return nil
    end
    year = date_match[:year].to_i
    month = date_match[:month].to_i
    day = date_match[:day].to_i
    return Time.new(year, month, day)
  end
  
  def find_variable_names
    # TODO: This will break if params[:term] contains a percent symbol. It needs to use escaping.
    model_id = session[:model_id]
    @variable_names = Variable.where('(model_id = ?) AND (name LIKE ?)', model_id, "#{params[:term]}%").order(:name)
    respond_to do |format|
      format.js { render :layout => false }
    end
  end
  
  def variable
    variable_form = params[:variable]
    if !variable_form.nil?
      variable_name_with_indices = variable_form[:name_with_indices]
      expression_string = variable_form[:expression_string]
      Variable.transaction do
        variable_record = Variable.where(:id => variable_form[:id]).first
        if variable_record.nil?
          flash[:unrecognized_variable] = "The variable you tried to edit, #{variable_name}, was probably recently" +
            " deleted by a member of your team. Your equation, #{expression_string}, was not saved."
        else
          variable_record.name_with_indices = variable_name_with_indices
          variable_record.expression_string = expression_string
          if !variable_record.save!
            flash[:variable_error] = variable_record.errors.full_messages
          end
        end
      end
    end
    redirect_to :back
  end
  
  def delete_variable
    Variable.transaction do
      variable = Variable.where(:id => params[:id], :model_id => params[:model_id]).first
      if !variable.nil?
        variable.destroy
      end
    end
    redirect_to :back
  end
  
  def delete_relationship
    Variable.transaction do
      variable = Variable.where(:id => params[:id]).first
      if !variable.nil?
        variable.expression_string = nil
        variable.save!
      end
    end
    redirect_to :back
  end
  
  def full_variable
    @var = Variable.where(:name => params[:name], :model_id => params[:model_id]).first
  end
  
end

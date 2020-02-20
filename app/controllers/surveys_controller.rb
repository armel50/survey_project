class SurveysController < ApplicationController
  def index
    @surveys = Survey.all
  end

  def new
    @survey = Survey.new()
  end

  def create
    # create survey
    @survey = Survey.create(name: survey_params[:name])

    #create the question

    if survey_params[:questions1]
        
        survey_params[:questions1].each do |question|
          # binding.pry
          new_question = @survey.survey_questions.create({question: question[:question][:content],is_fixed: true})
          new_option = question[:question][:question_options].each{|option| new_option = new_question.question_options.create({option_text: option})  }
        # binding.pry
        end
    end

      if survey_params[:questions]
          survey_params[:questions].each do |question|
            @survey.survey_questions.create({question: question})
            # binding.pry
          end
      end

    
    # binding.pry

    if !@survey.errors.any? 
      redirect_to @survey
    else 
      render :new
    end
    
  end

  def show 
    @survey = Survey.find(params[:id])
  end
  def edit
  end

  def update
  end

  private

  def survey_params
    params.require(:survey).permit!
  end

end

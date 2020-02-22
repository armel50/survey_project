class SurveysController < ApplicationController
  def index
    @surveys = Survey.all
  end

  def new
    @survey = Survey.new()
  end

  def create
    #In this code let's agree that 'questions1' represent the question for the fixed answer 
    #And 'questions' represent the question for the free answer

    # create survey
    @survey = Survey.create(name: survey_params[:name])

    #create the question

    if survey_params[:questions1]
        
        survey_params[:questions1].each do |question|
          # binding.pry
          new_question = @survey.survey_questions.create({question: question[:question][:content],order: question[:question][:order],is_fixed: true})
          new_option = question[:question][:question_options].each{|option| new_option = new_question.question_options.create({option_text: option})  }
        # binding.pry
        end
    end

      if survey_params[:questions]
          survey_params[:questions].each do |question|
            # binding.pry

            @survey.survey_questions.create({question: question[:question][:content], order: question[:question][:order]})
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
    @survey = Survey.find(params[:id])
  end

  def update
    # binding.pry
    @survey = Survey.find(params.require(:id))
    @survey.name = survey_params[:name]
    #iterate through the questions array
    survey_params[:questions].each do |el| 
      #el is an hash with only one key which is the id of a question
      el.keys.each do |key|
        survey_question = SurveyQuestion.find(key)
        survey_question.question = el[key]
        survey_question.save
      end
    end
    
    survey_params[:questions1].each do |el| 
      #el is an hash with only one key which is the id of a question
      el.keys.each do |key|
        survey_question = SurveyQuestion.find(key)
        survey_question.question = el[key]
        survey_question.save
      end

    end

    survey_params[:options].each do |el| 
      #el is an hash with with multiple keys which are the ids of an option
      el.keys.each do |key|
      # binding.pry
        question_option = QuestionOption.find(key)
        question_option.option_text = el[key]
        question_option.save
      end
      
    end


    if @survey.save 

      redirect_to @survey
    else 
      #we will handle errors here
      redirect_to edit_survey_path(@survey)
    end
  end

  private

  def survey_params
    params.require(:survey).permit!
  end

end

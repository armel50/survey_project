class SurveyQuestionsController < ApplicationController
  def index
    @survey = Survey.find( params.permit("survey_id")[:survey_id])
    @questions = SurveyQuestion.all.where("survey_id= ?", @survey.id)

  end

  def new
    @survey = Survey.find( params.permit("survey_id")[:survey_id])
    @question = SurveyQuestion.new
    
  end

  def create
    @survey = Survey.find( params.permit("survey_id")[:survey_id])
   if survey_question_params[:questions]
     question = @survey.survey_questions.create({question: survey_question_params[:questions] })
   else

    question = @survey.survey_questions.create({question: survey_question_params[:questions1][:question], is_fixed: true })
    survey_question_params[:questions1][:options].each do |option|
     option = question.question_options.create({option_text: option})
    end
   end
   if !@survey.errors.any? 
    redirect_to @survey
   else
    redirect_to :back
  end
  end

  def edit
    @survey = Survey.find(params.require(:survey_id))
    @question = SurveyQuestion.find(params.require("id"))
  end

  def update
    #find the survey and the question
    @survey = Survey.find(params.require(:survey_id))
    @question = SurveyQuestion.find(params.require("id"))

   if survey_question_params[:questions1]

      @question.is_fixed = true 
      @question.question = survey_question_params[:questions1][:question]
      #remove existing option
      if @question.question_options.length > 0 
        @question.question_options.each {|option| option.delete}
        
      end
      @question.save

      #iterate through the options
      survey_question_params[:questions1][:options].each do |key,val|
        # binding.pry
        if key != "new"
          option = QuestionOption.find(key)
          option.option_text = survey_question_params[:questions1][:options][key]
          # binding.pry
          option.save 
        else
          survey_question_params[:questions1][:options][key].each do |option|
            new_option = @question.question_options.create({option_text: option})
          end
          # binding.pry
        end
      

      end
   else
     @question.is_fixed = false 
      @question.question = survey_question_params[:question]
      @question.save
   end
  #check if there is an error
   if !@survey.errors.any? 
    redirect_to @survey
    
  else 
    redirect_to :back
  end
    
  end

  private

  def survey_question_params
    params.require(:survey_question).permit!
  end
end

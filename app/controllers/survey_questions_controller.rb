class SurveyQuestionsController < ApplicationController
  def index
    @questions = SurveyQuestion.all
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
    @question = SurveyQuestion.find(params[:id])
  end

  def update
  end

  private

  def survey_question_params
    params.require(:survey_question).permit!
  end
end

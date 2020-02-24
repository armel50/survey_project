class SurveysController < ApplicationController
  def index
    @surveys = Survey.all
  end

  def new
    @survey = Survey.new()
  end

  def create
    flash[:errors] = []
    #In this code let's agree that 'questions1' represent the question for the fixed answer 
    #And 'questions' represent the question for the free answer

    # create survey
    @survey = Survey.new(name: survey_params[:name])
    # binding.pry
    #  @survey.errors.full_messages.each{|msg| flash[:errors]  << msg} if @survey.errors.any?

     flash[:errors] << "Surveys must have a name" if survey_params[:name] == ""

    #Let's get an array of all the order 
    orders = []
    survey_params[:questions1].each{|el| orders << el[:question][:order]} if  survey_params[:questions1]
    survey_params[:questions].each{|el| orders << el[:question][:order]} if  survey_params[:questions]
   
    flash[:errors] << "Questions can't have the same order" if orders.uniq.length != orders.length
    # binding.pry

    #create the question 
    
    if survey_params[:questions1] 
        
        survey_params[:questions1].each do |question|
          new_question = @survey.survey_questions.build({question: question[:question][:content],order: question[:question][:order],is_fixed: true}) 

            flash[:errors] << "Questions can't be blank"  if new_question.question == ""

            # binding.pry
       
              question[:question][:question_options].each do |option| 
                  new_option = new_question.question_options.build({option_text: option})
                flash[:errors] << "Option can't be blank" if new_option.option_text == ""
              
          end
          
        # binding.pry
        end
    end

      if survey_params[:questions]
          survey_params[:questions].each do |question|

           new_question =  @survey.survey_questions.build({question: question[:question][:content], order: question[:question][:order]}) 
           flash[:errors] << "Questions can't be blank"  if new_question.question == ""

            
              new_question.errors.full_messages.each{|msg| @survey.errors.full_messages << msg[:question]} if new_question.errors.any?
            # binding.pry
          end
      end

    
    # binding.pry

    if  @survey.save && flash[:errors].empty?

      redirect_to @survey
    else 
      flash[:errors] = flash[:errors].uniq
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
    flash[:errors] = []
    @survey = Survey.find(params.require(:id))
    @survey.name = survey_params[:name]
    flash[:errors] <<  "Surveys must have a name"  if @survey.name == ""

    #check if the questions have the same order
    orders = []
    survey_params[:questions1].each{|el| el.keys.each{|key| orders << el[key][:order]} } if  survey_params[:questions1]
    survey_params[:questions].each{|el|  el.keys.each{|key| orders << el[key][:order]} } if  survey_params[:questions]
   
    flash[:errors] << "Questions can't have the same order" if orders.uniq.length != orders.length

    #iterate through the questions array
    if survey_params[:questions]
          survey_params[:questions].each do |el| 
                #el is an hash with only one key which is the id of a question
                el.keys.each do |key|
                  survey_question = SurveyQuestion.find(key)
                  survey_question.question = el[key][:question]
                  survey_question.order = el[key][:order]
                  flash[:errors] << "Questions can't be blank" if survey_question.question == ""
                  # binding.pry 
                   
                    
                      survey_question.save if flash[:errors].empty?
                    
                end
          end
    end
    if survey_params[:questions1]
        # binding.pry
          survey_params[:questions1].each do |el| 
            #el is an hash with only one key which is the id of a question
            el.keys.each do |key|
              survey_question = SurveyQuestion.find(key)
              survey_question.question = el[key][:question]
              survey_question.order = el[key][:order]
              # binding.pry
              flash[:errors] << "Questions can't be blank" if survey_question.question == ""

              survey_question.save if flash[:errors].empty?


            end

        end  
        
        survey_params[:options].each do |el| 
      #el is an hash with with multiple keys which are the ids of an option
      el.keys.each do |key|
      # binding.pry
        question_option = QuestionOption.find(key)
        question_option.option_text = el[key]
        # binding.pry
        flash[:errors] << "Option can't be blank" if question_option.option_text == ""

        question_option.save if flash[:errors].empty?
      end


  end

  
      
    end


    if flash[:errors].empty?
      @survey.save
      redirect_to @survey
    else 
      #we will handle errors here
      flash[:errors] = flash[:errors].uniq
      redirect_to edit_survey_path(@survey)
    end
  end

  private

  def survey_params
    params.require(:survey).permit!
  end

end

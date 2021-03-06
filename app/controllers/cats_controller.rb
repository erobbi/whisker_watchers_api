class CatsController < ApplicationController
  skip_before_action :authorize, only: :bcscalculator

  def index
    cats = Cat.where(user_id: session[:user_id])
    render json: cats, status: :ok
  end

  def show
    cat = Cat.find_by(id: params[:id])
    render json: cat, status: :ok
  end

  def create
    cat = @current_user.cats.create!(name: cat_params[:name], age: cat_params[:age], cat_url: cat_params[:cat_url], caloriesPerDay: cat_params[:caloriesPerDay], bcs: cat_params[:bcs], isNeutered: cat_params[:isNeutered])
    Weight.create!(weight: cat_params[:weight], cat_id: @current_user.cats.last.id)
    render json: cat, status: :created
  end

  def destroy
    cat = Cat.find(params[:id])
    cat.destroy
    head :no_content
  end

  def bcscalculator
    bcs = params[:BCS].to_f
    cw = params[:currentWeight].to_f
    isNuetered = params[:isNuetered]

    ratioOverweight = (0.1 * bcs - 0.5)
    percentOverweight = (ratioOverweight * 100).to_i
    warning = percentOverweight < 0
    suggestedIdealWeight = (cw - (cw * ratioOverweight)).round(1) if bcs > 5
    rer = (bcs / 2.2) ** 0.75
    rer = (rer * 70).to_i
    if bcs < 6
      if isNuetered = "true"
        suggestedCalories = rer * 1.0
      elsif isNuetered = "false"
        suggestedCalories = rer * 1.2
      end
    elsif bcs >= 6
      suggestedCalories = rer * 0.8
    end

    suggestedCalories = suggestedCalories.round

    if bcs.between?(6, 8)
      message = "Your cat is #{percentOverweight}% overweight!\nSuggested ideal weight is #{suggestedIdealWeight} pounds"
    elsif bcs >= 8
      message = "Your cat is obese!\nYour cat is #{percentOverweight}% over ideal weight.\nSuggested ideal weight is #{suggestedIdealWeight} pounds"
    elsif bcs.between?(4, 5)
      message = "Your cat is a perfect weight!"
    elsif bcs < 4
      message = "Your cat is underweight."
    else
      message = "Error."
    end

    bodyFat = params[:currentWeight] * 100

    messageCalories = "Suggested intake is #{suggestedCalories} Calories per day."

    render json: [percentOverWeight: percentOverweight, warning: warning, suggestedCalories: suggestedCalories, message: message, messageCalories: messageCalories],
           status: :accepted
  end

  def chartdata
    byebug
  end

  private

  def cat_params
    params.permit(:name, :age, :cat_url, :caloriesPerDay, :bcs, :id, :isNeutered, :weight)
  end
end

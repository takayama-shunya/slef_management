class ConditionsController < TopController

  before_action :authenticate_user!
  before_action :set_condition, only: %i[ edit show destroy update ]
  before_action :today_condition_create_not_2time, only: %i[ new create ]


  def new
    @condition = Condition.new
  end

  def create
    @condition = current_user.conditions.build(condition_params)
    if params[:back]
      render :new
    else
      if @condition.save
        redirect_to condition_path(@condition.id), notice: "created condition"
      else
        render :new
      end
    end
  end

  def index
    condition_average_value
    set_index_condition_date
  end

  def edit
  end

  def update
    if @condition.update(condition_params)
      redirect_to condition_path(@condition.id), notice: "updated condition"
    else
      rende :edit
    end
  end

  def destroy
    @condition.destroy
    redirect_to top_index_path, notice: "deleted condition"
  end

  def show
  end

  private

  def set_condition
    @condition = Condition.find(params[:id])
  end

  def condition_params
    params.require(:condition).permit(
      :retirung_time, :rising_time, :sleep_time, :sleep_quality, :meal_count, :stress_level,
      :toughness, :stress_recovery_balance, :positive_level, :enrichment_happiness_level,
      :negative_comment, :positive_comment)
  end

  def today_condition_create_not_2time
    redirect_to top_index_path, alert: "today condition create 1time" if today_condition.present?
  end

  def set_index_condition_date
    @conditions = Condition.where(user_id: current_user.id).order(created_at: :desc).page(params[:page])

    score = []
    created_at = []
    #graph_condition_date = @conditions.order(created)

    @conditions.reverse.each do |condition|
      condition_score = condition.sleep_time + condition.sleep_quality +
                        condition.meal_count + condition.stress_level +
                        condition.toughness + condition.stress_recovery_balance + 
                        condition.positive_level + condition.enrichment_happiness_level
      score << condition_score
      created_at << condition.created_at.strftime('%m/%d')
    end

    gon.condition_score = score
    gon.condition_created_at = created_at
  end

end


# <% @index_condition_score << index_condition_score %>
# <% @index_condition_created << condition.created_at %>

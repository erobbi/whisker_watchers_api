class Cat < ApplicationRecord
  belongs_to :user
  has_many :weights, dependent: :destroy

  def currentWeight
    if self.weights.last
      self.weights.last.weight.to_f.round(1)
    end
  end

  def goalWeight
    bcs = self.bcs
    cw = self.currentWeight
    ratioOverweight = (0.1 * bcs - 0.5)
    if bcs > 5
      suggestedIdealWeight = (cw - (cw * ratioOverweight)).to_f.round(1)
    else
      suggestedIdealWeight = cw
    end
    return suggestedIdealWeight
  end

  def suggestedCaloriesPerDay
    if self.bcs
      bcs = self.bcs
      rer = ((bcs) / 2.2) ** 0.75
      rer = (rer * 70).to_i
      return rer
    end
  end
end

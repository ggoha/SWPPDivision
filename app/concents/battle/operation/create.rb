class Battle < ApplicationRecord
  class Create < Trailblazer::Operation
    model Battle, :create

    contract do
      property :at
      property :raw

      validates :body, presence: true
    end

    def process(params)
      validate() do
        contract.save
      end
    end
  end
end

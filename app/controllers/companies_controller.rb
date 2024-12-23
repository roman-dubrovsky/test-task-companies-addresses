# frozen_string_literal: true

class CompaniesController < ApplicationController
  def create
    result = Companies::Create.new.call(company_params)

    if result.success?
      render status: :created, json: result.success
    else
      render status: :bad_request, json: result.failure
    end
  end

  def import
    head :not_found
  end

  private

  def company_params
    params.require(:company).permit(
      :name,
      :registration_number,
      addresses: %i[street city postal_code country],
    )
  end
end

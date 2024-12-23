# frozen_string_literal: true

class CompaniesController < ApplicationController
  def create
    company = CompanyContract.new.call(company_params.to_h)

    if company.success?
      head :created
    else
      render status: :bad_request, json: company.errors.to_h
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

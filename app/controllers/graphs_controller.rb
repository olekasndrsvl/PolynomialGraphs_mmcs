class GraphsController < ApplicationController
  def index
  end

  def calculate
    coefficients = params[:coefficients].split(',').map(&:to_f)
    x_range = (-10.0..10.0).step(0.5).to_a

    points = x_range.map do |x|
      y = coefficients.each_with_index.sum do |coeff, index|
        coeff * x**(coefficients.size - index - 1)
      end
      { x: x, y: y }
    end

    render json: { points: points }
  end
end
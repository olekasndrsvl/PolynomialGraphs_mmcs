class GraphsController < ApplicationController
  def index
  end

  def trigonometric_calculate
    trig_function = params[:coefficients]
    x_range = (-10.0..10.0).step(0.1).to_a

    points = x_range.map do |x|
      y = case trig_function
          when /sin/i then Math.sin(x)
          when /cos/i then Math.cos(x)
          when /tan/i then Math.tan(x)
          when /ctan/i then
            tan_x = Math.tan(x)
            tan_x.zero? ? Float::NAN : 1.0 / tan_x
          else 0
          end

      { x: x, y: y }
    end

    render json: {
      points: points,
      integral: "Не вычисляется для тригонометрических функций",
      definite: "Не вычисляется для тригонометрических функций"
    }
  end

  def calculate

    # Создаем полином и вычисляем интегралы
    coefficients = params[:coefficients].split(',').map do |c|
      Float(c.strip) rescue nil
    end.compact

    raise ArgumentError, "Введите хотя бы один коэффициент" if coefficients.empty?
    raise ArgumentError, "Недопустимые символы в коэффициентах" if coefficients.any?(&:nil?)



    x_range = (-10.0..10.0).step(0.5).to_a

    # Рассчитываем интегралы
    poly = PolynomialCalculus::Polynomial.new(coefficients)
    indefinite_integral = poly.indefinite_integral
    definite_value = poly.definite_integral(1, 5) # Можно сделать параметры настраиваемыми

    # Готовим данные для графика
    points = x_range.map do |x|
      y = coefficients.each_with_index.sum do |coeff, index|
        coeff * x**(coefficients.size - index - 1)
      end
      { x: x, y: y }
    end



    render json: {
      points: points,
      integral: indefinite_integral.to_s,
      definite: definite_value.round(4)
    }
  end
end
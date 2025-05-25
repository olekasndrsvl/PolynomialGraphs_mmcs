class GraphsController < ApplicationController
  def index
  end

  def trigonometric_calculate
    trig_function = params[:coefficients]

    x_min = params[:x_min].present? ? params[:x_min].to_f : -10.0
    x_max = params[:x_max].present? ? params[:x_max].to_f : 10.0
    # Проверка корректности диапазона только если параметры были переданы
    if params[:x_min].present? || params[:x_max].present?
      if x_min >= x_max
        render json: { error: "Минимальное значение X должно быть меньше максимального" }, status: :bad_request
        return
      end
    end

    x_range = (x_min..x_max).step(0.1).to_a

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

    x_min = params[:x_min].present? ? params[:x_min].to_f : -10.0
    x_max = params[:x_max].present? ? params[:x_max].to_f : 10.0
    step = params[:step].present? ? params[:step].to_f : 0.5
    y_max = params[:y_max].present? ? params[:y_max].to_f : nil

    # Проверка корректности диапазона только если параметры были переданы
    if params[:x_min].present? || params[:x_max].present?
      if x_min >= x_max
        render json: { error: "Минимальное значение X должно быть меньше максимального" }, status: :bad_request
        return
      end
    end

    if params[:step].present? && step <= 0
      render json: { error: "Шаг должен быть положительным числом" }, status: :bad_request
      return
    end

    x_range = (x_min..x_max).step(step).to_a

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

    y_values = points.map { |p| p[:y] }.reject { |y| y.nan? || y.infinite? } # Исключаем NaN значения
    calculated_y_max = y_values.max || 10.0
    calculated_y_min = y_values.min || 0
    y_min = 0
    y_max = params[:y_max].present? ? params[:y_max].to_f : [calculated_y_max, calculated_y_min.abs].max


    render json: {
      points: points,
      integral: indefinite_integral.to_s,
      definite: definite_value.round(4),
      y_range: {
        min: y_min,
        max: y_max
      }
    }
  end
end
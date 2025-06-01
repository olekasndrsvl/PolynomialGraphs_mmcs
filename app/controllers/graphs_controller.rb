class GraphsController < ApplicationController
  def index
  end
  def trigonometric_calculate
    function_str = params[:coefficients].downcase.strip

    # Обработка диапазона X
    x_min = params[:x_min].present? ? params[:x_min].to_f : -10.0
    x_max = params[:x_max].present? ? params[:x_max].to_f : 10.0

    if x_min >= x_max
      return render json: { error: "Минимальное значение X должно быть меньше максимального" }, status: :bad_request
    end

    match = function_str.match(/^(\d*\.?\d*)(sin|cos|tan|ctg|ctan|cot)\((\d*\.?\d*)x([+\-]\d*\.?\d*)?\)$/i)

    unless match
      return render json: {
        error: "Неверный формат функции. Примеры: 2sin(3x), cos(2x+1), tan(123x), ctan(42x)",
        received: function_str
      }, status: :bad_request
    end

    coefficient = match[1].empty? ? 1.0 : match[1].to_f
    func = match[2].downcase
    inner_coeff = match[3].empty? ? 1.0 : match[3].to_f
    inner_const = match[4] ? match[4].to_f : 0.0

    # Создаем тригонометрическую функцию
    trig_function = TrigonometricCalculus::TrigonometricFunction.new(
      coefficient: coefficient,
      function: func,
      inner_coefficient: inner_coeff,
      inner_constant: inner_const
    )

    step = [0.1, 0.5 / inner_coeff.abs].max
    x_range = (x_min..x_max).step(step).to_a

    points = x_range.map do |x|
      inner_value = inner_coeff * x + inner_const
      y = case func
          when 'sin' then coefficient * Math.sin(inner_value)
          when 'cos' then coefficient * Math.cos(inner_value)
          when 'tan' then coefficient * Math.tan(inner_value)
          when 'cot', 'ctan', 'ctg' then
            tan_val = Math.tan(inner_value)
            tan_val.zero? ? Float::NAN : coefficient / tan_val
          else 0
          end

      { x: x.round(4), y: y.nan? ? nil : y.round(6) }
    end.compact

    render json: {
      points: points,
      integral: trig_function.indefinite_integral,
      definite: "#{trig_function.definite_integral(x_min, x_max).round(6)}"
    }
  rescue => e
    render json: {
      error: "Ошибка обработки функции",
      details: e.message,
      backtrace: Rails.env.development? ? e.backtrace : nil
    }, status: :internal_server_error
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
class GraphsController < ApplicationController
  def index
  end

  def trigonometric_calculate
    trig_function = params[:trig_function]
    argument = params[:argument].presence || 'x'

    # Безопасная проверка аргумента
    unless argument.match?(/^[\d\s\.x+\-*\/()]+$/)
      render json: { error: "Недопустимые символы в аргументе функции" }, status: :bad_request
      return
    end

    # Автоматически определяем диапазон x в зависимости от частоты
    frequency = argument.include?('*x') ? argument.split('*x').first.to_f : 1.0
    x_range = if frequency > 10
                # Для высоких частот уменьшаем диапазон
                step = 0.1 / frequency
                (-2.0..2.0).step(step).to_a
              else
                (-10.0..10.0).step(0.1).to_a
              end

    points = x_range.map do |x|
      safe_arg = argument.gsub('x', x.to_s)
      begin
        calculated_arg = Dentaku::Calculator.new.evaluate(safe_arg) rescue 0
      rescue
        calculated_arg = 0
      end

      y = case trig_function
          when 'sin' then Math.sin(calculated_arg)
          when 'cos' then Math.cos(calculated_arg)
          when 'tan' then Math.tan(calculated_arg)
          when 'ctg' then 1.0 / Math.tan(calculated_arg)
          else 0
          end

      { x: x, y: y }
    end

    render json: {
      points: points,
      label: "#{trig_function}(#{argument})"
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
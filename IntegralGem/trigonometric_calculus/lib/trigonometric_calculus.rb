# frozen_string_literal: true

require_relative "trigonometric_calculus/version"

module TrigonometricCalculus
  class TrigonometricFunction
    def initialize(coefficient:, function:, inner_coefficient:, inner_constant:)
      @coefficient = coefficient.to_f
      @function = function.downcase
      @inner_coefficient = inner_coefficient.to_f
      @inner_constant = inner_constant.to_f
    end

    # Неопределенный интеграл
    def indefinite_integral
      if @inner_coefficient.zero?
        return "Неопределенный интеграл: константа"
      end

      case @function
      when 'sin'
        integral_coeff = -@coefficient / @inner_coefficient
        "#{integral_coeff}cos(#{@inner_coefficient}x#{format_constant(@inner_constant)}) + C"
      when 'cos'
        integral_coeff = @coefficient / @inner_coefficient
        "#{integral_coeff}sin(#{@inner_coefficient}x#{format_constant(@inner_constant)}) + C"
      when 'tan'
        integral_coeff = @coefficient / @inner_coefficient
        "#{-integral_coeff}ln|cos(#{@inner_coefficient}x#{format_constant(@inner_constant)})| + C"
      when 'ctan', 'cot', 'ctg'
        integral_coeff = @coefficient / @inner_coefficient
        "#{integral_coeff}ln|sin(#{@inner_coefficient}x#{format_constant(@inner_constant)})| + C"
      else
        "Неизвестная тригонометрическая функция"
      end
    end

    # Определенный интеграл между a и b
    def definite_integral(a, b)
      if @inner_coefficient.zero?
        return @coefficient * (b - a) * Math.send(@function, @inner_constant)
      end

      antiderivative_a = evaluate_antiderivative(a)
      antiderivative_b = evaluate_antiderivative(b)

      antiderivative_b - antiderivative_a
    rescue => e
      "Не удалось вычислить определенный интеграл: #{e.message}"
    end

    private

    def evaluate_antiderivative(x)
      inner_value = @inner_coefficient * x + @inner_constant

      case @function
      when 'sin'
        (-@coefficient / @inner_coefficient) * Math.cos(inner_value)
      when 'cos'
        (@coefficient / @inner_coefficient) * Math.sin(inner_value)
      when 'tan'
        (-@coefficient / @inner_coefficient) * Math.log(Math.cos(inner_value).abs)
      when 'ctan', 'cot', 'ctg'
        (@coefficient / @inner_coefficient) * Math.log(Math.sin(inner_value).abs)
      else
        0
      end
    end

    def format_constant(constant)
      return "" if constant.zero?
      constant.positive? ? "+#{constant}" : constant.to_s
    end
  end
end

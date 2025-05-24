# frozen_string_literal: true

require_relative "polynomial_calculus/version"

require 'active_support/core_ext/array'

module PolynomialCalculus
  class Polynomial
    def initialize(coefficients)
      @coefficients = coefficients.map(&:to_f)
    end

    # Неопределенный интеграл (возвращает новый полином + константу)
    def indefinite_integral
      new_coefficients = @coefficients.each_with_index.map do |coeff, index|
        power = @coefficients.size - index - 1
        coeff / (power + 1)
      end

      new_coefficients << 0.0 # Добавляем свободный член (x^0)
      Polynomial.new(new_coefficients)
    end

    # Определенный интеграл между a и b
    def definite_integral(a, b)
      antiderivative = indefinite_integral
      antiderivative.evaluate(b) - antiderivative.evaluate(a)
    end

    # Вычисление значения полинома в точке x
    def evaluate(x)
      @coefficients.each_with_index.sum do |coeff, index|
        power = @coefficients.size - index - 1
        coeff * (x ** power)
      end
    end

    # Строковое представление полинома
    def to_s
      terms = @coefficients.each_with_index.map do |coeff, index|
        power = @coefficients.size - index - 1
        next if coeff.zero?

        term =
          case power
          when 0 then coeff.to_s
          when 1 then "#{coeff}x"
          else "#{coeff}x^#{power}"
          end

        term.gsub(/\.0$/, '') # Убираем .0 для целых чисел
      end.compact

      terms.join(" + ").gsub('+ -', '- ') + " + C"
    end
  end
end

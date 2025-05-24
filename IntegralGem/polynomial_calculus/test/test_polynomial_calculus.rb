# frozen_string_literal: true

require "test_helper"

class TestPolynomialCalculus < Minitest::Test
  require 'polynomial_calculus'
   def test_indefinite_integral_calculation
      poly = PolynomialCalculus::Polynomial.new([2, 0, 3, 5])
      integral = poly.indefinite_integral
      assert_equal "0.5x^4 + 1.5x^2 + 5x + C", integral.to_s
    end

    def test_definite_integral_calculation
      poly = PolynomialCalculus::Polynomial.new([1, 0, 0]) # x^2
      result = poly.definite_integral(1, 2)
      assert_in_delta 2.333, result, 0.001
    end

    def test_polynomial_string_representation
      poly = PolynomialCalculus::Polynomial.new([3, 0, -2, 1.5])
      integral = poly.indefinite_integral
      assert_equal "0.75x^4 + -1.0x^3 + 1.5x^2 + C", integral.to_s
    end

    def test_zero_coefficients_handling
      poly = PolynomialCalculus::Polynomial.new([0, 0, 4])
      integral = poly.indefinite_integral
      assert_equal "2.0x^2 + 4x + C", integral.to_s
    end
end

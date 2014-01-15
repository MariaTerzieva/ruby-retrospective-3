class Integer
  def prime?
    return false if self < 0
    2.upto(self - 1).all? { |i| remainder(i).nonzero? }
  end

  def prime_factors
    prime_factors_array, upper_limit = [], abs
    2.upto(upper_limit).each do |i|
      while upper_limit.remainder(i).zero?
        upper_limit /= i
        prime_factors_array << i
      end
    end
    prime_factors_array
  end

  def harmonic
    0.upto(self).inject { |sum, i| sum + 1 / Rational(i) }
  end

  def digits
    abs.to_s.split('').map { |string_digit| string_digit.to_i }
  end
end

class Array
  def frequencies
    frequencies_hash = Hash.new(0)
    each { |value| frequencies_hash[value] += 1 }
    frequencies_hash
  end

  def average
    reduce(:+).to_f / size
  end

  def drop_every(n)
    select.with_index { |_, index| (index + 1).remainder(n).nonzero? }
  end

  def combine_with(other)
    zip(other).flatten.compact
  end
end
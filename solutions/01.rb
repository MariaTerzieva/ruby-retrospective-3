class Integer
  def prime?
    return false if self < 2
    2.upto(pred).all? { |i| remainder(i).nonzero? }
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
    0.upto(self).reduce { |sum, i| sum + Rational(1, i) }
  end

  def digits
    abs.to_s.chars.map(&:to_i)
  end
end

class Array
  def frequencies
    frequencies_hash = Hash.new(0)
    each { |value| frequencies_hash[value] += 1 }
    frequencies_hash
  end

  def average
    reduce(:+).to_f / size unless empty?
  end

  def drop_every(n)
    reject.with_index { |_, index| index.succ.remainder(n).zero? }
  end

  def combine_with(other)
    shorter, longer = length < other.length ? [self, other] : [other, self]

    combined = take(shorter.length).zip(other).flatten(1)
    rest     = longer.drop(shorter.length)

    combined + rest
  end
end

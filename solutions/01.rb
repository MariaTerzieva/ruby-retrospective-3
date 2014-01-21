class Integer
  def prime?
    return false if self < 2
    2.upto(pred).all? { |i| remainder(i).nonzero? }
  end

  def prime_factors
    return [] if self == 1
    factor = 2.upto(abs).find { |i| remainder(i).zero? }
    [factor] + (abs / factor).prime_factors
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
    each_with_object(Hash.new 0) { |value, hash| hash[value] += 1 }
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

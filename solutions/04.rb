module Asm
  def self.asm(&block)
    AsmProgram.new.evaluate(&block)
  end

  module RegisterActions
    def mov(destination_register, source)
      @instructions << -> do
        @registers[destination_register] = get_value(source)
      end
    end

    def inc(destination_register, value=1)
      @instructions << -> do
        @registers[destination_register] += get_value(value)
      end
    end

    def dec(destination_register, value=1)
      @instructions << -> do
        @registers[destination_register] -= get_value(value)
      end
    end

    def cmp(register, value)
      @instructions << -> do
        @flag = @registers[register] <=> get_value(value)
      end
    end
  end


  class AsmProgram
    include RegisterActions

    JUMPS = {
      jmp: -> { true },
      je: -> { @flag == 0 },
      jne: -> { @flag != 0 },
      jl: -> { @flag < 0 },
      jle: -> { @flag <= 0 },
      jg: -> { @flag > 0 },
      jge: -> { @flag >= 0 },
    }

    JUMPS.each do |jump_name, condition|
      define_method jump_name do |where|
        jump(where, condition)
      end
    end

    def initialize
      @registers = {ax: 0, bx: 0, cx: 0, dx: 0}
      @flag = 0
      @instructions = []
      @instruction = 0
      @labels = Hash.new { |_, key| key }
    end

    def label(label_name)
      @labels[label_name] = @instructions.size
    end

    def evaluate(&block)
      instance_eval &block
      until @instruction == @instructions.size
        instance_exec(&@instructions[@instruction])
        @instruction += 1
      end
      @registers.values
    end

    def method_missing(method, *args, &block)
      method
    end

    private

    def jump(where, condition)
      @instructions << -> do
        if instance_exec(&condition)
          @instruction = @labels[where].pred
        end
      end
    end

    def get_value(value)
      value.is_a?(Symbol) ? @registers[value] : value
    end
  end
end
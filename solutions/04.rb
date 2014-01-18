module Asm
  def self.asm(&block)
    asm_program = AsmProgram.new
    asm_program.evaluate(&block)
    asm_program.register_values
  end

  module Instructions
    def get_value(value)
      value.is_a?(Symbol) ? @registers[value] : value
    end

    def execute_mov(destination_register, source)
      @registers[destination_register] = get_value(source)
    end

    def execute_inc(destination_register, value=1)
      @registers[destination_register] += get_value(value)
    end

    def execute_dec(destination_register, value=1)
      @registers[destination_register] -= get_value(value)
    end

    def execute_cmp(register, value)
      @flag = @registers[register] <=> get_value(value)
    end
  end


  class AsmProgram
    include Instructions

    JUMPS = {
      execute_jmp: -> { true },
      execute_je: -> { @flag == 0 },
      execute_jne: -> { @flag != 0 },
      execute_jl: -> { @flag < 0 },
      execute_jle: -> { @flag <= 0 },
      execute_jg: -> { @flag > 0 },
      execute_jge: -> { @flag >= 0 },
    }

    FUNCTIONS = [:mov, :inc, :dec, :cmp, :jmp, :je, :jne, :jl, :jle, :jg, :jge]

    JUMPS.each do |jump_name, condition|
      define_method jump_name do |where|
        jump(where, condition)
      end
    end

    FUNCTIONS.each do |function|
      define_method function do |*args|
        @instructions << [function, *args]
      end
    end

    def initialize
      @registers = {ax: 0, bx: 0, cx: 0, dx: 0}
      @flag = 0
      @instructions = []
      @instruction = 0
      @labels = {}
    end

    def label(label_name)
      @labels[label_name] = @instructions.size
    end

    def jump(where, condition)
      if instance_exec(&condition)
        @instruction = (where.is_a?(Symbol) ? @labels[where] : where).pred
      end
    end

    def evaluate(&block)
      instance_eval &block
      until @instruction == @instructions.size
        name, *args = @instructions[@instruction]
        send "execute_#{name}".to_sym, *args
        @instruction += 1
      end
    end

    def register_values
      @registers.values
    end

    def method_missing(method, *args, &block)
      method
    end
  end
end
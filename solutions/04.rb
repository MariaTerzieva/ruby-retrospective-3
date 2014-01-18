module Asm
  def self.asm(&block)
    asm_program = AsmProgram.new
    asm_program.evaluate(&block)
    asm_program.register_values
  end

  module Jumps
    def execute_jmp(where)
      @current_instruction = (where.is_a?(Symbol) ? @labels[where] : where).pred
    end

    def execute_je(where)
      execute_jmp where if @flag == 0
    end

    def execute_jne(where)
      execute_jmp where if @flag != 0
    end

    def execute_jl(where)
      execute_jmp where if @flag < 0
    end

    def execute_jle(where)
      execute_jmp where if @flag <= 0
    end

    def execute_jg(where)
      execute_jmp where if @flag > 0
    end

    def execute_jge(where)
      execute_jmp where if @flag >= 0
    end
  end


  module Instructions
    include Jumps

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

    functions = [:mov, :inc, :dec, :cmp, :jmp, :je, :jne, :jl, :jle, :jg, :jge]
    functions.each do |function|
      define_method function do |*args|
        @instructions <<  [function, *args]
      end
    end

    def initialize
      @registers = {ax: 0, bx: 0, cx: 0, dx: 0}
      @flag = 0
      @instructions = []
      @current_instruction = 0
      @labels = {}
    end

    def label(label_name)
      @labels[label_name] = @instructions.size
    end

    def evaluate(&block)
      instance_eval &block
      until @current_instruction == @instructions.size
        name, *args = @instructions[@current_instruction]
        send "execute_#{name}".to_sym, *args
        @current_instruction += 1
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

module Asm
  def self.asm(&block)
    asm_program = AsmProgram.new
    asm_program.evaluate(&block)
    asm_program.register_values
  end

  module Jumps
    def execute_jmp(where)
      from = where.is_a?(Symbol) ? send(where) : where
      @current_instruction = from - 1
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

    def execute_mov(destination_register, source)
      if source.is_a? Fixnum
        @registers[destination_register] = source
      else
        @registers[destination_register] = @registers[source]
      end
    end

    def execute_inc(destination_register, value=1)
      if value.is_a? Fixnum
        @registers[destination_register] += value
      else
        @registers[destination_register] += @registers[value]
      end
    end

    def execute_dec(destination_register, value=1)
      if value.is_a? Fixnum
        @registers[destination_register] -= value
      else
        @registers[destination_register] -= @registers[value]
      end
    end

    def execute_cmp(register, value)
      if value.is_a? Fixnum
        @flag = @registers[register] <=> value
      else
        @flag = @registers[register] <=> @registers[value]
      end
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
    end

    def label(label_name)
      next_instruction = @instructions.size
      singleton_class.class_eval do
        define_method(label_name) { next_instruction }
      end
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
      singleton_class.class_eval do
        define_method(method) { __method__ }
      end
    end
  end
end

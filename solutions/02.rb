class Todo
  attr_reader :status, :description, :priority, :tags

  def initialize(status, description, priority, tags)
    @status      = status
    @description = description
    @priority    = priority
    @tags        = tags
  end
end

class Criteria
  class << self
    def status(status)
      Criteria.new { |task| task.status == status }
    end

    def priority(priority)
      Criteria.new { |task| task.priority == priority }
    end

    def tags(tags)
      Criteria.new { |task| tags & task.tags == tags }
    end
  end

  def initialize(&criteria)
    @criteria = criteria
  end

  def satisfied_by?(task)
    @criteria.call task
  end

  def &(other)
    Criteria.new { |task| satisfied_by? task and other.satisfied_by? task }
  end

  def |(other)
    Criteria.new { |task| satisfied_by? task or other.satisfied_by? task }
  end

  def !
    Criteria.new { |task| not satisfied_by? task }
  end
end

module TasksInformation
  def tasks_todo
    filter(Criteria.status :todo).count
  end

  def tasks_in_progress
    filter(Criteria.status :current).count
  end

  def tasks_completed
    filter(Criteria.status :done).count
  end

  def completed?
    tasks_completed == count
  end
end

class TodoList
  include Enumerable
  include TasksInformation

  attr_reader :tasks

  def self.parse(text)
    parsed = Parser.new(text) { |args| Todo.new *args }
    TodoList.new parsed.tasks
  end

  def initialize(tasks)
    @tasks = tasks
  end

  def each
    @tasks.each { |task| yield task }
  end

  def count
    @tasks.count
  end

  def filter(criteria)
    TodoList.new select { |task| criteria.satisfied_by? task }
  end

  def adjoin(other)
    TodoList.new @tasks.concat(other.tasks).uniq
  end


  class Parser
    attr_reader :tasks

    def initialize(text, &block)
      @tasks = parse_lines(text).map(&block)
    end

    def parse_lines(text)
      text.lines.map { |line| line.split('|').map(&:strip) }.map do |args|
        format_attributes *args
      end
    end

    def format_attributes(status, description, priority, tags)
      [
        status.downcase.to_sym,
        description,
        priority.downcase.to_sym,
        tags.split(',').map(&:strip)
      ]
    end
  end
end
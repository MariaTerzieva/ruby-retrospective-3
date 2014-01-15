class Todo
  attr_reader :status, :description, :priority, :tags

  def initialize(status, description, priority, tags)
    @status, @priority = [status, priority].map(&:downcase).map(&:to_sym)
    @description, @tags = description, tags
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
    tasks_information :todo
  end

  def tasks_in_progress
    tasks_information :current
  end

  def tasks_completed
    tasks_information :done
  end

  def completed?
    tasks_completed == count
  end

  private
  def tasks_information(status)
    filter(Criteria.status status).count
  end
end

class TodoList
  include Enumerable
  include TasksInformation

  attr_reader :tasks

  def self.parse(text)
    text_formatted = text.lines.map { |line| line.split('|').map(&:strip) }
    tasks = text_formatted.map do |status, description, priority, tags|
      Todo.new status, description, priority, tags.split(',').map(&:strip)
    end
    TodoList.new tasks
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
end
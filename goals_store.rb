require 'yaml/store'
require 'date'

GOALS_STORE_FILE = 'goals.store'
TIMESTAMP_FORMAT = '%d/%m/%y'

class GoalsStore

  attr_accessor :store

  def self.store_goals(goals)
    new.store_goals(goals)
  end

  def initialize(goals_file = GOALS_STORE_FILE)
    @store = YAML::Store.new("#{File.dirname(__FILE__)}/#{goals_file}")
  end

  def store_goals(goals, day = today)
    store.transaction do
      store["#{day}'s Goals || #{datestamp}"] = goals
    end
  end

  def fetch_goals
    store.transaction do
      @table = store.instance_variable_get(:@table)
    end
    @table.each do |day, goals|
      date = day.split(' || ').last
      next unless within_7_days(date)

      day = day.split(' || ').first
      puts day
      puts '-' * day.length
      goals.each { |goal| puts " - #{goal}" }
      puts "\n\n"
    end
  end

  private
	
    def today
      DateTime.now.strftime('%A')
    end

    def datestamp
      DateTime.now.strftime(TIMESTAMP_FORMAT)
    end
   
    def within_7_days(date)
      date = Date.strptime(date, TIMESTAMP_FORMAT)
      if date <= Date.today && date > Date.today - 7
	true
      else
	false
      end
    end

end

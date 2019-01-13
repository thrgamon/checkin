require 'date'
require_relative 'goals_store'
require 'readline'

class Checkin

  def initialize(store_goals: true)
    @date = DateTime.now
    @store_goals = store_goals
  end

  def checkin
    generate_slack_message.tap {|message| puts message}
  end

  def checkin!
    slack_message = checkin
    copy_message(slack_message)
  end

  private

    def generate_slack_message
      %(

#{greeting}


:night_with_stars: *#{previous_day}*
#{yesterdays_achievements}


:sunrise: *Today*
#{todays_goals}


:no_entry: *Blockers*
#{blockers}
      )
    end

    def greeting
      @date.hour < 12 ? 'Morning Morning!' : 'Afternoon all!'
    end

    def previous_day
      @date.monday? ? 'Friday' : 'Yesterday'
    end

    def yesterdays_achievements
      puts achievement_question
      achievements = get_user_input
      create_list_with_emoji(achievements, ':point_right:')
    end

    def achievement_question
      @date.monday? ? 'What did you achieve on Friday?' : 'What did you achieve yesterday?'
    end

    def create_list_with_emoji(list, emoji)
      list.map { |li| li.prepend("#{emoji} ") }.join("\n")
    end

    def todays_goals
      puts 'What are your goals for today?'
      get_user_input
        .tap {|goals| GoalsStore.store_goals(goals) if @store_goals}
        .yield_self {|goals| create_list_with_emoji(goals, ':dart:')}
    end

    def blockers
      puts 'Is there anything blocking you?'
      blockers = get_user_input
      if blockers.empty?
        'None! :tada:'
      else
        create_list_with_emoji(blockers, ':no_entry_sign:')
      end
    end

    def get_user_input
      input_array = []
      while buf = Readline.readline('', true)
        break if buf == ''
        input_array << buf
      end
      input_array
    end

    
    def copy_message(message)
      IO.popen('pbcopy', 'w') { |f| f << message }
    end

end

require 'date'
require 'optparse'
require 'ostruct'

class GitReview
  COMMIT_COLOUR = "33"
  MSG_COLOUR = "37"

  attr_accessor :logs
  attr_reader :options

  def initialize
    @logs = []
    @options = parse_options
  end

  def run
    generate_logs
    if options.output_format == 'day'
      output_by_day
    else
       output_by_project
    end
  end

  private

    def generate_logs
      Dir.chdir(options.path)
      Dir.foreach('.') do |file|
	next unless File.directory?(file)
	Dir.chdir(file) do
	  next if Dir.glob('.git').empty?
	  git_log_output = `git log --all --pretty='%ai || %h || %s' --since='6 days' --no-merges --author=#{options.email}`
	  next if git_log_output.empty?
	  git_log_output = git_log_output.lines.map(&:chomp).map { |string| string.split(' || ') }
	  logs << create_project_log(git_log_output)
	end
      end
    end

    def create_project_log(git_log_output)
      git_log_output.map do |git_log|
	{
	  project: Dir.pwd.split('/').last,
	  date: Date.parse(git_log[0]).strftime('%A'),
	  commit_id: git_log[1],
	  subject: git_log[2],
	}
	end
    end

    def parse_options
      options = OpenStruct.new
      options.output_format = 'project'
      options.path = '.'
      options.email = ""
      OptionParser.new do |opts|
	opts.banner = "Usage: standup.rb [options]"

	opts.on("-e", "--email [EMAIL]", "Set email account that you want to check for") do |email|
	  options.email = email
	end

	opts.on("-f", "--format [FORMAT]", "Set the format - split by day or by folder") do |output_format|
	  options.output_format = output_format
	end

	opts.on("-p", "--path [PATH]", "Set the path that you want to run this on. If left blank it will run in the current folder") do |path|
	  options.path = path
	end
      end.parse!(ARGV)
      options
    end

    def output_by_day
      logs
	.flatten
	.group_by{|h| h[:date]}
	.reverse_each do |day, logs|
	  puts day
	  puts "-" * day.length
	  logs.group_by{|h| h[:project]}.each do |project,commits|
	    puts colourize(COMMIT_COLOUR, project)
	    puts "\n"
	    commits.each {|commit| output_day_commit(commit)}
	    puts "\n"
	  end
	end
    end

    def output_day_commit(commit)
      puts colourize(
	MSG_COLOUR, 
	"#{commit[:commit_id]} #{commit[:subject]}"
	)
    end

    def output_by_project
      logs
	.flatten
	.group_by{|h| h[:project]}
	.each do |project, commits|
	  puts project
	  puts "-" * project.length
	  puts "\n"
	  commits.reverse_each {|commit| output_project_commit(commit)}
	  puts "\n"
	end
    end

    def output_project_commit(commit)
      puts colourize(
	MSG_COLOUR, 
	"#{commit[:date].ljust(10)}| #{commit[:commit_id]} #{commit[:subject]}"
	)
    end

    def colourize(colour, string)
      "\e[#{colour}m#{string}\e[0m"
    end

end

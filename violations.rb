require 'csv'

class Violations
  attr_reader :csv_path, :raw, :grouped, :analyzed

  def initialize()
    @csv_path = ARGV[0]
    @raw      = []
    @grouped  = []
    @analyzed = {}
  end

  def print_analysis
    read_csv
    group_violations
    analyze_violations
    puts format_violation("Name", ["Count", "Earliest Violation", "Latest Violation"])
    @analyzed.each do |violation_type, stats|
      puts format_violation(violation_type, stats)
    end
  end

  def read_csv
    violations = []
    CSV.foreach(@csv_path, {headers: true}) do |row|
      violations << row
    end
    @raw = violations
  end

  def group_violations
    @grouped = @raw.reduce({}) do |grouped_violations, violation|
      if grouped_violations[violation['violation_type']]
        grouped_violations[violation['violation_type']] << violation
      else
        grouped_violations[violation['violation_type']] = [violation]
      end
      grouped_violations
    end
  end

  def analyze_violations
    @grouped.each do |violation_type, violations|
      count = violations.count
      min_date = violations.min_by { |violation| violation['violation_date'] }['violation_date']
      max_date = violations.max_by { |violation| violation['violation_date'] }['violation_date']
      @analyzed[violation_type] = [count, min_date, max_date]
    end
  end

  def format_violation(name, stats)
    spaced_name = name.ljust(48)
    count = stats[0].to_s.rjust(7)
    early = stats[1].rjust(25)
    late  = stats[2].rjust(25)

    spaced_name + count + early + late
  end
end

violations = Violations.new
violations.print_analysis

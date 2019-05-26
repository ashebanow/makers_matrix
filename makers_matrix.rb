
require_relative 'dice'

class MakersMatrix
  VERSION = "0.0.1 prealpha"

  attr_accessor :total_crystal_orbs
  attr_accessor :total_magecoins

  # all values are in Crystal Orbs (CO). One orb is 0.01 CO, one magecoin is 200 CO but
  # is specified as a separate entry per row
  MaterialCost = Struct.new(:value, :magecoins) do
    def to_ary
      [value, magecoins]
    end
  end

  MaterialUsed = Struct.new(:material_type, :level, :value, :magecoins) do
    def to_s
      value 
      if value && magecoins && value > 0.0 && magecoins > 0.0
        puts "Level %d %s: cost of %.2f Crystal Orbs and %.2f Magecoins" %
            [level, material_type, level, value, magecoins]
      elsif value && value > 0.0
        puts "Level %d %s: cost of %.2f Crystal Orbs" %
            [level, material_type, value]
      elsif magecoins && magecoins > 0
        puts "Level %d %s: cost of %.2f Magecoins" %
            [level, material_type, magecoins]
      else
        puts "Level %d %s: no cost" %
            [level, material_type]
      end
    end
  end

  def run_matrix(item_level, use_sooth_deck: false)
    @materials = []
    @failures = []
    level = 1

    @sortilege = ask_numeric_question("How many sortilege for this challenge? (0-10, defaults to 0) ", 0, 10)
    @bene_added = ask_numeric_question("How many bene do you wish to use? (0-10, defaults to 0) ", 0, 10)

    add_material(item_level)
    while level <= item_level
      add_ingredient(level)
      level += 1
      # ask user whether or not they wish to continue.
      if ask_yes_no_question("Do you wish to continue? (Y/n) ")
        # if so, then keep adding ingrediants  
      else
        # if not, create random item at current level'
        puts "Created a RANDOM level %d item" % [level]
        print_results
        return
      end
    end
    add_power_source(level)

    print_results
  end

  def add_material(level)
    push_material(:material, level)    
  end

  def add_ingredient(level)
    push_material(:ingredient, level)

    if !do_challenge(:ingredient, level)
      puts "FAILURE adding ingredient"
      # if challenge fails, add_catalyst at level + 1
      add_catalyst(level + 1)
    end
  end

  def add_catalyst(level)
    push_material(:catalyst, level)    

    if do_challenge(:catalyst, level)
      puts "MINOR SIDE EFFECT!!!"
    else
      add_stabilizer(level)
    end
  end

  def add_stabilizer(level)
    push_material(:stabilizer, level)    

    if do_challenge(:stabilizer, level)
      puts "MAJOR SIDE EFFECT!!!"
    else
      puts "MISHAP!!!"
    end
  end

  def add_power_source(level)
    push_material(:power_source, level)    

    if do_challenge(:power_source, level)
      # item is created.
    else
      # mishap!
      puts "MISHAP!!!"
    end
  end

private
  MATERIALS = [
    MaterialCost.new( 10,  0),
    MaterialCost.new( 25,  0),
    MaterialCost.new( 75,  0),
    MaterialCost.new(200,  0),
    MaterialCost.new(500,  0),
    MaterialCost.new(  0,  1),
    MaterialCost.new(  0,  3),
    MaterialCost.new(  0,  7),
    MaterialCost.new(  0, 20),
    MaterialCost.new(  0, 50)
  ]

  INGREDIENTS = [
    MaterialCost.new(0.1,   0),
    MaterialCost.new(0.5,   0),
    MaterialCost.new(  2,   0),
    MaterialCost.new( 10,   0),
    MaterialCost.new( 50,   0),
    MaterialCost.new(200,   0),
    MaterialCost.new(  0,   1),
    MaterialCost.new(  0,   5),
    MaterialCost.new(  0,  12),
    MaterialCost.new(  0,  30)
  ]

  CATALYSTS = [
    MaterialCost.new(0.1,   0),
    MaterialCost.new(0.5,   0),
    MaterialCost.new(  2,   0),
    MaterialCost.new( 10,   0),
    MaterialCost.new( 50,   0),
    MaterialCost.new(200,   0),
    MaterialCost.new(  0,   1),
    MaterialCost.new(  0,   5),
    MaterialCost.new(  0,  12),
    MaterialCost.new(  0,  30)
  ]

  STABILIZERS = [
    MaterialCost.new(0.1,   0),
    MaterialCost.new(0.5,   0),
    MaterialCost.new(  2,   0),
    MaterialCost.new( 10,   0),
    MaterialCost.new( 50,   0),
    MaterialCost.new(200,   0),
    MaterialCost.new(  0,   1),
    MaterialCost.new(  0,   5),
    MaterialCost.new(  0,  12),
    MaterialCost.new(  0,  30)
  ]

  POWER_SOURCES = [
    MaterialCost.new( 25,  0),
    MaterialCost.new( 50,  0),
    MaterialCost.new( 75,  0),
    MaterialCost.new(100,  0),
    MaterialCost.new(125,  0),
    MaterialCost.new(  0,  3),
    MaterialCost.new(  0,  4),
    MaterialCost.new(  0,  5),
    MaterialCost.new(  0,  6),
    MaterialCost.new(  0,  7)
  ]

  MATERIAL_TYPE_MAP = {
    :material => MATERIALS,
    :ingredient => INGREDIENTS,
    :catalyst => CATALYSTS,
    :stabilizer => STABILIZERS,
    :power_source => POWER_SOURCES
  }

  def print_results
    #puts "Materials used: "
    #puts @materials

    @total_crystal_orbs = @materials.inject(0.0) { |crystal_orbs, material| crystal_orbs += material.value }
    @total_magecoins = @materials.inject(0.0) { |magecoins, material| magecoins += material.magecoins }
    puts "Total cost to make item: %.2f Crystal Orbs, %.2f Magecoins" % [@total_crystal_orbs, @total_magecoins]
  end

  def push_material(type, level)
    value, magecoins = MATERIAL_TYPE_MAP[type][level - 1]
    material_used = MaterialUsed.new(type, level, value, magecoins)
    @materials.push(material_used)
    return material_used
  end

  def do_challenge(type, level)
    puts "Rolling challenge for %s, level %d" % [ type, level ]
    dice = Dice.new(@sortilege + 1, 10)
    dice += @bene_added if @bene_added > 0
    roll = dice.best(1)
    # puts "dice best roll: ", roll
    return roll >= level
  end

  def ask_yes_no_question(prompt, default_true=true)
    answer = prompt_user(prompt).strip
    use_default = !answer || answer.length == 0
    return default_true if use_default
    return  answer.casecmp("YES") == 0 || answer.casecmp("Y") == 0
  end

  def ask_numeric_question(prompt, min, max, default=0)
    answer = prompt_user(prompt).strip
    return default if !answer || answer.length == 0 || answer !~ /^-?[0-9]+$/
    num = Integer(answer)
    return default if num < min || num > max
    return num
  end

  def prompt_user(prompt)
    puts prompt
    return STDIN.gets.chomp
  end

end

USAGE = <<ENDUSAGE
Usage:
   ruby makers_matrix.rb [-h] [-v] item_level
ENDUSAGE

HELP = <<ENDHELP
   -h, --help       Show this help.
   -v, --version    Show the version number (#{MakersMatrix::VERSION}).
   -sooth           Use the sooth deck for challenges instead of rolling
   item_level       Desired item level (1-10)

ENDHELP

ARGS = { :shell => 'default' }      # Setting default values
UNFLAGGED_ARGS = [ :item_level ]    # Bare arguments (no flag)
next_arg = UNFLAGGED_ARGS.first
ARGV.each do |arg|
  case arg
    when '-h','--help'      then ARGS[:help]      = true
    when '-v','--version'   then ARGS[:version]   = true
    else
      if next_arg
        ARGS[next_arg] = arg
        UNFLAGGED_ARGS.delete( next_arg )
      end
      next_arg = UNFLAGGED_ARGS.first
  end
end

puts "MakersMatrix v#{MakersMatrix::VERSION}" if ARGS[:version]

if ARGS[:help] or !ARGS[:item_level]
  puts USAGE unless ARGS[:version]
  puts HELP if ARGS[:help]
  exit
end

desired_level = Integer(ARGS[:item_level]) rescue false
if !desired_level || desired_level <= 0 || desired_level > 10
  puts USAGE unless ARGS[:version]
  puts HELP if ARGS[:help]
  exit
end

matrix = MakersMatrix.new
matrix.run_matrix(desired_level, use_sooth_deck: false)

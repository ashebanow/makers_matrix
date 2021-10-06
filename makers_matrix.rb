
require_relative 'dice'
require_relative 'maker_effects'

# To run:
#    ruby makers_matrix.rb item_level
class MakersMatrix
  VERSION = "0.0.1 prealpha"

  attr_accessor :total_crystal_orbs
  attr_accessor :total_magecoins

  def run_matrix(item_level, use_sooth_deck: false)
    @components_used = []
    @effects = []
    @effects_lookup = MakerEffects.new;
    @current_level = 1

    @bene_added = ask_numeric_question(
      "How many Intellect bene do you wish to use PER ROLL? (0-10, defaults to 0) ", 0, 10)
    @skill_bene = ask_numeric_question(
      "How many relevant skill levels do you have? (0-10, defaults to 0) ", 0, 10)

    # note that the material used is always at the desired level for the item
    add_material(item_level)

    while @current_level <= item_level
      if roll_challenge(@current_level)
        add_ingredient
      else
        puts "FAILURE attempting to add L%d ingredient" % [ @current_level ]
        add_catalyst

        if roll_challenge(@current_level)
          puts "Successfully used L%d catalyst" % [ @current_level - 1 ]
          @effects.push(SideEffect.new(:minor_effect, @current_level))
          # add a higher level ingredient than originally planned
          add_ingredient
        else
          puts "FAILURE using L%d catalyst" % [ @current_level - 1 ]
          add_stabilizer

          if roll_challenge(@current_level)
            puts "Successfully used L%d stabilizer" % [ @current_level - 1 ]
            @effects.push(SideEffect.new(:major_effect, @current_level))
            # add a higher level ingredient than originally planned
            add_ingredient
          else
            puts "FAILURE using L%d stabilizer" % [ @current_level - 1 ]
            puts "Item Creation FAILED"
            @effects.push(SideEffect.new(:mishap, @current_level))
            print_results
            return
          end
        end

        # ask user whether or not they wish to continue.
        if !ask_yes_no_question("Do you wish to continue? (Y/n) ")
          # if not, create random item at current level'
          puts "Created a RANDOM L%d item" % [@current_level]
          print_results
          return
        end
      end
    end

    add_power_source
    # Note that last challenge is at higher level than desired item level
    if roll_challenge(@current_level + 1)
      puts "Successfully created item"
    else
      puts "FAILURE creating item"
      @effects.push(SideEffect.new(:mishap, @current_level))
    end

    print_results
  end

private
  def add_material(level)
    push_component(:material, level)
    puts "Added L%d material" % [ level ]
  end

  def add_ingredient
    push_component(:ingredient, @current_level)
    puts "Added L%d ingredient" % [ @current_level ]
    @current_level += 1
  end

  def add_catalyst
    push_component(:catalyst, @current_level)
    puts "Added L%d catalyst" % [ @current_level ]
    @current_level += 1
  end

  def add_stabilizer
    push_component(:stabilizer, @current_level)    
    puts "Added L%d stabilizer" % [ @current_level ]
    @current_level += 1
  end

  def add_power_source
    push_component(:power_source, @current_level)
    puts "Added L%d power source" % [ @current_level ]
  end

  ComponentCost = Struct.new(:crystal_orbs, :magecoins) do
    def to_ary
      [crystal_orbs, magecoins]
    end
  end

  ComponentUsed = Struct.new(:type, :level, :crystal_orbs, :magecoins)

  SideEffect = Struct.new(:type, :level)

  MATERIALS = [
    ComponentCost.new( 10,   0),
    ComponentCost.new( 25,   0),
    ComponentCost.new( 50,   0),
    ComponentCost.new( 75,   0),
    ComponentCost.new(100,   0),
    ComponentCost.new(150,   0),
    ComponentCost.new(200,   0),
    ComponentCost.new(  0,   1),
    ComponentCost.new(  0,   2),
    ComponentCost.new(  0,   3),
    ComponentCost.new(  0,   4)
  ]

  INGREDIENTS = [
    ComponentCost.new(0.1,   0),
    ComponentCost.new(0.5,   0),
    ComponentCost.new(  1,   0),
    ComponentCost.new(  5,   0),
    ComponentCost.new( 10,   0),
    ComponentCost.new( 20,   0),
    ComponentCost.new( 50,   0),
    ComponentCost.new(  0,   1),
    ComponentCost.new(  0,   2),
    ComponentCost.new(  0,   3),
    ComponentCost.new(  0,   4)
  ]

  CATALYSTS = [
    ComponentCost.new(0.1,   0),
    ComponentCost.new(0.5,   0),
    ComponentCost.new(  1,   0),
    ComponentCost.new(  2,   0),
    ComponentCost.new(  5,   0),
    ComponentCost.new( 10,   0),
    ComponentCost.new( 20,   1),
    ComponentCost.new( 50,   5),
    ComponentCost.new(  0,   1),
    ComponentCost.new(  0,   2),
    ComponentCost.new(  0,   3)
  ]

  STABILIZERS = [
    ComponentCost.new(0.1,   0),
    ComponentCost.new(0.5,   0),
    ComponentCost.new(  1,   0),
    ComponentCost.new(  5,   0),
    ComponentCost.new( 10,   0),
    ComponentCost.new( 20,   0),
    ComponentCost.new( 50,   0),
    ComponentCost.new(  0,   1),
    ComponentCost.new(  0,   2),
    ComponentCost.new(  0,   5),
    ComponentCost.new(  0,   9)
  ]

  POWER_SOURCES = [
    ComponentCost.new(  0,   0),
    ComponentCost.new(  4,   0),
    ComponentCost.new(  8,   0),
    ComponentCost.new( 15,   0),
    ComponentCost.new( 30,   0),
    ComponentCost.new( 50,   0),
    ComponentCost.new(100,   0),
    ComponentCost.new(  0,   1),
    ComponentCost.new(  0,   2),
    ComponentCost.new(  0,   5),
    ComponentCost.new(  0,   9)
  ]

  COMPONENT_TYPE_MAP = {
    :material => MATERIALS,
    :ingredient => INGREDIENTS,
    :catalyst => CATALYSTS,
    :stabilizer => STABILIZERS,
    :power_source => POWER_SOURCES
  }

  SIDE_EFFECT_MAP = {
    :minor_effect => "Minor Effect",
    :major_effect => "Major Effect",
    :mishap => "Mishap"
  }

  def print_results
    puts
    puts "ITEM SUMMARY"

    @effects.each { |effect|
      puts "%s: %s" % [
        SIDE_EFFECT_MAP[effect.type],
        @effects_lookup.roll_effect(effect.type)
      ]
    }

    @total_crystal_orbs = @components_used.inject(0.0) { |crystal_orbs, material|
      crystal_orbs += material.crystal_orbs
    }
    @total_magecoins = @components_used.inject(0.0) { |magecoins, material|
      magecoins += material.magecoins
    }
    puts "Total cost to make item: %.2f Crystal Orbs, %.2f Magecoins" % [@total_crystal_orbs, @total_magecoins]
  end

  def push_component(type, level)
    crystal_orbs, magecoins = COMPONENT_TYPE_MAP[type][level - 1]
    puts "push_component: L%d %s %d crystal_orbs %d magecoins" % [ level, type, crystal_orbs, magecoins ]
    component_used = ComponentUsed.new(type, level, crystal_orbs, magecoins)
    @components_used.push(component_used)
    return component_used
  end

  def roll_challenge(level)
    dice = Dice.new(1, 10)
    total_bene = @bene_added + @skill_bene
    dice += total_bene if total_bene > 0
    return dice.roll >= level
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


class MakerEffects

def roll_effect(type)
	effect_table = EFFECTS[type]
	if !effect_table
		puts "Unknown effect type: %s" % [ type ]
		return "Unknown"
	end
    dice = Dice.new(1, effect_table.length)
    roll = dice.best(1)
    return effect_table[roll - 1]
end

private

MINOR_EFFECT = [
	"Item glows blue when used",
	"Item whispers unintelligibly when used",
	"Random nearby being gets a minor, non-damaging jolt when item is used",
	"User feels a bit nauseated when using item",
	"User recalls unpleasant memory when using item",
	"User must say mother’s name to use item",
	"User must say \“I am up to no good\” to use item",
	"User must mentally name all thirteen Soul Guardians to use item",
	"Item becomes invisible at random times",
	"Item does not function for ten minutes at a specific time each day",
	"User must whistle to use item",
	"Item functions normally but looks awful (broken, very poor quality, unseemly, etc.)",
	"Item grows hot or cold to the touch when used (unpleasant but non-damaging)",
	"Item works only in the hands of someone wearing at least one red garment",
	"User must make a series of complex gestures to use item",
	"With each use, lights twirl around user’s head",
	"User’s flesh turns green for one round when item is used",
	"In the night following each use, user has mild insomnia",
	"User must say their own name out loud to use item",
	"User’s hair grows about a week’s worth with each use",
	"User hiccups with each use",
	"Item must be kept very warm or very cool while not in use",
	"Item must be kept in the dark while not in use",
	"User experiences minor magical flux with each use"
]

MAJOR_EFFECT = [
	"Item inflicts 1 point of damage per level on user each time it is used",
	"Item drains nearby ephemera when used",
	"Item puts a scourge on the Perception pool of anyone possessing it, impossible to remove unless item is dropped",
	"Item puts a scourge on the Accuracy pool of anyone possessing it, impossible to remove unless item is dropped",
	"Item puts a scourge on the Interaction pool of anyone possessing it, impossible to remove unless item is dropped",
	"Item puts a scourge on the Sorcery pool of anyone possessing it, impossible to remove unless item is dropped",
	"Item puts a scourge on the Movement pool of anyone possessing it, impossible to remove unless item is dropped",
	"Item puts a scourge on the Intellect pool of anyone possessing it, impossible to remove unless item is dropped",
	"Anyone possessing the item cannot speak",
	"Item works only at night",
	"Item works only during the day",
	"Item must be bathed in blood once a day to function",
	"Item can be used only for altruistic purposes (user must justify each use)",
	"Item must be fitted with a new diamond (worth 30 crystal orbs) once each week to function",
	"User falls prone with each use of item",
	"User turns translucent for one minute after each use",
	"None of user’s magical possessions function for one minute after use of this item",
	"User must solve a new riddle each day for item to function",
	"Item functions normally but will eventually fade away forever at a random moment",
	"When item is used, all glass nearby becomes ebony black with filaments of clear crystal",
	"Each use produces the sound of a baby crying",
	"User is struck deaf until next sunrise",
	"With each use, user’s teeth immediately and painlessly fall out. A new, perfect set grows in the next ten hours.",
	"After use, user has an aura of unease and gains 3 vex in Interaction",
	"Each use produces a large quantity of ice in the air around user, which falls to the ground and shatters",
	"Each use produces the sound of a terrible shriek",
	"Temperature in any room the item occupies for more than a minute drops below freezing",
	"User loses one childhood memory with each use",
	"User is disoriented after each use and cannot take an action for one round",
	"User experiences major magical flux with each use"
]

MISHAP = [
	"Process explodes, inflicting damage equal to the desired item level on all nearby",
	"Location where mishap occurs is seriously damaged, requiring ten weeks of repair costing 500 crystal orbs.",
	"Item gains intelligence and deep hatred for Maker. It teleports away, vowing vengeance.",
	"Nearest magical item is drained permanently",
	"Maker becomes disfigured and unsightly",
	"Maker gains the attention of a powerful entity",
	"Maker loses all connection to their secret soul and their soul name changes",
	"Maker must attempt to resist possession by a level 6 demon",
	"Portal to the Dark opens",
	"Maker is cursed with a random curse spell effect",
	"Maker’s hand is burned and cannot be used for one week afterward",
	"Maker is struck blind for one week",
	"Item functions exactly as originally desired, but becomes a possession of the Maker’s worst enemy",
	"Item is possessed by a level 8 demon that attempts to corrupt its user",
	"Angel appears and demands possession of the item",
	"Three angry level 5 ghosts appear and attack Maker",
	"Maker is afflicted with a debilitating disease that gives a scourge in a random stat pool that remains until the disease is magically cured",
	"Someone the Maker knows and likes dies Maker is hurled to another world or realm",
	"Maker’s Testament of Suns (or vertula kada) is destroyed"
]

EFFECTS = {
	:minor_effect => MINOR_EFFECT,
	:major_effect => MAJOR_EFFECT,
	:mishap => MISHAP
}

end

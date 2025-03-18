## Survivor Deck Building Roguelike

# Scetch

    	 |     Boss                                       +----+  ^----- ^
    	 |   +------                                      |Deck|  |      ||
    	 |   |  -/                                        |    | / Map  / |
    	 |   |-/ -\                                       +----+ v----- v |
    	 |         -                                                      |
    	 |                                                                |
    	 |                    -          +----+           E               |
    	 |                               |J   |                           |
    	 |               E               |    |                           |
    	 |                               |   J|                  E        |
    	 |                      E        +----+                           |
    	 |                               -\                               |
    	 |                                 -|                             |
    	 |              E                   |--            E              |
    	 |                                 /                              |
    	 |                                 |                              |
    	 |                               -----                            |
    	 |            E                                                   |
    	 |                                                                |
    	 |          /------------------------------------------\          |
    	 |     /----     Hand +---+  +---+  +---+  +---+        -----\    |
    	 |  ---               |X3 |  |3  |  |Poi|  | / |              --- |
    		   Draw           |   |  |   |  |   |  | / |
    		  +----+          +---+  +---+  +---+  +---+
    		  |    |          +------------/-----------------------+
    		  +----+     Mana +-----------/------------------------+

(Top) Hud - Hand (built out as players summon cards over time)
(Middle) Player character - overhead WASD survivor like
E - enemies (drop xp / gold) - used in shops

# Classes

Player
Health
Mana - card draw per turn
walk speed (wasd)
shuffle speed

Projectiles launched from player
attack damage (auto bullet)
attack speed
attack length (duration before despawn)
attack fade (less damage farther away)
attack direction (targetted, patterns (zigzag, double, woozy, spin, circle, guard, random, away))

Deck
card draw speed (time for player to cast card draw (hand up animation and card summoned above player))
resolve speed (card fades from player to hud to build attack equation)
deck type (Red,green,blue) Deck draw adds attributes to attack

Cards

- Damage (weapon cards) - changes base attack type (pellet, knife, potion, spell, object)
- Function (draw 2, slow but more, speed with less dmg)
- modifyers (elemental, patterns above, drunk)
- multiplier

# Example

Cycle log
10s drawing 5 cards
each card draw moves to hand
when mana runs out hand resolves
state multiplier added to player for 40s

killing enemies drops xp, levels add base stats
after all cards drawn deck is shuffled (uses mana)
boss drop deck stickers

# Game loop

Every level add player modifiers
Every encounter/boss/chest add cards to deck
Some encounter/chest/event add deck modifyers

# Draft 1

# Base system

/Player that moves
health

/touch xp add to level
touch gold add to gold

> touch enemy take damage

Enemy

/moves to player
/damage player on touch

Bullet (dagger)
/picks random enemy
/fires from center (with circle offset) towards enemy current position
/Moves to enemy
/Kills enemy on kill
/despawns after timer

/drops loot on death, loot drop xp
drop table for enemy
/player level - experience
\/energy - mana

/Map spawn enemies

## Card system

bullet per https://godotengine.org/asset-library/asset/2053

https://github.com/Maaack/Godot-Game-Template
https://github.com/viniciusgerevini/godot-aseprite-wizard?tab=readme-ov-file

https://superuser.com/questions/491180/how-do-i-embed-multiple-sizes-in-an-ico-file

# TODO next

card selection (w/ player)
example sprites for cards (write over)
deck button
? levels on cards

Action Bar
resolve animation
shuffle animation
hit, level up animation

#### Survivor

Enemy state machines
Boss

#### CARDS

stats:
attack
spell

## Action Cards

Quick Draw - Instant draw 2 more cards. alt. Next 2 draws draw 2 cards or
Double Finale - Resolve now, resolve hand twice
Mirrage - Duplicates last card (stacks with effects)
Energy - Add 1 more draw to hand (should be next hand)

## Spells

## Throw (fade #)

Loot (drop chance)
Pattern (slow, wave, zigzag, spiral, gravity)
Duration (buff time)
Amount (shots fired per attack)

## Attacks

Pierce (weapon durability)

## Upgrades

APS

# Ideas bucket

Card that gives dash/doge charges
/ Weapons have a usage instead of buff timer, weapon use ticks down on attack




# TO DO
character_stats and player_stats

old method
player_stats > base_stats
attack_stats > base_stats

character
stats (stats_manager)
> buff
> debuff 

status_effect_manager
> status_effect (card(effect))

weapon
effect_status


# Current classes

## Stats
damage
durability (health)
speed
size

CHARGE_LIMIT
charges

Attack (stats)
weapon_type
fade
knockback

Player (stats)
armor
-- time
draw_speed
shuffle_speed
(resolve hand)
attacks
spells

Spell
trajectory
drops
status_effect

prompt
writing stat atributes for an overhead game where stats are set on cards and there's a function in Player called summon() that gets list of stats from all cards in hand (other code don't worry about it now) so that within a player, enemy, or weapon the same stat Resource can be passed around to do specific dunctionality



every stat in the Stats classes below are setup as this Stat Resource
# Stat inherits Resource
Key: enum stat_name
Value stat_type (
	enum type (value type) which of the below values to get
	float,int,enum value (amount)
	modifier (+-x%) 
)


# status effect
status_type (element - optional)
usage - duration (all in list would? be the same)
list of stats
  stat - damage [usage proc]
  stat - speed modifier [usage proc]


# usage
enum permanent, charges, duration, signal_name
charges (int) usage charges checks limit
duration (float) set's callback timer (decrement charges for proc)
signal (signal name) signal does a global signal connect
proc (damage over time)


stat - damage
damage
proc (aps)
debuff (attackstats)
  
  duration (usage)

for the format below showcase example of files written in go
## Class (inherits)
list of attributes

## Stats
damage
durability (health)
speed
size

## PlayerStats (characterStats)
draw_speed
shuffle_speed
recovery

## CharacterStats (stats)
attacks_per_second (timer)
armor

## AttackStats (stats)
weapon_type
fade (duration)
knockback

## SpellStats (stats)
trajectory
drops
status_effect


## Player
has list active_buffs Array[playerStats,attackStats,spellStats,statsStats]

## Card
list (attack,spell,stats) - used for having stats that pass to player on draw or hand 
status_effect

resolve



End goal (over complicating it for now)

Character has a stat dictionary


Cards have list of stats

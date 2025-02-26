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
https://github.com/russmatney/log.gd

# TODO next

card selection (w/ player)
example sprites for cards (write over)
deck button
levels on cards

Action Bar
resolve animation
shuffle animation
hit, level up animation

#### Survivor

Enemy state machines
Boss

#### CARDS

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

# TO DO

Scarecrow not targetable by enemy
Enemy state machine (lose target)

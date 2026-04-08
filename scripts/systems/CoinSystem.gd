extends Node
class_name CoinSystem

## Manages coins per character. Earned via SAT quiz correct answers.
## Spent on furniture upgrades.

signal coins_changed(character: String, amount: int)

const COINS_PER_CORRECT := 10
const COINS_PER_PERFECT_DAY := 25  # Bonus for all missions complete

var coins: Dictionary = {
	"gritty": 150,   # Middle class — parents' allowance, comfortable
	"smartle": 50,    # Favela — mom scraped together minimum for first week
}


func add_coins(character: String, amount: int) -> void:
	coins[character] = coins.get(character, 0) + amount
	coins_changed.emit(character, coins[character])


func spend_coins(character: String, amount: int) -> bool:
	if coins.get(character, 0) >= amount:
		coins[character] -= amount
		coins_changed.emit(character, coins[character])
		return true
	return false


func get_coins(character: String) -> int:
	return coins.get(character, 0)

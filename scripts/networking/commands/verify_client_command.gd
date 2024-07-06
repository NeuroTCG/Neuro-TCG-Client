extends Node

# Send these commands to the server after 
# converting the data into the appropriate format.

signal summon(card_id: int, position: Array)
signal attack(card_id: int, target_position: Array, attacker_position: Array) 


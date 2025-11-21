extends Node2D
class_name Card

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var card_template_label := $CardBack/CardTemplateLabel
@onready var card_hover_sprite := $CardBack/CardHover
@onready var card_unhover_sprite := $CardBack/CardUnhover
@onready var collision: CollisionShape2D = $Area2D/CollisionShape2D
@onready var card_sprite := $CardBack/CardFront
@onready var attack_sprite := $AttackSprite
@onready var buttons := %Buttons
@onready var atk_label: Label = %AtkLabel
@onready var hp_label: Label = %HpLabel
@onready var seal_sprite: Sprite2D = $SealSprite
@onready var shield_sprite: Sprite2D = $ShieldSprite

enum Placement {
	DECK,
	HAND,
	PLAYMAT,
	DESTROYED,
}

enum TurnPhase {
	Done = 0,
	AbilityOnly = 1,
	AttackOnly = 2,
	Action = 3,
	MoveOrAbility = 4,
	MoveOrAction = 5,
}

# TODO: remove
var owned_by_player := true

## no touchy
var state: CardState
## Static information about a card (eg. base atk, ability)
var info: CardStats

var current_slot: CardSlot

var current_attack_value: int:
	get:
		return info.base_atk + state.attack_bonus

var current_counter_attack_value: int:
	get:
		return clamp(current_attack_value - 1, info.min_counter_attack, info.max_counter_attack)

var current_ability_cost: int:
	get:
		return info.ability.cost - state.ability_cost_modifier

#region STATUS
var summon_sickness := false:
	get:
		if not owned_by_player:
			assert(false, "Attribute summon_sickness not implemented for enemy cards")
		return summon_sickness

var placement := Placement.DECK:
	get:
		if not owned_by_player:
			assert(false, "Attribute placement not implemented for enemy cards")
		return placement
var mouse_over := false
var selected := false

var dont_show_view := false
#endregion

#region TWEENS AND POSITION
var anchor_position: Vector2
var hover_tween: Tween
var unhover_tween: Tween
var button_y_pos: float
var movement_tween: Tween
#endregion


static func create_card(parent_scene: Node2D, id: int) -> Card:
	var new_card: Card = load("res://scenes/game/card.tscn").instantiate()
	var card_info: CardStats = CardStatsManager.card_info_dict[id]

	parent_scene.add_child(new_card)

	parent_scene.move_child(new_card, -1)

	new_card.state = CardState.fromCardStats(id, card_info)
	new_card.info = card_info
	print(card_info.graphics, ResourceLoader.exists(card_info.graphics))

	if ResourceLoader.exists(card_info.graphics):
		new_card.card_sprite.texture = load(card_info.graphics)
	else:
		new_card.card_template_label.text = card_info.name

	return new_card


func _ready() -> void:
	Global.mouse_input_functions.append(_on_mouse_clicked)
	VerifyClientAction.player_finished.connect(_on_player_finished)
	RenderOpponentAction.opponent_finished.connect(_on_opponent_finished)

	button_y_pos = buttons.position.y


func reset_variables() -> void:
	if owned_by_player:
		summon_sickness = false
		state.phase = TurnPhase.MoveOrAction
	summon_sickness = false
	state.phase = TurnPhase.MoveOrAction
	mouse_over = false
	selected = false


func _on_mouse_clicked() -> void:
	for button in buttons.get_children():
		if button.mouse_over:
			return

	if owned_by_player:
		if mouse_over and not selected:
			if placement == Placement.HAND:
				Global.hand_card_selected.emit(self)
			elif placement == Placement.PLAYMAT:
				Global.playmat_card_selected.emit(self)
		elif selected:
			if placement == Placement.HAND:
				Global.hand_card_unselected.emit(self)
			elif placement == Placement.PLAYMAT:
				Global.playmat_card_unselected.emit(self)
	else:
		if mouse_over and not selected:
			if dont_show_view:
				dont_show_view = false
			else:
				selected = true
				show_buttons([MatchManager.Actions.VIEW])
		elif selected:
			selected = false
			hide_buttons()


func _on_player_finished() -> void:
	if owned_by_player:
		summon_sickness = false
		if (Global.player_hand.cards.has(self)):
			state.phase = TurnPhase.Done
		else:
			state.phase = TurnPhase.MoveOrAction
		if state.sealed_turns_left > 0:
			state.sealed_turns_left -= 1
		if state.sealed_turns_left == 0:
			seal_sprite.visible = false

		#Refresh Deck Master Abilities
		if CardStatsManager.is_deck_master(state.id):
			state.ability_was_used = false


func _on_opponent_finished() -> void:
	if not owned_by_player:
		if state.sealed_turns_left > 0:
			state.sealed_turns_left -= 1
		if state.sealed_turns_left == 0:
			seal_sprite.visible = false


func select() -> void:
	selected = true

	if hover_tween:
		hover_tween.kill()
	hover_tween = get_tree().create_tween()
	hover_tween.tween_property(card_hover_sprite, "modulate:a", 1.0, 0.5)

	if unhover_tween:
		unhover_tween.kill()
	unhover_tween = get_tree().create_tween()
	unhover_tween.tween_property(card_unhover_sprite, "modulate:a", 0.0, 0.5)

	atk_label.text = str(current_attack_value)
	hp_label.text = str(state.health)


func unselect() -> void:
	selected = false

	if hover_tween:
		hover_tween.kill()
	hover_tween = get_tree().create_tween()
	hover_tween.tween_property(card_hover_sprite, "modulate:a", 0.0, 0.5)

	if unhover_tween:
		unhover_tween.kill()
	unhover_tween = get_tree().create_tween()
	unhover_tween.tween_property(card_unhover_sprite, "modulate:a", 1.0, 0.5)


func show_buttons(actions: Array) -> void:
	buttons.visible = true
	buttons.position.y = button_y_pos - actions.size() * 13

	var shortcut_strings := []

	for button in buttons.get_children():
		if button.button_action in actions:
			button.visible = true
			match button.button_action:
				MatchManager.Actions.SUMMON:
					shortcut_strings.append("S: Summon, ")
				MatchManager.Actions.SWITCH:
					shortcut_strings.append("W: Switch, ")
				MatchManager.Actions.ATTACK:
					shortcut_strings.append("A: Attack, ")
				MatchManager.Actions.ABILITY:
					shortcut_strings.append("E: Ability, ")
				MatchManager.Actions.VIEW:
					shortcut_strings.append("V: View, ")
				MatchManager.Actions.MAGIC:
					shortcut_strings.append("M: Magic, ")
		else:
			button.visible = false

	Global.show_shortcuts.emit(shortcut_strings)


func hide_buttons() -> void:
	Global.hide_shortcuts.emit()
	buttons.visible = false


func move_and_reanchor(pos: Vector2) -> void:
	anchor_position = pos
	visually_move_card(anchor_position)


func visually_move_card(end_pos: Vector2, time := 0.5) -> void:
	if movement_tween:
		movement_tween.kill()

	movement_tween = get_tree().create_tween()
	movement_tween.tween_property(self, "position", end_pos, time)

	await get_tree().create_timer(0.01).timeout
	MatchManager.input_paused = true
	await get_tree().create_timer(time).timeout
	MatchManager.input_paused = false


func set_slot(slot: CardSlot) -> void:
	assert(current_slot == null)
	current_slot = slot
	slot.stored_card = self


func remove_from_slot() -> void:
	assert(current_slot != null)
	current_slot.stored_card = null
	current_slot = null


func set_shield(num_turns: int) -> void:
	assert(num_turns >= 0)
	state.shield = num_turns
	shield_sprite.visible = num_turns > 0


func set_seal(num_turns: int) -> void:
	assert(num_turns >= 0)
	state.sealed_turns_left = num_turns
	seal_sprite.visible = num_turns > 0


## returns true if the card died
func take_damage(
	amount: int,
	attacker: Card = null,
) -> bool:
	assert(amount >= 0)

	#var dmg_event_info = DamageEventInfo.new(attacker, self, amount, source)

	if state.shield > 0:
		state.shield -= 1

		if state.shield == 0:
			shield_sprite.visible = false
		return false

	state.health -= amount
	render_attack(state.health)
	if state.health <= 0:
		Global.player_field.destroy_card(current_slot.slot_no, self)
		return true

	return false


func apply_ability_to(targets: Array[Card]):
	match info.ability.effect:
		Ability.AbilityEffect.ADD_HP:
			for target in targets:
				target.add_hp(info.ability.value)
		Ability.AbilityEffect.ADD_ATTACK_HP:
			for target in targets:
				target.add_hp(info.ability.value)
				target.add_attack(info.ability.value)
		Ability.AbilityEffect.ATTACK:
			var atk_value := info.ability.value
			for target in targets:
				#assert(false, "player took damage")
				# TODO: Verify if attack modifiers apply to ability attack values as well.
				target.take_damage(atk_value, self)
		Ability.AbilityEffect.SEAL:
			print("APPLYING SEAL TO CARD")
			for target in targets:
				target.set_seal(info.ability.value)
				print(target.state.sealed_turns_left)
		Ability.AbilityEffect.SHIELD:
			for target in targets:
				target.set_shield(info.ability.value)
				print(target.state.shield)
		Ability.AbilityEffect.DRAW_CARD:
			#Draw card ability is handled by server
			targets = []
		Ability.AbilityEffect.BUFF_SELF_REMOVE_CARD:
			add_hp(info.ability.value)
			add_attack(info.ability.value)
			for target in targets:
				Global.player_field.destroy_card(target.current_slot.slot_no, target)
		_:
			assert(false, "no action for AbilityEffect: %s" % [info.ability.effect])

	if (
		self in Global.enemy_hand.cards
		or (current_slot != null and current_slot.slot_no in Global.ENEMY_ROWS)
	):
		Global.use_enemy_ram.emit(current_ability_cost)
	else:
		Global.use_ram.emit(current_ability_cost)


func get_card_position() -> CardPosition:
	if (placement == Placement.HAND):
		var hand: Hand = null
		if owned_by_player:
			hand = Global.player_hand
		else:
			hand = Global.enemy_hand
		return CardPosition.new(-1, hand.cards.find(self))
	elif (placement == Placement.PLAYMAT):
		var field: Field = null
		if owned_by_player:
			field = Global.player_field
		else:
			field = Global.enemy_field
		return CardPosition.from_array(field.get_slot_array(self))
	else:
		return null

func add_hp(amount: int) -> void:
	assert(amount > 0)
	state.health += amount  # not capped by design


## Some situations require hp to be removed without it being explicitly an attack.
func sub_hp(amount: int, min_hp: int = 0) -> void:
	assert(amount > 0)
	state.health -= amount
	if state.health < min_hp:
		state.health = min_hp


func add_attack(amount: int) -> void:
	assert(amount > 0)
	state.attack_bonus += amount


func sub_attack(amount: int) -> void:
	assert(amount > 0)
	state.attack_bonus -= amount


func add_ability_cost_modifier(amount: int) -> void:
	assert(amount > 0)
	state.ability_cost_modifier += amount


func sub_ability_cost_modifier(amount: int) -> void:
	assert(amount > 0)
	state.ability_cost_modifier -= amount


## By default sets z index to 0
func set_card_visibility(index := 0) -> void:
	z_index = index


func shift_card_y(amount: float, time := 0.1) -> void:
	if movement_tween:
		movement_tween.kill()
	movement_tween = get_tree().create_tween()
	movement_tween.tween_property(self, "position:y", anchor_position.y + amount, time)


func flip_card(enemy := false) -> void:
	if not enemy:
		animation_player.play("flip")
	else:
		animation_player.play("flip_enemy")


func render_attack(_hp: int) -> void:
	animation_player.play("nuke")


func _on_mouse_hover() -> void:
	mouse_over = true


func _on_mouse_exit() -> void:
	mouse_over = false


func _on_tree_exiting() -> void:
	Global.mouse_input_functions.erase(_on_mouse_clicked)


#Returns the name of the graphics file with the extension.
func _to_string():
	return "%s(#%s)" % [info.graphics.get_file().get_slice(".", 0), get_instance_id()]

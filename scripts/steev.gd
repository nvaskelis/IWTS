extends CharacterBody2D

@export var speed: int = 70
@onready var anims: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var alert: Sprite2D = $alert
@onready var interactLabel: Label = $Interactions/interactLabel
@onready var allInteractions = []
var vecm: Vector2 = Vector2.ZERO
var faceR: bool = true
var canInteract: bool = false

func _ready():
	updateInteractions()

func handleInput():
	vecm = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if vecm != Vector2.ZERO:
		velocity = vecm * speed
	else:
		velocity = Vector2.ZERO
		
	if Input.is_action_just_pressed("interact"):
		executeInteraction()
	if Input.is_action_just_pressed("Quit"):
		get_tree().quit()
	

func updateAnims():
	if vecm == Vector2.ZERO:
		anims.play("idle")
		return
	elif vecm.x<0 && faceR: 
		sprite.flip_h = true
		faceR = false
	elif vecm.x>0 && !faceR:
		sprite.flip_h = false
		faceR = true
	anims.play("walk")
	if canInteract:
		alert.visible = true
	else:
		alert.visible = false

func _physics_process(delta):
	handleInput()
	updateAnims()
	move_and_slide()

#Interactions:
func _on_interact_area_area_entered(area):
	allInteractions.insert(0, area)
	updateInteractions()

func _on_interact_area_area_exited(area):
	allInteractions.erase(area)
	updateInteractions()
	
func updateInteractions():
	if allInteractions:
		interactLabel.text = allInteractions[0].iLabel
	else:
		interactLabel.text = ""
		
func executeInteraction():
	if allInteractions:
		var curI = allInteractions[0]
		match curI.iType:
			"dialog": 
				var layout = Dialogic.start("res://dialog/" + curI.iValue + ".dtl")
				layout
			"debug" : print(curI.iValue)


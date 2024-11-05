extends CharacterBody3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@export var speed: int = 10
@export var jumpVelocity = 15
@export var mouseSens = 0.4
@onready var anims: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite3D = $Sprite3D
@onready var interactLabel: Label3D = $Interactions/Label3D
@onready var allInteractions = []
@onready var rpgcam: Camera3D = $Cams/rpgcam
@onready var fpscam: Camera3D = $Cams/fpscam
var vecm: Vector2 = Vector2.ZERO
var faceR: bool = true
var canInteract: bool = false
var fpsCamActive = false

func _ready():
	updateInteractions()
	
func _input(event):
	if event is InputEventMouseMotion and fpsCamActive:
		rotate_y(deg_to_rad(-event.relative.x * mouseSens))
		fpscam.rotate_x(deg_to_rad(-event.relative.y * mouseSens))
		fpscam.rotation.x = clamp(fpscam.rotation.x, deg_to_rad(-89), deg_to_rad(89))

func handleInput():
	vecm = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(vecm.x, 0, vecm.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		
	if Input.is_action_just_pressed("game_jump") and is_on_floor():
		velocity.y = jumpVelocity
		
	if Input.is_action_just_pressed("interact"):
		executeInteraction()
	if Input.is_action_just_pressed("game_camswap"):
		switchCam()
	if Input.is_action_just_pressed("Quit"):
		get_tree().quit()
	

func updateAnims():
	if vecm.x<0 && faceR: 
		sprite.flip_h = true
		faceR = false
	elif vecm.x>0 && !faceR:
		sprite.flip_h = false
		faceR = true
	if !is_on_floor() and velocity.y>0:
		anims.play("jump")
		return
	elif !is_on_floor():
		anims.play("fall")
		return
	if vecm == Vector2.ZERO and anims.current_animation != "idle":
		anims.play("idle")
		return
	elif vecm != Vector2.ZERO and anims.current_animation != "walk":
		anims.play("walk")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	handleInput()
	if !fpsCamActive:
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
			"debug" : print(curI.iValue)
			
func switchCam():
	if(fpsCamActive):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		rpgcam.make_current()
		sprite.show()
		fpsCamActive = false
		fpscam.rotation.x = 0
		print("rpgcam on")
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		fpscam.make_current()
		anims.stop()
		sprite.hide()
		fpsCamActive = true
		print("fpscam on")

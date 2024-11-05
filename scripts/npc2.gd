extends CharacterBody2D

@onready var anims = $AnimationPlayer
@onready var i: Interactable = $interactArea

@export var iLabel: String = "none"
@export var iType: String = "none"
@export var iValue = "none"

func _ready():
	i.iLabel = iLabel
	i.iType = iType
	i.iValue = iValue

func _physics_process(delta):
	anims.play("idle")

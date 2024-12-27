extends Node2D
##this script moves shit parallaxely.
##it was created to simulate layers in a 2d body but what it in fact does is add a vanishing point at the camera, creating perspective.
##if you layer a bunch of equal images with this script it will start to look like a cilinder
##it is recommended you use this as a node2d and put the sprites and other stuff as childs. i like to use this attached to a canvasgroup

@onready var camera_current=get_viewport().get_camera_2d()
##current camera

@export var node_to_follow:Node2D
##father figure of this node or whoever you want to follow

@export var paralax_speed:float=1
##Parallax speed
##0 represents object at the infinite and 1 represents object at the same level as the camera.
##if you put 0 in it, it will consequentially follow the camera (and have a size of 0 so why would you do it)

@export var limit_distortion:bool=false
##this is a cool one. it determines if your body should have a maximum distortion.
##as i said before, i was working with planets and if you dont use this they tend to... break.
##the layers get far away from eachother so i set a maximum distortion to keep everyone inside

@export var limit_radius:float=0
##maximum limit for the distortion. that means nothing will go further from limit_radius.
##do nothing if the bool up there is false

#camera position
var camera_position=Vector2(0,0)
#root position
var root_position=Vector2(0,0)
#maximum radius for ME. taking into account the speed of my layer
@onready var local_limit_radius=limit_radius*(1-paralax_speed)


func _ready() -> void:
	scale.x=paralax_speed
	scale.y=paralax_speed

func _physics_process(_delta: float) -> void:
	#update camera data
	camera_position=camera_current.global_position
	#update root data
	root_position=node_to_follow.global_position
	#move the shit based on stuff
	var delta_difference=(camera_position-root_position)*(1-paralax_speed)
	
    #"am i going too far?"- this node asked themself
	if delta_difference.length()> local_limit_radius and limit_distortion:
		position=(delta_difference.normalized()*local_limit_radius).rotated(-node_to_follow.rotation)
        #and i answered: "yes. yes you are"
	else:
		position=delta_difference.rotated(-node_to_follow.rotation)
	
	
	

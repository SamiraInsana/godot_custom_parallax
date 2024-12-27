extends Sprite2D

#i had a lot of glitches with ParallaxBackground so i decided to make my own parallax script
#this should be attached to each layer
#well at least i can make my own sauce with this.

#----------------------------------------------------------------------------------------------

@export_category("custom_parallax")



@export var parallax_speed=1.0 
##this is the speed with wich the background moves. 0=static background and 1=background moving with the same speed as the camera.
##backgrounds wih 0 also dont change size, so if you zoom the camera it will look the same.
##that is because in real life, if you walk a step closer to the moon, the moon will appear exactly the same. what a surprise, huh?
##yeah yeah in short: 0 back, 1 front.

@export var parallax_position=Vector2(0.0,0.0) 
##this offsets the position. i never actually used it because i can just move the sprites in the editor and it works fine. you can ignore this line.

@export var mirror_x=false 
##determinate if you want to copy this image in the x axis (for making continuous effect)

@export var mirror_y=false
##same shit. y axis.

##determina se vai acontecer a correção de zoom. caso esteja desmarcado, os objetos permanecerão
##com o mesmo tamanho independente do zoom da câmera
@export var do_zoom_correction=false
##determines if the objects are going to do their zoom magic. i suggest you enable it. it looks better.
##or not. im not your mother
##or am i????

#-------------------------------------------------------------------------------------------------

var screensize=DisplayServer.screen_get_size() 
#screensize [vector2]

var image_size=texture.get_size()
#texture size [vector2]

var pixel_safe_margin=10
#this is a safety margin that determines the distance to the border before jumping the images (only happens in the continuous effect)
#so far this wasnt actually necessary. maybe if you are travelling at humongous speeds.

var screen_rotation=0
#screen rotation, radians

var canvasitem_material=self.material
##material used in the canvasitem

#-----------------------------------------------------------------------------------------

func _ready() -> void:
	position+=parallax_position 
    #moves *a bit* the shit
	
	
	global_signals.camera_moved.connect(move)
	#connect itself to the global signal
    #WARNING: no signal, no moving.
    
    
	if mirror_x: #detect if is going to mirror in the x axis
		var mirrowed_x = Sprite2D.new() #creates a new sprite to hold the texture
		mirrowed_x.texture=self.texture #apply my own texture in the new sprite
		mirrowed_x.position.x=-image_size.x #moves the texture to make it side by side
		mirrowed_x.material=canvasitem_material #apply my own material in the child
		add_child(mirrowed_x) #add as a child
		
	if mirror_y: #same shit. y axis.
		var mirrowed_y = Sprite2D.new() 
		mirrowed_y.texture=self.texture 
		mirrowed_y.position.y=-image_size.y 
		mirrowed_y.material=canvasitem_material 
		add_child(mirrowed_y)
		
	if mirror_y and mirror_x: #same shit, but AGAIN. because we need 4 images to make a parallax baby
		var mirrowed_xy = Sprite2D.new()
		mirrowed_xy.texture=self.texture
		mirrowed_xy.position=-image_size
		mirrowed_xy.material=canvasitem_material 
		add_child(mirrowed_xy) 
	
	global_signals.just_zoomed.connect(_zoom_correction)
	#connect to the global signal emmited by the camera
    ##WARNING AGAIN: no signal no doing stuff!!

#------------------------------------------------------------------------------------------

func move(delta_distance):
	#sent by the camera
	
    #please dont mess with the scale...
	position-=delta_distance*parallax_speed*scale.x
	
	#i hate how the scale of the screen is the inverse of the zoom. should be proportional
	
    
    #updates the viewport size and recalculate baes in the camera zoom to know what is the real size of the visible area
	#world coordinates btw
    
	screensize.x=get_viewport().get_visible_rect().size.x/global_values.camera_zoom.x 
	screensize.y=get_viewport().get_visible_rect().size.y/global_values.camera_zoom.y
	#ah, i should mention that this script also rotates
	screen_rotation=get_viewport_transform().get_rotation() 
	
	#----------------------------------------------------------------------
	
    #this part of the code checks to see if the viewport hits the edge of the image
    #then it moves the image accordingly
    
    #honestly, dont try to understand the calculations here. they werent easy at all to deduce
    #just accept that it checks to see if the image is on the edge.
    
	#hit right limit
	if mirror_x and position.x<(-image_size.x+(screensize.x*abs(cos(screen_rotation))+screensize.y*abs(sin(screen_rotation)))+pixel_safe_margin)/2:
		#print("screen moved to the right")
		position.x+=image_size.x
	#hit left limit
	elif mirror_x and position.x>1.5*image_size.x-0.5*(screensize.x*abs(cos(screen_rotation))+screensize.y*abs(sin(screen_rotation)))-pixel_safe_margin:
		position.x-=image_size.x
		#print("screen moved to the left")
	
	#hit up limit
	if mirror_y and position.y>1.5*image_size.y-0.5*(screensize.y*abs(cos(screen_rotation))+screensize.x*abs(sin(screen_rotation)))-pixel_safe_margin:
		position.y-=image_size.y
		#print("screen moved up")
	
	#hit down limit
	elif mirror_y and position.y<(-image_size.y+(screensize.y*abs(cos(screen_rotation))+screensize.x*abs(sin(screen_rotation))))/2+pixel_safe_margin:
		position.y+=image_size.y
		#print("screen moved down")
		
#this recieves a signal every time the camera zooms
func _zoom_correction():
	
	if do_zoom_correction:
    
        #yes. i know. this formula is hedious
	
		position.x*=1/((global_values.camera_zoom.x+parallax_speed-global_values.camera_zoom.x*parallax_speed)*scale.x)
		position.y*=1/((global_values.camera_zoom.y+parallax_speed-global_values.camera_zoom.y*parallax_speed)*scale.y)
		#horrible function to calculate the new position for stuff
		scale.y=1/(global_values.camera_zoom.y+parallax_speed-global_values.camera_zoom.y*parallax_speed)
		scale.x=1/(global_values.camera_zoom.x+parallax_speed-global_values.camera_zoom.x*parallax_speed)
		#once i close this i will never understand again how this works
		image_size.x=texture.get_size().x*scale.x
		image_size.y=texture.get_size().y*scale.y
		#this lines update the scale of the image
		
	

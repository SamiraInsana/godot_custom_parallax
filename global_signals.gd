extends Node
#this is a global signals script, you should put it in autoload so that signals emmited here can reach anyone

@warning_ignore("unused_signal")
signal just_zoomed
#sent by the camera whenever it zooms
@warning_ignore("unused_signal")
signal camera_moved(delta_distance)
#sent by the camera whenever it moves

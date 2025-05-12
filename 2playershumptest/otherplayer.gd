extends CharacterBody2D

@export var speed : int = 100
const BULLET = preload("res://bullet.tscn")

func shoot() -> void:
	var newbullet = BULLET.instantiate()
	newbullet.init(self.transform,self.global_position)

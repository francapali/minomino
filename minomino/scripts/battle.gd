extends Node2D

var timer = 5;
var was_pressed = false;
var press_window = 0.2;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Timer.start();
	$Label.text = str(timer);
	$Label2.text = "Premi SU al momento giusto...";
	
	$Label.set_position(Vector2(100, 100));
	$Label2.set_position(Vector2(300, 100));

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (timer == 0):
		if ($Timer.is_stopped() == false && was_pressed == false):
			if Input.is_action_pressed("ui_up"):
				print(1 - $Timer.time_left);
				if ((1 - $Timer.time_left) <= press_window):
					$Label2.text = "Hai ottenuto un bonus!";
				else:
					$Label2.text = "Non hai azzeccato il timing!";
				was_pressed = true;
	else:
		if ($Timer.is_stopped() == false && was_pressed == false):
			if Input.is_action_pressed("ui_up"):
				print($Timer.time_left);
				if ($Timer.time_left <= press_window && timer == 1):
					$Label2.text = "Hai ottenuto un bonus!";
				else:
					$Label2.text = "Non hai azzeccato il timing!";
				was_pressed = true;

func _on_timer_timeout() -> void:
	timer = timer - 1;
	
	if (timer >= 0):
		$Label.text = str(timer);
		
	$Timer.start();
		
	if timer == -1:
		if (was_pressed == false):
			$Label2.text = "Non hai azzeccato il timing! Tempo scaduto!";
		else:
			$Label2.text = $Label2.text + " Tempo scaduto!";
			
		$Timer.stop();

extends RichTextLabel

func _ready():
	# Imposta il testo
	text = "[center]Turno 1.[/center]"
	
	# Imposta il colore del testo
	add_theme_color_override("default_color", Color.WHITE)

	# Crea lo stylebox nero per lo sfondo
	var stylebox = StyleBoxFlat.new()
	stylebox.bg_color = Color(0, 0, 0, 1.0)  # Nero pieno, opaco
	stylebox.set_content_margin_all(8)  # Padding

	# Applica lo stylebox al RichTextLabel
	add_theme_stylebox_override("normal", stylebox)  # <-- ATTENZIONE: "normal", non "panel"

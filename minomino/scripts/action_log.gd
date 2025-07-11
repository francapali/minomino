extends RichTextLabel

func _ready():
	# Colore sfondo con trasparenza
	var background_color := Color("#a44025", 1)

	# Crea lo stile personalizzato
	var style := StyleBoxFlat.new()
	style.bg_color = background_color

	# Angoli arrotondati
	style.corner_radius_top_left = 15
	style.corner_radius_top_right = 15
	style.corner_radius_bottom_left = 15
	style.corner_radius_bottom_right = 15
	style.corner_detail = 8

	# Outline (bordo) BIANCO spesso 2px
	style.border_color = Color.WHITE
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_width_left = 2
	style.border_width_right = 2

	# Applica lo stile al RichTextLabel
	add_theme_stylebox_override("normal", style)

	# Colore del testo
	add_theme_color_override("default_color", Color.WHITE)

	# Pulisce e aggiunge testo
	clear()
	append_text("Log di sistema attivo...\n")

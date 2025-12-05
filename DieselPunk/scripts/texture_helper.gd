extends Node2D

# Helper to create colored square textures
static func create_colored_square(color: Color, size: int = 30) -> ImageTexture:
	var img = Image.create(size, size, false, Image.FORMAT_RGBA8)
	img.fill(color)
	return ImageTexture.create_from_image(img)

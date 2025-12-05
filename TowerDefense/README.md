# Tower Defense Game - Test Scene
	
	## Project Structure
	
	```
	TowerDefense/
	├── scenes/
	│   └── test_level.tscn      # Main test scene
	├── scripts/
	│   ├── game_manager.gd      # Handles gold, lives, waves
	│   ├── enemy.gd             # Enemy behavior
	│   ├── tower.gd             # Tower shooting logic
	│   ├── projectile.gd        # Bullet behavior
	│   └── enemy_spawner.gd     # Spawns enemy waves
	└── assets/
		├── towers/              # Put tower sprites here
		├── enemies/             # Put enemy sprites here
		├── ui/                  # Put UI elements here
		└── terrain/             # Put road/path textures here
	```
	
	## Current Placeholders (Replace with Your Art)
	
	### Visual Placeholders:
	- **PATH** (brown line) - Replace with road texture
	- **TOWER SPOTS** (green squares) - Replace with platform sprites
	- **TOWERS** (blue squares) - Replace with your tower sprites
	- **ENEMIES** (red squares) - Replace with your enemy sprites
	- **PROJECTILES** (yellow squares) - Replace with bullet/arrow sprites
	
	## How to Add Your Art
	
	### For the Path:
	1. Select the `PathLayer/EnemyPath/PathVisual` node
	2. Delete the Line2D and add a TileMap or repeated sprites
	3. Follow the path curve to draw your road
	
	### For Towers:
	1. Open `scripts/tower.gd`
	2. In the `_ready()` function, replace the ColorRect with:
	```gdscript
	var sprite = Sprite2D.new()
	sprite.texture = load("res://TowerDefense/assets/towers/your_tower.png")
	add_child(sprite)
	```
	
	### For Enemies:
	1. Open `scripts/enemy.gd`
	2. Replace the ColorRect in `_ready()` with your sprite
	
	### For Projectiles:
	1. Open `scripts/projectile.gd`
	2. Replace the ColorRect with your projectile sprite
	
	## Game Mechanics
	
	### Current Features:
	- ✅ Wave system (press START WAVE button)
	- ✅ Gold economy (start with 500 gold)
	- ✅ Tower placement (click green spots, costs 100 gold)
	- ✅ Auto-targeting towers
	- ✅ Enemy pathfinding
	- ✅ Health system with visual health bars
	- ✅ Lives system (lose life when enemy reaches end)
	- ✅ Wave scaling (more enemies, more health, more speed)
	
	### Tower Stats:
	- Damage: 20
	- Fire Rate: 1 shot/second
	- Range: 200 pixels
	- Cost: 100 gold
	
	### Enemy Stats (Wave 1):
	- Health: 100 HP
	- Speed: 100 pixels/second
	- Gold Reward: 10 gold
	
	Stats increase with each wave!
	
	## Testing Instructions
	
	1. Open `res://TowerDefense/scenes/test_level.tscn`
	2. Press F5 to run the scene
	3. Click green spots to place towers (costs 100 gold each)
	4. Click "START WAVE" to spawn enemies
	5. Watch towers automatically shoot enemies
	6. Try to survive multiple waves!
	
	## Next Steps for Development
	
	1. **Add Your Art**: Replace all placeholder ColorRects with sprites
	2. **Tower Types**: Create different tower types with different stats
	3. **Enemy Types**: Create different enemy types (fast, tanky, flying)
	4. **Upgrades**: Add tower upgrade system
	5. **Tower Selling**: Add ability to sell towers for partial refund
	6. **Sound Effects**: Add shooting, death, and UI sounds
	7. **Particle Effects**: Add explosions and hit effects
	8. **Mobile Controls**: Add touch controls for tower selection
	9. **More Levels**: Design different paths and difficulties
	10. **Save System**: Save player progress and unlocks
	
	## Mobile Optimization Tips
	
	- Use texture atlases for better performance
	- Keep draw calls low by batching similar sprites
	- Use Area2D instead of checking distances every frame
	- Optimize enemy count based on device capability
	- Add quality settings for effects/particles
	
	Enjoy building your tower defense game!
	
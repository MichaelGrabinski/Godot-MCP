# Level Editor Guide
	
	## 🎨 How to Create a Level
	
	### Step 1: Prepare Your Map Image
	1. Create your map background image (roads, terrain, etc.)
	2. Save it to: `res://TowerDefense/assets/terrain/your_map.png`
	3. Recommended size: 1080x1920 (portrait for mobile) or 1920x1080 (landscape)
	
	### Step 2: Open the Level Editor
	1. Open scene: `res://TowerDefense/scenes/level_editor.tscn`
	2. Press F6 to run the scene
	
	### Step 3: Load Your Map
	1. In the text field, enter your image path:
	Example: `res://TowerDefense/assets/terrain/my_map.png`
	2. Click "Load Image"
	3. Your map should appear in the editor
	
	### Step 4: Draw the Enemy Path
	1. Click "Click to Draw Path" button (it will highlight)
	2. Click on your map to create path points
	- Click at the START of where enemies spawn
	- Click along the road to create waypoints
	- Click at the END where enemies should reach
	3. Adjust "Path Width" slider to match your road width
	4. The red line shows where enemies will walk
	
	**Tips:**
	- Add more points for smoother curves
	- You can zoom with mouse wheel
	- Middle-click + drag to pan the view
	- Click "Clear Path" to start over
	
	### Step 5: Place Tower Spots
	1. Click "Click to Place Towers" button
	2. Click anywhere to place a green tower spot
	- Place them strategically around the path
	- Right-click on a spot to delete it
	3. Adjust "Tower Spot Size" if needed
	4. Click "Clear All Towers" to remove all spots
	
	**Tips:**
	- Can't place towers too close to each other
	- Think about tower range coverage
	- Leave some spots harder to reach for strategy
	
	### Step 6: Export Your Level
	1. Click "Export to JSON"
	2. Your level data saves to: `res://TowerDefense/assets/level_data.json`
	3. Status will show "Exported to level_data.json!"
	
	---
	
	## 🎮 Using Your Level in the Game
	
	### Option 1: Update test_level.tscn
	Open `res://TowerDefense/scripts/game_manager.gd` or the test level script and add at the start:
	
	```gdscript
	func _ready():
		# Load level data
		var LevelLoader = load("res://TowerDefense/scripts/level_loader.gd")
		LevelLoader.load_level("res://TowerDefense/assets/level_data.json", get_parent())
		
		# Your existing _ready code...
	```
	
	### Option 2: Create a New Level Scene
	1. Duplicate `test_level.tscn`
	2. Delete the PathLayer and TowerSpots nodes
	3. Add this to the root script's `_ready()`:
	```gdscript
	var LevelLoader = load("res://TowerDefense/scripts/level_loader.gd")
	LevelLoader.load_level("res://TowerDefense/assets/level_1.json", self)
	```
	
	---
	
	## 📝 Level Data Format
	
	The exported JSON looks like this:
	
	```json
	{
		"map_image": "res://TowerDefense/assets/terrain/map.png",
		"path": [
			{"x": 100, "y": 100},
			{"x": 200, "y": 150},
			{"x": 300, "y": 200}
		],
		"tower_spots": [
			{"x": 250, "y": 250, "size": 80},
			{"x": 400, "y": 300, "size": 80}
		]
	}
	```
	
	You can edit this manually if needed!
	
	---
	
	## 🔧 Editor Controls
	
	| Control | Action |
	|---------|--------|
	| Left Click | Add path point / Place tower spot |
	| Right Click | Delete tower spot |
	| Mouse Wheel | Zoom in/out |
	| Middle Click + Drag | Pan camera |
	
	---
	
	## 💡 Level Design Tips
	
	### Good Path Design:
	✅ Multiple turns (enemies exposed longer)
	✅ Some straight sections (easier to hit)
	✅ Not too long or too short
	✅ Clear start and end points
	
	### Good Tower Placement:
	✅ Cover all sections of path
	✅ Some spots better than others (strategy!)
	✅ Allow for different tower types/ranges
	✅ Not too many (players need to choose)
	✅ Not too few (players get overwhelmed)
	
	### Mobile Optimization:
	✅ Larger tower spots for touch (80-100 pixels)
	✅ Clear visual distinction between spots
	✅ Don't overcrowd the screen
	✅ Portrait orientation often works better
	
	---
	
	## 🐛 Troubleshooting
	
	**Image won't load?**
	- Check the file path is correct
	- Make sure image is in res:// folder
	- Supported formats: PNG, JPG, WebP
	
	**Path looks wrong in game?**
	- Check path points are in the right order
	- Make sure there are enough waypoints
	- Verify path width matches your road
	
	**Tower spots not showing?**
	- Make sure you exported the level
	- Check the JSON file was created
	- Verify level_loader.gd is being called
	
	**Camera is stuck?**
	- Middle-click and drag to pan
	- Mouse wheel to zoom
	- Camera starts centered on image
	
	---
	
	Enjoy building your tower defense levels! 🏰
	
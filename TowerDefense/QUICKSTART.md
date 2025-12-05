# 🚀 QUICK START - Level Editor
	
	## In 5 Minutes, Create Your First Level!
	
	### 1️⃣ Run the Editor (30 seconds)
	```
	1. Open: res://TowerDefense/scenes/level_editor.tscn
	2. Press F6 to run
	```
	
	### 2️⃣ Load a Test Image (30 seconds)
	```
	1. Put ANY image in: TowerDefense/assets/terrain/
	2. In the editor text box, type: res://TowerDefense/assets/terrain/YOUR_IMAGE.png
	3. Click "Load Image"
	```
	
	Don't have an image? Just use a placeholder for now!
	
	### 3️⃣ Draw Enemy Path (2 minutes)
	```
	1. Click "Click to Draw Path" button
	2. Click 4-6 points to make a winding path
	- Start point (where enemies spawn)
	- 2-4 waypoints (along the path)
	- End point (where enemies exit)
	3. Done! You'll see a red line
	```
	
	### 4️⃣ Place Tower Spots (1 minute)
	```
	1. Click "Click to Place Towers" button  
	2. Click 5-8 times around your path
	3. Done! You'll see green squares
	```
	
	### 5️⃣ Export & Play (1 minute)
	```
	1. Click "Export to JSON"
	2. Close the editor
	3. Open: res://TowerDefense/scenes/level_from_json.tscn
	4. Press F5 to play YOUR level!
	```
	
	---
	
	## ✨ What You Can Do Now:
	
	### In the Game Scene:
	- Click green spots to build towers (100 gold)
	- Click START WAVE to send enemies
	- Watch your towers defend!
	
	### Back in the Editor:
	- Zoom: Mouse wheel
	- Pan: Middle mouse + drag
	- Delete tower: Right click on spot
	- Adjust sizes: Use the sliders
	
	---
	
	## 🎨 Next Steps:
	
	1. **Replace placeholder with your actual map art**
	- Draw roads, terrain, decorations
	- Export as PNG, put in assets/terrain/
	
	2. **Refine your level**
	- Add more path curves for interest
	- Position towers strategically
	- Test difficulty by playing
	
	3. **Create multiple levels**
	- Export each as level_1.json, level_2.json, etc.
	- Change the path in level_from_json.tscn
	
	4. **Replace visual placeholders**
	- Swap ColorRects with your sprites
	- See LEVEL_EDITOR_GUIDE.md for details
	
	---
	
	## 🆘 Common First-Time Issues:
	
	**"Image won't load"**
	→ Double-check the path starts with `res://`
	
	**"Path looks weird"**
	→ Click points in ORDER from start to finish
	
	**"Can't place towers"**
	→ They can't overlap, try different spot
	
	**"Nothing happens when I play"**
	→ Did you export? Check level_data.json exists
	
	**"Game crashes"**
	→ Make sure you have at least 2 path points
	
	---
	
	That's it! You're ready to create levels! 🎮
	
	For more details, see: LEVEL_EDITOR_GUIDE.md
	
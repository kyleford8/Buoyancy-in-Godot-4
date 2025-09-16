# Surfing Game - Godot 4

A minimally viable surfing game prototype built in Godot 4 with realistic wave physics and surfing mechanics.

## Features

### 🌊 Surfable Waves
- Realistic Gerstner wave equations for authentic surfing physics
- Multiple wave layers with different frequencies and directions
- Dynamic wave height and steepness parameters
- Infinite water system with seamless tiling

### 🏄‍♂️ Surfing Mechanics
- Wave gradient detection for automatic wave riding
- Balance controls with mouse/touch input
- Air time tracking for tricks and stunts
- Speed-based scoring system
- Trick scoring with air time bonuses

### 🎮 Game Features
- Real-time UI showing score, speed, and wave status
- Objective system with progressive challenges
- Dynamic camera that follows surfing action
- 5-minute time limit with scoring objectives
- Trick detection and scoring

## Controls

- **Mouse/Touch Drag**: Balance and steer the surfboard
- **WASD**: Alternative keyboard controls for movement
- **Space**: Jump/boost (for tricks)

## Objectives

1. **First Wave**: Ride your first wave for 5 seconds (100 points)
2. **Speed Demon**: Reach 100 km/h speed (200 points)
3. **Air Time**: Stay airborne for 2 seconds (300 points)
4. **Score Master**: Reach 1000 points (500 points)

## Technical Implementation

### Wave System
- Uses Gerstner wave equations for realistic water displacement
- Multiple wave layers create complex, surfable wave patterns
- Infinite water tiling system for seamless exploration
- Real-time wave height calculation for physics interaction

### Physics
- RigidBody3D with custom buoyancy forces
- Wave gradient detection for surfing mechanics
- Air time tracking for trick detection
- Speed-based camera adjustments

### Game Loop
- Objective-based progression system
- Real-time scoring and UI updates
- Dynamic camera following
- Time-limited gameplay sessions

## Files Structure

- `assets/shaders/water.gdshader` - Enhanced water shader with Gerstner waves
- `Water.gd` - Water tile management and height calculation
- `InfiniteWater.gd` - Infinite water system with dynamic tiling
- `Cube.gd` - Surfboard physics and surfing mechanics
- `CameraFollow.gd` - Dynamic camera system
- `GameUI.gd` - Real-time UI and HUD
- `GameManager.gd` - Game objectives and progression
- `main.tscn` - Main game scene

## Quick Start

1. Open the project in Godot 4
2. Run the main scene
3. Use mouse/touch to control the surfboard
4. Complete objectives to score points
5. Try to achieve the highest score in 5 minutes!

This is a minimally viable prototype ready for further development and expansion.

---

*Original water shader from: https://stayathomedev.com/?utm_source=youtube&utm_medium=desc&utm_content=watershader*

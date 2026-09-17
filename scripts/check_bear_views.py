"""Render two inspection views from the editable Blender mother file, without saving changes."""
from pathlib import Path
import bpy
from mathutils import Vector

root = Path(__file__).resolve().parents[1]
bpy.ops.wm.open_mainfile(filepath=str(root / 'game/source/before-waking-art.blend'))
bear = bpy.data.objects['Bear']
def children(obj):
    return [obj] + [desc for child in obj.children for desc in children(child)]
visible = set(children(bear))
for obj in bpy.data.objects:
    if obj.type not in {'LIGHT', 'CAMERA'}:
        obj.hide_render = obj not in visible
target = bear.location + Vector((0, 0, .52))
bpy.ops.object.light_add(type='AREA', location=target + Vector((-1.2, -2.5, 2)))
light = bpy.context.object
light.data.energy = 250
light.data.shape = 'DISK'
light.data.size = 2.5
light.rotation_euler = (target-light.location).to_track_quat('-Z', 'Y').to_euler()
scene = bpy.context.scene
scene.render.engine = 'CYCLES'
scene.cycles.device = 'CPU'
scene.cycles.samples = 16
scene.render.resolution_x = scene.render.resolution_y = 640
scene.render.resolution_percentage = 100
scene.camera.data.lens = 65
out = root / 'docs/evidence/final-game'
out.mkdir(parents=True, exist_ok=True)
for name, offset in [('bear-front', (0, -2.5, .25)), ('bear-side', (2.2, -.9, .30))]:
    scene.camera.location = target + Vector(offset)
    scene.camera.rotation_euler = (target-scene.camera.location).to_track_quat('-Z','Y').to_euler()
    scene.render.filepath = str(out / (name + '.png'))
    bpy.ops.render.render(write_still=True)

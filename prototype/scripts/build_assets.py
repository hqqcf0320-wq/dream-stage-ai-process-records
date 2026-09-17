"""Editable Blender master for Before Waking. Metres, Z up, +Y is upstage.
Run: .tools/blender-env/Scripts/python.exe prototype/scripts/build_assets.py
"""
import bpy, math, os
from mathutils import Vector
ROOT=os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT=os.path.join(ROOT,'public','assets'); os.makedirs(OUT,exist_ok=True)
bpy.ops.object.select_all(action='SELECT'); bpy.ops.object.delete(use_global=False)
def mat(name,color,rough=.6,metal=0):
 m=bpy.data.materials.new(name);m.diffuse_color=(*color,1);m.use_nodes=True
 p=m.node_tree.nodes.get('Principled BSDF');p.inputs['Base Color'].default_value=(*color,1);p.inputs['Roughness'].default_value=rough;p.inputs['Metallic'].default_value=metal
 return m
stone=mat('青绿石板 | sea-green slate',(.055,.25,.22),.38);red=mat('朱红旧窗 | vermilion',(.47,.065,.04),.48)
wood=mat('深色木扶手',(.085,.046,.027));cloth=mat('姥爷灰蓝外套 | actor stand-in',(.13,.19,.20));pants=mat('深灰裤子',(.052,.065,.066));skin=mat('温暖皮肤',(.42,.29,.19));hair=mat('银灰头发',(.44,.43,.37));fur=mat('蜂蜜色毛绒',(.55,.30,.11),.95);cream=mat('小熊浅色口鼻',(.83,.66,.40),1);dark=mat('黑褐眼睛',(.025,.013,.009),.3);shirt=mat('小熊砖红衣服',(.45,.09,.05));floor=mat('墨绿舞台',(.017,.028,.025),.4);brass=mat('旧金色',(.55,.35,.09),.3,.7)
def empty(name,loc=(0,0,0),parent=None):
 o=bpy.data.objects.new(name,None);bpy.context.collection.objects.link(o);o.location=loc;o.parent=parent;return o
def cube(name,loc,size,material,parent=None,bevel=.035):
 bpy.ops.mesh.primitive_cube_add(size=1);o=bpy.context.object;o.name=name;o.location=loc;o.scale=size;bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
 if bevel:mod=o.modifiers.new('软化边缘','BEVEL');mod.width=bevel;mod.segments=3;o.modifiers.new('加权法线','WEIGHTED_NORMAL')
 o.data.materials.append(material);o.parent=parent;return o
def ell(name,loc,scale,material,parent=None):
 bpy.ops.mesh.primitive_uv_sphere_add(segments=24,ring_count=16);o=bpy.context.object;o.name=name;o.location=loc;o.scale=scale;o.data.materials.append(material);o.parent=parent
 for p in o.data.polygons:p.use_smooth=True
 return o
room=empty('RoomSet')
cube('SlateFloor',(0,2,-.09),(7.6,5.8,.16),floor,room)
window=empty('RedWindow',(0,4.1,0),room)
for x in [-2.45,0,2.45]:cube('WindowUpright',(x,0,2.5),(.13,.18,3.8),red,window)
for z in [.65,2.2,4.4]:cube('WindowHorizontal',(0,0,z),(5.02,.19,.12),red,window)
for x in [-1.63,-.82,.82,1.63]:cube('WindowFineBar',(x,0,3.3),(.045,.075,2.1),red,window,.01)
cube('WindowSill',(0,-.06,.62),(5.3,.55,.13),stone,window)
table=empty('SlateTable',(1.35,2.3,0),room)
cube('TableTop',(0,0,1.0),(2.4,1.15,.13),stone,table)
for x in [-.94,.94]:
 for y in [-.38,.38]:cube('TableLeg',(x,y,.48),(.13,.13,.96),stone,table)
chair=empty('GreenChair',(-.6,1.9,0))
cube('ChairSeat',(0,0,.59),(.83,.82,.13),stone,chair)
for x in [-.32,.32]:
 for y in [-.30,.30]:cube('ChairLeg',(x,y,.3),(.10,.10,.6),stone,chair)
for x in [-.37,.37]:
 cube('ChairBackPost',(x,-.32,1.01),(.10,.11,1.0),stone,chair)
 cube('ChairArm',(x,0,.94),(.11,.88,.10),wood,chair)
cube('ChairBack',(0,-.32,1.28),(.76,.11,.45),stone,chair)
grandpa=empty('Grandpa',(-.6,1.9,0))
ell('CoatTorso',(0,0,1.10),(.32,.23,.46),cloth,grandpa)
ell('CoatHip',(0,.13,.73),(.31,.3,.19),cloth,grandpa)
for x in [-.17,.17]:
 ell('Thigh',(x,.38,.65),(.145,.34,.14),pants,grandpa)
 ell('Shin',(x,.64,.32),(.10,.10,.32),pants,grandpa)
 ell('Shoe',(x,.75,.07),(.13,.23,.09),dark,grandpa)
ell('Neck',(0,.02,1.49),(.11,.11,.16),skin,grandpa)
head=empty('GrandpaHead',(0,.035,1.73),grandpa)
ell('Head',(0,0,0),(.205,.18,.25),skin,head)
ell('Hair',(0,-.04,.075),(.21,.17,.2),hair,head)
ell('Nose',(0,.18,-.025),(.047,.085,.065),skin,head)
for x in [-.19,.19]:ell('Ear',(x,0,-.01),(.041,.039,.067),skin,head)
for side,x in [('L',-.28),('R',.28)]:
 arm=empty('GrandpaArm'+side,(x,0,1.36),grandpa)
 ell('UpperSleeve',(0,.05,-.18),(.115,.115,.24),cloth,arm)
 fore=ell('ForeSleeve',(0,.24,-.36),(.10,.25,.09),cloth,arm)
 ell('Hand',(0,.48,-.36),(.075,.12,.05),skin,arm)
def bear(name,loc,scale=1):
 b=empty(name,loc);b.scale=(scale,scale,scale)
 ell('BearBody',(0,0,.30),(.23,.16,.28),fur,b);ell('BearBelly',(0,-.135,.3),(.15,.035,.19),cream,b)
 ell('BearHead',(0,0,.65),(.24,.18,.22),fur,b)
 for x in [-.19,.19]:
  ell('BearEar',(x,0,.84),(.10,.065,.105),fur,b);ell('BearEarInner',(x,-.06,.84),(.055,.015,.06),cream,b)
  ell('BearLeg',(x*.8,-.035,.075),(.105,.17,.11),fur,b)
  ell('BearArm',(x*1.28,0,.32),(.095,.11,.19),fur,b)
 ell('BearMuzzle',(0,-.17,.60),(.13,.06,.08),cream,b);ell('BearNose',(0,-.227,.63),(.035,.025,.025),dark,b)
 for x in [-.085,.085]:ell('BearEye',(x,-.167,.697),(.021,.018,.023),dark,b)
 cube('BearRibbon',(0,-.168,.445),(.20,.035,.08),red,b,.025)
 return b
small=bear('SmallBear',(1.1,2.3,1.08),.67)
big=bear('BigBear',(-3.1,.15,.20),1.65)
cube('ExchangePlinth',(-3.1,.15,.06),(1.6,1.4,.12),stone)
# Removable garment: the live actor performs the actual dressing, this is a visual marker only.
garment=ell('BearGarment',(0,0,.29),(.245,.175,.22),shirt,small)
# Keep transforms evaluated for glTF export; runtime controls garment visibility.
# Master previsualisation camera/light, kept in .blend only.
bpy.ops.object.camera_add(location=(8,-12,6));cam=bpy.context.object;cam.name='AudiencePreviewCamera';cam.rotation_euler=(Vector((0,2,1.4))-cam.location).to_track_quat('-Z','Y').to_euler();cam.data.lens=43;bpy.context.scene.camera=cam
for name,loc,power,col,size in [('WindowSun',(-1,5,5),1600,(1,.72,.36),4),('SoftAudience',(2,-4,5),650,(.65,.81,1),5)]:
 bpy.ops.object.light_add(type='AREA',location=loc);l=bpy.context.object;l.name=name;l.data.energy=power;l.data.color=col;l.data.shape='DISK';l.data.size=size;l.rotation_euler=(Vector((0,2,1))-l.location).to_track_quat('-Z','Y').to_euler()
scene=bpy.context.scene;scene.world.color=(.04,.04,.04);scene.render.engine='CYCLES';scene.cycles.samples=24;scene.render.resolution_x=1200;scene.render.resolution_y=800;scene.render.resolution_percentage=100
bpy.ops.wm.save_as_mainfile(filepath=os.path.join(OUT,'before-waking-master.blend'))
bpy.ops.export_scene.gltf(filepath=os.path.join(OUT,'before-waking-stage.glb'),export_format='GLB',export_cameras=False,export_lights=False,export_apply=True)
print('ASSETS_READY',os.path.join(OUT,'before-waking-stage.glb'))

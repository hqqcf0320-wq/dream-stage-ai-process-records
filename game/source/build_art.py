"""Authored game-ready memory theatre assets, Blender 4.5.3. Z-up, metres."""
import bpy, math, random, json, struct
from pathlib import Path
from mathutils import Vector
random.seed(19);ROOT=Path(__file__).resolve().parents[1];OUT=ROOT/'assets'
bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
def material(name,c,rough=.65,texture=None):
 m=bpy.data.materials.new(name);m.diffuse_color=(*c,1);m.use_nodes=True;p=m.node_tree.nodes.get('Principled BSDF');p.inputs['Base Color'].default_value=(*c,1);p.inputs['Roughness'].default_value=rough
 if texture:
  for suffix,socket in [('color','Base Color'),('rough','Roughness'),('normal','Normal')]:
   tex=m.node_tree.nodes.new('ShaderNodeTexImage');tex.image=bpy.data.images.load(str(OUT/(texture+'_'+suffix+'.png')),check_existing=True)
   if suffix!='color':tex.image.colorspace_settings.name='Non-Color'
   if suffix=='normal':
    normal=m.node_tree.nodes.new('ShaderNodeNormalMap');normal.inputs['Strength'].default_value=.28;m.node_tree.links.new(tex.outputs['Color'],normal.inputs['Color']);m.node_tree.links.new(normal.outputs['Normal'],p.inputs[socket])
   else:m.node_tree.links.new(tex.outputs['Color'],p.inputs[socket])
 return m
slate=material('青绿石板',( .1,.3,.24),texture='slate');red=material('朱红旧漆',(.48,.1,.06),texture='paint');fur=material('蜂蜜毛毡',(.68,.42,.18),texture='felt');knit=material('砖红针织',(.4,.1,.08),texture='knit')
cream=material('棉麻奶油',(.76,.65,.45),.96);thread=material('手缝浅线',(.55,.44,.30),.95);eye=material('深褐玻璃眼',(.025,.014,.009),.17);wood=material('旧木边缘',(.16,.082,.035));brass=material('暗黄铜',(.37,.25,.08),.34);skin=material('暖肤色',(.48,.30,.19),.72);silver=material('银白发',(.59,.57,.49),.9);coat=material('墨绿开衫',(.075,.14,.125),.92);pants=material('炭灰裤',(.055,.057,.052),.9);plaster=material('温暖石灰墙',(.42,.40,.31),.98);floor=material('石面暗边',(.058,.089,.076),.85)
def empty(n,loc=(0,0,0),parent=None):
 o=bpy.data.objects.new(n,None);bpy.context.collection.objects.link(o);o.location=loc;o.parent=parent;return o
def cube(n,p,s,m,parent=None,b=.018):
 bpy.ops.mesh.primitive_cube_add(size=1,location=p);o=bpy.context.object;o.name=n;o.scale=s;bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
 if b:
  mod=o.modifiers.new('Rounded tangible edge','BEVEL');mod.width=b;mod.segments=3;o.modifiers.new('Weighted normal','WEIGHTED_NORMAL')
 o.data.materials.append(m);o.parent=parent;return o
def oval(n,p,s,m,parent=None,seg=32):
 bpy.ops.mesh.primitive_uv_sphere_add(segments=seg,ring_count=20,location=p);o=bpy.context.object;o.name=n;o.scale=s;o.data.materials.append(m);o.parent=parent
 for f in o.data.polygons:f.use_smooth=True
 return o
def line(n,pts,r,m,parent=None):
 cu=bpy.data.curves.new(n,'CURVE');cu.dimensions='3D';cu.resolution_u=2;cu.bevel_depth=r;cu.bevel_resolution=2;sp=cu.splines.new('POLY');sp.points.add(len(pts)-1)
 for v,p in zip(sp.points,pts):v.co=(*p,1)
 o=bpy.data.objects.new(n,cu);bpy.context.collection.objects.link(o);o.data.materials.append(m);o.parent=parent;return o
def loft(n,rings,m,parent=None):
 verts=[];faces=[];segs=40
 for z,rx,ry,cy in rings:
  for j in range(segs):
   a=j/segs*2*math.pi;verts.append((rx*math.cos(a),cy+ry*math.sin(a),z))
 for i in range(len(rings)-1):
  for j in range(segs):faces.append((i*segs+j,i*segs+(j+1)%segs,(i+1)*segs+(j+1)%segs,(i+1)*segs+j))
 faces.extend([tuple(reversed(range(segs))),tuple((len(rings)-1)*segs+j for j in range(segs))]);me=bpy.data.meshes.new(n);me.from_pydata(verts,[],faces);me.update();uv=me.uv_layers.new(name='UVMap')
 for poly in me.polygons:
  indices=[me.loops[k].vertex_index for k in poly.loop_indices];seam=any(v%segs==segs-1 for v in indices) and any(v%segs==0 for v in indices)
  for k in poly.loop_indices:
   v=me.loops[k].vertex_index;j=v%segs
   if len(poly.vertices)>4:
    a=j/segs*2*math.pi;uv.data[k].uv=(.5+.5*math.cos(a),.5+.5*math.sin(a))
   else:uv.data[k].uv=((1.0 if seam and j==0 else j/segs), (v//segs)/max(1,len(rings)-1))
 o=bpy.data.objects.new(n,me);bpy.context.collection.objects.link(o);o.data.materials.append(m);o.parent=parent
 for p in me.polygons:p.use_smooth=True
 o.modifiers.new('Stable export triangulation','TRIANGULATE')
 return o
room=empty('RoomSet')
# Irregular islands of floor; gaps are deliberate and thin enough to cross.
for ix in range(-5,6):
 for iy in range(-2,7):
  if abs(ix)==5 and random.random()<.5:continue
  cube('SlateTile',(ix*.77,iy*.77,-.07),(.765,.765,.12),floor,room,.008)
window=empty('RedWindow',(0,4.9,0),room)
for x in [-2.8,2.8]:
 cube('WindowOuter',(x,0,2.65),(.22,.31,4.6),red,window,.025)
 cube('WindowRebate',(x*.953,-.13,2.65),(.06,.08,4.3),wood,window,.008)
for z in [.44,4.86]:cube('WindowOuterCross',(0,0,z),(5.8,.32,.22),red,window)
for x in [-1.4,0,1.4]:cube('WindowMullion',(x,0,2.65),(.075,.19,4.2),red,window,.01)
cube('WindowCross',(0,-.018,2.46),(5.5,.2,.085),red,window,.01)
cube('DeepSlateSill',(0,-.15,.36),(6.0,.7,.14),slate,window,.028)
for x in [-3.5,3.5]:cube('PlasterWing',(x,.2,2.4),(1.1,.24,4.7),plaster,window,.04)
# A few meaningful props; clear actor/hand silhouette has priority.
table=empty('SlateTable',(1.7,3.1,0),room)
cube('HeavySlab',(0,0,.94),(2.2,1.1,.12),slate,table,.026)
for x in [-.88,.88]:
 for y in [-.35,.35]:cube('TaperLeg',(x,y,.45),(.12,.13,.89),slate,table,.016)
for x in [-.85,.85]:cube('TableApron',(x,0,.77),(.1,.86,.12),slate,table)
mug=empty('EnamelCup',(-.5,0,1.0),table)
loft('Cup',[(0,.105,.105,0),(.02,.12,.12,0),(.23,.125,.125,0),(.25,.13,.13,0)],cream,mug)
line('CupHandle',[(.12+.078*math.cos(a),0,.14+.088*math.sin(a)) for a in [i/24*2*math.pi for i in range(25)]],.017,cream,mug)
oval('Tea',(0,0,.246),(.115,.115,.006),wood,mug)
cube('FoldedCardigan',(.48,0,1.035),(.72,.45,.09),knit,table,.04)
for i in range(9):line('FoldStitch',[(.18+i*.07,-.22,1.085),(.18+i*.07,.22,1.085)],.002,thread,table)
chair=empty('GreenChair',(-.8,2.5,0))
cube('ChairSeat',(0,0,.57),(.85,.83,.13),slate,chair,.035)
for x in [-.34,.34]:
 for y in [-.31,.31]:cube('ChairLeg',(x,y,.28),(.10,.11,.55),slate,chair,.012)
 cube('ChairPost',(x,-.31,1.0),(.10,.105,.94),slate,chair)
 cube('ArmRail',(x,0,.90),(.12,.88,.1),slate,chair,.025)
for z in [1.04,1.28]:cube('ChairBackRail',(0,-.33,z),(.73,.1,.13),slate,chair)
exchange=empty('ExchangePedestal',(-3.0,-.3,0))
cube('Pedestal',(0,0,.18),(1.55,1.55,.35),slate,exchange,.06)
def bear():
 b=empty('Bear')
 oval('Body',(0,0,.34),(.26,.185,.32),fur,b)
 oval('Belly',(0,-.166,.30),(.18,.032,.205),cream,b)
 h=empty('BearHead',(0,-.01,.73),b)
 oval('Head',(0,0,0),(.265,.205,.238),fur,h)
 oval('Muzzle',(0,-.193,-.047),(.153,.073,.097),cream,h)
 oval('Nose',(0,-.257,-.021),(.045,.029,.034),eye,h)
 for x in [-.092,.092]:
  oval('Eye',(x,-.187,.055),(.025,.02,.028),eye,h)
  oval('EyeGlint',(x-.006,-.205,.065),(.005,.004,.006),cream,h,16)
 for side,x in [('L',-.217),('R',.217)]:
  e=empty('BearEar'+side,(x,.008,.185),h);e.rotation_euler.y=-.24 if side=='L' else .12
  oval('SoftEar',(0,0,0),(.111,.061,.13),fur,e);oval('EarFelt',(0,-.055,0),(.069,.018,.082),knit,e)
 for side,x in [('L',-.26),('R',.26)]:
  a=empty('BearArm'+side,(x,0,.49),b);a.rotation_euler.y=.19 if side=='L' else -.19
  oval('Arm',(0,0,-.13),(.098,.11,.20),fur,a)
  oval('Paw',(0,-.081,-.26),(.066,.038,.06),cream,a)
  leg=empty('BearLeg'+side,(x*.69,-.065,.10),b);oval('Foot',(0,0,0),(.12,.19,.13),fur,leg);oval('Sole',(0,-.173,.015),(.079,.027,.075),cream,leg)
 garment=empty('BearGarment',(0,0,0),b)
 loft('KnitVest',[(.17,.28,.255,0),(.28,.292,.27,0),(.43,.28,.25,0),(.52,.23,.21,0),(.56,.16,.16,0)],knit,garment)
 for x in [-.045,.045]:line('VestTrim',[(x,-.265,.22),(x,-.267,.35),(x,-.213,.51)],.008,cream,garment)
 for z in [.27,.35,.43]:oval('Button',(0,-.277,z),(.014,.009,.014),wood,garment,16)
 # The two bears retain the same little left-sleeve repair.
 patch=cube('LeftSleevePatch',(-.279,-.095,.38),(.11,.028,.10),cream,b,.018)
 for i in range(5):
  z=.343+i*.018;line('RepairStitch',[(-.321,-.114,z),(-.30,-.118,z+.006)],.0025,knit,b)
 for i in range(17):
  z=.10+i*.029;f=math.sqrt(max(.01,1-((z-.34)/.33)**2));yy=-.187*f
  line('BodyStitch',[(-.007,yy-.004,z),(.007,yy-.004,z+.008)],.0018,thread,b)
 line('Mouth',[(-.038,-.261,-.080),(0,-.269,-.089),(.035,-.261,-.079)],.0035,wood,h)
 return b
bear_root=bear();bear_root.location=(-3,-.3,.37)
grandpa=empty('Grandpa',(-.8,2.5,0))
loft('CardiganBody',[(.60,.27,.21,.06),(.70,.34,.26,.06),(.94,.33,.23,0),(1.18,.35,.21,-.025),(1.36,.32,.19,-.01),(1.43,.15,.12,0)],coat,grandpa)
for side,x in [('L',-.17),('R',.17)]:
 oval('TrouserThigh',(x,.31,.62),(.145,.33,.135),pants,grandpa)
 oval('TrouserShin',(x,.57,.32),(.115,.13,.31),pants,grandpa)
 oval('SoftShoe',(x,.70,.068),(.135,.235,.086),wood,grandpa)
for x in [-.055,.055]:line('CardiganPlacket',[(x,.245,.7),(x,.235,1.07),(x,.16,1.40)],.012,wood,grandpa)
for z in [.80,.94,1.08,1.22]:oval('CardiganButton',(0,.25,z),(.017,.014,.017),brass,grandpa,16)
oval('Neck',(0,0,1.43),(.09,.09,.15),skin,grandpa)
head=empty('GrandpaHead',(0,.01,1.66),grandpa)
oval('Face',(0,0,0),(.177,.17,.235),skin,head)
oval('HairBack',(0,-.060,.055),(.184,.145,.211),silver,head)
oval('Forehead',(0,.08,.065),(.148,.104,.14),skin,head)
oval('Nose',(0,.17,-.025),(.046,.080,.066),skin,head)
oval('Chin',(0,.083,-.158),(.104,.092,.067),skin,head)
for x in [-.17,.17]:oval('Ear',(x,0,-.022),(.037,.04,.064),skin,head)
for x in [-.067,.067]:
 line('Eyebrow',[(x-.028,.165,.04),(x,.18,.047),(x+.028,.166,.04)],.008,silver,head)
 oval('Eye',(x,.164,.015),(.024,.009,.01),wood,head,16)
line('QuietMouth',[(-.048,.163,-.105),(0,.18,-.109),(.046,.163,-.101)],.0035,wood,head)
for side,x in [('L',-.32),('R',.32)]:
 arm=empty('GrandpaArm'+side,(x,0,1.30),grandpa)
 oval('UpperSleeve',(0,.035,-.16),(.12,.125,.255),coat,arm)
 oval('BentElbow',(0,.11,-.36),(.116,.14,.12),coat,arm)
 elbow=empty('GrandpaElbow'+side,(0,.11,-.36),arm)
 oval('LowerSleeve',(0,.19,-.02),(.098,.255,.096),coat,elbow)
 oval('Cuff',(0,.39,-.01),(.09,.06,.075),wood,elbow)
 hand=empty('GrandpaHand'+side,(0,.46,-.01),elbow)
 oval('Palm',(0,0,0),(.071,.102,.043),skin,hand)
 for i in range(4):
  xx=-.045+i*.030;line('Finger',[(xx,.045,0),(xx,.13,-.006),(xx,.154,-.034)],.014,skin,hand)
 line('Thumb',[(.062,0,0),(.105,.054,-.005),(.09,.095,-.025)],.019,skin,hand)
# Preview lights and cameras stay in the editable mother file, not the exported assets.
for name,loc,power,col,size in [('WarmWindow',(-2,5.8,5.5),1600,(1,.73,.43),3.5),('AudienceFill',(2,-4,4),380,(.66,.81,.85),5)]:
 bpy.ops.object.light_add(type='AREA',location=loc);l=bpy.context.object;l.name=name;l.data.energy=power;l.data.color=col;l.data.shape='DISK';l.data.size=size;l.rotation_euler=(Vector((0,2,1))-l.location).to_track_quat('-Z','Y').to_euler()
bpy.ops.object.camera_add(location=(5,-8,3.0));cam=bpy.context.object;cam.rotation_euler=(Vector((-.3,2.5,1.2))-cam.location).to_track_quat('-Z','Y').to_euler();cam.data.lens=40;bpy.context.scene.camera=cam
scene=bpy.context.scene;scene.render.engine='CYCLES';scene.cycles.samples=24;scene.render.resolution_x=1440;scene.render.resolution_y=900;scene.render.resolution_percentage=100;scene.world.color=(.04,.04,.04)
for im in bpy.data.images:
 if im.source=='FILE':im.pack()
bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'source'/'before-waking-art.blend'))
def descendants(root):
 return [root]+[c for child in root.children for c in descendants(child)]
def export(name,roots,origin=False):
 bpy.ops.object.select_all(action='DESELECT');old=[]
 for root in roots:
  old.append(root.location.copy())
  if origin:root.location=(0,0,0)
  for o in descendants(root):o.select_set(True)
 bpy.context.view_layer.update()
 bpy.ops.export_scene.gltf(filepath=str(OUT/(name+'.glb')),export_format='GLB',use_selection=True,export_apply=True,export_tangents=True,export_cameras=False,export_lights=False)
 # Tangents have no purpose on flat-color materials; remove unnecessary exported attributes.
 # Keep the binary chunk unchanged, so all buffer-view offsets remain valid.
 path=OUT/(name+'.glb');data=path.read_bytes();length=struct.unpack_from('<I',data,12)[0];doc=json.loads(data[20:20+length])
 for mesh in doc['meshes']:
  for primitive in mesh['primitives']:
   if 'normalTexture' not in doc['materials'][primitive['material']]:primitive['attributes'].pop('TANGENT',None)
 encoded=json.dumps(doc,separators=(',',':'),ensure_ascii=False).encode('utf-8');encoded+=b' '*((-len(encoded))%4);tail=data[20+length:]
 path.write_bytes(struct.pack('<4sII',b'glTF',2,20+len(encoded)+len(tail))+struct.pack('<I4s',len(encoded),b'JSON')+encoded+tail)
 for root,loc in zip(roots,old):root.location=loc
export('room',[room,chair,exchange]);export('bear',[bear_root],True);export('grandpa',[grandpa],True)
print('Authored game assets exported')

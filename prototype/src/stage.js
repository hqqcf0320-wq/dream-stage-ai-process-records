import * as THREE from 'three';
import {GLTFLoader} from 'three/addons/loaders/GLTFLoader.js';
import {EffectComposer} from 'three/addons/postprocessing/EffectComposer.js';
import {RenderPass} from 'three/addons/postprocessing/RenderPass.js';
import {UnrealBloomPass} from 'three/addons/postprocessing/UnrealBloomPass.js';
import {OutputPass} from 'three/addons/postprocessing/OutputPass.js';
import {people} from './score.js';
export async function createStage(container,state){
 const scene=new THREE.Scene();scene.background=new THREE.Color('#030706');scene.fog=new THREE.FogExp2('#030706',.023);
 const renderer=new THREE.WebGLRenderer({antialias:true,powerPreference:'high-performance'});renderer.setPixelRatio(Math.min(devicePixelRatio,1.35));renderer.shadowMap.enabled=true;renderer.shadowMap.type=THREE.PCFSoftShadowMap;renderer.toneMapping=THREE.ACESFilmicToneMapping;renderer.toneMappingExposure=1.22;container.appendChild(renderer.domElement);
 const camera=new THREE.PerspectiveCamera(43,1,.1,90);camera.position.set(7.8,5.3,11.7);
 const composer=new EffectComposer(renderer);composer.addPass(new RenderPass(scene,camera));const bloom=new UnrealBloomPass(new THREE.Vector2(800,600),.65,.5,.8);composer.addPass(bloom);composer.addPass(new OutputPass());
 const hemi=new THREE.HemisphereLight('#c5dfd4','#141a18',.40);scene.add(hemi);
 const sun=new THREE.SpotLight('#ffd79b',100,30,.72,.5,1.1);sun.position.set(-2.8,6.5,-6);sun.target.position.set(0,0,2);sun.castShadow=true;sun.shadow.mapSize.set(1024,1024);sun.shadow.bias=-.001;scene.add(sun,sun.target);
 const fill=new THREE.DirectionalLight('#a2c4c7',1.3);fill.position.set(1,5,7);scene.add(fill);
 const chairLight=new THREE.PointLight('#8ecfc3',9,10,1.4);chairLight.position.set(-1,3,-2);scene.add(chairLight);
 const ground=new THREE.Mesh(new THREE.PlaneGeometry(80,80),new THREE.MeshStandardMaterial({color:'#060e0d',roughness:.42,metalness:.25}));ground.rotation.x=-Math.PI/2;ground.position.y=-.09;ground.receiveShadow=true;scene.add(ground);
 const gltf=await new GLTFLoader().loadAsync('/assets/before-waking-stage.glb');const world=gltf.scene;scene.add(world);
 const get=n=>world.getObjectByName(n);const room=get('RoomSet'),grandpa=get('Grandpa'),small=get('SmallBear'),big=get('BigBear'),plinth=get('ExchangePlinth'),head=get('GrandpaHead');
 const smallStart=small.position.clone(),bigStart=big.position.clone();let lookMode='audience',angle=0,zoom=0,drag=false,prevX=0;
 const roomMaterials=[];const matSeen=new Set();world.traverse(o=>{if(o.isMesh){o.castShadow=true;o.receiveShadow=true;if(o.material){o.material=o.material.clone();if(o.material.name.includes('石板')){o.material.roughness=.38;o.material.metalness=.06;
 o.material.onBeforeCompile=shader=>{shader.fragmentShader=shader.fragmentShader.replace('#include <color_fragment>',`#include <color_fragment>
 float vein=sin(vViewPosition.x*15.0+sin(vViewPosition.y*12.0+vViewPosition.z*5.0)*2.5);diffuseColor.rgb*=.75+.20*vein;`);};
 } }} });
 room.traverse(o=>{if(o.isMesh&&!matSeen.has(o.material)){matSeen.add(o.material);roomMaterials.push(o.material);o.material.transparent=true;}});
 // A procedural window-world: cloud field stays editable in the renderer, not baked into a film.
 const skyMat=new THREE.ShaderMaterial({uniforms:{t:{value:0},amount:{value:0},wind:{value:0}},side:THREE.DoubleSide,transparent:true,depthWrite:false,vertexShader:'varying vec2 v; void main(){v=uv;gl_Position=projectionMatrix*modelViewMatrix*vec4(position,1.);}',fragmentShader:`varying vec2 v;uniform float t;uniform float amount;uniform float wind;
 float hash(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}float noise(vec2 p){vec2 i=floor(p),f=fract(p);f=f*f*(3.-2.*f);return mix(mix(hash(i),hash(i+vec2(1,0)),f.x),mix(hash(i+vec2(0,1)),hash(i+1.),f.x),f.y);}float fbm(vec2 p){float a=.5,s=0.;for(int i=0;i<4;i++){s+=a*noise(p);p=p*2.05;a*=.5;}return s;}
 void main(){vec2 uv=v;vec3 c=mix(vec3(.7,.52,.29),vec3(.20,.38,.40),smoothstep(0.,1.,uv.y));float cloud=fbm(uv*5.+vec2(t*.016+wind*.1,0));c=mix(c,vec3(.95,.83,.64),smoothstep(.42,.72,cloud)*.8);float sun=exp(-length((uv-vec2(.27,.67))*vec2(1.,1.3))*14.);c+=vec3(1.,.65,.3)*sun*1.3;gl_FragColor=vec4(c,amount);}`});
 const sky=new THREE.Mesh(new THREE.PlaneGeometry(4.95,3.75),skyMat);sky.position.set(0,2.52,-4.25);room.add(sky);
 const horizon=new THREE.Group();room.add(horizon);
 // Partial plaster walls make a room, while its unfinished edges still dissolve into black.
 const plaster=new THREE.MeshStandardMaterial({color:'#a7a184',roughness:.95,side:THREE.DoubleSide,transparent:true});roomMaterials.push(plaster);
 for(const [x,y,w,h] of [[-3.1,2.3,1.2,4.6],[3.1,2.3,1.2,4.6],[0,.29,5.1,.55],[0,4.6,5.1,.3]]){const wall=new THREE.Mesh(new THREE.PlaneGeometry(w,h),plaster);wall.position.set(x,y,-4.32);wall.receiveShadow=true;room.add(wall);}
 const rainbow=new THREE.Group();room.add(rainbow);['#f39f80','#ecc17f','#aaca8b','#7fc7bc','#9cabe0'].forEach((c,i)=>{const pts=[];for(let j=0;j<50;j++){const a=Math.PI*.12+j/49*Math.PI*.76;pts.push(new THREE.Vector3(Math.cos(a)*(1.9+i*.045),Math.sin(a)*(1.9+i*.045)+.3,-4.12));}const curve=new THREE.CatmullRomCurve3(pts);rainbow.add(new THREE.Mesh(new THREE.TubeGeometry(curve,50,.014,5,false),new THREE.MeshBasicMaterial({color:c,transparent:true,opacity:.65,blending:THREE.AdditiveBlending,depthWrite:false})));});
 const rayMat=new THREE.MeshBasicMaterial({color:'#ffc879',transparent:true,opacity:.035,side:THREE.DoubleSide,depthWrite:false,blending:THREE.AdditiveBlending});const rays=new THREE.Group();scene.add(rays);
 for(let i=0;i<5;i++){const g=new THREE.BufferGeometry();const x=-2.1+i*.85;g.setAttribute('position',new THREE.Float32BufferAttribute([x,3.5,-4,x+.23,3.5,-4,x+3.5,.01,3.5,x+2.4,.01,3.5],3));g.setIndex([0,1,2,0,2,3]);rays.add(new THREE.Mesh(g,rayMat));}
 const rainCount=1500,rainPos=new Float32Array(rainCount*6),rainSeed=[];for(let i=0;i<rainCount;i++)rainSeed.push({x:(Math.random()-.5)*4.7,z:-4.20-Math.random()*.035,y:Math.random()*3.6,s:.7+Math.random()});
 const rainGeo=new THREE.BufferGeometry();rainGeo.setAttribute('position',new THREE.BufferAttribute(rainPos,3));const rain=new THREE.LineSegments(rainGeo,new THREE.LineBasicMaterial({color:'#f9d7a0',transparent:true,opacity:.48,blending:THREE.AdditiveBlending,depthWrite:false}));room.add(rain);rain.renderOrder=1;rainbow.children.forEach(o=>o.renderOrder=2);
 const dustArr=new Float32Array(240*3);for(let i=0;i<dustArr.length;i+=3){dustArr[i]=(Math.random()-.5)*10;dustArr[i+1]=Math.random()*5;dustArr[i+2]=(Math.random()-.5)*10;}
 const dustGeo=new THREE.BufferGeometry();dustGeo.setAttribute('position',new THREE.BufferAttribute(dustArr,3));const dust=new THREE.Points(dustGeo,new THREE.PointsMaterial({color:'#ffe0a4',size:.027,transparent:true,opacity:.4,depthWrite:false,blending:THREE.AdditiveBlending}));scene.add(dust);
 const paths=[];const halos=[];people.forEach(p=>{const ring=new THREE.Mesh(new THREE.RingGeometry(.3,.315,64),new THREE.MeshBasicMaterial({color:p.color,transparent:true,opacity:.28,side:THREE.DoubleSide}));ring.rotation.x=-Math.PI/2;ring.position.set(p.x,.018,p.z);scene.add(ring);halos.push(ring);});
 const layout=new THREE.Group();scene.add(layout);const grid=new THREE.GridHelper(16,16,'#60867e','#1a3831');grid.position.y=.025;layout.add(grid);
 function label(text,pos){const c=document.createElement('canvas');c.width=512;c.height=80;const ctx=c.getContext('2d');ctx.fillStyle='#dcdfd3';ctx.font='28px sans-serif';ctx.textAlign='center';ctx.fillText(text,256,45);const s=new THREE.Sprite(new THREE.SpriteMaterial({map:new THREE.CanvasTexture(c),transparent:true,depthTest:false}));s.position.copy(pos);s.scale.set(3.2,.5,1);layout.add(s);}
 label('真人姥爷 + 实体椅子',new THREE.Vector3(-.6,2.8,-1.9));label('数字窗景 / 投影面',new THREE.Vector3(0,5,-4.1));label('交换区 · 显露模拟',new THREE.Vector3(-3.1,2,.15));people.forEach(p=>label(p.name+' · 输入区',new THREE.Vector3(p.x,.5,p.z)));
 let t=0,last=performance.now(),energy=0,wind=0,song=0,flash=0,callbackUntil=0,callbackWho=null,phaseAge=0,lastChapter=-1,assetsReady=true;
 function trace(e,callback=false){const p=people.find(p=>p.id===e.who);if(!p)return;const n=50,verts=[];const start=new THREE.Vector3(p.x,.028,p.z),end=new THREE.Vector3(-.6,.028,-1.9);for(let i=0;i<n;i++){const a=i/(n-1),v=start.clone().lerp(end,a);v.x+=Math.sin(i*2.4+paths.length)*.16*Math.sin(a*Math.PI);v.z+=Math.sin(i*1.6)*.11;verts.push(v);}const geo=new THREE.BufferGeometry().setFromPoints(verts);geo.setDrawRange(0,2);const line=new THREE.Line(geo,new THREE.LineBasicMaterial({color:callback?p.color:'#ffd88d',transparent:true,opacity:1,blending:THREE.AdditiveBlending}));scene.add(line);paths.push({line,born:t,who:e.who,callback});if(paths.length>80){const old=paths.shift();scene.remove(old.line);old.line.geometry.dispose();old.line.material.dispose();}}
 function gesture(e){energy=Math.min(2,energy+(e.kind==='stomp'?.4:.15));if(e.kind==='sway')wind+=1;if(e.kind==='sing')song=1;if(e.kind==='call')flash=1;if(e.kind!=='call'||state().chapter>0)trace(e);}
 function callback(p){callbackUntil=t+9;callbackWho=p.who;trace({who:p.who},true);}
 function reset(){paths.forEach(p=>{scene.remove(p.line);p.line.geometry.dispose();p.line.material.dispose();});paths.length=0;energy=wind=song=flash=0;callbackUntil=0;lastChapter=-1;big.position.copy(bigStart);small.position.copy(smallStart);room.position.set(0,0,0);room.rotation.y=0;}
 function resize(){const w=container.clientWidth,h=container.clientHeight;renderer.setSize(w,h);composer.setSize(w,h);camera.aspect=w/h;camera.updateProjectionMatrix();}new ResizeObserver(resize).observe(container);resize();
 container.addEventListener('pointerdown',e=>{if(e.button!==0)return;drag=true;prevX=e.clientX;container.setPointerCapture(e.pointerId);});container.addEventListener('pointermove',e=>{if(drag){angle+=(e.clientX-prevX)*.003;prevX=e.clientX;}});container.addEventListener('pointerup',()=>drag=false);container.addEventListener('wheel',e=>{zoom=THREE.MathUtils.clamp(zoom+e.deltaY*.004,-3,5);e.preventDefault();},{passive:false});
 function render(now){requestAnimationFrame(render);const s=state(),dt=s.paused?0:Math.min((now-last)/1000,.05);last=now;if(!s.paused){t+=dt;phaseAge+=dt;energy*=Math.exp(-dt*.1);wind*=Math.exp(-dt*.3);song*=Math.exp(-dt*.025);flash*=Math.exp(-dt*3);}
 if(lastChapter!==s.chapter){lastChapter=s.chapter;phaseAge=0;}const warm=s.chapter>=2?Math.min(1,phaseAge*.45):0;const show=s.chapter>=2;room.visible=show;roomMaterials.forEach(m=>m.opacity=warm);skyMat.uniforms.amount.value=warm;skyMat.uniforms.t.value=t;skyMat.uniforms.wind.value=wind;horizon.visible=show;rays.visible=show;rayMat.opacity=.035*warm;dust.material.opacity=show?.36:.06;sun.intensity=show?(100+flash*160)*warm:0;hemi.intensity=show?.52:.12;fill.intensity=show?1.3:.38;chairLight.intensity=show?4:9;
 room.rotation.y=THREE.MathUtils.damp(room.rotation.y,s.chapter===3?Math.sin(s.approaches*.7)*.45:0,2,dt);room.position.z=THREE.MathUtils.damp(room.position.z,s.chapter===3?-Math.min(s.approaches,5)*.32:0,2,dt);
 grandpa.rotation.y=THREE.MathUtils.damp(grandpa.rotation.y,show?(s.chapter>=4?-.95:-.68):0,1.5,dt);head.rotation.y=show&&s.chapter<4?Math.sin(t*.23)*.12+.10:0;
 big.visible=s.chapter>=4;plinth.visible=s.chapter>=4;if(!s.exchanged)big.position.y=bigStart.y+(s.chapter>=4?Math.min(phaseAge,2)*.02:0);if(s.exchanged)big.position.lerp(new THREE.Vector3(-2.5,.08,2.3),1-Math.exp(-dt*1.5));
 small.visible=show;const care=s.exchanged||s.chapter===5;const target=care?new THREE.Vector3(0,.98,-.36).applyAxisAngle(new THREE.Vector3(0,1,0),grandpa.rotation.y).add(grandpa.position):smallStart;small.position.lerp(target,1-Math.exp(-dt*2));const act=s.accepted?.action||'rock';const active=care&&(callbackUntil>t||s.chapter===5);small.rotation.z=active?Math.sin(t*(act==='pat'?2.7:1.1))*.09:0;
 const armL=get('GrandpaArmL'),armR=get('GrandpaArmR');armL.rotation.x=THREE.MathUtils.damp(armL.rotation.x,care?-.46:0,2,dt);armR.rotation.x=THREE.MathUtils.damp(armR.rotation.x,care?-.46:0,2,dt);if(active&&act==='cheek')armR.rotation.z=Math.sin(t)*.08+.12;else armR.rotation.z=0;
 const garment=get('BearGarment');if(garment)garment.visible=s.chapter===5&&phaseAge>5;
 for(let i=0;i<rainCount;i++){const r=rainSeed[i],y=(r.y-t*r.s*2.3)%3.6;const yy=(y<0?y+3.6:y)+.7;const j=i*6;rainPos[j]=r.x+Math.sin(t*.2)*wind*.07;rainPos[j+1]=yy;rainPos[j+2]=r.z;rainPos[j+3]=rainPos[j]-.025-wind*.015;rainPos[j+4]=yy+.11;rainPos[j+5]=r.z;}rainGeo.attributes.position.needsUpdate=true;rainGeo.setDrawRange(0,Math.floor((.35+Math.min(energy,1)*.65)*rainCount)*2);rain.material.opacity=s.chapter===5?.16:.45;
 paths.forEach(p=>{const age=t-p.born;p.line.geometry.setDrawRange(0,Math.min(50,Math.floor(age*45)+2));p.line.material.opacity=Math.max(.1,1-age*.028);});halos.forEach((h,i)=>{const is=people[i].id===s.selected||people[i].id===callbackWho&&callbackUntil>t;h.material.opacity=is?.75:.25;h.scale.setScalar(is?1+Math.sin(t*2)*.08:1);});
 rainbow.visible=show&&song>.02;rainbow.children.forEach(o=>o.material.opacity=song*.55);
 if(lookMode==='layout'){layout.visible=true;scene.fog.density=.008;camera.position.lerp(new THREE.Vector3(.01,15,4),.07);camera.lookAt(0,0,0);}else{layout.visible=false;scene.fog.density=.023;const radius=lookMode==='close'?11+zoom:13+zoom;const a=(lookMode==='close'?.20:.47)+angle;camera.position.lerp(new THREE.Vector3(Math.sin(a)*radius,lookMode==='close'?1.8:4.2,Math.cos(a)*radius-1),.055);camera.lookAt(-.25,1.5,-1.5);}
 bloom.strength=.56+flash*.25;composer.render();
 }
 requestAnimationFrame(render);
 return{gesture,callback,reset,setView:v=>lookMode=v,renderer,assetsReady};
}

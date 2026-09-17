shader_type spatial;
render_mode unshaded, cull_disabled, fog_disabled;
uniform float weather = 0.0;
uniform float song = 0.0;
float hash(vec2 p){vec3 q=fract(vec3(p.xyx)*.1031);q+=dot(q,q.yzx+33.33);return fract((q.x+q.y)*q.z);}
float noise(vec2 p){vec2 i=floor(p),f=fract(p);f=f*f*(3.0-2.0*f);return mix(mix(hash(i),hash(i+vec2(1,0)),f.x),mix(hash(i+vec2(0,1)),hash(i+1.0),f.x),f.y);}
void fragment(){
 vec2 p=UV;float cloud=noise(p*6.0+vec2(TIME*.016,0.0))*.65+noise(p*13.0+vec2(TIME*.012,0.0))*.35;
 vec3 color=mix(vec3(.78,.62,.38),vec3(.30,.48,.49),p.y);
 color=mix(color,vec3(.96,.84,.62),smoothstep(.38,.78,cloud)*.7);
 float sun=exp(-length((p-vec2(.31,.55))*vec2(1.0,1.4))*18.0);
 color+=vec3(.9,.66,.32)*sun;
 float radius=length((p-vec2(.56,1.07))*vec2(1.2,1.0));
 float band=exp(-pow((radius-.62)*65.0,2.0))*song*.23;
 color+=vec3(.7,.32,.15)*band;
 ALBEDO=color*weather;EMISSION=color*weather*.15;
}

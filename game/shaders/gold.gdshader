shader_type spatial;
render_mode unshaded, cull_disabled, shadows_disabled;
uniform float reveal = 0.0;
uniform float fade = 1.0;
void fragment(){
 ALBEDO=vec3(1.0,.66,.26);
 EMISSION=vec3(.2,.09,.02);
 ALPHA=(1.0-smoothstep(reveal-.025,reveal,UV.x))*fade*(.88+.12*sin(TIME*1.4-UV.x*7.0));
}

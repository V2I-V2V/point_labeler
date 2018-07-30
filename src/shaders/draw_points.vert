#version 330 core

layout (location = 0) in vec4  in_vertex;
layout (location = 1) in uint  in_label;
layout (location = 2) in uint  in_visible;

uniform sampler2DRect label_colors;
uniform sampler2D     heightMap;

#include "shaders/color.glsl"

// materials.
uniform mat4 mvp;

uniform bool useRemission;
uniform bool useColor;



uniform bool removeGround;
uniform float groundThreshold;

uniform bool planeRemoval;
uniform int planeDimension;
uniform float planeThreshold;
uniform float planeDirection;

uniform bool planeRemovalNormal;
uniform float planeA1;
uniform float planeA2;
uniform float planeA3;
uniform float planeThresholdNormal;
uniform float planeDirectionNormal;


uniform vec2 tilePos;
uniform float tileSize;

out vec4 color;

void main()
{
  vec4 in_color = texture(label_colors, vec2(in_label, 0));
  float in_remission = in_vertex.w;
  
  float range = length(in_vertex.xyz);
  gl_Position = mvp * vec4(in_vertex.xyz, 1.0);

  vec2 v = in_vertex.xy - tilePos;
  
    
  bool visible = (in_visible > uint(0)) && (!removeGround || in_vertex.z > texture(heightMap, v / tileSize + 0.5).r + groundThreshold); 
  
  if(planeRemoval) visible = visible && (planeDirection * (in_vertex[planeDimension] - planeThreshold)  < 0);

  if(planeRemovalNormal){
    float scalar_product = in_vertex[0] * planeA1 + in_vertex[1] * planeA2 + in_vertex[2] * planeA3;
  
    visible = visible && (planeDirectionNormal * (scalar_product - planeThresholdNormal) < 0);
  }

  
  // if(!visible || range < minRange || range > maxRange) gl_Position = vec4(-10, -10, -10, 1);
  if(!visible) gl_Position = vec4(-10, -10, -10, 1);
  
  
  if(useRemission)
  { 
    in_remission = clamp(in_remission, 0.0, 1.0);
    float r = in_remission * 0.25 + 0.75; // ensure r in [0.75, 1.0]
    if(in_label == uint(0)) r = in_remission * 0.7 + 0.3; // r in [0.3, 1.0]
    vec3 hsv = rgb2hsv(in_color.rgb);
    hsv.b = max(hsv.b, 0.8);
    
    color = vec4(hsv2rgb(vec3(1, 1, r) * hsv), 1.0);
  }
  else 
  {
    color = vec4(in_color.rgb, 1.0);
  }
}

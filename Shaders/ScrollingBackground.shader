Shader"Custom/ScrollingBackground" {
    Properties {
        _MainTex ("Main Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _ScrollSpeedX ("Scroll Speed X", Range(-5, 5)) = 1
        _ScrollSpeedY ("Scroll Speed Y", Range(-5, 5)) = 0
        _Tiling ("Tiling", Vector) = (1, 1, 0, 0)
        [Toggle]_MirrorRepeat ("Mirror Repeat", Float) = 0
    }
    
    SubShader {
        Tags { 
            "RenderType"="Opaque"
            "Queue"="Geometry"
        }
        
        Pass {
            Tags { "LightMode"="ForwardBase" }
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
#include "UnityCG.cginc"
            
struct appdata
{
    float4 vertex : POSITION;
    float2 uv : TEXCOORD0;
};
            
struct v2f
{
    float4 pos : SV_POSITION;
    float2 uv : TEXCOORD0;
};
            
sampler2D _MainTex;
float4 _MainTex_ST;
fixed4 _Color;
float _ScrollSpeedX;
float _ScrollSpeedY;
float4 _Tiling;
float _MirrorRepeat;
            
v2f vert(appdata v)
{
    v2f o;
    o.pos = UnityObjectToClipPos(v.vertex);
    o.uv = v.uv;
    return o;
}
            
fixed4 frag(v2f i) : SV_Target
{
                // 应用平铺
    float2 uv = i.uv * _Tiling.xy;
                
                // 计算滚动偏移
    float2 scrollOffset;
    scrollOffset.x = _Time.y * _ScrollSpeedX;
    scrollOffset.y = _Time.y * _ScrollSpeedY;
                
                // 应用滚动
    uv += scrollOffset;
                
                // 镜像重复
    if (_MirrorRepeat > 0.5)
    {
        uv = abs(frac(uv) * 2.0 - 1.0);
    }
    else
    {
        uv = frac(uv); // 普通重复
    }
                
                // 采样纹理
    fixed4 col = tex2D(_MainTex, uv) * _Color;
                
    return col;
}
            ENDCG
        }
    }
Fallback"Diffuse"
}
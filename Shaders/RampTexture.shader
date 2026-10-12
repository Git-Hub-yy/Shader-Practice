Shader"Custom/RampTexture" {
    Properties {
        _Color ("Color Tint", Color) = (1,1,1,1)
        _RampTex ("Ramp Texture", 2D) = "white" {}
        _Specular ("Specular", Color) = (1,1,1,1)
        _Gloss ("Gloss", Range(8.0, 256)) = 20
    }
    
    SubShader {
        Tags { "RenderType"="Opaque" }
LOD 100
        
        Pass {
            Tags { "LightMode"="ForwardBase" }
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
#include "UnityCG.cginc"
#include "Lighting.cginc"
            
struct a2v
{
    float4 vertex : POSITION;
    float3 normal : NORMAL;
    float4 texcoord : TEXCOORD0;
};
            
struct v2f
{
    float4 pos : SV_POSITION;
    float3 worldNormal : TEXCOORD0;
    float3 worldPos : TEXCOORD1;
    float2 uv : TEXCOORD2;
};
            
fixed4 _Color;
sampler2D _RampTex;
float4 _RampTex_ST;
fixed4 _Specular;
float _Gloss;
            
v2f vert(a2v v)
{
    v2f o;
    o.pos = UnityObjectToClipPos(v.vertex);
    o.worldNormal = UnityObjectToWorldNormal(v.normal);
    o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
    o.uv = TRANSFORM_TEX(v.texcoord, _RampTex);
    return o;
}
            
fixed4 frag(v2f i) : SV_Target
{
    fixed3 worldNormal = normalize(i.worldNormal);
    fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                
                // 使用兰伯特值作为渐变纹理的UV坐标
    fixed lambert = dot(worldNormal, worldLightDir) * 0.5 + 0.5;
    fixed2 rampUV = fixed2(lambert, lambert);
                
                // 从渐变纹理采样
    fixed3 rampColor = tex2D(_RampTex, rampUV).rgb * _Color.rgb;
                
                // 环境光
    fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * rampColor;
                
                // 漫反射 (使用渐变纹理颜色)
    fixed3 diffuse = _LightColor0.rgb * rampColor;
                
                // 高光反射
    fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
    fixed3 halfDir = normalize(worldLightDir + viewDir);
    fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);
                
    return fixed4(ambient + diffuse + specular, 1.0);
}
            ENDCG
        }
    }
Fallback"Specular"
}
Shader"Custom/NormalTexture" {
    Properties {
        _Color ("Color Tint", Color) = (1,1,1,1)
        _MainTex ("Main Tex", 2D) = "white" {}
        _NormalMap ("Normal Map", 2D) = "bump" {}
        _BumpScale ("Bump Scale", Float) = 1.0
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
    float4 tangent : TANGENT;
    float4 texcoord : TEXCOORD0;
};
            
struct v2f
{
    float4 pos : SV_POSITION;
    float4 uv : TEXCOORD0;
    float3 tangentLightDir : TEXCOORD1;
    float3 tangentViewDir : TEXCOORD2;
};
            
fixed4 _Color;
sampler2D _MainTex;
float4 _MainTex_ST;
sampler2D _NormalMap;
float4 _NormalMap_ST;
float _BumpScale;
fixed4 _Specular;
float _Gloss;
            
v2f vert(a2v v)
{
    v2f o;
    o.pos = UnityObjectToClipPos(v.vertex);
                
    o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
    o.uv.zw = TRANSFORM_TEX(v.texcoord, _NormalMap);
                
                // 构建从对象空间到切线空间的矩阵
    TANGENT_SPACE_ROTATION;
                
                // 变换光线和视线方向到切线空间
                o.
    tangentLightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
    o.tangentViewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;
                
    return o;
}
            
fixed4 frag(v2f i) : SV_Target
{
    fixed3 tangentLightDir = normalize(i.tangentLightDir);
    fixed3 tangentViewDir = normalize(i.tangentViewDir);
                
                // 从法线贴图获取法线
    fixed4 packedNormal = tex2D(_NormalMap, i.uv.zw);
    fixed3 tangentNormal = UnpackNormal(packedNormal);
    tangentNormal.xy *= _BumpScale;
    tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));
                
                // 采样漫反射纹理
    fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb;
                
                // 环境光
    fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                
                // 漫反射
    fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(tangentNormal, tangentLightDir));
                
                // 高光反射 (Blinn-Phong)
    fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);
    fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(tangentNormal, halfDir)), _Gloss);
                
    return fixed4(ambient + diffuse + specular, 1.0);
}
            ENDCG
        }
    }
Fallback"Specular"
}
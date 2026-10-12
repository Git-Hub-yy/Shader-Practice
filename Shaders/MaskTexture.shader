Shader"Custom/MaskTexture" {
    Properties {
        _Color ("Color Tint", Color) = (1,1,1,1)
        _MainTex ("Main Tex", 2D) = "white" {}
        _MaskTex ("Mask Tex", 2D) = "white" {}
        _Specular ("Specular", Color) = (1,1,1,1)
        _Gloss ("Gloss", Range(8.0, 256)) = 20
        _MaskScale ("Mask Scale", Range(0.0, 1.0)) = 1.0
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
sampler2D _MainTex;
float4 _MainTex_ST;
sampler2D _MaskTex;
float4 _MaskTex_ST;
fixed4 _Specular;
float _Gloss;
fixed _MaskScale;
            
v2f vert(a2v v)
{
    v2f o;
    o.pos = UnityObjectToClipPos(v.vertex);
    o.worldNormal = UnityObjectToWorldNormal(v.normal);
    o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
    o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
    return o;
}
            
fixed4 frag(v2f i) : SV_Target
{
    fixed3 worldNormal = normalize(i.worldNormal);
    fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                
                // 采样主纹理
    fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
                
                // 采样遮罩纹理
    fixed4 mask = tex2D(_MaskTex, i.uv);
                
                // 环境光
    fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                
                // 漫反射
    fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));
                
                // 高光反射 (使用遮罩控制强度)
    fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
    fixed3 halfDir = normalize(worldLightDir + viewDir);
    fixed specularMask = mask.r * _MaskScale;
    fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss) * specularMask;
                
    return fixed4(ambient + diffuse + specular, 1.0);
}
            ENDCG
        }
    }
Fallback"Specular"
}
Shader"Custom/BlinnPhong"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _DiffuseColor ("Diffuse Color", Color) = (1,1,1,1)
        _SpecularColor ("Specular Color", Color) = (1,1,1,1)
        _Gloss ("Gloss", Range(1, 256)) = 20
    }
    
    SubShader
    {
        Tags { "RenderType"="Opaque" }
LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
#include "UnityCG.cginc"
#include "Lighting.cginc"

struct appdata
{
    float4 vertex : POSITION;
    float3 normal : NORMAL;
    float2 uv : TEXCOORD0;
};

struct v2f
{
    float2 uv : TEXCOORD0;
    float4 vertex : SV_POSITION;
    float3 worldNormal : TEXCOORD1;
    float3 worldPos : TEXCOORD2;
};

sampler2D _MainTex;
float4 _MainTex_ST;
fixed4 _DiffuseColor;
fixed4 _SpecularColor;
float _Gloss;

v2f vert(appdata v)
{
    v2f o;
    o.vertex = UnityObjectToClipPos(v.vertex);
    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
    o.worldNormal = normalize(mul(v.normal, (float3x3) unity_WorldToObject));
    o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
    return o;
}

fixed4 frag(v2f i) : SV_Target
{
                // 光照向量计算
    float3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
    float3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                
                // 漫反射计算
    float ndotl = max(0, dot(i.worldNormal, worldLightDir));
    fixed3 diffuse = _LightColor0.rgb * _DiffuseColor.rgb * ndotl;
                
                // Blinn-Phong高光计算
    float3 halfDir = normalize(worldLightDir + worldViewDir);
    float ndoth = max(0, dot(i.worldNormal, halfDir));
    fixed3 specular = _LightColor0.rgb * _SpecularColor.rgb * pow(ndoth, _Gloss);
                
    fixed4 col = tex2D(_MainTex, i.uv);
    col.rgb *= diffuse + specular + UNITY_LIGHTMODEL_AMBIENT.rgb;
    return col;
}
            ENDCG
        }
    }
}
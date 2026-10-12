Shader"Custom/PerPixelDiffuse"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _DiffuseColor ("Diffuse Color", Color) = (1,1,1,1)
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
};

sampler2D _MainTex;
float4 _MainTex_ST;
fixed4 _DiffuseColor;

v2f vert(appdata v)
{
    v2f o;
    o.vertex = UnityObjectToClipPos(v.vertex);
    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
    o.worldNormal = normalize(mul(v.normal, (float3x3) unity_WorldToObject));
    return o;
}

fixed4 frag(v2f i) : SV_Target
{
                // 逐像素漫反射计算
    float3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
    float ndotl = max(0, dot(i.worldNormal, worldLightDir));
    fixed3 diffuse = _LightColor0.rgb * _DiffuseColor.rgb * ndotl;
                
    fixed4 col = tex2D(_MainTex, i.uv);
                // 环境光 + 漫反射
    col.rgb *= diffuse + UNITY_LIGHTMODEL_AMBIENT.rgb;
    return col;
}
            ENDCG
        }
    }
}
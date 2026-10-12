Shader"Custom/PerPixelPhong"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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
    float3 worldView : TEXCOORD2;
    float3 worldLight : TEXCOORD3;
};

sampler2D _MainTex;
float4 _MainTex_ST;
fixed4 _SpecularColor;
float _Gloss;

v2f vert(appdata v)
{
    v2f o;
    o.vertex = UnityObjectToClipPos(v.vertex);
    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
    o.worldNormal = normalize(mul(v.normal, (float3x3) unity_WorldToObject));
    o.worldView = normalize(WorldSpaceViewDir(v.vertex));
    o.worldLight = normalize(_WorldSpaceLightPos0.xyz);
    return o;
}

fixed4 frag(v2f i) : SV_Target
{
                // 逐像素Phong高光计算
    float3 reflectDir = reflect(-i.worldLight, i.worldNormal);
    float rdotv = max(0, dot(reflectDir, i.worldView));
    fixed3 specular = _LightColor0.rgb * _SpecularColor.rgb * pow(rdotv, _Gloss);
                
                // 漫反射
    float ndotl = max(0, dot(i.worldNormal, i.worldLight));
    fixed3 diffuse = _LightColor0.rgb * ndotl;
                
    fixed4 col = tex2D(_MainTex, i.uv);
    col.rgb *= diffuse + specular + UNITY_LIGHTMODEL_AMBIENT.rgb;
    return col;
}
            ENDCG
        }
    }
}
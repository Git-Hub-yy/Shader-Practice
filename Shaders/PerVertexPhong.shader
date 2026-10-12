Shader"Custom/PerVertexPhong"
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
    fixed3 color : COLOR;
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
                
                // 世界空间向量计算
    float3 worldNormal = normalize(mul(v.normal, (float3x3) unity_WorldToObject));
    float3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
    float3 worldViewDir = normalize(WorldSpaceViewDir(v.vertex));
                
                // 漫反射
    float ndotl = max(0, dot(worldNormal, worldLightDir));
    fixed3 diffuse = _LightColor0.rgb * ndotl;
                
                // Phong高光计算
    float3 reflectDir = reflect(-worldLightDir, worldNormal);
    float rdotv = max(0, dot(reflectDir, worldViewDir));
    fixed3 specular = _LightColor0.rgb * _SpecularColor.rgb * pow(rdotv, _Gloss);
                
    o.color = diffuse + specular + UNITY_LIGHTMODEL_AMBIENT.rgb;
                
    return o;
}

fixed4 frag(v2f i) : SV_Target
{
    fixed4 col = tex2D(_MainTex, i.uv);
    col.rgb *= i.color;
    return col;
}
            ENDCG
        }
    }
}
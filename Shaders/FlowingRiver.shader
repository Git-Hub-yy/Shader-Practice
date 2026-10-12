Shader"Custom/FlowingRiver" {
    Properties {
        _MainTex ("Main Texture", 2D) = "white" {}
        _NormalMap ("Normal Map", 2D) = "bump" {}
        _Color ("Water Color", Color) = (0.2, 0.6, 1, 0.8)
        _Speed ("Flow Speed", Range(0, 2)) = 0.5
        _WaveScale ("Wave Scale", Range(0, 0.1)) = 0.02
        _WaveSpeed ("Wave Speed", Range(0, 2)) = 1
        _DepthColor ("Depth Color", Color) = (0.1, 0.3, 0.5, 1)
        _FresnelPower ("Fresnel Power", Range(0, 10)) = 3
        _Glossiness ("Glossiness", Range(0, 1)) = 0.5
    }
    
    SubShader {
        Tags { 
            "RenderType"="Transparent"
            "Queue"="Transparent"
        }
        
        Pass {
            Tags { "LightMode"="ForwardBase" }
            
Blend SrcAlpha
OneMinusSrcAlpha
            ZWrite
Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
#include "UnityCG.cginc"
#include "Lighting.cginc"
            
struct appdata
{
    float4 vertex : POSITION;
    float3 normal : NORMAL;
    float4 tangent : TANGENT;
    float2 uv : TEXCOORD0;
};
            
struct v2f
{
    float4 pos : SV_POSITION;
    float2 uv : TEXCOORD0;
    float3 worldPos : TEXCOORD1;
    float3 worldNormal : TEXCOORD2;
    float3 worldTangent : TEXCOORD3;
    float3 worldBinormal : TEXCOORD4;
};
            
sampler2D _MainTex;
float4 _MainTex_ST;
sampler2D _NormalMap;
float4 _NormalMap_ST;
fixed4 _Color;
fixed4 _DepthColor;
float _Speed;
float _WaveScale;
float _WaveSpeed;
float _FresnelPower;
float _Glossiness;
            
            // 噪声函数，用于生成水波
float noise(float2 p)
{
    return sin(p.x * 10.0 + _Time.y * _WaveSpeed) *
                       sin(p.y * 12.0 + _Time.y * _WaveSpeed) * 0.5 + 0.5;
}
            
v2f vert(appdata v)
{
    v2f o;
                
                // 顶点动画：正弦波
    float wave = sin(v.vertex.x * 10.0 + _Time.y * _WaveSpeed) *
                             sin(v.vertex.z * 12.0 + _Time.y * _WaveSpeed) * _WaveScale;
    v.vertex.y += wave;
                
    o.pos = UnityObjectToClipPos(v.vertex);
    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
    o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
    o.worldNormal = UnityObjectToWorldNormal(v.normal);
    o.worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
    o.worldBinormal = cross(o.worldNormal, o.worldTangent) * v.tangent.w;
                
    return o;
}
            
fixed4 frag(v2f i) : SV_Target
{
                // 创建流动UV
    float2 flowUV = i.uv;
    flowUV.x += _Time.y * _Speed * 0.1;
    flowUV.y += sin(_Time.y * _Speed * 0.5) * 0.02;
                
                // 添加噪声扰动
    float2 noiseUV = i.uv;
    noiseUV.x += noise(i.uv) * 0.1;
    noiseUV.y += noise(i.uv + 0.5) * 0.1;
                
                // 采样法线贴图
    float3 normal = UnpackNormal(tex2D(_NormalMap, flowUV));
                
                // 构建TBN矩阵
    float3x3 TBN = float3x3(
                    normalize(i.worldTangent),
                    normalize(i.worldBinormal),
                    normalize(i.worldNormal)
                );
    float3 worldNormal = mul(TBN, normal);
                
                // 计算光照
    float3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
    float3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                
                // 菲涅尔效应
    float fresnel = pow(1.0 - max(0, dot(worldNormal, viewDir)), _FresnelPower);
                
                // 漫反射
    float diffuse = max(0, dot(worldNormal, lightDir));
                
                // 镜面反射
    float3 halfDir = normalize(lightDir + viewDir);
    float specular = pow(max(0, dot(worldNormal, halfDir)), 32.0 * _Glossiness);
                
                // 混合颜色
    fixed4 baseColor = tex2D(_MainTex, noiseUV);
    fixed4 waterColor = lerp(_DepthColor, _Color, diffuse + fresnel);
                
                // 最终颜色
    fixed4 finalColor = waterColor * baseColor;
    finalColor.rgb += specular * _LightColor0.rgb;
    finalColor.a = _Color.a;
                
    return finalColor;
}
            ENDCG
        }
    }
Fallback"Transparent/Diffuse"
}
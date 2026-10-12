Shader"Custom/Billboard" {

    Properties{
        _MainTex("Main Texure",2D) = "white"{}
        _Color("Color",Color) = (1,1,1,1)
        _VerticalBillboard("Vertical Billboard",Range(0,1)) = 1
        _Rotation("Rotation",Range(0,360)) = 0
        _Scale("Scale",Vector) = (1,1,1,0)
        [Toggle]_FixedSize("Fixed Screen Size",Float) = 0
}
SubShader {
    Tags { 
        "RenderType"= "Transparent"
        "Queue"="Transparent"
}
    Pass {
        Tags{"LightMode"="ForwardBase"}
        
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off
        Cull Off
        CGPROGRAM
        #pragma vertex vert
        #pragma fragment frag
        #include "UnityCG.cginc"

struct appdata
{
    float4 vertex : POSITION;
    float2 uv : TEXCOORD0;
    float4 color : COLOR;
};
struct v2f
{
    float4 pos : SV_POSITION;
    float2 uv : TEXCOORD0;
    fixed4 color : COLOR;
};
sampler2D _MainTex;
float4 _MainTex_ST;
fixed4 _Color;
float _VerticalBillboard;
float _Rotation;
float4 _Scale;
float _FixedSize;
v2f vert(appdata v)
{
    v2f o;
    float3 cameraPos = _WorldSpaceCameraPos;
    float3 objPos = mul(unity_ObjectToWorld, float4(0, 0, 0, 1)).xyz;
    float3 forward = cameraPos - objPos;
    if (_VerticalBillboard > 0.5)
    {
        forward.y = 0;
    }
    forward = normalize(forward);
    float3 up = float3(0, 1, 0);
    if (_VerticalBillboard > 0.5)
    {
        up = float3(0, 1, 0);
    }
    else
    {
        up = normalize(cross(forward, float3(0, 0, 1)));
    }
    float3 right = normalize(cross(up, forward));
    if (_Rotation != 0)
    {
        float rad = radians(_Rotation);
        float sinRot = sin(rad);
        float cosRot = cos(rad);
        float3 newRight = right * cosRot + up * sinRot;
        float3 newUp = up * cosRot - right * sinRot;
        right = newRight;
        up = newUp;
    }
    
    float3 vertexOffset = v.vertex.xyz;
    vertexOffset.x *= _Scale.x;
    vertexOffset.y *= _Scale.y;
    vertexOffset.z *= _Scale.z;
    
    float3 localVertex = vertexOffset.x * right + vertexOffset.y * up + vertexOffset.z * forward;
    
    float3 worldPos = objPos + localVertex;
    if (_FixedSize > 0.5)
    {
        float distance = length(cameraPos - worldPos);
        float scaleFactor = distance * 0.1;
        localVertex = vertexOffset.x * right * scaleFactor + vertexOffset.y * up * scaleFactor + vertexOffset.z * forward * scaleFactor;
        worldPos = objPos + localVertex;
        
    }
    o.pos = mul(UNITY_MATRIX_VP, float4(worldPos, 1.0));
    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
    o.color = v.color * _Color;
    
    return o;

}
fixed4 frag(v2f i) : SV_Target
{
    fixed4 col = tex2D(_MainTex, i.uv) * i.color;
    clip(col.a - 0.01);
    return col;
}
ENDCG
}
}
Fallback "Transparent/VertexLit"
}
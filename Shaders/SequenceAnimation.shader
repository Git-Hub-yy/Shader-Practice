Shader"Custom/SequenceAnimation" {
    Properties {
        _Color ("Color Tint", Color) = (1,1,1,1)
        _SequenceTex ("Sequence Texture", 2D) = "white" {}
        _HorizontalCount ("Horizontal Frame Count", Int) = 4
        _VerticalCount ("Vertical Frame Count", Int) = 4
        _Speed ("Play Speed", Range(0, 10)) = 1
        _FPS ("Frames Per Second", Float) = 30
        [Toggle]_Loop ("Loop", Float) = 1
        [Toggle]_PingPong ("PingPong", Float) = 0
        _StartFrame ("Start Frame", Int) = 0
        _EndFrame ("End Frame", Int) = 15
    }
    
    SubShader {
        Tags { 
            "RenderType"="Transparent"
            "Queue"="Transparent"
            "IgnoreProjector"="True"
        }
        
        Pass {
            Tags { "LightMode"="ForwardBase" }
            
Blend SrcAlpha
OneMinusSrcAlpha
            ZWrite
Off
            Cull
Off
            
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
    float4 color : COLOR;
};
            
sampler2D _SequenceTex;
float4 _SequenceTex_ST;
fixed4 _Color;
int _HorizontalCount;
int _VerticalCount;
float _Speed;
float _FPS;
float _Loop;
float _PingPong;
int _StartFrame;
int _EndFrame;
            
v2f vert(appdata v)
{
    v2f o;
    o.pos = UnityObjectToClipPos(v.vertex);
    o.uv = TRANSFORM_TEX(v.uv, _SequenceTex);
    o.color = v.color * _Color;
    return o;
}
            
fixed4 frag(v2f i) : SV_Target
{
                // 计算总帧数和有效帧数
    int totalFrames = _HorizontalCount * _VerticalCount;
    int effectiveFrames = min(totalFrames, _EndFrame + 1);
                
                // 计算当前时间
    float time = _Time.y * _Speed;
                
                // 计算当前帧索引
    int frameIndex = 0;
                
    if (_Loop > 0.5)
    {
                    // 循环播放模式
        if (_PingPong > 0.5)
        {
                        // 乒乓播放（往返播放）
            float pingPongTime = fmod(time, 2.0);
            if (pingPongTime < 1.0)
            {
                frameIndex = (int) (pingPongTime * effectiveFrames);
            }
            else
            {
                frameIndex = (int) ((2.0 - pingPongTime) * effectiveFrames);
            }
        }
        else
        {
                        // 普通循环播放
            frameIndex = (int) (fmod(time, effectiveFrames));
        }
    }
    else
    {
                    // 播放一次模式
        frameIndex = min((int) time, effectiveFrames - 1);
    }
                
                // 限制在起始帧和结束帧之间
    frameIndex = clamp(frameIndex, _StartFrame, _EndFrame);
                
                // 计算当前帧的行列位置
    int row = frameIndex / _HorizontalCount;
    int col = frameIndex % _HorizontalCount;
                
                // 计算每帧的UV大小（修正：确保浮点数计算）
    float frameWidth = 1.0 / max(1, _HorizontalCount);
    float frameHeight = 1.0 / max(1, _VerticalCount);
                
                // 计算当前帧的UV坐标（修正：简化计算）
    float2 frameUV;
                // X方向：列偏移 + UV在帧内的位置
    frameUV.x = (col * frameWidth) + (i.uv.x * frameWidth);
                // Y方向：行偏移（从下往上计算，Unity纹理原点在左下角）
    frameUV.y = 1.0 - ((row + 1) * frameHeight) + (i.uv.y * frameHeight);
                
                // 添加边界保护
    frameUV.x = clamp(frameUV.x, col * frameWidth + 0.001, (col + 1) * frameWidth - 0.001);
    frameUV.y = clamp(frameUV.y, 1.0 - (row + 1) * frameHeight + 0.001, 1.0 - row * frameHeight - 0.001);
                
                // 采样序列帧纹理
    fixed4 c = tex2D(_SequenceTex, frameUV) * i.color;
                
                // 透明度测试，丢弃完全透明的像素
    clip(c.a - 0.01);
                
    return c;
}
            ENDCG
        }
    }
Fallback"Transparent/VertexLit"
}
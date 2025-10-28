Shader "Custom/TouchHoldProgress"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)
        _Progress ("Progress", Range(0, 1)) = 0
        [Toggle] _Flip ("Flip Direction", Float) = 0
    }

    SubShader
    {
        Tags
        {
            "Queue" = "Transparent"
            "RenderType" = "Transparent"
            "CanUseSpriteAtlas" = "True"
            "PreviewType" = "Plane"
        }

        Cull Off
        Lighting Off
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 color : COLOR;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                fixed4 color : COLOR;
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            fixed4 _Color;
            float _Progress;
            float _Flip;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.color = v.color * _Color;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 texColor = tex2D(_MainTex, i.uv);
                
                // 计算像素相对于中心的极坐标角度
                float2 centeredUV = i.uv - float2(0.5, 0.5);
                float angle = atan2(centeredUV.y, centeredUV.x);
                
                // 将角度从[-π, π]转换到[0, 2π]
                if (angle < 0) angle += 6.28318530718; // 2π
                
                // 从正上方(12点方向)开始
                // 目标角度：0°=上，90°=左，180°=下，270°=右 (顺时针)
                float clockwiseAngle = fmod(6.28318530718 - angle + 1.57079633, 6.28318530718);
                
                // 将角度转换为[0, 1]范围
                float normalizedAngle = clockwiseAngle / 6.28318530718;
                
                // 根据进度和翻转设置决定是否显示像素
                bool shouldShow;
                if (_Flip > 0.5)
                {
                    // 反向填充：从满到空
                    shouldShow = normalizedAngle > _Progress;
                }
                else
                {
                    // 正向填充：从空到满  
                    shouldShow = normalizedAngle < _Progress;
                }
                
                // 应用进度遮罩
                fixed4 finalColor = texColor * i.color;
                finalColor.a *= shouldShow ? 1.0 : 0.0;
                
                return finalColor;
            }
            ENDCG
        }
    }
}
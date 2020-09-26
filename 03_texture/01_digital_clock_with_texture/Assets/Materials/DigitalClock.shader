Shader "Unlit/DigitalClock"
{
    Properties
    {
        _TexChars ("Characters", 2D) = "white" {}
        _CharacterCount_X ("CharacterCount_X", Float) = 8
        _CharacterCount_Y ("CharacterCount_Y", Float) = 2
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

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _TexChars;
            float4 _TexChars_ST;
            float _CharacterCount_X;
            float _CharacterCount_Y;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                // o.uv = TRANSFORM_TEX(v.uv, _TexChars);
                o.uv = v.uv;
                return o;
            }

            float2 getNumber(float2 uv, float number)
            {
                float divide = 2.0;
                float2 uvOrigin = uv;

                uv.x = fmod(uv.x * divide, divide);
                float firstNum = floor(number / 10);
                float secondNum = floor(frac(number / 10) * 10);
                float2 step = float2(1.0 / _CharacterCount_X, 1.0 / _CharacterCount_Y);

                // 1st number
                float x1 = uv.x / _CharacterCount_X + step.x * (fmod(firstNum, _CharacterCount_X) - 0);
                float y1 = uv.y / _CharacterCount_Y + step.y * (1.0 - fmod(floor(firstNum / _CharacterCount_X), _CharacterCount_Y));

                // 2nd number
                float x2 = uv.x / _CharacterCount_X + step.x * (fmod(secondNum, _CharacterCount_X) - 1);
                float y2 = uv.y / _CharacterCount_Y + step.y * (1.0 - fmod(floor(secondNum / _CharacterCount_X), _CharacterCount_Y));

                float digitStep = 1.0 / divide;
                float x = x2;
                float y = y2;

                if (uvOrigin.x < digitStep)
                {
                    // First number
                    x = x1;
                    y = y1;
                }

                return float2(x, y);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 t = getNumber(i.uv, _Time.y);
                float4 col = tex2D(_TexChars, t);
                return col;
            }
            ENDCG
        }
    }
}

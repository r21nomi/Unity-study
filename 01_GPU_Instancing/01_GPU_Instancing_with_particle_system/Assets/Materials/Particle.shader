Shader "Unlit/Particle"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "DisableBatching" = "True" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            #pragma instancing_options procedural:vertInstancingSetup

            #include "UnityCG.cginc"
            #include "UnityStandardParticleInstancing.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 color : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _CurveStrength;

            float3x3 XRotationMatrix(float degrees)
            {
                float radian = degrees * UNITY_PI / 180.0;
                float s = sin(radian);
                float c = cos(radian);
                return float3x3(
                    1, 0, 0,
                    0, c, s,
                    0, -s, c
                );
            }

            v2f vert (appdata v)
            {
                UNITY_SETUP_INSTANCE_ID(v);

                v2f o;
                float4 rotVert = v.vertex;
//                rotVert.z = (v.vertex.z * cos(_Time.y * 3.14f) - v.vertex.x * sin(_Time.y * 3.14f));
//                rotVert.x = (v.vertex.z * sin(_Time.y * 3.14f) + v.vertex.x * cos(_Time.y * 3.14f));
                rotVert.xyz = mul(XRotationMatrix(90), rotVert.xyz);
                o.vertex = UnityObjectToClipPos(rotVert);
//                float dist = UNITY_Z_0_FAR_FROM_CLIPSPACE(o.vertex.z);
//                o.vertex.y -= _CurveStrength * dist * dist * _ProjectionParams.x;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}

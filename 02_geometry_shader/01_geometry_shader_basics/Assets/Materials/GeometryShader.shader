Shader "Unlit/GeometryShader"
{
    Properties
    {
        _Color("Color", Color) = (1, 1, 1, 1)
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma target 4.0
            #pragma vertex vert
            #pragma geometry geom
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2g {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct g2f
            {
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
            };

            sampler2D _MainTex;
            float4 _Color;

            v2g vert (appdata v)
            {
                v2g o;
                o.vertex = v.vertex;
                o.normal = v.normal;
                return o;
            }

            g2f VertexOutput(float3 vertex, half3 normal)
            {
                g2f o;
                o.vertex = UnityObjectToClipPos(float4(vertex, 1));
                o.normal = UnityObjectToWorldNormal(normal);
                return o;
            }

            float3 GetNormal(float3 v1, float3 v2, float3 v3)
            {
                return normalize(cross(v2 - v1, v3 - v1));
            }

            // Max vertex count for output
            [maxvertexcount(3 * 1 + 4 * 3)]  // upper triangle(3 vertices * 1 surface) + side rectangles(4 vertices * 3 surfaces) = 15
            void geom(triangle v2g input[3], uint pid : SV_PrimitiveID, inout TriangleStream<g2f> outStream)
            {
                float3 v0 = input[0].vertex.xyz;
                float3 v1 = input[1].vertex.xyz;
                float3 v2 = input[2].vertex.xyz;

                float ext = saturate(cos(_Time.y * 2 + pid));

                float3 offs = GetNormal(v0, v1, v2) * ext;
                float3 v3 = v0 + offs;
                float3 v4 = v1 + offs;
                float3 v5 = v2 + offs;

                // Top triangle
                float3 n = GetNormal(v3, v4, v5);
                outStream.Append(VertexOutput(v3, n));
                outStream.Append(VertexOutput(v4, n));
                outStream.Append(VertexOutput(v5, n));
                outStream.RestartStrip();

                // Side rectangle 1
                n = GetNormal(v3, v0, v4);
                outStream.Append(VertexOutput(v3, n));
                outStream.Append(VertexOutput(v0, n));
                outStream.Append(VertexOutput(v4, n));
                outStream.Append(VertexOutput(v1, n));
                outStream.RestartStrip();

                // Side rectangle 2
                n = GetNormal(v4, v1, v5);
                outStream.Append(VertexOutput(v4, n));
                outStream.Append(VertexOutput(v1, n));
                outStream.Append(VertexOutput(v5, n));
                outStream.Append(VertexOutput(v2, n));
                outStream.RestartStrip();

                // Side rectangle 3
                n = GetNormal(v5, v2, v3);
                outStream.Append(VertexOutput(v5, n));
                outStream.Append(VertexOutput(v2, n));
                outStream.Append(VertexOutput(v3, n));
                outStream.Append(VertexOutput(v0, n));
                outStream.RestartStrip();
            }

            fixed4 frag (g2f i) : SV_Target
            {
                fixed4 col = _Color;
                col.rgb *= i.normal;
                return col;
            }
            ENDCG
        }
    }
}

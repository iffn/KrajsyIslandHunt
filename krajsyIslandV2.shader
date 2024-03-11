Shader "Unlit/krajsyIslandV2"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float getGpuValue()
            {
                float a = 0.;
                if (_Time.y != -1.)
                    a = 1.;
                return frac(abs(sin(a*3.1415))*pow(2., 10.));
            }

            float noiseMethod(float2 uv)
            {
                float fpA = 127.1;
                float fpB = 311.7;
                float fpC = 269.5;
                float fpD = 183.3;
                float fpE = 43758.5453123;

                float2 i = floor(uv * 2.);
                float2 f = frac(uv * 2.);
                float2 t = f * f * f * ( f * ( f * 6.0 - 15.0 ) + 10.0 );
                float2 a = i + float2( 0.0, 0.0 );
                float2 b = i + float2( 1.0, 0.0 );
                float2 c = i + float2( 0.0, 1.0 );
                float2 d = i + float2( 1.0, 1.0 );
                a = -1.0 + 2.0 * frac( sin( float2( dot( a, float2( fpA, fpB ) ),dot( a, float2( fpC, fpD ) ) ) ) * fpE );
                b = -1.0 + 2.0 * frac( sin( float2( dot( b, float2( fpA, fpB ) ),dot( b, float2( fpC, fpD ) ) ) ) * fpE );
                c = -1.0 + 2.0 * frac( sin( float2( dot( c, float2( fpA, fpB ) ),dot( c, float2( fpC, fpD ) ) ) ) * fpE );
                d = -1.0 + 2.0 * frac( sin( float2( dot( d, float2( fpA, fpB ) ),dot( d, float2( fpC, fpD ) ) ) ) * fpE );
                float A = dot( a, f - float2( 0.0, 0.0 ) );
                float B = dot( b, f - float2( 1.0, 0.0 ) );
                float C = dot( c, f - float2( 0.0, 1.0 ) );
                float D = dot( d, f - float2( 1.0, 1.0 ) );
                float noise = ( lerp( lerp( A, B, t.x ), lerp( C, D, t.x ), t.y ) );

                return clamp(1.5 * noise, -1.0, 1.0 )*.5+.5;
            }

            float getFalloff(float2 uv)
            {
                float land = smoothstep(.2, .5, length(uv - .5));
                return 1.-clamp(land, 0., 1.);
            }

            float3 colDisplay(float2 uv, float value)
            {
                float segments = 32.;
                int thisSeg = int((1.-uv.x)*segments);

                int newValue = int(value * pow(2., segments-1.));
                //newValue = int(floor(_Time.y));

                float3 outCol = .15;
                outCol.g = .9 * clamp(float(newValue & (1 << thisSeg)), 0., 1.);

                if (thisSeg % 2. == 0.)
                    outCol.rb *= .2;

                return outCol;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv;
                float2 noiseUv = uv - float2(0, .05);
                float4 col = 1;

                uv /= .9;
                noiseUv /= .9;

                float noise = getFalloff(noiseUv) * noiseMethod((noiseUv*2.+100.));
                col.rgb = step(.5, noise);

                float gpuValue = getGpuValue();
                if (uv.y < .1)
                {
                    col.rgb = colDisplay(uv, gpuValue);
                }

                if (max(uv.x, uv.y) > 1.)
                {
                    col.rgb = float3(.8,.1,.1);
                    if (int(gpuValue * pow(2., 31.)) == 203755792)
                        col.rg = col.gr;
                }

                return col;
            }
            ENDCG
        }
    }
}

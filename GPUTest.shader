//Made by Krajsyboys

Shader "Unlit/GPUTest"
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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            // Island shader noise:
            // https://forum.unity.com/threads/mathf-perlinnoise-x-y-in-a-shader.532963/
            // Some values are changed from the og
            float noiseMethod(float2 uv)
            {
                float _lacunarity = 2; // Noiseness
                float _gain = 0.5; // Crispyness
                float _amplitude = 1.5; // How much is does
                float _frequency = 2; // Another kind of scale?
                float _power = 1; // Color sharpness

                float _octaves = 1;

                float _finalValue = 0;

                float2 p = uv;

                //p = p * _scale + float2(_offsetX,_offsetY);

                float fpA = 127.1; // 127.1
                float fpB = 311.7; // 311.7
                float fpC = 269.5; // 269.5
                float fpD = 183.3; // 183.3
                float fpE = 43758.5453123; // 43758.5453123

                for( int i = 0; i < _octaves; i++ )
                {
                    float2 i = floor( p * _frequency );
                    float2 f = frac( p * _frequency );      
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
                    _finalValue += _amplitude * noise;
                    _frequency *= _lacunarity;
                    _amplitude *= _gain;
                }
                _finalValue = clamp(_finalValue, -1.0, 1.0 );
                return pow(_finalValue * 0.5 + 0.5, _power);
            }

            float getFalloff(float2 uv)
            {
                float land;

                land = smoothstep(0.2, .5, distance(uv, 0.5));

                land = -clamp(land, 0, 1)+1;
                return land;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv;
                // sample the texture
                fixed4 col = 0;// = tex2D(_MainTex, i.uv);
                // apply fog
                //UNITY_APPLY_FOG(i.fogCoord, col);

                float _ScaleValue = 2.0;
                float _OffsetValue = 100.0;

                col = noiseMethod(uv*_ScaleValue + float2(1,1)*_OffsetValue);

                col = getFalloff(uv)*col;

                col = col<0.5?0:1;

                return col;
            }
            ENDCG
        }
    }
}

Shader "Custom/WaveGradient"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _PeakColour("PeakColour", Color ) = (0,0,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}

        _DisplacementMap("Displacement", 2D) = "black" {}
        _DisplacementStrength("Displacement Strength", Range(0,5)) = 0.5

        _v("Smoothness", Range(-10,10)) = 1.0
        _m("Movement", Range(-10,10)) = 0.6
        _z("Variation", Range(-10,10)) = 0.3
        _Amp("Ampliture", Range(0,20)) = 4.2

        _speed("Speed",Range(-10,10)) = 1
        
    }
    SubShader
    {
        Pass
        {

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog
            #include "UnityCG.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _DisplacementMap;
            half _DisplacementStrength;

            half _v;
            half _m;
            half _z;
            half _Amp;

            half _speed;

            struct Input
            {
                float2 uv_MainTex;
            };

            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float normal : NORMAL;
            };

            struct v2f
            {
                float2 uv :TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            v2f vert(appdata v) {
                v2f o;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                float3 displaceCalc = v.vertex.xyz;
                displaceCalc.y = _Amp * sin(displaceCalc.x * _v + _m*(_speed * _Time.y)) * _z ; //calculates the sine wave
                v.vertex.xyz = displaceCalc; 
                float displacement = tex2Dlod(_DisplacementMap, float4(o.uv, 0, 0)).r;

                float4 temp = float4(v.vertex.x, v.vertex.y, v.vertex.z, 1.0);
                temp.xyz += displacement * v.normal * _DisplacementStrength; //extrudes vertex by displacement based on its normal by amount of displacment strength
                
                o.vertex = UnityObjectToClipPos(temp);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target{
                fixed4 col = _Color * tex2D(_MainTex, i.uv);
                UNITY_APPLY_FOG(i.fogCoord, col)
                return col;

            }
            ENDCG

        }

    }
}

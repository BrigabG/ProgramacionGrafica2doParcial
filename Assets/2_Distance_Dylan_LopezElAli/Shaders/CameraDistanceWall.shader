// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X
Shader "CameraDistanceWall"
{
    Properties
    {
        _MainTex ("Reveal Texture", 2D) = "white" {}
        _CutoutScreenPos ("Cutout Screen Position", Vector) = (0.5, 0.5, 0, 0)
        _CutoutRadius ("Cutout Radius", Float) = 0.18
        _CutoutFade ("Cutout Fade", Float) = 0.075
        _Aspect ("Aspect", Float) = 1
        _TintColor ("Tint Color", Color) = (0.75, 0.95, 1, 0.18)
        _PlayerOpacity ("Player Opacity", Range(0, 1)) = 1
        _Enabled ("Enabled", Range(0, 1)) = 0
        [HideInInspector] __dirty( "", Int ) = 1
    }

    SubShader
    {
        Tags
        {
            "Queue" = "Overlay"
            "RenderType" = "Transparent"
            "IgnoreProjector" = "True"
        }

        Cull Off
        Lighting Off
        ZWrite Off
        ZTest Always
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _CutoutScreenPos;
            float _CutoutRadius;
            float _CutoutFade;
            float _Aspect;
            float4 _TintColor;
            float _PlayerOpacity;
            float _Enabled;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                fixed4 color : COLOR;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                fixed4 color : COLOR;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.color = v.color;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float2 centeredUv = i.uv - _CutoutScreenPos.xy;
                centeredUv.x *= _Aspect;

                float radius = max(_CutoutRadius, 0.0001);
                float fade = max(_CutoutFade, 0.0001);
                float distanceToPlayer = distance(centeredUv, float2(0.0, 0.0));
                float mask = 1.0 - smoothstep(radius, radius + fade, distanceToPlayer);
                mask *= saturate(_Enabled);

                fixed4 reveal = tex2D(_MainTex, i.uv);
                fixed4 color = lerp(reveal, fixed4(_TintColor.rgb, 1.0), saturate(_TintColor.a));
                color.a = mask * saturate(_PlayerOpacity);
                return color * i.color;
            }
            ENDCG
        }
    }

    Fallback Off
    CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18900
6.4;6.4;2035.2;1078.2;1625.343;732.6706;1.3;True;True
Node;AmplifyShaderEditor.Vector4Node;2;-1787.28,45.2;Inherit;False;Property;_CutoutScreenPos;Cutout Screen Pos;1;0;Create;True;0;0;0;False;0;False;0.5,0.5,0,0;0.5,0.5,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;1;-1780,-180;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SwizzleNode;3;-1510,40;Inherit;True;FLOAT2;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-1280,110;Inherit;True;Property;_Aspect;Aspect;4;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;4;-1294.4,-130.8;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;6;-1020.4,-166;Inherit;True;2;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;7;-1035.84,81.87997;Inherit;True;Constant;_Cero;Cero;0;0;Create;True;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;9;-800,120;Inherit;True;Property;_CutoutRadius;Cutout Radius;2;0;Create;True;0;0;0;False;0;False;0.18;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;8;-789.6001,-138.8;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-562.7202,136.04;Inherit;True;Property;_CutoutFade;Cutout Fade;3;0;Create;True;0;0;0;False;0;False;0.075;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;10;-557.52,-130.28;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;12;-354.16,-94.92006;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0.075;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;13;-102.3599,-114.68;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;14;85.99997,-114.68;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-158.6399,194.92;Inherit;True;Property;_Enabled;Enabled;7;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;299.1201,-123.4;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;17;266.2401,181.2;Inherit;True;Property;_PlayerOpacity;Player Opacity;6;0;Create;True;0;0;0;False;0;False;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;20;-520,-555;Inherit;False;Property;_TintColor;Tint Color;5;0;Create;True;0;0;0;False;0;False;0.75,0.95,1,0.18;0.75,0.95,1,0.18;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;19;-790,-360;Inherit;True;Property;_MainTex;Reveal Texture;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;535.7599,-63.27997;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;21;-230,-390;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;891.04,-186.24;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;CameraDistanceWall;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;3;0;2;0
WireConnection;4;0;1;0
WireConnection;4;1;3;0
WireConnection;6;0;4;0
WireConnection;6;1;5;0
WireConnection;8;0;6;0
WireConnection;8;1;7;0
WireConnection;10;0;8;0
WireConnection;10;1;9;0
WireConnection;12;0;10;0
WireConnection;12;1;11;0
WireConnection;13;0;12;0
WireConnection;14;0;13;0
WireConnection;16;0;14;0
WireConnection;16;1;15;0
WireConnection;19;1;1;0
WireConnection;18;0;16;0
WireConnection;18;1;17;0
WireConnection;21;0;19;0
WireConnection;21;1;20;0
WireConnection;21;2;20;4
WireConnection;0;2;21;0
WireConnection;0;9;18;0
ASEEND*/
//CHKSM=3C6073B6D89990E16F73D70F1A9A3E1BAA36C47F


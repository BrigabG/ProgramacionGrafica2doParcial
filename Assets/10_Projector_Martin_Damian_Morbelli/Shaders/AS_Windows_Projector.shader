// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "AS_Windows_Projector"
{
	Properties
	{
		_BlindsMask("_BlindsMask", 2D) = "white" {}
		_LightColor("_LightColor", Color) = (1,0.88,0.6,1)
		_Intensity("_Intensity", Float) = 0.8
		_Alpha("_Alpha", Float) = 0.45
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Off
		Blend One One
		
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Unlit keepalpha noshadow 
		struct Input
		{
			float3 worldPos;
		};

		uniform float4 _LightColor;
		uniform sampler2D _BlindsMask;
		float4x4 unity_Projector;
		uniform float _Intensity;
		uniform float _Alpha;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float4 ase_vertex4Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float4 break16 = mul( unity_Projector, ase_vertex4Pos );
			float4 appendResult17 = (float4(break16.x , break16.y , 0.0 , 0.0));
			float2 projUV = ( appendResult17 / break16.w ).xy;

			// Recorte: sin esto, el wrap "Clamp" de la textura repite el pixel del borde
			// (blanco) por todo el piso en vez de quedarse solo en el rectangulo real.
			clip( break16.w );
			clip( projUV.x );
			clip( 1.0 - projUV.x );
			clip( projUV.y );
			clip( 1.0 - projUV.y );

			float4 tex2DNode4 = tex2D( _BlindsMask, projUV );
			o.Emission = ( ( _LightColor * tex2DNode4 ) * _Intensity ).rgb;
			o.Alpha = ( tex2DNode4.r * _Alpha );
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18900
220;73;1483;707;1806.72;381.9861;1.6;False;False
Node;AmplifyShaderEditor.UnityProjectorMatrixNode;1;-1861.148,-212.112;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.PosVertexDataNode;2;-1855.45,-103.9732;Inherit;False;1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;-1651.551,-139.8587;Inherit;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.BreakToComponentsNode;16;-1497.698,-87.14996;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;17;-1351.382,-159.5775;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;18;-1155.239,-13.13058;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;4;-942.2874,21.94298;Inherit;True;Property;_BlindsMask;_BlindsMask;1;0;Create;True;0;0;0;False;0;False;-1;None;12cfd83abb9e3144594241a193f47e58;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;5;-871.8498,-167.0107;Inherit;False;Property;_LightColor;_LightColor;2;0;Create;True;0;0;0;False;0;False;1,0.88,0.6,1;1,0.88,0.6,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;7;-468.3474,-133.839;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;6;-468.8893,-17.45151;Inherit;False;Property;_Intensity;_Intensity;3;0;Create;True;0;0;0;False;0;False;0.8;0.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;9;-808.4571,255.9116;Inherit;False;Property;_Alpha;_Alpha;4;0;Create;True;0;0;0;False;0;False;0.45;0.45;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;-261.1228,-101.7248;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;11;-530.1874,152.4031;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-2.328851,0;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;AS_Windows_Projector;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;False;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;4;1;False;-1;1;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;15;0;1;0
WireConnection;15;1;2;0
WireConnection;16;0;15;0
WireConnection;17;0;16;0
WireConnection;17;1;16;1
WireConnection;18;0;17;0
WireConnection;18;1;16;3
WireConnection;4;1;18;0
WireConnection;7;0;5;0
WireConnection;7;1;4;0
WireConnection;10;0;7;0
WireConnection;10;1;6;0
WireConnection;11;0;4;1
WireConnection;11;1;9;0
WireConnection;0;2;10;0
WireConnection;0;9;11;0
ASEEND*/
//CHKSM=7DCBF8D80A4AA33FF47B508F76C7E5831BD33698
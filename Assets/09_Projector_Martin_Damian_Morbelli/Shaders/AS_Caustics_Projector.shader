// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "AS_Caustics_Projector"
{
	Properties
	{
		_CausticsScale("_CausticsScale", Float) = 2
		_Caustics_A("Caustics_A", 2D) = "white" {}
		_Caustics_B("Caustics_B", 2D) = "white" {}
		_CausticsIntensity("_CausticsIntensity", Float) = 1.5
		_Float0("Float 0", Float) = 1.37
		_CausticsColor("_CausticsColor", Color) = (0.5490196,0.9490196,1,0)
		_Alpha("_Alpha", Float) = 0.5
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

		uniform sampler2D _Caustics_B;
		float4x4 unity_Projector;
		uniform float _CausticsScale;
		uniform float _Float0;
		uniform sampler2D _Caustics_A;
		uniform float4 _CausticsColor;
		uniform float _CausticsIntensity;
		uniform float _Alpha;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float4 ase_vertex4Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float4 break4 = mul( unity_Projector, ase_vertex4Pos );
			float4 appendResult5 = (float4(break4.x , break4.y , 0.0 , 0.0));
			float4 temp_output_6_0 = ( appendResult5 / break4.w );
			float2 panner12 = ( 1.0 * _Time.y * float2( -0.02,0.035 ) + ( ( temp_output_6_0 * _CausticsScale ) * _Float0 ).xy);
			float2 panner9 = ( 1.0 * _Time.y * float2( 0.03,0.02 ) + ( temp_output_6_0 * _CausticsScale ).xy);
			float4 temp_output_19_0 = ( 1.0 - ( ( 1.0 - tex2D( _Caustics_B, panner12 ) ) * ( 1.0 - tex2D( _Caustics_A, panner9 ) ) ) );
			o.Emission = ( ( temp_output_19_0 * _CausticsColor ) * _CausticsIntensity ).rgb;
			o.Alpha = ( temp_output_19_0.r * _Alpha );
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18900
220;73;1483;707;95.81873;384.1194;1;False;False
Node;AmplifyShaderEditor.UnityProjectorMatrixNode;1;-2389.702,-315.9782;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.PosVertexDataNode;2;-2425.567,-217.7014;Inherit;False;1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;3;-2163.802,-270.7912;Inherit;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.BreakToComponentsNode;4;-2004.802,-258.7912;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;5;-1843.801,-325.7912;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-1721.473,-60.01939;Inherit;False;Property;_CausticsScale;_CausticsScale;1;0;Create;True;0;0;0;False;0;False;2;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;6;-1687.801,-179.7911;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-1485.327,-231.6066;Inherit;False;Property;_Float0;Float 0;5;0;Create;True;0;0;0;False;0;False;1.37;1.37;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;11;-1474.127,-355.1578;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;-1476.842,-118.3578;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;-1278.673,-307.1876;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.PannerNode;9;-1096.687,-120.2709;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.03,0.02;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;12;-1096.961,-317.8942;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;-0.02,0.035;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;10;-771.571,14.53518;Inherit;True;Property;_Caustics_A;Caustics_A;2;0;Create;True;0;0;0;False;0;False;-1;b04fe94db0394d9e9184df61b122b7e4;b04fe94db0394d9e9184df61b122b7e4;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;13;-772.7943,-282.6063;Inherit;True;Property;_Caustics_B;Caustics_B;3;0;Create;True;0;0;0;False;0;False;-1;b04fe94db0394d9e9184df61b122b7e4;b04fe94db0394d9e9184df61b122b7e4;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;16;-420.9311,-125.5487;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;17;-415.7887,-15.85105;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;-225.5322,-86.12608;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;20;-145.5748,167.1694;Inherit;False;Property;_CausticsColor;_CausticsColor;6;0;Create;True;0;0;0;False;0;False;0.5490196,0.9490196,1,0;0.5490196,0.9490196,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;19;-81.38187,-54.66057;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.BreakToComponentsNode;26;188.1638,-273.5739;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;22;164.7666,-77.75212;Inherit;False;Property;_Alpha;_Alpha;7;0;Create;True;0;0;0;False;0;False;0.5;0.85;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;21;127.7991,131.0162;Inherit;False;Property;_CausticsIntensity;_CausticsIntensity;4;0;Create;True;0;0;0;False;0;False;1.5;0.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;165.2879,17.36341;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;24;361.2802,49.99678;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;373.249,-207.6725;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;639.7872,-262.997;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;AS_Caustics_Projector;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;False;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;4;1;False;-1;1;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;3;0;1;0
WireConnection;3;1;2;0
WireConnection;4;0;3;0
WireConnection;5;0;4;0
WireConnection;5;1;4;1
WireConnection;6;0;5;0
WireConnection;6;1;4;3
WireConnection;11;0;6;0
WireConnection;11;1;7;0
WireConnection;8;0;6;0
WireConnection;8;1;7;0
WireConnection;15;0;11;0
WireConnection;15;1;14;0
WireConnection;9;0;8;0
WireConnection;12;0;15;0
WireConnection;10;1;9;0
WireConnection;13;1;12;0
WireConnection;16;0;13;0
WireConnection;17;0;10;0
WireConnection;18;0;16;0
WireConnection;18;1;17;0
WireConnection;19;0;18;0
WireConnection;26;0;19;0
WireConnection;23;0;19;0
WireConnection;23;1;20;0
WireConnection;24;0;23;0
WireConnection;24;1;21;0
WireConnection;27;0;26;0
WireConnection;27;1;22;0
WireConnection;0;2;24;0
WireConnection;0;9;27;0
ASEEND*/
//CHKSM=E339E9E71ECA8357726F4F4F04314DE915C9BF74
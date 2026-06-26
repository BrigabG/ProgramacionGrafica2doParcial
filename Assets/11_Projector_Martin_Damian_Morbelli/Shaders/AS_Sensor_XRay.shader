// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "AS_Sensor_XRay"
{
	Properties
	{
		_GridScale("_GridScale", Float) = 3
		_ScanGrad_A("_ScanGrad_A", 2D) = "white" {}
		_ScanGrid_B("_ScanGrid_B", 2D) = "white" {}
		_XRayIntensity("_XRayIntensity", Float) = 1.4
		_SecondaryScale("_SecondaryScale", Float) = 1.37
		_XrayColor("_XrayColor", Color) = (0.55,0.95,1,1)
		_Alpha("_Alpha", Float) = 0.85
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

		uniform sampler2D _ScanGrad_A;
		float4x4 unity_Projector;
		uniform float _GridScale;
		uniform sampler2D _ScanGrid_B;
		uniform float _SecondaryScale;
		uniform float4 _XrayColor;
		uniform float _XRayIntensity;
		uniform float _Alpha;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float4 ase_vertex4Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float4 break11 = mul( unity_Projector, ase_vertex4Pos );
			float4 appendResult12 = (float4(break11.x , break11.y , 0.0 , 0.0));
			float4 temp_output_13_0 = ( appendResult12 / break11.w );
			float2 panner23 = ( 1.0 * _Time.y * float2( 0.03,0.02 ) + ( temp_output_13_0 * _GridScale ).xy);
			float2 panner27 = ( 1.0 * _Time.y * float2( 0.02,0.035 ) + ( ( temp_output_13_0 * _GridScale ) * _SecondaryScale ).xy);
			float4 temp_output_31_0 = ( 1.0 - ( ( 1.0 - tex2D( _ScanGrad_A, panner23 ) ) * ( 1.0 - tex2D( _ScanGrid_B, panner27 ) ) ) );
			o.Emission = ( ( temp_output_31_0 * _XrayColor ) * _XRayIntensity ).rgb;
			o.Alpha = ( temp_output_31_0 * _Alpha ).r;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18900
253;73;1377;707;540.6302;797.0755;2.017716;False;False
Node;AmplifyShaderEditor.PosVertexDataNode;8;-1542.459,104.7795;Inherit;False;1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.UnityProjectorMatrixNode;9;-1520.983,-7.552368;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;-1322.752,51.91742;Inherit;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.BreakToComponentsNode;11;-1157.557,70.08858;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;12;-993.7938,-34.49466;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;1;-424.0026,-218.5928;Inherit;False;Property;_GridScale;_GridScale;0;0;Create;True;0;0;0;False;0;False;3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;13;-853.3677,182.1034;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-348.7299,46.24952;Inherit;False;Property;_SecondaryScale;_SecondaryScale;5;0;Create;True;0;0;0;False;0;False;1.37;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;-261.8858,-100.4466;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;26;-78.72494,-157.8265;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;-265.6765,-525.4436;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.PannerNode;27;74.50816,-167.1977;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.02,0.035;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;23;-88.27007,-458.1778;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0.03,0.02;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;3;286.3036,-124.0448;Inherit;True;Property;_ScanGrid_B;_ScanGrid_B;3;0;Create;True;0;0;0;False;0;False;-1;3fef788a9be6b0847833c3a7209d1d5f;ed01e10b7d28d23419139e90b39a6202;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;2;278.9543,-396.5533;Inherit;True;Property;_ScanGrad_A;_ScanGrad_A;2;0;Create;True;0;0;0;False;0;False;-1;3fef788a9be6b0847833c3a7209d1d5f;ed01e10b7d28d23419139e90b39a6202;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;29;674.1006,-141.6456;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;28;675.2141,-234.0834;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;868.9634,-213.2565;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;6;933.9595,-92.91974;Inherit;False;Property;_XrayColor;_XrayColor;6;0;Create;True;0;0;0;False;0;False;0.55,0.95,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;31;1008.325,-200.7192;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;1198.753,-157.5372;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;7;996.1467,232.9376;Inherit;False;Property;_Alpha;_Alpha;7;0;Create;True;0;0;0;False;0;False;0.85;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;4;1169.919,-13.68591;Inherit;False;Property;_XRayIntensity;_XRayIntensity;4;0;Create;True;0;0;0;False;0;False;1.4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;15;-749.9333,428.6151;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.OneMinusNode;18;-585.9063,449.2143;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClipNode;16;-413.0152,722.5595;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;17;-580.4117,662.1214;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClipNode;14;-1032.857,316.7574;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;1411.801,-85.52763;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClipNode;20;-415.0301,572.8378;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClipNode;19;-412.1917,256.773;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;1208.188,208.4001;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClipNode;21;-409.8108,410.7999;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1581.774,-57.44845;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;AS_Sensor_XRay;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;False;0;True;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;4;1;False;-1;1;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;10;0;9;0
WireConnection;10;1;8;0
WireConnection;11;0;10;0
WireConnection;12;0;11;0
WireConnection;12;1;11;1
WireConnection;13;0;12;0
WireConnection;13;1;11;3
WireConnection;25;0;13;0
WireConnection;25;1;1;0
WireConnection;26;0;25;0
WireConnection;26;1;5;0
WireConnection;22;0;13;0
WireConnection;22;1;1;0
WireConnection;27;0;26;0
WireConnection;23;0;22;0
WireConnection;3;1;27;0
WireConnection;2;1;23;0
WireConnection;29;0;3;0
WireConnection;28;0;2;0
WireConnection;30;0;28;0
WireConnection;30;1;29;0
WireConnection;31;0;30;0
WireConnection;32;0;31;0
WireConnection;32;1;6;0
WireConnection;15;0;13;0
WireConnection;18;0;15;0
WireConnection;17;0;15;1
WireConnection;14;0;11;3
WireConnection;33;0;32;0
WireConnection;33;1;4;0
WireConnection;20;0;15;1
WireConnection;19;0;15;0
WireConnection;34;0;31;0
WireConnection;34;1;7;0
WireConnection;21;0;18;0
WireConnection;0;2;33;0
WireConnection;0;9;34;0
ASEEND*/
//CHKSM=3861664839DB1514A7DFA6E2E515F61BF3FFF973
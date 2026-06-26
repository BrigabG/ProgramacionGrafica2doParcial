// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "AS_Sensor_Approval"
{
	Properties
	{
		_Intensity("_Intensity", Float) = 1.8
		_IndicatorColor("_IndicatorColor", Color) = (1,1,1,0)
		_Alpha("_Alpha", Float) = 0.8
		_PulseSpeed("_PulseSpeed", Float) = 3
		_RingWidth("_RingWidth", Float) = 0.08
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IsEmissive" = "true"  }
		Cull Back
		Blend One One
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Unlit keepalpha noshadow 
		struct Input
		{
			float3 worldPos;
		};

		uniform float4 _IndicatorColor;
		float4x4 unity_Projector;
		uniform float _RingWidth;
		uniform float _PulseSpeed;
		uniform float _Intensity;
		uniform float _Alpha;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float4 ase_vertex4Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float4 break9 = mul( unity_Projector, ase_vertex4Pos );
			float4 appendResult10 = (float4(break9.x , break9.y , 0.0 , 0.0));
			float4 temp_output_11_0 = ( appendResult10 / break9.w );
			float temp_output_21_0 = distance( temp_output_11_0 , float4( float2( 0.5,0.5 ), 0.0 , 0.0 ) );
			float2 break19_g1 = float2( -0.5,0.5 );
			float temp_output_1_0_g1 = ( _Time.y * _PulseSpeed );
			float sinIn7_g1 = sin( temp_output_1_0_g1 );
			float sinInOffset6_g1 = sin( ( temp_output_1_0_g1 + 1.0 ) );
			float lerpResult20_g1 = lerp( break19_g1.x , break19_g1.y , frac( ( sin( ( ( sinIn7_g1 - sinInOffset6_g1 ) * 91.2228 ) ) * 43758.55 ) ));
			float4 temp_output_45_0 = ( _IndicatorColor * ( ( ( saturate( ( 1.0 - ( temp_output_21_0 * 1.4 ) ) ) * 0.4 ) + saturate( ( 1.0 - ( abs( ( temp_output_21_0 - 0.38 ) ) / _RingWidth ) ) ) ) * ( ( ( lerpResult20_g1 + sinIn7_g1 ) * 0.35 ) + 0.65 ) ) );
			o.Emission = ( temp_output_45_0 * _Intensity ).rgb;
			o.Alpha = saturate( ( temp_output_45_0 * _Alpha ) ).r;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18900
1027;197;891;707;-1743.767;-0.7815247;1;False;False
Node;AmplifyShaderEditor.UnityProjectorMatrixNode;6;-1427.521,119.7952;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.PosVertexDataNode;7;-1459.689,203.6328;Inherit;False;1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;-1219.617,158.3513;Inherit;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.BreakToComponentsNode;9;-1037.617,194.3513;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;10;-878.6166,125.3513;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;11;-722.6166,253.3513;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector2Node;22;-546.5632,199.0596;Inherit;False;Constant;_Vector0;Vector 0;4;0;Create;True;0;0;0;False;0;False;0.5,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.DistanceOpNode;21;-475.0298,-57.81792;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-49.89841,-168.3004;Inherit;False;Constant;_Float1;Float 1;4;0;Create;True;0;0;0;False;0;False;0.38;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-364.228,56.88046;Inherit;False;Constant;_Float0;Float 0;4;0;Create;True;0;0;0;False;0;False;1.4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;27;102.8932,-325.6179;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;36;240.8469,221.5601;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;244.7316,-171.4113;Inherit;False;Property;_RingWidth;_RingWidth;5;0;Create;True;0;0;0;False;0;False;0.08;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;4;235.9102,319.4994;Inherit;False;Property;_PulseSpeed;_PulseSpeed;4;0;Create;True;0;0;0;False;0;False;3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;29;283.8393,-276.2369;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;-161.1624,-56.11585;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;25;-2.312554,-49.56532;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;510.8473,223.5601;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;30;444.5473,-209.874;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;26;176.1904,-34.82696;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;40;699.9935,401.5354;Inherit;False;Constant;_Float3;Float 3;4;0;Create;True;0;0;0;False;0;False;0.35;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;34;558.2621,54.9982;Inherit;False;Constant;_Float2;Float 2;4;0;Create;True;0;0;0;False;0;False;0.4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;31;584.1187,-166.8957;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;38;666.0451,302.4048;Inherit;False;Noise Sine Wave;-1;;1;a6eff29f739ced848846e3b648af87bd;0;2;1;FLOAT;0;False;2;FLOAT2;-0.5,0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;32;751.1187,-155.8957;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;756.6019,-20.19113;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;917.2653,299.6888;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;43;884.6736,459.9273;Inherit;False;Constant;_Float4;Float 4;4;0;Create;True;0;0;0;False;0;False;0.65;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;42;1065.281,389.3138;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;35;977.2621,-83.0018;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;1;1327.157,-114.4882;Inherit;False;Property;_IndicatorColor;_IndicatorColor;2;0;Create;True;0;0;0;False;0;False;1,1,1,0;0.003921569,0.003921569,0.003921569,0.003921569;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;1310.002,119.3028;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;3;1677.817,348.9997;Inherit;False;Property;_Alpha;_Alpha;3;0;Create;True;0;0;0;False;0;False;0.8;0.8;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;1672.553,14.97351;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;47;1887.533,304.1565;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;2;1670.636,144.2572;Inherit;False;Property;_Intensity;_Intensity;1;0;Create;True;0;0;0;False;0;False;1.8;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;46;1886.989,38.79907;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClipNode;17;-369.6166,557.3513;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;20;-444.459,693.5334;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClipNode;18;-240.6166,705.3513;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClipNode;12;-917.6166,390.3513;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;13;-588.6166,453.3513;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.ClipNode;15;-372.6166,292.3513;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;19;-405.459,458.5335;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClipNode;16;-200.6166,427.3513;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;48;2122.807,318.2568;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;2420.008,10.35297;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;AS_Sensor_Approval;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;False;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;4;1;False;-1;1;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;8;0;6;0
WireConnection;8;1;7;0
WireConnection;9;0;8;0
WireConnection;10;0;9;0
WireConnection;10;1;9;1
WireConnection;11;0;10;0
WireConnection;11;1;9;3
WireConnection;21;0;11;0
WireConnection;21;1;22;0
WireConnection;27;0;21;0
WireConnection;27;1;28;0
WireConnection;29;0;27;0
WireConnection;23;0;21;0
WireConnection;23;1;24;0
WireConnection;25;0;23;0
WireConnection;37;0;36;0
WireConnection;37;1;4;0
WireConnection;30;0;29;0
WireConnection;30;1;5;0
WireConnection;26;0;25;0
WireConnection;31;0;30;0
WireConnection;38;1;37;0
WireConnection;32;0;31;0
WireConnection;33;0;26;0
WireConnection;33;1;34;0
WireConnection;39;0;38;0
WireConnection;39;1;40;0
WireConnection;42;0;39;0
WireConnection;42;1;43;0
WireConnection;35;0;33;0
WireConnection;35;1;32;0
WireConnection;44;0;35;0
WireConnection;44;1;42;0
WireConnection;45;0;1;0
WireConnection;45;1;44;0
WireConnection;47;0;45;0
WireConnection;47;1;3;0
WireConnection;46;0;45;0
WireConnection;46;1;2;0
WireConnection;17;0;13;1
WireConnection;20;0;13;1
WireConnection;18;0;20;0
WireConnection;12;0;9;3
WireConnection;13;0;11;0
WireConnection;15;0;13;0
WireConnection;19;0;13;0
WireConnection;16;0;19;0
WireConnection;48;0;47;0
WireConnection;0;2;46;0
WireConnection;0;9;48;0
ASEEND*/
//CHKSM=E2CEB3026A927FAB9F6C7D6565157B09463C192A
// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "AS_Sensor_LightRay"
{
	Properties
	{
		_LightColor("_LightColor", Color) = (0.6,0.95,1,1)
		_Intensity("_Intensity", Float) = 1.2
		_Alpha("_Alpha", Float) = 0.6
		_BaseGlow("_BaseGlow", Float) = 0.25
		_ScanBandWidth("_ScanBandWidth", Float) = 0.12
		_ScanSpeed("_ScanSpeed", Float) = 1.5
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
		float4x4 unity_Projector;
		uniform float _BaseGlow;
		uniform float _ScanSpeed;
		uniform float _ScanBandWidth;
		uniform float _Intensity;
		uniform float _Alpha;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float4 ase_vertex4Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float4 break5 = mul( unity_Projector, ase_vertex4Pos );
			float4 appendResult6 = (float4(break5.x , break5.y , 0.0 , 0.0));
			float4 temp_output_7_0 = ( appendResult6 / break5.w );
			float4 break9 = temp_output_7_0;
			float temp_output_52_0 = ( ( saturate( ( 1.0 - ( distance( temp_output_7_0 , float4( float2( 0.5,0.5 ), 0.0 , 0.0 ) ) * 1.4 ) ) ) * _BaseGlow ) + pow( saturate( ( 1.0 - ( abs( ( break9.y - abs( ( ( frac( ( _Time.y * _ScanSpeed ) ) * 2.0 ) - 1.0 ) ) ) ) / _ScanBandWidth ) ) ) , 3.0 ) );
			o.Emission = ( ( _LightColor * temp_output_52_0 ) * _Intensity ).rgb;
			o.Alpha = saturate( ( temp_output_52_0 * _Alpha ) );
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18900
398;73;1215;700;-3132.035;-378.5658;1;False;False
Node;AmplifyShaderEditor.RangedFloatNode;26;889.8199,332.3515;Inherit;False;Property;_ScanSpeed;_ScanSpeed;6;0;Create;True;0;0;0;False;0;False;1.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.UnityProjectorMatrixNode;2;-630.4869,-16.90335;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.PosVertexDataNode;1;-651.9633,95.42854;Inherit;False;1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;36;885.2599,202.0836;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;4;-432.2561,42.56644;Inherit;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;1091.26,308.0836;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;40;1147.214,520.3901;Inherit;False;Constant;_Float1;Float 1;6;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;38;1230.937,339.4547;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;5;-267.0616,60.7376;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;42;1333.213,599.0562;Inherit;False;Constant;_Float2;Float 2;6;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;1329.214,476.3901;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;6;-103.2978,-43.84566;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;41;1527.954,476.0112;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;7;37.12866,172.7524;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.AbsOpNode;43;1686.213,485.0562;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;9;155.5322,617.0127;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleSubtractOpNode;44;1816.421,645.5381;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;30;216.6364,190.6046;Inherit;False;Constant;_Vector0;Vector 0;6;0;Create;True;0;0;0;False;0;False;0.5,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;32;403.1906,158.9453;Inherit;False;Constant;_Float0;Float 0;6;0;Create;True;0;0;0;False;0;False;1.4;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;29;343.6364,17.60458;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;45;1965.686,666.7858;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;25;1895.741,780.0256;Inherit;False;Property;_ScanBandWidth;_ScanBandWidth;5;0;Create;True;0;0;0;False;0;False;0.12;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;571.9685,8.046234;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;46;2141.538,713.5237;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;34;710.2555,48.49396;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;47;2290.957,728.6292;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;35;858.2555,43.49396;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;24;2450.811,551.8754;Inherit;False;Property;_BaseGlow;_BaseGlow;4;0;Create;True;0;0;0;False;0;False;0.25;0.25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;50;2458.957,817.6292;Inherit;False;Constant;_Float3;Float 3;6;0;Create;True;0;0;0;False;0;False;3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;48;2456.957,727.6292;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;2619.202,439.655;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;49;2609.957,763.6292;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;52;2787.146,617.2282;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;21;2788.99,401.694;Inherit;False;Property;_LightColor;_LightColor;1;0;Create;True;0;0;0;False;0;False;0.6,0.95,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;23;2865.569,971.4949;Inherit;False;Property;_Alpha;_Alpha;3;0;Create;True;0;0;0;False;0;False;0.6;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;55;3091.882,902.7346;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;53;3075.662,535.8491;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;22;3068.305,733.178;Inherit;False;Property;_Intensity;_Intensity;2;0;Create;True;0;0;0;False;0;False;1.2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;14;325.0538,850.519;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClipNode;11;493.2739,445.1706;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;12;319.5593,637.6119;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClipNode;13;495.6548,599.1975;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClipNode;16;492.4504,910.9571;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;56;3302.003,916.1066;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClipNode;15;490.4355,761.2354;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClipNode;28;-142.3607,307.4064;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;54;3290.063,605.6036;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;3843.092,509.8496;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;AS_Sensor_LightRay;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;False;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;4;1;False;-1;1;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;4;0;2;0
WireConnection;4;1;1;0
WireConnection;37;0;36;0
WireConnection;37;1;26;0
WireConnection;38;0;37;0
WireConnection;5;0;4;0
WireConnection;39;0;38;0
WireConnection;39;1;40;0
WireConnection;6;0;5;0
WireConnection;6;1;5;1
WireConnection;41;0;39;0
WireConnection;41;1;42;0
WireConnection;7;0;6;0
WireConnection;7;1;5;3
WireConnection;43;0;41;0
WireConnection;9;0;7;0
WireConnection;44;0;9;1
WireConnection;44;1;43;0
WireConnection;29;0;7;0
WireConnection;29;1;30;0
WireConnection;45;0;44;0
WireConnection;33;0;29;0
WireConnection;33;1;32;0
WireConnection;46;0;45;0
WireConnection;46;1;25;0
WireConnection;34;0;33;0
WireConnection;47;0;46;0
WireConnection;35;0;34;0
WireConnection;48;0;47;0
WireConnection;51;0;35;0
WireConnection;51;1;24;0
WireConnection;49;0;48;0
WireConnection;49;1;50;0
WireConnection;52;0;51;0
WireConnection;52;1;49;0
WireConnection;55;0;52;0
WireConnection;55;1;23;0
WireConnection;53;0;21;0
WireConnection;53;1;52;0
WireConnection;14;0;9;1
WireConnection;11;0;9;0
WireConnection;12;0;9;0
WireConnection;13;0;12;0
WireConnection;56;0;55;0
WireConnection;15;0;9;1
WireConnection;28;0;5;3
WireConnection;54;0;53;0
WireConnection;54;1;22;0
WireConnection;0;2;54;0
WireConnection;0;9;56;0
ASEEND*/
//CHKSM=C5E86DD2DB71091A45E97E8926FA6A36C7077679
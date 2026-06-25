// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "PostFX_Drunk"
{
	Properties
	{
		_DrunkSpeed("Drunk Speed", Float) = 2.2
		_DrunkAmount("Drunk Amount", Float) = 0.025
		_MainTex("Main Tex", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Off
		ZWrite Off
		ZTest Always
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Unlit keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _MainTex;
		uniform float _DrunkSpeed;
		uniform float _DrunkAmount;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float temp_output_3_0 = ( _Time.y * _DrunkSpeed );
			float4 appendResult6 = (float4(sin( temp_output_3_0 ) , cos( temp_output_3_0 ) , 0.0 , 0.0));
			float4 temp_output_8_0 = ( appendResult6 * _DrunkAmount );
			float2 temp_cast_0 = (temp_output_8_0).xx;
			float4 lerpResult15 = lerp( tex2D( _MainTex, ( i.uv_texcoord + temp_output_8_0 ) ) , tex2D( _MainTex, ( i.uv_texcoord - temp_cast_0 ) ) , 0.5);
			o.Emission = lerpResult15.rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18900
235;73;1302;590;3952.608;-96.31902;2.902183;True;False
Node;AmplifyShaderEditor.CommentaryNode;17;-2613.824,756.574;Inherit;False;725.5249;379.1891;Genera un valor que oscila con el tiempo;5;5;4;3;2;1;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;2;-2561.943,1031.709;Inherit;False;Property;_DrunkSpeed;Drunk Speed;0;0;Create;True;0;0;0;False;0;False;2.2;2.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;1;-2561.943,891.7088;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;3;-2301.942,941.7089;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;4;-2051.942,871.7088;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;18;-1829.264,756.5745;Inherit;False;412.7625;370.3539;Convierte el valor en desplazamiento de coordenadas;3;8;7;6;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CosOpNode;5;-2051.942,1021.709;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;19;-1361.005,666.4558;Inherit;False;638.941;817.4099;Lee la pantalla en una direccion y la otra;6;11;12;14;13;9;10;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-1822.818,1015.135;Inherit;False;Property;_DrunkAmount;Drunk Amount;1;0;Create;True;0;0;0;False;0;False;0.025;0.025;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;6;-1822.818,875.135;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;10;-1348.085,812.3846;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;-1562.818,915.1351;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;12;-1242.55,1063.069;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;11;-1137.627,910.6879;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;9;-1306.797,1231.492;Inherit;True;Property;_MainTex;Main Tex;2;0;Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerNode;13;-994.4142,917.9238;Inherit;True;Property;_TextureSample0;Texture Sample 0;3;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;14;-1021.424,1164.675;Inherit;True;Property;_TextureSample1;Texture Sample 1;4;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;16;-653.651,1136.125;Inherit;False;Constant;_Float2;Float 2;5;0;Create;True;0;0;0;False;0;False;0.5;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;15;-558.4879,933.2355;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-364.5809,850.5232;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;PostFX_Drunk;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;2;False;-1;7;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;3;0;1;0
WireConnection;3;1;2;0
WireConnection;4;0;3;0
WireConnection;5;0;3;0
WireConnection;6;0;4;0
WireConnection;6;1;5;0
WireConnection;8;0;6;0
WireConnection;8;1;7;0
WireConnection;12;0;10;0
WireConnection;12;1;8;0
WireConnection;11;0;10;0
WireConnection;11;1;8;0
WireConnection;13;0;9;0
WireConnection;13;1;11;0
WireConnection;14;0;9;0
WireConnection;14;1;12;0
WireConnection;15;0;13;0
WireConnection;15;1;14;0
WireConnection;15;2;16;0
WireConnection;0;2;15;0
ASEEND*/
//CHKSM=E97BEB66B65D47A6752E13113503E6F70FCC1816
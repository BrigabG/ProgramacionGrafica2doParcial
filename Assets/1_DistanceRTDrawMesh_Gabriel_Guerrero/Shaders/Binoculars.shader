// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Binoculars"
{
	Properties
	{
		_MainTex ( "Screen", 2D ) = "black" {}
		_Radio("Radio", Float) = 0.2
		_Suavidad("Suavidad", Float) = 0.22
		_CentroDer("CentroDer", Vector) = (0.58,0.5,0,0)
		_CentroIzq("CentroIzq", Vector) = (0.42,0.5,0,0)
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}

	SubShader
	{
		LOD 0

		
		
		ZTest Always
		Cull Off
		ZWrite Off

		
		Pass
		{ 
			CGPROGRAM 

			

			#pragma vertex vert_img_custom 
			#pragma fragment frag
			#pragma target 3.0
			#include "UnityCG.cginc"
			#include "UnityShaderVariables.cginc"


			struct appdata_img_custom
			{
				float4 vertex : POSITION;
				half2 texcoord : TEXCOORD0;
				
			};

			struct v2f_img_custom
			{
				float4 pos : SV_POSITION;
				half2 uv   : TEXCOORD0;
				half2 stereoUV : TEXCOORD2;
		#if UNITY_UV_STARTS_AT_TOP
				half4 uv2 : TEXCOORD1;
				half4 stereoUV2 : TEXCOORD3;
		#endif
				
			};

			uniform sampler2D _MainTex;
			uniform half4 _MainTex_TexelSize;
			uniform half4 _MainTex_ST;
			
			uniform float _Radio;
			uniform float _Suavidad;
			uniform float2 _CentroIzq;
			uniform float2 _CentroDer;


			v2f_img_custom vert_img_custom ( appdata_img_custom v  )
			{
				v2f_img_custom o;
				
				o.pos = UnityObjectToClipPos( v.vertex );
				o.uv = float4( v.texcoord.xy, 1, 1 );

				#if UNITY_UV_STARTS_AT_TOP
					o.uv2 = float4( v.texcoord.xy, 1, 1 );
					o.stereoUV2 = UnityStereoScreenSpaceUVAdjust ( o.uv2, _MainTex_ST );

					if ( _MainTex_TexelSize.y < 0.0 )
						o.uv.y = 1.0 - o.uv.y;
				#endif
				o.stereoUV = UnityStereoScreenSpaceUVAdjust ( o.uv, _MainTex_ST );
				return o;
			}

			half4 frag ( v2f_img_custom i ) : SV_Target
			{
				#ifdef UNITY_UV_STARTS_AT_TOP
					half2 uv = i.uv2;
					half2 stereoUV = i.stereoUV2;
				#else
					half2 uv = i.uv;
					half2 stereoUV = i.stereoUV;
				#endif	
				
				half4 finalColor;

				// ase common template code
				float2 uv_MainTex = i.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 texCoord8 = i.uv.xy * float2( 1,1 ) + float2( 0,0 );
				float4 appendResult6 = (float4(( _ScreenParams.x / _ScreenParams.y ) , 1.0 , 0.0 , 0.0));
				float smoothstepResult18 = smoothstep( _Radio , _Suavidad , length( ( float4( ( texCoord8 - _CentroIzq ), 0.0 , 0.0 ) * appendResult6 ) ));
				float2 texCoord13 = i.uv.xy * float2( 1,1 ) + float2( 0,0 );
				float smoothstepResult19 = smoothstep( _Radio , _Suavidad , length( ( float4( ( texCoord13 - _CentroDer ), 0.0 , 0.0 ) * appendResult6 ) ));
				

				finalColor = ( tex2D( _MainTex, uv_MainTex ) * saturate( ( ( 1.0 - smoothstepResult18 ) + ( 1.0 - smoothstepResult19 ) ) ) );

				return finalColor;
			} 
			ENDCG 
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18900
217;73;1026;715;1404.013;-186.1866;1;True;False
Node;AmplifyShaderEditor.CommentaryNode;3;-1147.264,61.21652;Inherit;False;423.9296;301.0326;dimensiones de la pantalla a 16:9;2;4;2;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ScreenParams;2;-1106.701,133.0283;Inherit;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;9;-905.7163,-81.52355;Inherit;False;Property;_CentroIzq;CentroIzq;3;0;Create;True;0;0;0;False;0;False;0.42,0.5;0.42,0.5;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleDivideOpNode;4;-891.1827,153.7117;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;16;-916.6583,587.8829;Inherit;False;Property;_CentroDer;CentroDer;2;0;Create;True;0;0;0;False;0;False;0.58,0.5;0.58,0.5;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;13;-934.8217,453.817;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;8;-924.9841,-215.5895;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;7;-679.9935,292.3441;Inherit;False;Constant;_Float0;Float 0;1;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;14;-703.6581,532.8829;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;6;-672.494,153.3441;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;10;-693.8205,-136.5235;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;-485.6574,274.8639;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;11;-503.665,51.87244;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.LengthOpNode;17;-347.5278,271.6381;Inherit;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-220.5278,215.6381;Inherit;False;Property;_Suavidad;Suavidad;1;0;Create;True;0;0;0;False;0;False;0.22;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LengthOpNode;12;-350.5355,50.79688;Inherit;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-218.5278,155.6381;Inherit;False;Property;_Radio;Radio;0;0;Create;True;0;0;0;False;0;False;0.2;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;18;-202,50;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;19;-203.5278,272.6381;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;22;0.09119797,124.0006;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;23;-3.163742,202.1191;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;24;157.824,151.5034;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;30;71.98077,-240.3721;Inherit;False;0;0;_MainTex;Shader;False;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;29;225.0944,-239.5667;Inherit;True;Property;_TextureSample1;Texture Sample 1;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;25;350,153;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;27;550.2512,61.81784;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;785.073,55.38017;Float;False;True;-1;2;ASEMaterialInspector;0;4;Binoculars;c71b220b631b6344493ea3cf87110c93;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;True;7;False;-1;False;True;0;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;4;0;2;1
WireConnection;4;1;2;2
WireConnection;14;0;13;0
WireConnection;14;1;16;0
WireConnection;6;0;4;0
WireConnection;6;1;7;0
WireConnection;10;0;8;0
WireConnection;10;1;9;0
WireConnection;15;0;14;0
WireConnection;15;1;6;0
WireConnection;11;0;10;0
WireConnection;11;1;6;0
WireConnection;17;0;15;0
WireConnection;12;0;11;0
WireConnection;18;0;12;0
WireConnection;18;1;20;0
WireConnection;18;2;21;0
WireConnection;19;0;17;0
WireConnection;19;1;20;0
WireConnection;19;2;21;0
WireConnection;22;0;18;0
WireConnection;23;0;19;0
WireConnection;24;0;22;0
WireConnection;24;1;23;0
WireConnection;29;0;30;0
WireConnection;25;0;24;0
WireConnection;27;0;29;0
WireConnection;27;1;25;0
WireConnection;0;0;27;0
ASEEND*/
//CHKSM=EA8F55E7B072F125B2D79FEC344BED8C5CF4D19A
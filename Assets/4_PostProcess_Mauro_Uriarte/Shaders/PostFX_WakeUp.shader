// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "PostFX_WakeUp"
{
	Properties
	{
		_MainTex ( "Screen", 2D ) = "black" {}
		_MainTex("Main Tex", 2D) = "white" {}
		_Wake("Wake", Float) = 1
		_BlurStrength("Blur Strength", Float) = 0.02

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
			
			uniform float _Wake;
			uniform float _BlurStrength;


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
				float2 texCoord2 = i.uv.xy * float2( 1,1 ) + float2( 0,0 );
				float temp_output_4_0 = ( 1.0 - _Wake );
				float temp_output_6_0 = ( temp_output_4_0 * _BlurStrength );
				float4 appendResult7 = (float4(temp_output_6_0 , temp_output_6_0 , 0.0 , 0.0));
				float3 desaturateInitialColor14 = ( ( tex2D( _MainTex, texCoord2 ) + tex2D( _MainTex, ( float4( texCoord2, 0.0 , 0.0 ) + appendResult7 ).xy ) ) * 0.5 ).rgb;
				float desaturateDot14 = dot( desaturateInitialColor14, float3( 0.299, 0.587, 0.114 ));
				float3 desaturateVar14 = lerp( desaturateInitialColor14, desaturateDot14.xxx, temp_output_4_0 );
				float lerpResult19 = lerp( 0.1 , 1.35 , _Wake);
				float2 texCoord27 = i.uv.xy * float2( 1,1 ) + float2( 0,0 );
				

				finalColor = float4( ( desaturateVar14 * saturate( ( ( lerpResult19 - distance( texCoord27 , float2( 0.5,0.5 ) ) ) * 6.0 ) ) ) , 0.0 );

				return finalColor;
			} 
			ENDCG 
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18900
235;73;1302;590;2487.051;239.1375;2.303056;True;False
Node;AmplifyShaderEditor.CommentaryNode;25;-2130.628,226.4861;Inherit;False;618;238;_Wake = qué tan despierto. Es el que maneja la fuerza del blur y la desaturación;2;4;3;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;26;-1676.057,-402.3508;Inherit;False;1579.208;581.4198;Lee la pantalla en dos posiciones y las promedia -> se despierta borroso y va pasando a nítido, el desaturate mezcla con gris;12;2;10;13;14;12;11;9;7;6;8;1;5;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;3;-1998,316;Inherit;False;Property;_Wake;Wake;1;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;4;-1720,315;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-1616.123,3.902135;Inherit;False;Property;_BlurStrength;Blur Strength;2;0;Create;True;0;0;0;False;0;False;0.02;0.02;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;6;-1430.103,25.95081;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;2;-1286.21,-149.9515;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;7;-1263.476,-9.615763;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;28;-1280.472,241.5583;Inherit;False;1099.929;680.4733;Mide la distancia de cada pixel al centro y compara con un radio que crece con wake (los ojos que se van abriendo);10;27;23;22;21;20;16;19;15;17;18;;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector2Node;15;-1140,560;Inherit;False;Constant;_Vector0;Vector 0;5;0;Create;True;0;0;0;False;0;False;0.5,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;18;-1140,820;Inherit;False;Constant;_Float4;Float 4;5;0;Create;True;0;0;0;False;0;False;1.35;1.35;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-1140,700;Inherit;False;Constant;_Float3;Float 3;5;0;Create;True;0;0;0;False;0;False;0.1;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;8;-1071.5,44.99663;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;27;-1243.132,343.9245;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;1;-1244.618,-355.1014;Inherit;True;Property;_MainTex;Main Tex;0;0;Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.DistanceOpNode;16;-940,460;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;19;-940,640;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;9;-917.3322,-314.7263;Inherit;True;Property;_TextureSample0;Texture Sample 0;3;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;10;-928.384,-86.15739;Inherit;True;Property;_TextureSample1;Texture Sample 1;4;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;20;-740,520;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;11;-600.9657,-173.015;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-595.8571,-30.88801;Inherit;False;Constant;_Float2;Float 2;5;0;Create;True;0;0;0;False;0;False;0.5;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-740,680;Inherit;False;Constant;_Float5;Float 5;5;0;Create;True;0;0;0;False;0;False;6;6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;-432.9533,-131.0585;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;-560,520;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;23;-400,520;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DesaturateOpNode;14;-280.9242,-111.0792;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;24;-97.61841,216.628;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;37.09166,222.5501;Float;False;True;-1;2;ASEMaterialInspector;0;2;PostFX_WakeUp;c71b220b631b6344493ea3cf87110c93;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;True;7;False;-1;False;True;0;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;4;0;3;0
WireConnection;6;0;4;0
WireConnection;6;1;5;0
WireConnection;7;0;6;0
WireConnection;7;1;6;0
WireConnection;8;0;2;0
WireConnection;8;1;7;0
WireConnection;16;0;27;0
WireConnection;16;1;15;0
WireConnection;19;0;17;0
WireConnection;19;1;18;0
WireConnection;19;2;3;0
WireConnection;9;0;1;0
WireConnection;9;1;2;0
WireConnection;10;0;1;0
WireConnection;10;1;8;0
WireConnection;20;0;19;0
WireConnection;20;1;16;0
WireConnection;11;0;9;0
WireConnection;11;1;10;0
WireConnection;12;0;11;0
WireConnection;12;1;13;0
WireConnection;22;0;20;0
WireConnection;22;1;21;0
WireConnection;23;0;22;0
WireConnection;14;0;12;0
WireConnection;14;1;4;0
WireConnection;24;0;14;0
WireConnection;24;1;23;0
WireConnection;0;0;24;0
ASEEND*/
//CHKSM=CAFFB9766F37306431626BD046209F77C804331D
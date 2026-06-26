// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Unlit/BackGround"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_Vel1("Vel1", Vector) = (0.5,0.5,0,0)
		_Vel2("Vel2", Vector) = (0.7,0.7,0,0)
		_Vel3("Vel3", Vector) = (0.1,0.1,0,0)
		_col1("col1", Color) = (0.2841108,0.2180046,0.6698113,0)
		_col2("col2", Color) = (0.2242941,0.1862317,0.4245283,0)
		_col3("col3", Color) = (0.3014982,0.2231666,0.5566038,0)
		_scale1("scale1", Float) = 0
		_scale2("scale2", Float) = 0
		_scale3("scale3", Float) = 0
		_Deformacion("Deformacion", Float) = 0.5
		_Progreso("Progreso", Range( 0 , 1.5)) = 0.532014
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows vertex:vertexDataFunc 
		struct Input
		{
			float4 screenPosition;
			float2 uv_texcoord;
		};

		uniform float2 _Vel1;
		uniform float _scale1;
		uniform float4 _col1;
		uniform float2 _Vel3;
		uniform float _scale3;
		uniform float4 _col3;
		uniform float2 _Vel2;
		uniform float _scale2;
		uniform float4 _col2;
		uniform float _Progreso;
		uniform float _Deformacion;
		uniform float _Cutoff = 0.5;


		inline float Dither4x4Bayer( int x, int y )
		{
			const float dither[ 16 ] = {
				 1,  9,  3, 11,
				13,  5, 15,  7,
				 4, 12,  2, 10,
				16,  8, 14,  6 };
			int r = y * 4 + x;
			return dither[r] / 16; // same # of instructions as pre-dividing due to compiler magic
		}


		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
		}


		float2 voronoihash39( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi39( float2 v, float time, inout float2 id, inout float2 mr, float smoothness )
		{
			float2 n = floor( v );
			float2 f = frac( v );
			float F1 = 8.0;
			float F2 = 8.0; float2 mg = 0;
			for ( int j = -1; j <= 1; j++ )
			{
				for ( int i = -1; i <= 1; i++ )
			 	{
			 		float2 g = float2( i, j );
			 		float2 o = voronoihash39( n + g );
					o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
					float d = 0.500 * pow( ( pow( abs( r.x ), 1 ) + pow( abs( r.y ), 1 ) ), 1.000 );
			 		if( d<F1 ) {
			 			F2 = F1;
			 			F1 = d; mg = g; mr = r; id = o;
			 		} else if( d<F2 ) {
			 			F2 = d;
			 		}
			 	}
			}
			return F1;
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float4 ase_screenPos = ComputeScreenPos( UnityObjectToClipPos( v.vertex ) );
			o.screenPosition = ase_screenPos;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float4 ase_screenPos = i.screenPosition;
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float2 clipScreen24 = ase_screenPosNorm.xy * _ScreenParams.xy;
			float dither24 = Dither4x4Bayer( fmod(clipScreen24.x, 4), fmod(clipScreen24.y, 4) );
			float2 panner5 = ( 1.0 * _Time.y * _Vel1 + i.uv_texcoord);
			float simplePerlin2D12 = snoise( panner5*_scale1 );
			float2 panner7 = ( 1.0 * _Time.y * _Vel3 + i.uv_texcoord);
			float simplePerlin2D14 = snoise( panner7*_scale3 );
			float2 panner6 = ( 1.0 * _Time.y * _Vel2 + i.uv_texcoord);
			float simplePerlin2D13 = snoise( panner6*_scale2 );
			dither24 = step( dither24, ( ( simplePerlin2D12 * _col1 ) + ( simplePerlin2D14 * _col3 ) + ( simplePerlin2D13 * _col2 ) ).r );
			float3 temp_cast_1 = (dither24).xxx;
			o.Albedo = temp_cast_1;
			o.Alpha = 1;
			float time39 = 0.0;
			float2 coords39 = i.uv_texcoord * 18.82;
			float2 id39 = 0;
			float2 uv39 = 0;
			float voroi39 = voronoi39( coords39, time39, id39, uv39, 0 );
			clip( step( _Progreso , ( ( voroi39 * _Deformacion ) + distance( i.uv_texcoord , float2( 0.5,0.5 ) ) ) ) - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18900
268;73;1030;644;1110.148;1084.685;4.461507;True;False
Node;AmplifyShaderEditor.Vector2Node;8;-891.7111,-25.03548;Inherit;False;Property;_Vel1;Vel1;1;0;Create;True;0;0;0;False;0;False;0.5,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;11;-880.5071,313.2848;Inherit;False;Property;_Vel3;Vel3;3;0;Create;True;0;0;0;False;0;False;0.1,0.1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;10;-879.6039,139.4247;Inherit;False;Property;_Vel2;Vel2;2;0;Create;True;0;0;0;False;0;False;0.7,0.7;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;2;-1136,144;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;26;-610.8479,-133.2434;Inherit;False;Property;_scale2;scale2;8;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-702.8479,-163.2434;Inherit;False;Property;_scale1;scale1;7;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;7;-695.2874,263.6936;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;27;-559.8479,-132.2434;Inherit;False;Property;_scale3;scale3;9;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;5;-691.1981,22.42043;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;6;-695.2872,145.1017;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;28;129.201,-221.7235;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NoiseGeneratorNode;12;-495.2609,-91.15816;Inherit;True;Simplex2D;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;14;-503.2979,288.2986;Inherit;True;Simplex2D;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;13;-501.6292,85.44437;Inherit;True;Simplex2D;False;False;2;0;FLOAT2;0,0;False;1;FLOAT;1.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;33;302.7076,-344.4774;Inherit;False;Property;_Deformacion;Deformacion;10;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VoronoiNode;39;293.7065,-610.6671;Inherit;True;0;4;1;0;1;False;1;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;18.82;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.ColorNode;15;-314.2261,-244.3592;Inherit;False;Property;_col1;col1;4;0;Create;True;0;0;0;False;0;False;0.2841108,0.2180046,0.6698113,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;18;-444.3648,502.9583;Inherit;False;Property;_col3;col3;6;0;Create;True;0;0;0;False;0;False;0.3014982,0.2231666,0.5566038,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;17;-334.4707,125.9187;Inherit;False;Property;_col2;col2;5;0;Create;True;0;0;0;False;0;False;0.2242941,0.1862317,0.4245283,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;30;188.7296,-98.07697;Inherit;False;Constant;_centro;centro ;9;0;Create;True;0;0;0;False;0;False;0.5,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;-172.1351,134.1743;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;-209.8894,296.4852;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DistanceOpNode;29;384.7487,-219.0323;Inherit;True;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;476.5123,-393.0543;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;19;-214.819,-7.682502;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;35;773.5591,-404.7317;Inherit;False;Property;_Progreso;Progreso;11;0;Create;True;0;0;0;False;0;False;0.532014;0;0;1.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;22;323.0842,112.5859;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;34;624.9498,-234.84;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;36;1045.44,-261.6768;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DitheringNode;24;681.8925,107.9343;Inherit;False;0;False;4;0;FLOAT;0;False;1;SAMPLER2D;;False;2;FLOAT4;0,0,0,0;False;3;SAMPLERSTATE;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1428.023,117.5621;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Unlit/BackGround;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;False;Transparent;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;7;0;2;0
WireConnection;7;2;11;0
WireConnection;5;0;2;0
WireConnection;5;2;8;0
WireConnection;6;0;2;0
WireConnection;6;2;10;0
WireConnection;12;0;5;0
WireConnection;12;1;25;0
WireConnection;14;0;7;0
WireConnection;14;1;27;0
WireConnection;13;0;6;0
WireConnection;13;1;26;0
WireConnection;20;0;13;0
WireConnection;20;1;17;0
WireConnection;21;0;14;0
WireConnection;21;1;18;0
WireConnection;29;0;28;0
WireConnection;29;1;30;0
WireConnection;32;0;39;0
WireConnection;32;1;33;0
WireConnection;19;0;12;0
WireConnection;19;1;15;0
WireConnection;22;0;19;0
WireConnection;22;1;21;0
WireConnection;22;2;20;0
WireConnection;34;0;32;0
WireConnection;34;1;29;0
WireConnection;36;0;35;0
WireConnection;36;1;34;0
WireConnection;24;0;22;0
WireConnection;0;0;24;0
WireConnection;0;10;36;0
ASEEND*/
//CHKSM=60BEEC4F273AEAB8F786BC5CD02444399D5153F4
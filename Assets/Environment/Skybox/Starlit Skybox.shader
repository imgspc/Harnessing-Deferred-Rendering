// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Skybox/Starlit Skybox"
{
	Properties
	{
		_CloudSpeed("Cloud Speed", Float) = 0.1
		_Cloud1("Cloud 1", CUBE) = "white" {}
		[HDR]_Cloud2("Cloud 2", CUBE) = "white" {}
		_BottomColor("Bottom Color", Color) = (0,0,0,0)
		_CloudBottomColor("Cloud Bottom Color", Color) = (0,0,0,0)
		_TopColor("Top Color", Color) = (1,1,1,0)
		_CloudTopColor("Cloud Top Color", Color) = (1,1,1,0)
		_CloudOpacity("Cloud Opacity", Float) = 0
		_CloudDistortion("Cloud Distortion", Float) = 1
		_HDR_Stars("HDR_Stars", CUBE) = "white" {}
		_StarsBrightness("Stars Brightness", Float) = 1
		_E_Moon("E_Moon", CUBE) = "black" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Unlit keepalpha noshadow 
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
			float3 viewDir;
		};

		uniform samplerCUBE _HDR_Stars;
		uniform float _StarsBrightness;
		uniform float4 _BottomColor;
		uniform float4 _TopColor;
		uniform samplerCUBE _E_Moon;
		uniform samplerCUBE _Cloud2;
		uniform float _CloudSpeed;
		uniform float _CloudDistortion;
		uniform samplerCUBE _Cloud1;
		uniform float _CloudOpacity;
		uniform float4 _CloudBottomColor;
		uniform float4 _CloudTopColor;


		float3 RotateAroundAxis( float3 center, float3 original, float3 u, float angle )
		{
			original -= center;
			float C = cos( angle );
			float S = sin( angle );
			float t = 1 - C;
			float m00 = t * u.x * u.x + C;
			float m01 = t * u.x * u.y - S * u.z;
			float m02 = t * u.x * u.z + S * u.y;
			float m10 = t * u.x * u.y + S * u.z;
			float m11 = t * u.y * u.y + C;
			float m12 = t * u.y * u.z - S * u.x;
			float m20 = t * u.x * u.z - S * u.y;
			float m21 = t * u.y * u.z + S * u.x;
			float m22 = t * u.z * u.z + C;
			float3x3 finalMatrix = float3x3( m00, m01, m02, m10, m11, m12, m20, m21, m22 );
			return mul( finalMatrix, original ) + center;
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


		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float mulTime110 = _Time.y * 0.005;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = Unity_SafeNormalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 rotatedValue109 = RotateAroundAxis( float3( 0,0,0 ), ase_worldViewDir, normalize( float3( 0,1,0 ) ), mulTime110 );
			float4 lerpResult85 = lerp( _BottomColor , _TopColor , i.uv_texcoord.y);
			float mulTime65 = _Time.y * ( ( 1.0 - _CloudSpeed ) * 0.015 );
			float3 rotatedValue67 = RotateAroundAxis( float3( 0,0,0 ), ase_worldViewDir, normalize( float3( 0,1,0 ) ), mulTime65 );
			float simplePerlin2D96 = snoise( i.uv_texcoord*5.0 );
			simplePerlin2D96 = simplePerlin2D96*0.5 + 0.5;
			float temp_output_100_0 = ( simplePerlin2D96 * _CloudDistortion );
			float mulTime28 = _Time.y * ( _CloudSpeed * 0.01 );
			float3 rotatedValue30 = RotateAroundAxis( float3( 0,0,0 ), ase_worldViewDir, normalize( float3( 0,1,0 ) ), mulTime28 );
			float4 lerpResult113 = lerp( _CloudBottomColor , _CloudTopColor , i.uv_texcoord.y);
			o.Emission = ( ( texCUBE( _HDR_Stars, rotatedValue109 ) * _StarsBrightness ) + ( ( lerpResult85 + texCUBE( _E_Moon, i.viewDir ) ) + ( ( ( texCUBE( _Cloud2, ( rotatedValue67 + temp_output_100_0 ) ) + texCUBE( _Cloud1, ( rotatedValue30 + temp_output_100_0 ) ) ) * _CloudOpacity ) * lerpResult113 ) ) ).rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17101
47;941;1335;480;250.2338;48.62833;1.950015;True;True
Node;AmplifyShaderEditor.RangedFloatNode;32;-1800.635,-41.96711;Inherit;False;Property;_CloudSpeed;Cloud Speed;2;0;Create;True;0;0;False;0;0.1;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;63;-1564.746,283.7899;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-1535.606,-32.78862;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;64;-1387.711,285.9252;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.015;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;83;843.0834,839.5287;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NoiseGeneratorNode;96;-711.2424,548.5405;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;10;-1208.998,70.34396;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;66;-1208.658,395.1279;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleTimeNode;65;-1216.866,284.969;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;28;-1217.206,-39.81492;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;98;-857.0895,131.1938;Inherit;False;Property;_CloudDistortion;Cloud Distortion;11;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RotateAboutAxisNode;67;-987.1177,255.5298;Inherit;False;True;4;0;FLOAT3;0,1,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;1,1,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RotateAboutAxisNode;30;-987.4576,-69.25409;Inherit;False;True;4;0;FLOAT3;0,1,0;False;1;FLOAT;0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;1,1,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;100;-654.7886,141.7452;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;99;-504.7654,368.8076;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;101;-565.5858,-16.38732;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;52;-403.5984,-96.6498;Inherit;True;Property;_Cloud1;Cloud 1;4;0;Create;True;0;0;False;0;e99d8fb7eac60474dbee600585991a7a;e99d8fb7eac60474dbee600585991a7a;True;0;False;white;Auto;False;Object;-1;Auto;Cube;6;0;SAMPLER2D;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;94;-336.1416,274.5496;Inherit;True;Property;_Cloud2;Cloud 2;5;1;[HDR];Create;True;0;0;False;0;5c61b7a0c7c4d0f42901b260d4fca7a3;e99d8fb7eac60474dbee600585991a7a;True;0;False;white;Auto;False;Object;-1;Auto;Cube;6;0;SAMPLER2D;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;111;644.0401,159.8787;Inherit;False;Property;_CloudBottomColor;Cloud Bottom Color;7;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;108;600.2311,-295.5164;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;90;504.2865,80.70198;Inherit;False;Property;_CloudOpacity;Cloud Opacity;10;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;110;542.8672,-399.2668;Inherit;False;1;0;FLOAT;0.005;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;112;648.5899,336.7944;Inherit;False;Property;_CloudTopColor;Cloud Top Color;9;0;Create;True;0;0;False;0;1,1,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;86;843.712,480.035;Inherit;False;Property;_BottomColor;Bottom Color;6;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;115;543.9181,500.4077;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ColorNode;88;848.2617,658.5342;Inherit;False;Property;_TopColor;Top Color;8;0;Create;True;0;0;False;0;1,1,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;95;17.76002,157.5764;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;114;1118.633,379.4103;Inherit;True;Property;_E_Moon;E_Moon;14;0;Create;True;0;0;False;0;3da881e943f68b240a521a90d3626ce2;3da881e943f68b240a521a90d3626ce2;True;0;False;white;Auto;False;Object;-1;Auto;Cube;6;0;SAMPLER2D;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;113;1016.818,297.0092;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;89;736.6274,-30.89485;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RotateAboutAxisNode;109;822.9489,-435.1145;Inherit;False;True;4;0;FLOAT3;0,1,0;False;1;FLOAT;90;False;2;FLOAT3;0,0,0;False;3;FLOAT3;1,1,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;85;1216.49,617.1655;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;116;1475.078,563.4236;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;107;1512.012,28.72864;Inherit;False;Property;_StarsBrightness;Stars Brightness;13;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;102;1220.281,-264.6427;Inherit;True;Property;_HDR_Stars;HDR_Stars;12;0;Create;True;0;0;False;0;cace64c1ab73bb14db26d75ba61b0690;cace64c1ab73bb14db26d75ba61b0690;True;0;False;white;Auto;False;Object;-1;Auto;Cube;6;0;SAMPLER2D;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;92;1295.09,38.97578;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;106;1643.463,-92.61096;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;93;1451.477,336.761;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;171.1844,-644.5772;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;8;-380.9813,-432.3928;Inherit;True;Property;_Stars;Stars;0;1;[HDR];Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Cube;6;0;SAMPLER2D;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;45;-5.489433,-202.4975;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;37;-307.0263,-523.889;Inherit;False;Property;_Exposure;Exposure;3;0;Create;True;0;0;False;0;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;-226.4303,-739.5615;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-839.7751,693.7778;Inherit;False;Property;_Float0;Float 0;1;0;Create;True;0;0;False;0;0.5;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;40;-348.1675,-638.9908;Inherit;False;Constant;_Float1;Float 1;4;0;Create;True;0;0;False;0;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;105;1805.368,202.0156;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;14;-999.6505,757.3313;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;2302.149,123.5902;Float;False;True;2;ASEMaterialInspector;0;0;Unlit;Skybox/Starlit Skybox;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;False;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;63;0;32;0
WireConnection;41;0;32;0
WireConnection;64;0;63;0
WireConnection;96;0;83;0
WireConnection;65;0;64;0
WireConnection;28;0;41;0
WireConnection;67;1;65;0
WireConnection;67;3;66;0
WireConnection;30;1;28;0
WireConnection;30;3;10;0
WireConnection;100;0;96;0
WireConnection;100;1;98;0
WireConnection;99;0;67;0
WireConnection;99;1;100;0
WireConnection;101;0;30;0
WireConnection;101;1;100;0
WireConnection;52;1;101;0
WireConnection;94;1;99;0
WireConnection;95;0;94;0
WireConnection;95;1;52;0
WireConnection;114;1;115;0
WireConnection;113;0;111;0
WireConnection;113;1;112;0
WireConnection;113;2;83;2
WireConnection;89;0;95;0
WireConnection;89;1;90;0
WireConnection;109;1;110;0
WireConnection;109;3;108;0
WireConnection;85;0;86;0
WireConnection;85;1;88;0
WireConnection;85;2;83;2
WireConnection;116;0;85;0
WireConnection;116;1;114;0
WireConnection;102;1;109;0
WireConnection;92;0;89;0
WireConnection;92;1;113;0
WireConnection;106;0;102;0
WireConnection;106;1;107;0
WireConnection;93;0;116;0
WireConnection;93;1;92;0
WireConnection;36;0;45;0
WireConnection;36;1;37;0
WireConnection;45;0;8;0
WireConnection;39;1;40;0
WireConnection;105;0;106;0
WireConnection;105;1;93;0
WireConnection;0;2;105;0
ASEEND*/
//CHKSM=9BEEE383CC6B8C422BA124D0D6E25968B0848A6D
// Made with Amplify Shader Editor v1.9.8.1
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Saphi/FPV/Surface"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,0)
		_SpecColor("Specular", Color) = (1,1,1,0)
		_EmissionColor("Emission", Color) = (1,1,1,0)
		_HueShift("HueShift", Float) = 0
		_ColorMultiplier("ColorMultiplier", Float) = 1
		_Emission("Emission", Float) = 0
		_Saturation("Saturation", Float) = 1
		_ShowRendering("_ShowRendering", Float) = 0
		_Value("Value", Float) = 1
		_ShowMain("_ShowMain", Float) = 0
		_Alpha("Alpha", Range( 0 , 1)) = 1
		_Glossiness("Smoothness", Range( 0 , 1)) = 1
		_BlendMode("BlendMode", Float) = 0
		[Enum(UnityEngine.Rendering.BlendMode)]_BlendModeDst("BlendModeDst", Float) = 10
		[Enum(UnityEngine.Rendering.BlendMode)]_BlendModeSrc("BlendModeSrc", Float) = 5
		[Enum(UnityEngine.Rendering.CullMode)]_Culling("Culling", Float) = 2
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Custom"  "Queue" = "Transparent+0" "IsEmissive" = "true"  }
		Cull [_Culling]
		ZWrite On
		ZTest LEqual
		Blend [_BlendModeSrc] [_BlendModeDst]
		
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 4.0
		#define ASE_VERSION 19801
		struct Input
		{
			half filler;
		};

		uniform float _BlendModeDst;
		uniform float _BlendModeSrc;
		uniform float _BlendMode;
		uniform float _ShowMain;
		uniform float _ShowRendering;
		uniform float _Culling;
		uniform float4 _Color;
		uniform float _HueShift;
		uniform float _Saturation;
		uniform float _Value;
		uniform float _ColorMultiplier;
		uniform float4 _EmissionColor;
		uniform float _Emission;
		uniform float _Glossiness;
		uniform float _Alpha;


		float3 HSVToRGB( float3 c )
		{
			float4 K = float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
			float3 p = abs( frac( c.xxx + K.xyz ) * 6.0 - K.www );
			return c.z * lerp( K.xxx, saturate( p - K.xxx ), c.y );
		}


		float3 RGBToHSV(float3 c)
		{
			float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
			float4 p = lerp( float4( c.bg, K.wz ), float4( c.gb, K.xy ), step( c.b, c.g ) );
			float4 q = lerp( float4( p.xyw, c.r ), float4( c.r, p.yzx ), step( p.x, c.r ) );
			float d = q.x - min( q.w, q.y );
			float e = 1.0e-10;
			return float3( abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
		}

		void surf( Input i , inout SurfaceOutputStandardSpecular o )
		{
			float3 hsvTorgb5 = RGBToHSV( _Color.rgb );
			float3 hsvTorgb4 = HSVToRGB( float3(( hsvTorgb5.x + _HueShift ),( hsvTorgb5.y * _Saturation ),( hsvTorgb5.z * _Value )) );
			o.Albedo = ( hsvTorgb4 * _ColorMultiplier );
			float3 hsvTorgb44 = RGBToHSV( _EmissionColor.rgb );
			float3 hsvTorgb46 = HSVToRGB( float3(( hsvTorgb44.x + _HueShift ),( hsvTorgb44.y * _Saturation ),( hsvTorgb44.z * _Value )) );
			o.Emission = ( ( hsvTorgb46 * _ColorMultiplier ) * _Emission );
			float3 hsvTorgb40 = RGBToHSV( _SpecColor.rgb );
			float3 hsvTorgb39 = HSVToRGB( float3(( hsvTorgb40.x + _HueShift ),( hsvTorgb40.y * _Saturation ),( hsvTorgb40.z * _Value )) );
			o.Specular = ( hsvTorgb39 * _ColorMultiplier );
			o.Smoothness = _Glossiness;
			o.Alpha = _Alpha;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardSpecular keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float3 worldPos : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				SurfaceOutputStandardSpecular o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandardSpecular, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "Saphi.FPVShader.FPVSurfaceShaderUI"
}
/*ASEBEGIN
Version=19801
Node;AmplifyShaderEditor.ColorNode;43;-1360,352;Inherit;False;Property;_EmissionColor;Emission;2;0;Create;False;0;0;0;False;0;False;1,1,1,0;0,0,0,0;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.RGBToHSVNode;44;-1040,368;Inherit;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;7;-1824,416;Inherit;False;Property;_HueShift;HueShift;3;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-1824,608;Inherit;False;Property;_Value;Value;9;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;37;-1344,720;Inherit;False;Property;_SpecColor;Specular;1;0;Fetch;False;0;0;0;True;0;False;1,1,1,0;0,0,0,0;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.ColorNode;2;-1296,-80;Inherit;False;Property;_Color;Color;0;0;Create;True;0;0;0;False;0;False;1,1,1,0;0,0,0,0;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.RangedFloatNode;22;-1824,512;Inherit;False;Property;_Saturation;Saturation;6;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RGBToHSVNode;5;-1024,-64;Inherit;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RGBToHSVNode;40;-1024,736;Inherit;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;48;-752,592;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;45;-736,368;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;47;-752,480;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;6;-768,-64;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;-784,48;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;-784,160;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;38;-720,736;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-736,848;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;42;-736,960;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.HSVToRGBNode;46;-576,368;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;8;32,176;Inherit;False;Property;_ColorMultiplier;ColorMultiplier;4;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.HSVToRGBNode;4;-608,-64;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.HSVToRGBNode;39;-560,736;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;50;512,368;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;52;512,496;Inherit;False;Property;_Emission;Emission;5;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;9;448,-64;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;49;512,736;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;704,368;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;35;832,96;Inherit;False;Property;_Glossiness;Smoothness;12;0;Create;False;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;59;-480,-416;Inherit;False;Property;_BlendModeDst;BlendModeDst;14;1;[Enum];Create;True;0;1;Option1;0;1;UnityEngine.Rendering.BlendMode;True;0;False;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;58;-656,-416;Inherit;False;Property;_BlendModeSrc;BlendModeSrc;15;1;[Enum];Create;True;0;1;Option1;0;1;UnityEngine.Rendering.BlendMode;True;0;False;5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;57;-832,-416;Inherit;False;Property;_BlendMode;BlendMode;13;0;Create;True;0;0;0;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;55;-160,-384;Inherit;False;Property;_ShowMain;_ShowMain;10;0;Create;True;0;0;0;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;54;128,-400;Inherit;False;Property;_ShowRendering;_ShowRendering;8;0;Create;True;0;0;0;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;60;-656,-320;Inherit;False;Property;_Culling;Culling;16;1;[Enum];Create;False;0;1;Option1;0;1;UnityEngine.Rendering.CullMode;True;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;34;1120,560;Inherit;False;Property;_Alpha;Alpha;11;0;Create;True;0;0;0;False;0;False;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1504,-64;Float;False;True;-1;4;Saphi.FPVShader.FPVSurfaceShaderUI;0;0;StandardSpecular;Saphi/FPV/Surface;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;1;False;;3;False;;False;0;False;;0;False;;False;0;Custom;0.5;True;True;0;True;Custom;;Transparent;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;2;5;True;_BlendModeSrc;10;True;_BlendModeDst;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;7;-1;-1;-1;0;False;0;0;True;_Culling;-1;0;False;;0;0;0;False;0.1;True;_ChromaticAberration;0;False;;False;17;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;44;0;43;5
WireConnection;5;0;2;5
WireConnection;40;0;37;5
WireConnection;48;0;44;3
WireConnection;48;1;24;0
WireConnection;45;0;44;1
WireConnection;45;1;7;0
WireConnection;47;0;44;2
WireConnection;47;1;22;0
WireConnection;6;0;5;1
WireConnection;6;1;7;0
WireConnection;30;0;5;2
WireConnection;30;1;22;0
WireConnection;31;0;5;3
WireConnection;31;1;24;0
WireConnection;38;0;40;1
WireConnection;38;1;7;0
WireConnection;41;0;40;2
WireConnection;41;1;22;0
WireConnection;42;0;40;3
WireConnection;42;1;24;0
WireConnection;46;0;45;0
WireConnection;46;1;47;0
WireConnection;46;2;48;0
WireConnection;4;0;6;0
WireConnection;4;1;30;0
WireConnection;4;2;31;0
WireConnection;39;0;38;0
WireConnection;39;1;41;0
WireConnection;39;2;42;0
WireConnection;50;0;46;0
WireConnection;50;1;8;0
WireConnection;9;0;4;0
WireConnection;9;1;8;0
WireConnection;49;0;39;0
WireConnection;49;1;8;0
WireConnection;51;0;50;0
WireConnection;51;1;52;0
WireConnection;0;0;9;0
WireConnection;0;2;51;0
WireConnection;0;3;49;0
WireConnection;0;4;35;0
WireConnection;0;9;34;0
ASEEND*/
//CHKSM=335B6160255B23E463BEA90F8DAB1BFC726AFB4F
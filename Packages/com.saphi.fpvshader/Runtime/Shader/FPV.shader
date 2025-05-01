// Made with Amplify Shader Editor v1.9.8.1
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Saphi/FPV"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,0)
		[HDR]_ColorHDR("ColorHDR", Color) = (1,1,1,0)
		_HueShift("HueShift", Float) = 0
		_ColorMultiplier("ColorMultiplier", Float) = 1
		[Toggle]_UseHDR("UseHDR", Float) = 0
		_Saturation("Saturation", Float) = 1
		_Value("Value", Float) = 1
		_Visibility("Visibility", Float) = 1
		_ShowRendering("_ShowRendering", Float) = 0
		_ShowMain("_ShowMain", Float) = 0
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Overlay"  "Queue" = "Transparent+0" "IsEmissive" = "true"  }
		Cull Off
		ZWrite Off
		ZTest Always
		Blend DstColor Zero
		
		CGPROGRAM
		#pragma target 4.0
		#define ASE_VERSION 19801
		#pragma surface surf Unlit keepalpha noshadow noambient novertexlights nolightmap  nodynlightmap nodirlightmap nofog nometa noforwardadd 
		struct Input
		{
			half filler;
		};

		uniform float _ShowRendering;
		uniform float _ShowMain;
		uniform float _UseHDR;
		uniform float4 _Color;
		uniform float4 _ColorHDR;
		uniform float _HueShift;
		uniform float _Saturation;
		uniform float _Value;
		uniform float _ColorMultiplier;
		uniform float _Visibility;
		uniform float _VRChatCameraMode;
		uniform float _VRChatMirrorMode;


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

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float4 color27 = IsGammaSpace() ? float4(1,1,1,0) : float4(1,1,1,0);
			float3 hsvTorgb5 = RGBToHSV( (( _UseHDR )?( _ColorHDR.rgb ):( _Color.rgb )) );
			float3 hsvTorgb4 = HSVToRGB( float3(( hsvTorgb5.x + _HueShift ),( hsvTorgb5.y * _Saturation ),( hsvTorgb5.z * _Value )) );
			float3 lerpResult28 = lerp( color27.rgb , ( hsvTorgb4 * _ColorMultiplier ) , _Visibility);
			clip( 0.0 - ( _VRChatCameraMode + _VRChatMirrorMode ));
			o.Emission = lerpResult28;
			o.Alpha = 1;
		}

		ENDCG
	}
	CustomEditor "Saphi.FPVShader.FPVShaderUI"
}
/*ASEBEGIN
Version=19801
Node;AmplifyShaderEditor.ColorNode;26;-816,96;Inherit;False;Property;_ColorHDR;ColorHDR;1;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,0;0,0,0,0;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.ColorNode;2;-816,-128;Inherit;False;Property;_Color;Color;0;0;Create;True;0;0;0;False;0;False;1,1,1,0;0,0,0,0;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.ToggleSwitchNode;25;-528,-64;Inherit;False;Property;_UseHDR;UseHDR;5;0;Create;True;0;0;0;False;0;False;0;True;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RGBToHSVNode;5;-256,-64;Inherit;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;22;-256,208;Inherit;False;Property;_Saturation;Saturation;6;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;24;-256,304;Inherit;False;Property;_Value;Value;7;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-256,112;Inherit;False;Property;_HueShift;HueShift;2;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;6;0,-64;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;-64,176;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;-64,288;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.HSVToRGBNode;4;160,-64;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;8;192,80;Inherit;False;Property;_ColorMultiplier;ColorMultiplier;3;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;27;320,-272;Inherit;False;Constant;_NormalColors;NormalColors;8;0;Create;True;0;0;0;False;0;False;1,1,1,0;0,0,0,0;True;True;0;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.RangedFloatNode;29;416,112;Inherit;False;Property;_Visibility;Visibility;8;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;14;176,288;Inherit;False;Global;_VRChatCameraMode;_VRChatCameraMode;4;1;[HideInInspector];Create;False;0;0;0;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;15;208,368;Inherit;False;Global;_VRChatMirrorMode;_VRChatMirrorMode;6;1;[HideInInspector];Create;False;0;0;0;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;9;416,-64;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;20;448,288;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;28;624,-80;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ClipNode;11;800,-48;Inherit;True;3;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;32;-476.1934,681.6935;Inherit;False;Property;_ShowRendering;_ShowRendering;9;0;Create;True;0;0;0;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;33;-464,768;Inherit;False;Property;_ShowMain;_ShowMain;10;0;Create;True;0;0;0;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1216,-128;Float;False;True;-1;4;Saphi.FPVShader.FPVShaderUI;0;0;Unlit;Saphi/FPV;False;False;False;False;True;True;True;True;True;True;True;True;False;False;False;False;False;False;False;False;False;Off;2;False;;7;False;;False;0;False;;0;False;;False;0;Custom;0.5;True;False;0;True;Overlay;;Transparent;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;False;6;2;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;4;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;16;FLOAT4;0,0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;25;0;2;5
WireConnection;25;1;26;5
WireConnection;5;0;25;0
WireConnection;6;0;5;1
WireConnection;6;1;7;0
WireConnection;30;0;5;2
WireConnection;30;1;22;0
WireConnection;31;0;5;3
WireConnection;31;1;24;0
WireConnection;4;0;6;0
WireConnection;4;1;30;0
WireConnection;4;2;31;0
WireConnection;9;0;4;0
WireConnection;9;1;8;0
WireConnection;20;0;14;0
WireConnection;20;1;15;0
WireConnection;28;0;27;5
WireConnection;28;1;9;0
WireConnection;28;2;29;0
WireConnection;11;0;28;0
WireConnection;11;2;20;0
WireConnection;0;2;11;0
ASEEND*/
//CHKSM=334DF3A3ECEC668424E8E67CD205D40CCA5B7B37
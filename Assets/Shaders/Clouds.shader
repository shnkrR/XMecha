﻿Shader "Environment/Clouds" {
Properties {
	_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
	_MainTex ("Particle Texture", 2D) = "white" {}
	_InvFade ("Soft Particles Factor", Range(0.01,3.0)) = 1.0
}

Category {
	Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
	Blend SrcAlpha OneMinusSrcAlpha
	AlphaTest Greater .01
	ColorMask RGB
	ZWrite Off
	BindChannels {
		Bind "Color", color
		Bind "Vertex", vertex
		Bind "TexCoord", texcoord
	}
	
	// ---- Fragment program cards
	SubShader {
		Pass {
		
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma multi_compile_particles
			
			#include "HLSLSupport.cginc"
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			sampler2D _MainTex;
			fixed4 _TintColor;
			
			struct appdata_t {
				float4 vertex : POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
				half3 normal : NORMAL;
			};

			struct v2f {
				float4 vertex : POSITION;
				fixed4 color : COLOR;
				float2 texcoord : TEXCOORD0;
				half height : TEXCOORD1;	
				half3 vWorldNormal : TEXCOORD2;			
			};
			
			float4 _MainTex_ST;

			v2f vert (appdata_t v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				
				o.color = v.color;
				o.texcoord = TRANSFORM_TEX(v.texcoord,_MainTex);

				float3 vWorldPos = mul(_Object2World, v.vertex);				
				o.height = vWorldPos.y;
				o.vWorldNormal = UnityObjectToWorldNormal(v.normal);

				return o;
			}

			sampler2D _CameraDepthTexture;
			float _InvFade;
			
			fixed4 frag (v2f i) : COLOR
			{				

				half sunDir = dot(normalize(i.vWorldNormal), _WorldSpaceLightPos0.xyz) * 0.5 + 0.5;
				
				float height = saturate((i.height - 40) / 500);
				//return height;
				_TintColor.a = saturate(lerp(0, _TintColor.a, saturate(height))) ;
				_TintColor.a = _TintColor.a * _TintColor.a;
				
				half4 finalColor = 2.0f * i.color * _TintColor * tex2D(_MainTex, i.texcoord);
				finalColor.rgb = lerp(finalColor.rgb, finalColor.rgb * _LightColor0.rgb, saturate(2 - saturate(finalColor.a * sunDir * 100)));
				
				return finalColor;
			}
			ENDCG 
		}
	} 	
	
}
}
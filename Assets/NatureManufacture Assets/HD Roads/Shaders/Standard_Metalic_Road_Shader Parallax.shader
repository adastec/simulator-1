Shader "NatureManufacture Shaders/HD SRP Road Material"
{
	/*CustomNodeUI:HDPBR*/
    Properties
    {
		_TextureSample1("Second Road Noise Mask", 2D) = "white" {}
		_SecondRoadNoiseMaskPower("Second Road Noise Mask Power", Range( 0 , 10)) = 0.1
		_SecondRoadNoiseMaskTreshold("Second Road Noise Mask Treshold", Range( 0 , 10)) = 1
		_MainRoadColor("Main Road Color", Color) = (1,1,1,1)
		_MainRoadBrightness("Main Road Brightness", Float) = 1
		_MainTex("Main Road Albedo_T", 2D) = "white" {}
		_MainRoadAlphaCutOut("Main Road Alpha CutOut", Range( 0 , 2)) = 1
		_BumpMap("Main Road Normal", 2D) = "bump" {}
		_BumpScale("Main Road BumpScale", Range( 0 , 5)) = 0
		_MetalicRAmbientOcclusionGHeightBEmissionA("Main Road Metallic (R) Ambient Occlusion (G) Height (B) Smoothness (A)", 2D) = "white" {}
		_MainRoadMetalicPower("Main Road Metalic Power", Range( 0 , 2)) = 0
		_MainRoadAmbientOcclusionPower("Main Road Ambient Occlusion Power", Range( 0 , 1)) = 1
		_MainRoadSmoothnessPower("Main Road Smoothness Power", Range( 0 , 2)) = 1
		_SecondRoadColor("Second Road Color", Color) = (1,1,1,1)
		_SecondRoadBrightness("Second Road Brightness", Float) = 1
		_TextureSample3("Second Road Albedo_T", 2D) = "white" {}
		_MainRoadParallaxPower("Main Road Parallax Power", Range( 0 , 0.1)) = 0
		[Toggle(_IGNORESECONDROADALPHA_ON)] _IgnoreSecondRoadAlpha("Ignore Second Road Alpha", Float) = 0
		_SecondRoadAlphaCutOut("Second Road Alpha CutOut", Range( 0 , 2)) = 1
		_SecondRoadNormal("Second Road Normal", 2D) = "bump" {}
		_SecondRoadNormalScale("Second Road Normal Scale", Range( 0 , 5)) = 0
		_SecondRoadNormalBlend("Second Road Normal Blend", Range( 0 , 1)) = 0.8
		_SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA("Second Road Metallic (R) Ambient occlusion (G) Height (B) Smoothness (A)", 2D) = "white" {}
		_SecondRoadMetalicPower("Second Road Metalic Power", Range( 0 , 2)) = 1
		_SecondRoadAmbientOcclusionPower("Second Road Ambient Occlusion Power", Range( 0 , 1)) = 1
		_SecondRoadSmoothnessPower("Second Road Smoothness Power", Range( 0 , 2)) = 1
		_DetailMask("DetailMask (A)", 2D) = "white" {}
		_DetailAlbedoMap("DetailAlbedoMap", 2D) = "black" {}
		_DetailAlbedoPower("Main Road Detail Albedo Power", Range( 0 , 2)) = 0
		_Float2("Second Road Detail Albedo Power", Range( 0 , 2)) = 0
		_DetailNormalMap("DetailNormalMap", 2D) = "bump" {}
		_DetailNormalMapScale("Main Road DetailNormalMapScale", Range( 0 , 5)) = 0
		_Float1("Second Road DetailNormalMapScale", Range( 0 , 5)) = 0
		_SecondRoadParallaxPower("Second Road Parallax Power", Range( -0.1 , 0.1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
    }

    SubShader
    {
		
        Tags { "RenderPipeline"="HDRenderPipeline" "RenderType"="Opaque" "Queue"="Geometry" }
        
		Cull Back
		Blend One Zero
		ZTest LEqual
		ZWrite On
		ZClip [_ZClip]

		HLSLINCLUDE
		#pragma target 4.5
		#pragma only_renderers d3d11 ps4 xboxone vulkan metal switch
		#pragma multi_compile_instancing
		#pragma instancing_options renderinglayer
		#pragma multi_compile _ LOD_FADE_CROSSFADE

		struct GlobalSurfaceDescription
		{
			//Standard
			float3 Albedo;
			float3 Normal;
			float3 Specular;
			float Metallic;
			float3 Emission;
			float Smoothness;
			float Occlusion;
			float Alpha;
			float AlphaClipThreshold;
			float CoatMask;
			//SSS
			float DiffusionProfile;
			float SubsurfaceMask;
			//Transmission
			float Thickness;
			// Anisotropic
			float3 TangentWS;
			float Anisotropy; 
			//Iridescence
			float IridescenceThickness;
			float IridescenceMask;
			// Transparency
			float IndexOfRefraction;
			float3 TransmittanceColor;
			float TransmittanceAbsorptionDistance;
			float TransmittanceMask;
		};

		struct AlphaSurfaceDescription
		{
			float Alpha;
			float AlphaClipThreshold;
		};

		ENDHLSL
		
        Pass
        {
			
            Name "GBuffer"
            Tags { "LightMode"="GBuffer" }    
			Stencil
			{
				Ref 2
				WriteMask 7
				Comp Always
				Pass Replace
				Fail Keep
				ZFail Keep
			}

     
            HLSLPROGRAM
        	//#define UNITY_MATERIAL_LIT
			#pragma vertex Vert
			#pragma fragment Frag
			
			#define ASE_SRP_VERSION 51000
			#define _NORMALMAP 1
			#define _ALPHATEST_ON 1
			#pragma shader_feature _IGNORESECONDROADALPHA_ON

		
        
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/NormalSurfaceGradient.hlsl"        
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/FragInputs.hlsl"
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPass.cs.hlsl"
        
            #define SHADERPASS SHADERPASS_GBUFFER
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ DYNAMICLIGHTMAP_ON
            #pragma multi_compile _ SHADOWS_SHADOWMASK
			#pragma multi_compile DECALS_OFF DECALS_3RT DECALS_4RT
			#pragma multi_compile _ LIGHT_LAYERS
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define ATTRIBUTES_NEED_TEXCOORD2
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_TANGENT_TO_WORLD
            #define VARYINGS_NEED_TEXCOORD1
            #define VARYINGS_NEED_TEXCOORD2
        
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Material.hlsl"
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/Lit.hlsl"
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/BuiltinUtilities.hlsl"
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/MaterialUtilities.hlsl"
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Decal/DecalUtilities.hlsl"
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/LitDecalData.hlsl"
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderGraphFunctions.hlsl"

            struct AttributesMesh 
			{
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float4 uv1 : TEXCOORD1;
                float4 uv2 : TEXCOORD2;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_color : COLOR;
				#if UNITY_ANY_INSTANCING_ENABLED
				uint instanceID : INSTANCEID_SEMANTIC;
				#endif
            };

            struct PackedVaryingsMeshToPS 
			{
                float4 positionCS : SV_Position;
                float3 interp00 : TEXCOORD0;
                float3 interp01 : TEXCOORD1;
                float4 interp02 : TEXCOORD2;
                float4 interp03 : TEXCOORD3;
				float4 interp04 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				float4 ase_texcoord6 : TEXCOORD6;
				float4 ase_color : COLOR;
				#if UNITY_ANY_INSTANCING_ENABLED
				uint instanceID : INSTANCEID_SEMANTIC;
				#endif
				UNITY_VERTEX_OUTPUT_STEREO
            };
        
			float _MainRoadBrightness;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _MetalicRAmbientOcclusionGHeightBEmissionA;
			float4 _MetalicRAmbientOcclusionGHeightBEmissionA_ST;
			float _MainRoadParallaxPower;
			float4 _MainRoadColor;
			float _DetailAlbedoPower;
			sampler2D _DetailAlbedoMap;
			float4 _DetailAlbedoMap_ST;
			sampler2D _DetailMask;
			float4 _DetailMask_ST;
			float _SecondRoadBrightness;
			sampler2D _TextureSample3;
			float4 _TextureSample3_ST;
			sampler2D _SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA;
			float4 _SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA_ST;
			float _SecondRoadParallaxPower;
			float4 _SecondRoadColor;
			float _Float2;
			sampler2D _TextureSample1;
			float4 _TextureSample1_ST;
			float _SecondRoadNoiseMaskPower;
			float _SecondRoadNoiseMaskTreshold;
			float _BumpScale;
			sampler2D _BumpMap;
			float _DetailNormalMapScale;
			sampler2D _DetailNormalMap;
			float _SecondRoadNormalScale;
			sampler2D _SecondRoadNormal;
			float _SecondRoadNormalBlend;
			float _Float1;
			float _MainRoadMetalicPower;
			float _SecondRoadMetalicPower;
			float _MainRoadSmoothnessPower;
			float _SecondRoadSmoothnessPower;
			float _MainRoadAmbientOcclusionPower;
			float _SecondRoadAmbientOcclusionPower;
			float _MainRoadAlphaCutOut;
			float _SecondRoadAlphaCutOut;
			
			
			void BuildSurfaceData ( FragInputs fragInputs, GlobalSurfaceDescription surfaceDescription, float3 V, PositionInputs posInput, out SurfaceData surfaceData )
			{
				ZERO_INITIALIZE ( SurfaceData, surfaceData );

				float3 normalTS = float3( 0.0f, 0.0f, 1.0f );
				normalTS = surfaceDescription.Normal;
				float3 doubleSidedConstants = float3(1.0, 1.0, 1.0);
				GetNormalWS ( fragInputs, normalTS, surfaceData.normalWS ,doubleSidedConstants);

				surfaceData.ambientOcclusion = 1.0f;

				surfaceData.baseColor = surfaceDescription.Albedo;
				surfaceData.perceptualSmoothness = surfaceDescription.Smoothness;
				surfaceData.ambientOcclusion = surfaceDescription.Occlusion;

				surfaceData.materialFeatures = MATERIALFEATUREFLAGS_LIT_STANDARD;

#ifdef _MATERIAL_FEATURE_SPECULAR_COLOR
				surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_SPECULAR_COLOR;
				surfaceData.specularColor = surfaceDescription.Specular;
#else
				surfaceData.metallic = surfaceDescription.Metallic;
#endif

#if defined(_MATERIAL_FEATURE_SUBSURFACE_SCATTERING) || defined(_MATERIAL_FEATURE_TRANSMISSION)
				surfaceData.diffusionProfileHash = asuint (surfaceDescription.DiffusionProfile);
#endif

#ifdef _MATERIAL_FEATURE_SUBSURFACE_SCATTERING
				surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_SUBSURFACE_SCATTERING;
				surfaceData.subsurfaceMask = surfaceDescription.SubsurfaceMask;
#else
				surfaceData.subsurfaceMask = 1.0f;
#endif

#ifdef _MATERIAL_FEATURE_TRANSMISSION
				surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_TRANSMISSION;
				surfaceData.thickness = surfaceDescription.Thickness;
#endif

				surfaceData.tangentWS = normalize ( fragInputs.worldToTangent[ 0 ].xyz );
				surfaceData.tangentWS = Orthonormalize ( surfaceData.tangentWS, surfaceData.normalWS );

#ifdef _MATERIAL_FEATURE_ANISOTROPY
				surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_ANISOTROPY;
				surfaceData.anisotropy = surfaceDescription.Anisotropy;

#else
				surfaceData.anisotropy = 0;
#endif

#ifdef _MATERIAL_FEATURE_CLEAR_COAT
				surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_CLEAR_COAT;
				surfaceData.coatMask = surfaceDescription.CoatMask;
#else
				surfaceData.coatMask = 0.0f;
#endif

#ifdef _MATERIAL_FEATURE_IRIDESCENCE
				surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_IRIDESCENCE;
				surfaceData.iridescenceThickness = surfaceDescription.IridescenceThickness;
				surfaceData.iridescenceMask = surfaceDescription.IridescenceMask;
#else
				surfaceData.iridescenceThickness = 0.0;
				surfaceData.iridescenceMask = 1.0;
#endif

				//ASE CUSTOM TAG
#ifdef _MATERIAL_FEATURE_TRANSPARENCY
				surfaceData.ior = surfaceDescription.IndexOfRefraction;
				surfaceData.transmittanceColor = surfaceDescription.TransmittanceColor;
				surfaceData.atDistance = surfaceDescription.TransmittanceAbsorptionDistance;
				surfaceData.transmittanceMask = surfaceDescription.TransmittanceMask;
#else
				surfaceData.ior = 1.0;
				surfaceData.transmittanceColor = float3( 1.0, 1.0, 1.0 );
				surfaceData.atDistance = 1000000.0;
				surfaceData.transmittanceMask = 0.0;
#endif

				surfaceData.specularOcclusion = 1.0;

#if defined(_BENTNORMALMAP) && defined(_ENABLESPECULAROCCLUSION)
				surfaceData.specularOcclusion = GetSpecularOcclusionFromBentAO ( V, bentNormalWS, surfaceData );
#elif defined(_MASKMAP)
				surfaceData.specularOcclusion = GetSpecularOcclusionFromAmbientOcclusion ( NdotV, surfaceData.ambientOcclusion, PerceptualSmoothnessToRoughness ( surfaceData.perceptualSmoothness ) );
#endif
#if HAVE_DECALS
				if (_EnableDecals)
				{
					DecalSurfaceData decalSurfaceData = GetDecalSurfaceData (posInput, surfaceDescription.Alpha);
					ApplyDecalToSurfaceData (decalSurfaceData, surfaceData);
				}
#endif
			}

            void GetSurfaceAndBuiltinData( GlobalSurfaceDescription surfaceDescription , FragInputs fragInputs, float3 V, inout PositionInputs posInput, out SurfaceData surfaceData, out BuiltinData builtinData)
            {
        
#if _ALPHATEST_ON
				DoAlphaTest ( surfaceDescription.Alpha, surfaceDescription.AlphaClipThreshold );
#endif
				BuildSurfaceData( fragInputs, surfaceDescription, V, posInput, surfaceData );
        
                // Builtin Data
                // For back lighting we use the oposite vertex normal 
				InitBuiltinData (posInput, surfaceDescription.Alpha, surfaceData.normalWS, -fragInputs.worldToTangent[2], fragInputs.texCoord1, fragInputs.texCoord2, builtinData);
        
				builtinData.emissiveColor =             surfaceDescription.Emission;
                builtinData.distortion =                float2(0.0, 0.0);           // surfaceDescription.Distortion -- if distortion pass
                builtinData.distortionBlur =            0.0;                        // surfaceDescription.DistortionBlur -- if distortion pass
                builtinData.depthOffset =               0.0;                        // ApplyPerPixelDisplacement(input, V, layerTexCoord, blendMasks); #ifdef _DEPTHOFFSET_ON : ApplyDepthOffsetPositionInput(V, depthOffset, GetWorldToHClipMatrix(), posInput);
        
                PostInitBuiltinData(V, posInput, surfaceData, builtinData);            
            }
        
			PackedVaryingsMeshToPS Vert ( AttributesMesh inputMesh  )
			{
				PackedVaryingsMeshToPS outputPackedVaryingsMeshToPS;

				UNITY_SETUP_INSTANCE_ID ( inputMesh );
				UNITY_TRANSFER_INSTANCE_ID ( inputMesh, outputPackedVaryingsMeshToPS );

				#if UNITY_ANY_INSTANCING_ENABLED
				outputPackedVaryingsMeshToPS.instanceID = inputMesh.instanceID;
				#endif

				float3 ase_worldNormal = TransformObjectToWorldNormal(inputMesh.normalOS);
				float3 ase_worldTangent = TransformObjectToWorldDir(inputMesh.tangentOS.xyz);
				float ase_vertexTangentSign = inputMesh.tangentOS.w * unity_WorldTransformParams.w;
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				outputPackedVaryingsMeshToPS.ase_texcoord6.xyz = ase_worldBitangent;
				
				outputPackedVaryingsMeshToPS.ase_texcoord5.xy = inputMesh.ase_texcoord.xy;
				outputPackedVaryingsMeshToPS.ase_color = inputMesh.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				outputPackedVaryingsMeshToPS.ase_texcoord5.zw = 0;
				outputPackedVaryingsMeshToPS.ase_texcoord6.w = 0;
				float3 vertexValue =  float3( 0, 0, 0 ) ;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
				inputMesh.positionOS.xyz = vertexValue;
				#else
				inputMesh.positionOS.xyz += vertexValue;
				#endif

				inputMesh.normalOS =  inputMesh.normalOS ;

				float3 positionRWS = TransformObjectToWorld ( inputMesh.positionOS.xyz );
				float3 normalWS = TransformObjectToWorldNormal ( inputMesh.normalOS );
				float4 tangentWS = float4( TransformObjectToWorldDir ( inputMesh.tangentOS.xyz ), inputMesh.tangentOS.w );
				float4 positionCS = TransformWorldToHClip ( positionRWS );

				outputPackedVaryingsMeshToPS.positionCS = positionCS;
				outputPackedVaryingsMeshToPS.interp00.xyz = positionRWS;
				outputPackedVaryingsMeshToPS.interp01.xyz = normalWS;
				outputPackedVaryingsMeshToPS.interp02.xyzw = tangentWS;
				outputPackedVaryingsMeshToPS.interp03 = inputMesh.uv1;
				outputPackedVaryingsMeshToPS.interp04 = inputMesh.uv2;
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( outputPackedVaryingsMeshToPS );
				return outputPackedVaryingsMeshToPS;
			}

			void Frag ( PackedVaryingsMeshToPS packedInput, 
						OUTPUT_GBUFFER ( outGBuffer )
						#ifdef _DEPTHOFFSET_ON
						, out float outputDepth : SV_Depth
						#endif
						 
						)
			{
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( packedInput );
				FragInputs input;
				ZERO_INITIALIZE ( FragInputs, input );
				input.worldToTangent = k_identity3x3;
				
				float3 positionRWS = packedInput.interp00.xyz;
				float3 normalWS = packedInput.interp01.xyz;
				float4 tangentWS = packedInput.interp02.xyzw;
			
				input.positionSS = packedInput.positionCS;
				input.positionRWS = positionRWS;
				input.worldToTangent = BuildWorldToTangent ( tangentWS, normalWS );
				input.texCoord1 = packedInput.interp03;
				input.texCoord2 = packedInput.interp04;

				// input.positionSS is SV_Position
				PositionInputs posInput = GetPositionInput ( input.positionSS.xy, _ScreenSize.zw, input.positionSS.z, input.positionSS.w, input.positionRWS );

				float3 normalizedWorldViewDir = GetWorldSpaceNormalizeViewDir ( input.positionRWS );

				SurfaceData surfaceData;
				BuiltinData builtinData;

				GlobalSurfaceDescription surfaceDescription = ( GlobalSurfaceDescription ) 0;
				float2 uv0_MainTex = packedInput.ase_texcoord5.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 uv_MetalicRAmbientOcclusionGHeightBEmissionA = packedInput.ase_texcoord5.xy * _MetalicRAmbientOcclusionGHeightBEmissionA_ST.xy + _MetalicRAmbientOcclusionGHeightBEmissionA_ST.zw;
				float3 ase_worldBitangent = packedInput.ase_texcoord6.xyz;
				float3 tanToWorld0 = float3( tangentWS.xyz.x, ase_worldBitangent.x, normalWS.x );
				float3 tanToWorld1 = float3( tangentWS.xyz.y, ase_worldBitangent.y, normalWS.y );
				float3 tanToWorld2 = float3( tangentWS.xyz.z, ase_worldBitangent.z, normalWS.z );
				float3 ase_tanViewDir =  tanToWorld0 * normalizedWorldViewDir.x + tanToWorld1 * normalizedWorldViewDir.y  + tanToWorld2 * normalizedWorldViewDir.z;
				ase_tanViewDir = normalize(ase_tanViewDir);
				float2 Offset817 = ( ( tex2D( _MetalicRAmbientOcclusionGHeightBEmissionA, uv_MetalicRAmbientOcclusionGHeightBEmissionA ).b - 1 ) * ase_tanViewDir.xy * _MainRoadParallaxPower ) + uv0_MainTex;
				float2 Offset837 = ( ( tex2D( _MetalicRAmbientOcclusionGHeightBEmissionA, Offset817 ).b - 1 ) * ase_tanViewDir.xy * _MainRoadParallaxPower ) + Offset817;
				float2 Offset859 = ( ( tex2D( _MetalicRAmbientOcclusionGHeightBEmissionA, Offset837 ).b - 1 ) * ase_tanViewDir.xy * _MainRoadParallaxPower ) + Offset837;
				float2 Offset886 = ( ( tex2D( _MetalicRAmbientOcclusionGHeightBEmissionA, Offset859 ).b - 1 ) * ase_tanViewDir.xy * _MainRoadParallaxPower ) + Offset859;
				float4 tex2DNode1 = tex2D( _MainTex, Offset886 );
				float4 temp_output_77_0 = ( ( _MainRoadBrightness * tex2DNode1 ) * _MainRoadColor );
				float2 uv0_DetailAlbedoMap = packedInput.ase_texcoord5.xy * _DetailAlbedoMap_ST.xy + _DetailAlbedoMap_ST.zw;
				float4 tex2DNode486 = tex2D( _DetailAlbedoMap, uv0_DetailAlbedoMap );
				float4 blendOpSrc474 = temp_output_77_0;
				float4 blendOpDest474 = ( _DetailAlbedoPower * tex2DNode486 );
				float2 uv0_DetailMask = packedInput.ase_texcoord5.xy * _DetailMask_ST.xy + _DetailMask_ST.zw;
				float4 tex2DNode481 = tex2D( _DetailMask, uv0_DetailMask );
				float4 lerpResult480 = lerp( temp_output_77_0 , (( blendOpDest474 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest474 ) * ( 1.0 - blendOpSrc474 ) ) : ( 2.0 * blendOpDest474 * blendOpSrc474 ) ) , ( _DetailAlbedoPower * tex2DNode481.a ));
				float2 uv0_TextureSample3 = packedInput.ase_texcoord5.xy * _TextureSample3_ST.xy + _TextureSample3_ST.zw;
				float2 uv_SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA = packedInput.ase_texcoord5.xy * _SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA_ST.xy + _SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA_ST.zw;
				float2 Offset819 = ( ( tex2D( _SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA, uv_SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA ).b - 1 ) * ase_tanViewDir.xy * _SecondRoadParallaxPower ) + uv0_TextureSample3;
				float2 Offset839 = ( ( tex2D( _SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA, Offset819 ).b - 1 ) * ase_tanViewDir.xy * _SecondRoadParallaxPower ) + Offset819;
				float2 Offset863 = ( ( tex2D( _SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA, Offset839 ).b - 1 ) * ase_tanViewDir.xy * _SecondRoadParallaxPower ) + Offset839;
				float2 Offset885 = ( ( tex2D( _SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA, Offset863 ).b - 1 ) * ase_tanViewDir.xy * _SecondRoadParallaxPower ) + Offset863;
				float4 tex2DNode537 = tex2D( _TextureSample3, Offset885 );
				float4 temp_output_540_0 = ( ( _SecondRoadBrightness * tex2DNode537 ) * _SecondRoadColor );
				float4 blendOpSrc619 = temp_output_540_0;
				float4 blendOpDest619 = ( tex2DNode486 * _Float2 );
				float4 lerpResult618 = lerp( temp_output_540_0 , (( blendOpDest619 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest619 ) * ( 1.0 - blendOpSrc619 ) ) : ( 2.0 * blendOpDest619 * blendOpSrc619 ) ) , ( _Float2 * tex2DNode481.a ));
				float4 break666 = ( packedInput.ase_color / float4( 1,1,1,1 ) );
				float2 uv0_TextureSample1 = packedInput.ase_texcoord5.xy * _TextureSample1_ST.xy + _TextureSample1_ST.zw;
				float clampResult673 = clamp( pow( abs( ( min( min( min( tex2D( _TextureSample1, uv0_TextureSample1 ).r , tex2D( _TextureSample1, ( uv0_TextureSample1 * float2( 0.5,0.5 ) ) ).r ) , tex2D( _TextureSample1, ( uv0_TextureSample1 * float2( 0.2,0.2 ) ) ).r ) , tex2D( _TextureSample1, ( uv0_TextureSample1 * float2( 0.36,0.35 ) ) ).r ) * _SecondRoadNoiseMaskPower ) ) , abs( _SecondRoadNoiseMaskTreshold ) ) , 0.0 , 1.0 );
				float4 appendResult665 = (float4(( break666.r - clampResult673 ) , break666.g , break666.b , break666.a));
				float4 clampResult672 = clamp( appendResult665 , float4( 0,0,0,0 ) , float4( 1,1,1,1 ) );
				float4 lerpResult592 = lerp( lerpResult480 , lerpResult618 , ( 1.0 - clampResult672 ).x);
				
				float3 tex2DNode4 = UnpackNormalmapRGorAG( tex2D( _BumpMap, Offset886 ), _BumpScale );
				float3 lerpResult479 = lerp( tex2DNode4 , BlendNormal( tex2DNode4 , UnpackNormalmapRGorAG( tex2D( _DetailNormalMap, uv0_DetailAlbedoMap ), _DetailNormalMapScale ) ) , tex2DNode481.a);
				float3 tex2DNode535 = UnpackNormalmapRGorAG( tex2D( _SecondRoadNormal, Offset885 ), _SecondRoadNormalScale );
				float3 lerpResult570 = lerp( lerpResult479 , tex2DNode535 , _SecondRoadNormalBlend);
				float3 lerpResult617 = lerp( tex2DNode535 , BlendNormal( lerpResult570 , UnpackNormalmapRGorAG( tex2D( _DetailNormalMap, uv0_DetailAlbedoMap ), _Float1 ) ) , tex2DNode481.a);
				float3 lerpResult593 = lerp( lerpResult479 , lerpResult617 , ( 1.0 - clampResult672 ).x);
				
				float4 tex2DNode2 = tex2D( _MetalicRAmbientOcclusionGHeightBEmissionA, Offset886 );
				float4 tex2DNode536 = tex2D( _SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA, Offset885 );
				float lerpResult601 = lerp( ( tex2DNode2.r * _MainRoadMetalicPower ) , ( tex2DNode536.r * _SecondRoadMetalicPower ) , ( 1.0 - clampResult672 ).x);
				
				float lerpResult594 = lerp( ( tex2DNode2.a * _MainRoadSmoothnessPower ) , ( _SecondRoadSmoothnessPower * tex2DNode536.a ) , ( 1.0 - clampResult672 ).x);
				
				float clampResult96 = clamp( tex2DNode2.g , ( 1.0 - _MainRoadAmbientOcclusionPower ) , 1.0 );
				float clampResult546 = clamp( tex2DNode536.g , ( 1.0 - _SecondRoadAmbientOcclusionPower ) , 1.0 );
				float lerpResult602 = lerp( clampResult96 , clampResult546 , ( 1.0 - clampResult672 ).x);
				
				float temp_output_629_0 = ( tex2DNode1.a * _MainRoadAlphaCutOut );
				#ifdef _IGNORESECONDROADALPHA_ON
				float staticSwitch685 = temp_output_629_0;
				#else
				float staticSwitch685 = ( tex2DNode537.a * _SecondRoadAlphaCutOut );
				#endif
				float lerpResult628 = lerp( temp_output_629_0 , staticSwitch685 , ( 1.0 - clampResult672 ).x);
				
				surfaceDescription.Albedo = lerpResult592.rgb;
				surfaceDescription.Normal = lerpResult593;
				surfaceDescription.Emission = 0;
				surfaceDescription.Specular = 0;
				surfaceDescription.Metallic = lerpResult601;
				surfaceDescription.Smoothness = lerpResult594;
				surfaceDescription.Occlusion = lerpResult602;
				surfaceDescription.Alpha = lerpResult628;
				surfaceDescription.AlphaClipThreshold = 0.5;

#ifdef _MATERIAL_FEATURE_CLEAR_COAT
				surfaceDescription.CoatMask = 0;
#endif

#if defined(_MATERIAL_FEATURE_SUBSURFACE_SCATTERING) || defined(_MATERIAL_FEATURE_TRANSMISSION)
				surfaceDescription.DiffusionProfile = asfloat(uint(1074012128));
#endif

#ifdef _MATERIAL_FEATURE_SUBSURFACE_SCATTERING
				surfaceDescription.SubsurfaceMask = 1;
#endif

#ifdef _MATERIAL_FEATURE_TRANSMISSION
				surfaceDescription.Thickness = 0;
#endif

#ifdef _MATERIAL_FEATURE_ANISOTROPY
				surfaceDescription.Anisotropy = 0;
#endif

#ifdef _MATERIAL_FEATURE_IRIDESCENCE
				surfaceDescription.IridescenceThickness = 0;
				surfaceDescription.IridescenceMask = 1;
#endif

#ifdef _MATERIAL_FEATURE_TRANSPARENCY
				surfaceDescription.IndexOfRefraction = 1;
				surfaceDescription.TransmittanceColor = float3( 1, 1, 1 );
				surfaceDescription.TransmittanceAbsorptionDistance = 1000000;
				surfaceDescription.TransmittanceMask = 0;
#endif
				GetSurfaceAndBuiltinData ( surfaceDescription, input, normalizedWorldViewDir, posInput, surfaceData, builtinData );
				ENCODE_INTO_GBUFFER ( surfaceData, builtinData, posInput.positionSS, outGBuffer );
#ifdef _DEPTHOFFSET_ON
				outputDepth = posInput.deviceDepth;
#endif
			}

            ENDHLSL
        }
        
		
		
        Pass
        {
			
            Name "META"
            Tags { "LightMode"="Meta" }
            Cull Off
            HLSLPROGRAM
			//#define UNITY_MATERIAL_LIT
			#pragma vertex Vert
			#pragma fragment Frag

			#define ASE_SRP_VERSION 51000
			#define _NORMALMAP 1
			#define _ALPHATEST_ON 1
			#pragma shader_feature _IGNORESECONDROADALPHA_ON

        
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/NormalSurfaceGradient.hlsl"
        
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/FragInputs.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPass.cs.hlsl"
        
			#define SHADERPASS SHADERPASS_LIGHT_TRANSPORT
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define ATTRIBUTES_NEED_TEXCOORD2
			#define ATTRIBUTES_NEED_COLOR
        
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Material.hlsl"
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/Lit.hlsl"
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/BuiltinUtilities.hlsl"
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/MaterialUtilities.hlsl"
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Decal/DecalUtilities.hlsl"
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/LitDecalData.hlsl"
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderGraphFunctions.hlsl"

            struct AttributesMesh 
			{
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float2 uv0 : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
                float2 uv2 : TEXCOORD2;
                float4 color : COLOR;
				
            };

            struct PackedVaryingsMeshToPS
			{
                float4 positionCS : SV_Position;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_color : COLOR;
            };
            
			float _MainRoadBrightness;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _MetalicRAmbientOcclusionGHeightBEmissionA;
			float4 _MetalicRAmbientOcclusionGHeightBEmissionA_ST;
			float _MainRoadParallaxPower;
			float4 _MainRoadColor;
			float _DetailAlbedoPower;
			sampler2D _DetailAlbedoMap;
			float4 _DetailAlbedoMap_ST;
			sampler2D _DetailMask;
			float4 _DetailMask_ST;
			float _SecondRoadBrightness;
			sampler2D _TextureSample3;
			float4 _TextureSample3_ST;
			sampler2D _SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA;
			float4 _SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA_ST;
			float _SecondRoadParallaxPower;
			float4 _SecondRoadColor;
			float _Float2;
			sampler2D _TextureSample1;
			float4 _TextureSample1_ST;
			float _SecondRoadNoiseMaskPower;
			float _SecondRoadNoiseMaskTreshold;
			float _BumpScale;
			sampler2D _BumpMap;
			float _DetailNormalMapScale;
			sampler2D _DetailNormalMap;
			float _SecondRoadNormalScale;
			sampler2D _SecondRoadNormal;
			float _SecondRoadNormalBlend;
			float _Float1;
			float _MainRoadMetalicPower;
			float _SecondRoadMetalicPower;
			float _MainRoadSmoothnessPower;
			float _SecondRoadSmoothnessPower;
			float _MainRoadAmbientOcclusionPower;
			float _SecondRoadAmbientOcclusionPower;
			float _MainRoadAlphaCutOut;
			float _SecondRoadAlphaCutOut;
			
			
			void BuildSurfaceData ( FragInputs fragInputs, GlobalSurfaceDescription surfaceDescription, float3 V, PositionInputs posInput, out SurfaceData surfaceData )
			{
				ZERO_INITIALIZE ( SurfaceData, surfaceData );

				float3 normalTS = float3( 0.0f, 0.0f, 1.0f );
				normalTS = surfaceDescription.Normal;
				float3 doubleSidedConstants = float3(1.0, 1.0, 1.0);
				GetNormalWS ( fragInputs, normalTS, surfaceData.normalWS ,doubleSidedConstants);

				surfaceData.ambientOcclusion = 1.0f;

				surfaceData.baseColor = surfaceDescription.Albedo;
				surfaceData.perceptualSmoothness = surfaceDescription.Smoothness;
				surfaceData.ambientOcclusion = surfaceDescription.Occlusion;

				surfaceData.materialFeatures = MATERIALFEATUREFLAGS_LIT_STANDARD;

#ifdef _MATERIAL_FEATURE_SPECULAR_COLOR
				surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_SPECULAR_COLOR;
				surfaceData.specularColor = surfaceDescription.Specular;
#else
				surfaceData.metallic = surfaceDescription.Metallic;
#endif

#if defined(_MATERIAL_FEATURE_SUBSURFACE_SCATTERING) || defined(_MATERIAL_FEATURE_TRANSMISSION)
				surfaceData.diffusionProfileHash = asuint(surfaceDescription.DiffusionProfile);
#endif

#ifdef _MATERIAL_FEATURE_SUBSURFACE_SCATTERING
				surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_SUBSURFACE_SCATTERING;
				surfaceData.subsurfaceMask = surfaceDescription.SubsurfaceMask;

#else
				surfaceData.subsurfaceMask = 1.0f;
#endif

#ifdef _MATERIAL_FEATURE_TRANSMISSION
				surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_TRANSMISSION;
				surfaceData.thickness = surfaceDescription.Thickness;
#endif

				surfaceData.tangentWS = normalize ( fragInputs.worldToTangent[ 0 ].xyz );
				surfaceData.tangentWS = Orthonormalize ( surfaceData.tangentWS, surfaceData.normalWS );

#ifdef _MATERIAL_FEATURE_ANISOTROPY
				surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_ANISOTROPY;
				surfaceData.anisotropy = surfaceDescription.Anisotropy;

#else
				surfaceData.anisotropy = 0;
#endif

#ifdef _MATERIAL_FEATURE_CLEAR_COAT
				surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_CLEAR_COAT;
				surfaceData.coatMask = surfaceDescription.CoatMask;
#else
				surfaceData.coatMask = 0.0f;
#endif

#ifdef _MATERIAL_FEATURE_IRIDESCENCE
				surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_IRIDESCENCE;
				surfaceData.iridescenceThickness = surfaceDescription.IridescenceThickness;
				surfaceData.iridescenceMask = surfaceDescription.IridescenceMask;
#else
				surfaceData.iridescenceThickness = 0.0;
				surfaceData.iridescenceMask = 1.0;
#endif

				//ASE CUSTOM TAG
#ifdef _MATERIAL_FEATURE_TRANSPARENCY
				surfaceData.ior = surfaceDescription.IndexOfRefraction;
				surfaceData.transmittanceColor = surfaceDescription.TransmittanceColor;
				surfaceData.atDistance = surfaceDescription.TransmittanceAbsorptionDistance;
				surfaceData.transmittanceMask = surfaceDescription.TransmittanceMask;
#else
				surfaceData.ior = 1.0;
				surfaceData.transmittanceColor = float3( 1.0, 1.0, 1.0 );
				surfaceData.atDistance = 1000000.0;
				surfaceData.transmittanceMask = 0.0;
#endif

				surfaceData.specularOcclusion = GetSpecularOcclusionFromAmbientOcclusion (ClampNdotV (dot (surfaceData.normalWS, V)), surfaceData.ambientOcclusion, PerceptualSmoothnessToRoughness (surfaceData.perceptualSmoothness));

#if HAVE_DECALS
				if (_EnableDecals)
				{
					DecalSurfaceData decalSurfaceData = GetDecalSurfaceData (posInput, surfaceDescription.Alpha);
					ApplyDecalToSurfaceData (decalSurfaceData, surfaceData);
				}
#endif

#if defined(_BENTNORMALMAP) && defined(_ENABLESPECULAROCCLUSION)
				surfaceData.specularOcclusion = GetSpecularOcclusionFromBentAO ( V, bentNormalWS, surfaceData );
#elif defined(_MASKMAP)
				surfaceData.specularOcclusion = GetSpecularOcclusionFromAmbientOcclusion ( NdotV, surfaceData.ambientOcclusion, PerceptualSmoothnessToRoughness ( surfaceData.perceptualSmoothness ) );
#endif
			}

            void GetSurfaceAndBuiltinData( GlobalSurfaceDescription surfaceDescription, FragInputs fragInputs, float3 V, inout PositionInputs posInput, out SurfaceData surfaceData, out BuiltinData builtinData)
            {
#if _ALPHATEST_ON
				DoAlphaTest ( surfaceDescription.Alpha, surfaceDescription.AlphaClipThreshold );
#endif
				BuildSurfaceData (fragInputs, surfaceDescription, V, posInput, surfaceData);
        
               // Builtin Data
                // For back lighting we use the oposite vertex normal 
				InitBuiltinData (posInput, surfaceDescription.Alpha, surfaceData.normalWS, -fragInputs.worldToTangent[2], fragInputs.texCoord1, fragInputs.texCoord2, builtinData);
        
		        builtinData.emissiveColor =             surfaceDescription.Emission;
                builtinData.distortion =                float2(0.0, 0.0);           // surfaceDescription.Distortion -- if distortion pass
                builtinData.distortionBlur =            0.0;                        // surfaceDescription.DistortionBlur -- if distortion pass
                builtinData.depthOffset =               0.0;                        // ApplyPerPixelDisplacement(input, V, layerTexCoord, blendMasks); #ifdef _DEPTHOFFSET_ON : ApplyDepthOffsetPositionInput(V, depthOffset, GetWorldToHClipMatrix(), posInput);
        
                PostInitBuiltinData(V, posInput, surfaceData, builtinData);
            }
        
           
			CBUFFER_START ( UnityMetaPass )
				bool4 unity_MetaVertexControl;
				bool4 unity_MetaFragmentControl;
			CBUFFER_END


			float unity_OneOverOutputBoost;
			float unity_MaxOutputValue;

			PackedVaryingsMeshToPS Vert ( AttributesMesh inputMesh  )
			{
				PackedVaryingsMeshToPS outputPackedVaryingsMeshToPS;

				UNITY_SETUP_INSTANCE_ID ( inputMesh );
				UNITY_TRANSFER_INSTANCE_ID ( inputMesh, outputPackedVaryingsMeshToPS );

				float3 ase_worldTangent = TransformObjectToWorldDir(inputMesh.tangentOS.xyz);
				outputPackedVaryingsMeshToPS.ase_texcoord1.xyz = ase_worldTangent;
				float3 ase_worldNormal = TransformObjectToWorldNormal(inputMesh.normalOS);
				outputPackedVaryingsMeshToPS.ase_texcoord2.xyz = ase_worldNormal;
				float ase_vertexTangentSign = inputMesh.tangentOS.w * unity_WorldTransformParams.w;
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				outputPackedVaryingsMeshToPS.ase_texcoord3.xyz = ase_worldBitangent;
				float3 ase_worldPos = GetAbsolutePositionWS( TransformObjectToWorld( (inputMesh.positionOS).xyz ) );
				outputPackedVaryingsMeshToPS.ase_texcoord4.xyz = ase_worldPos;
				
				outputPackedVaryingsMeshToPS.ase_texcoord.xy = inputMesh.uv0;
				outputPackedVaryingsMeshToPS.ase_color = inputMesh.color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				outputPackedVaryingsMeshToPS.ase_texcoord.zw = 0;
				outputPackedVaryingsMeshToPS.ase_texcoord1.w = 0;
				outputPackedVaryingsMeshToPS.ase_texcoord2.w = 0;
				outputPackedVaryingsMeshToPS.ase_texcoord3.w = 0;
				outputPackedVaryingsMeshToPS.ase_texcoord4.w = 0;
				float3 vertexValue =  float3( 0, 0, 0 ) ;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
				inputMesh.positionOS.xyz = vertexValue;
				#else
				inputMesh.positionOS.xyz += vertexValue;
				#endif

				inputMesh.normalOS =  inputMesh.normalOS ;

				float2 uv;

				if ( unity_MetaVertexControl.x )
				{
					uv = inputMesh.uv1 * unity_LightmapST.xy + unity_LightmapST.zw;
				}
				else if ( unity_MetaVertexControl.y )
				{
					uv = inputMesh.uv2 * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
				}

				outputPackedVaryingsMeshToPS.positionCS = float4( uv * 2.0 - 1.0, inputMesh.positionOS.z > 0 ? 1.0e-4 : 0.0, 1.0 );

				return outputPackedVaryingsMeshToPS;
			}

			float4 Frag ( PackedVaryingsMeshToPS packedInput  ) : SV_Target
			{
				FragInputs input;
				ZERO_INITIALIZE ( FragInputs, input );
				input.worldToTangent = k_identity3x3;
				input.positionSS = packedInput.positionCS;

				PositionInputs posInput = GetPositionInput ( input.positionSS.xy, _ScreenSize.zw, input.positionSS.z, input.positionSS.w, input.positionRWS );

				float3 V = 0;

				SurfaceData surfaceData;
				BuiltinData builtinData;

				GlobalSurfaceDescription surfaceDescription = ( GlobalSurfaceDescription ) 0;
				float2 uv0_MainTex = packedInput.ase_texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 uv_MetalicRAmbientOcclusionGHeightBEmissionA = packedInput.ase_texcoord.xy * _MetalicRAmbientOcclusionGHeightBEmissionA_ST.xy + _MetalicRAmbientOcclusionGHeightBEmissionA_ST.zw;
				float3 ase_worldTangent = packedInput.ase_texcoord1.xyz;
				float3 ase_worldNormal = packedInput.ase_texcoord2.xyz;
				float3 ase_worldBitangent = packedInput.ase_texcoord3.xyz;
				float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
				float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
				float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
				float3 ase_worldPos = packedInput.ase_texcoord4.xyz;
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - ase_worldPos );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 ase_tanViewDir =  tanToWorld0 * ase_worldViewDir.x + tanToWorld1 * ase_worldViewDir.y  + tanToWorld2 * ase_worldViewDir.z;
				ase_tanViewDir = normalize(ase_tanViewDir);
				float2 Offset817 = ( ( tex2D( _MetalicRAmbientOcclusionGHeightBEmissionA, uv_MetalicRAmbientOcclusionGHeightBEmissionA ).b - 1 ) * ase_tanViewDir.xy * _MainRoadParallaxPower ) + uv0_MainTex;
				float2 Offset837 = ( ( tex2D( _MetalicRAmbientOcclusionGHeightBEmissionA, Offset817 ).b - 1 ) * ase_tanViewDir.xy * _MainRoadParallaxPower ) + Offset817;
				float2 Offset859 = ( ( tex2D( _MetalicRAmbientOcclusionGHeightBEmissionA, Offset837 ).b - 1 ) * ase_tanViewDir.xy * _MainRoadParallaxPower ) + Offset837;
				float2 Offset886 = ( ( tex2D( _MetalicRAmbientOcclusionGHeightBEmissionA, Offset859 ).b - 1 ) * ase_tanViewDir.xy * _MainRoadParallaxPower ) + Offset859;
				float4 tex2DNode1 = tex2D( _MainTex, Offset886 );
				float4 temp_output_77_0 = ( ( _MainRoadBrightness * tex2DNode1 ) * _MainRoadColor );
				float2 uv0_DetailAlbedoMap = packedInput.ase_texcoord.xy * _DetailAlbedoMap_ST.xy + _DetailAlbedoMap_ST.zw;
				float4 tex2DNode486 = tex2D( _DetailAlbedoMap, uv0_DetailAlbedoMap );
				float4 blendOpSrc474 = temp_output_77_0;
				float4 blendOpDest474 = ( _DetailAlbedoPower * tex2DNode486 );
				float2 uv0_DetailMask = packedInput.ase_texcoord.xy * _DetailMask_ST.xy + _DetailMask_ST.zw;
				float4 tex2DNode481 = tex2D( _DetailMask, uv0_DetailMask );
				float4 lerpResult480 = lerp( temp_output_77_0 , (( blendOpDest474 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest474 ) * ( 1.0 - blendOpSrc474 ) ) : ( 2.0 * blendOpDest474 * blendOpSrc474 ) ) , ( _DetailAlbedoPower * tex2DNode481.a ));
				float2 uv0_TextureSample3 = packedInput.ase_texcoord.xy * _TextureSample3_ST.xy + _TextureSample3_ST.zw;
				float2 uv_SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA = packedInput.ase_texcoord.xy * _SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA_ST.xy + _SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA_ST.zw;
				float2 Offset819 = ( ( tex2D( _SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA, uv_SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA ).b - 1 ) * ase_tanViewDir.xy * _SecondRoadParallaxPower ) + uv0_TextureSample3;
				float2 Offset839 = ( ( tex2D( _SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA, Offset819 ).b - 1 ) * ase_tanViewDir.xy * _SecondRoadParallaxPower ) + Offset819;
				float2 Offset863 = ( ( tex2D( _SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA, Offset839 ).b - 1 ) * ase_tanViewDir.xy * _SecondRoadParallaxPower ) + Offset839;
				float2 Offset885 = ( ( tex2D( _SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA, Offset863 ).b - 1 ) * ase_tanViewDir.xy * _SecondRoadParallaxPower ) + Offset863;
				float4 tex2DNode537 = tex2D( _TextureSample3, Offset885 );
				float4 temp_output_540_0 = ( ( _SecondRoadBrightness * tex2DNode537 ) * _SecondRoadColor );
				float4 blendOpSrc619 = temp_output_540_0;
				float4 blendOpDest619 = ( tex2DNode486 * _Float2 );
				float4 lerpResult618 = lerp( temp_output_540_0 , (( blendOpDest619 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest619 ) * ( 1.0 - blendOpSrc619 ) ) : ( 2.0 * blendOpDest619 * blendOpSrc619 ) ) , ( _Float2 * tex2DNode481.a ));
				float4 break666 = ( packedInput.ase_color / float4( 1,1,1,1 ) );
				float2 uv0_TextureSample1 = packedInput.ase_texcoord.xy * _TextureSample1_ST.xy + _TextureSample1_ST.zw;
				float clampResult673 = clamp( pow( abs( ( min( min( min( tex2D( _TextureSample1, uv0_TextureSample1 ).r , tex2D( _TextureSample1, ( uv0_TextureSample1 * float2( 0.5,0.5 ) ) ).r ) , tex2D( _TextureSample1, ( uv0_TextureSample1 * float2( 0.2,0.2 ) ) ).r ) , tex2D( _TextureSample1, ( uv0_TextureSample1 * float2( 0.36,0.35 ) ) ).r ) * _SecondRoadNoiseMaskPower ) ) , abs( _SecondRoadNoiseMaskTreshold ) ) , 0.0 , 1.0 );
				float4 appendResult665 = (float4(( break666.r - clampResult673 ) , break666.g , break666.b , break666.a));
				float4 clampResult672 = clamp( appendResult665 , float4( 0,0,0,0 ) , float4( 1,1,1,1 ) );
				float4 lerpResult592 = lerp( lerpResult480 , lerpResult618 , ( 1.0 - clampResult672 ).x);
				
				float3 tex2DNode4 = UnpackNormalmapRGorAG( tex2D( _BumpMap, Offset886 ), _BumpScale );
				float3 lerpResult479 = lerp( tex2DNode4 , BlendNormal( tex2DNode4 , UnpackNormalmapRGorAG( tex2D( _DetailNormalMap, uv0_DetailAlbedoMap ), _DetailNormalMapScale ) ) , tex2DNode481.a);
				float3 tex2DNode535 = UnpackNormalmapRGorAG( tex2D( _SecondRoadNormal, Offset885 ), _SecondRoadNormalScale );
				float3 lerpResult570 = lerp( lerpResult479 , tex2DNode535 , _SecondRoadNormalBlend);
				float3 lerpResult617 = lerp( tex2DNode535 , BlendNormal( lerpResult570 , UnpackNormalmapRGorAG( tex2D( _DetailNormalMap, uv0_DetailAlbedoMap ), _Float1 ) ) , tex2DNode481.a);
				float3 lerpResult593 = lerp( lerpResult479 , lerpResult617 , ( 1.0 - clampResult672 ).x);
				
				float4 tex2DNode2 = tex2D( _MetalicRAmbientOcclusionGHeightBEmissionA, Offset886 );
				float4 tex2DNode536 = tex2D( _SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA, Offset885 );
				float lerpResult601 = lerp( ( tex2DNode2.r * _MainRoadMetalicPower ) , ( tex2DNode536.r * _SecondRoadMetalicPower ) , ( 1.0 - clampResult672 ).x);
				
				float lerpResult594 = lerp( ( tex2DNode2.a * _MainRoadSmoothnessPower ) , ( _SecondRoadSmoothnessPower * tex2DNode536.a ) , ( 1.0 - clampResult672 ).x);
				
				float clampResult96 = clamp( tex2DNode2.g , ( 1.0 - _MainRoadAmbientOcclusionPower ) , 1.0 );
				float clampResult546 = clamp( tex2DNode536.g , ( 1.0 - _SecondRoadAmbientOcclusionPower ) , 1.0 );
				float lerpResult602 = lerp( clampResult96 , clampResult546 , ( 1.0 - clampResult672 ).x);
				
				float temp_output_629_0 = ( tex2DNode1.a * _MainRoadAlphaCutOut );
				#ifdef _IGNORESECONDROADALPHA_ON
				float staticSwitch685 = temp_output_629_0;
				#else
				float staticSwitch685 = ( tex2DNode537.a * _SecondRoadAlphaCutOut );
				#endif
				float lerpResult628 = lerp( temp_output_629_0 , staticSwitch685 , ( 1.0 - clampResult672 ).x);
				
				surfaceDescription.Albedo = lerpResult592.rgb;
				surfaceDescription.Normal = lerpResult593;
				surfaceDescription.Emission = 0;
				surfaceDescription.Specular = 0;
				surfaceDescription.Metallic = lerpResult601;
				surfaceDescription.Smoothness = lerpResult594;
				surfaceDescription.Occlusion = lerpResult602;
				surfaceDescription.Alpha = lerpResult628;
				surfaceDescription.AlphaClipThreshold = 0.5;

#ifdef _MATERIAL_FEATURE_CLEAR_COAT
				surfaceDescription.CoatMask = 0;
#endif

#if defined(_MATERIAL_FEATURE_SUBSURFACE_SCATTERING) || defined(_MATERIAL_FEATURE_TRANSMISSION)
				surfaceDescription.DiffusionProfile = asfloat(uint(1074012128));
#endif

#ifdef _MATERIAL_FEATURE_SUBSURFACE_SCATTERING
				surfaceDescription.SubsurfaceMask = 1;
#endif

#ifdef _MATERIAL_FEATURE_TRANSMISSION
				surfaceDescription.Thickness = 0;
#endif

#ifdef _MATERIAL_FEATURE_ANISOTROPY
				surfaceDescription.Anisotropy = 0;
#endif

#ifdef _MATERIAL_FEATURE_IRIDESCENCE
				surfaceDescription.IridescenceThickness = 0;
				surfaceDescription.IridescenceMask = 1;
#endif

#ifdef _MATERIAL_FEATURE_TRANSPARENCY
				surfaceDescription.IndexOfRefraction = 1;
				surfaceDescription.TransmittanceColor = float3( 1, 1, 1 );
				surfaceDescription.TransmittanceAbsorptionDistance = 1000000;
				surfaceDescription.TransmittanceMask = 0;
#endif

				GetSurfaceAndBuiltinData ( surfaceDescription, input, V, posInput, surfaceData, builtinData );

				BSDFData bsdfData = ConvertSurfaceDataToBSDFData ( input.positionSS.xy, surfaceData );

				LightTransportData lightTransportData = GetLightTransportData ( surfaceData, builtinData, bsdfData );

				float4 res = float4( 0.0, 0.0, 0.0, 1.0 );
				if ( unity_MetaFragmentControl.x )
				{
					res.rgb = clamp ( pow ( abs ( lightTransportData.diffuseColor ), saturate ( unity_OneOverOutputBoost ) ), 0, unity_MaxOutputValue );
				}

				if ( unity_MetaFragmentControl.y )
				{
					res.rgb = lightTransportData.emissiveColor;
				}

				return res;
			}
       
            ENDHLSL
        }

		
		Pass
        {
			
            Name "ShadowCaster"
            Tags { "LightMode"="ShadowCaster" }
            ColorMask 0
			

            HLSLPROGRAM
			//#define UNITY_MATERIAL_LIT
			#pragma vertex Vert
			#pragma fragment Frag

			#define ASE_SRP_VERSION 51000
			#define _ALPHATEST_ON 1
			#pragma shader_feature _IGNORESECONDROADALPHA_ON

        
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/NormalSurfaceGradient.hlsl"
        
        
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/FragInputs.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPass.cs.hlsl"
        
            #define SHADERPASS SHADERPASS_SHADOWS
        
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
            #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Material.hlsl"
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/Lit.hlsl"
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/BuiltinUtilities.hlsl"
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/MaterialUtilities.hlsl"
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Decal/DecalUtilities.hlsl"
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/LitDecalData.hlsl"
			#include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderGraphFunctions.hlsl"
        

            struct AttributesMesh 
			{
                float4 positionOS : POSITION;
				float3 normalOS : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_tangent : TANGENT;
				float4 ase_color : COLOR;
				#if UNITY_ANY_INSTANCING_ENABLED
				uint instanceID : INSTANCEID_SEMANTIC;
				#endif 
            };

            struct PackedVaryingsMeshToPS 
			{
                float4 positionCS : SV_Position;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_color : COLOR;
				#if UNITY_ANY_INSTANCING_ENABLED
				uint instanceID : INSTANCEID_SEMANTIC;
				#endif
				UNITY_VERTEX_OUTPUT_STEREO
            };
        
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _MetalicRAmbientOcclusionGHeightBEmissionA;
			float4 _MetalicRAmbientOcclusionGHeightBEmissionA_ST;
			float _MainRoadParallaxPower;
			float _MainRoadAlphaCutOut;
			sampler2D _TextureSample3;
			float4 _TextureSample3_ST;
			sampler2D _SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA;
			float4 _SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA_ST;
			float _SecondRoadParallaxPower;
			float _SecondRoadAlphaCutOut;
			sampler2D _TextureSample1;
			float4 _TextureSample1_ST;
			float _SecondRoadNoiseMaskPower;
			float _SecondRoadNoiseMaskTreshold;
			
			
            void BuildSurfaceData(FragInputs fragInputs, AlphaSurfaceDescription surfaceDescription, float3 V, PositionInputs posInput, out SurfaceData surfaceData)
            {
                ZERO_INITIALIZE(SurfaceData, surfaceData);
                surfaceData.ambientOcclusion =      1.0f;
                surfaceData.subsurfaceMask =        1.0f;
        
                surfaceData.materialFeatures = MATERIALFEATUREFLAGS_LIT_STANDARD;
        #ifdef _MATERIAL_FEATURE_SUBSURFACE_SCATTERING
                surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_SUBSURFACE_SCATTERING;
        #endif
        #ifdef _MATERIAL_FEATURE_TRANSMISSION
                surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_TRANSMISSION;
        #endif
        #ifdef _MATERIAL_FEATURE_ANISOTROPY
                surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_ANISOTROPY;
        #endif
        #ifdef _MATERIAL_FEATURE_CLEAR_COAT
                surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_CLEAR_COAT;
        #endif
        #ifdef _MATERIAL_FEATURE_IRIDESCENCE
                surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_IRIDESCENCE;
        #endif
        #ifdef _MATERIAL_FEATURE_SPECULAR_COLOR
                surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_SPECULAR_COLOR;
        #endif
        
                float3 normalTS = float3(0.0f, 0.0f, 1.0f);
                float3 doubleSidedConstants = float3(1.0, 1.0, 1.0);
				GetNormalWS(fragInputs, normalTS, surfaceData.normalWS,doubleSidedConstants);
                surfaceData.tangentWS = normalize(fragInputs.worldToTangent[0].xyz);
                surfaceData.tangentWS = Orthonormalize(surfaceData.tangentWS, surfaceData.normalWS);
                surfaceData.anisotropy = 0;
                surfaceData.coatMask = 0.0f;
                surfaceData.iridescenceThickness = 0.0;
                surfaceData.iridescenceMask = 1.0;
                surfaceData.ior = 1.0;
                surfaceData.transmittanceColor = float3(1.0, 1.0, 1.0);
                surfaceData.atDistance = 1000000.0;
                surfaceData.transmittanceMask = 0.0;
                surfaceData.specularOcclusion = 1.0;
        #if defined(_BENTNORMALMAP) && defined(_ENABLESPECULAROCCLUSION)
                surfaceData.specularOcclusion = GetSpecularOcclusionFromBentAO(V, bentNormalWS, surfaceData);
        #elif defined(_MASKMAP)
                surfaceData.specularOcclusion = GetSpecularOcclusionFromAmbientOcclusion(NdotV, surfaceData.ambientOcclusion, PerceptualSmoothnessToRoughness(surfaceData.perceptualSmoothness));
        #endif
		#if HAVE_DECALS
				if (_EnableDecals)
				{
					DecalSurfaceData decalSurfaceData = GetDecalSurfaceData (posInput, surfaceDescription.Alpha);
					ApplyDecalToSurfaceData (decalSurfaceData, surfaceData);
				}
		#endif
            }
        
            void GetSurfaceAndBuiltinData( AlphaSurfaceDescription surfaceDescription, FragInputs fragInputs, float3 V, inout PositionInputs posInput, out SurfaceData surfaceData, out BuiltinData builtinData)
            {
#if _ALPHATEST_ON
				DoAlphaTest ( surfaceDescription.Alpha, surfaceDescription.AlphaClipThreshold );
#endif
                BuildSurfaceData(fragInputs, surfaceDescription, V, posInput, surfaceData);
                // Builtin Data
                // For back lighting we use the oposite vertex normal 
				InitBuiltinData (posInput, surfaceDescription.Alpha, surfaceData.normalWS, -fragInputs.worldToTangent[2], fragInputs.texCoord1, fragInputs.texCoord2, builtinData);
                builtinData.distortion =                float2(0.0, 0.0);           // surfaceDescription.Distortion -- if distortion pass
                builtinData.distortionBlur =            0.0;                        // surfaceDescription.DistortionBlur -- if distortion pass
                builtinData.depthOffset =               0.0;                        // ApplyPerPixelDisplacement(input, V, layerTexCoord, blendMasks); #ifdef _DEPTHOFFSET_ON : ApplyDepthOffsetPositionInput(V, depthOffset, GetWorldToHClipMatrix(), posInput);
                PostInitBuiltinData(V, posInput, surfaceData, builtinData);            
            }

			PackedVaryingsMeshToPS Vert( AttributesMesh inputMesh  )
			{
				PackedVaryingsMeshToPS outputPackedVaryingsMeshToPS;

				UNITY_SETUP_INSTANCE_ID ( inputMesh );
				UNITY_TRANSFER_INSTANCE_ID ( inputMesh, outputPackedVaryingsMeshToPS );

				float3 ase_worldTangent = TransformObjectToWorldDir(inputMesh.ase_tangent.xyz);
				outputPackedVaryingsMeshToPS.ase_texcoord1.xyz = ase_worldTangent;
				float3 ase_worldNormal = TransformObjectToWorldNormal(inputMesh.normalOS);
				outputPackedVaryingsMeshToPS.ase_texcoord2.xyz = ase_worldNormal;
				float ase_vertexTangentSign = inputMesh.ase_tangent.w * unity_WorldTransformParams.w;
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				outputPackedVaryingsMeshToPS.ase_texcoord3.xyz = ase_worldBitangent;
				float3 ase_worldPos = GetAbsolutePositionWS( TransformObjectToWorld( (inputMesh.positionOS).xyz ) );
				outputPackedVaryingsMeshToPS.ase_texcoord4.xyz = ase_worldPos;
				
				outputPackedVaryingsMeshToPS.ase_texcoord.xy = inputMesh.ase_texcoord.xy;
				outputPackedVaryingsMeshToPS.ase_color = inputMesh.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				outputPackedVaryingsMeshToPS.ase_texcoord.zw = 0;
				outputPackedVaryingsMeshToPS.ase_texcoord1.w = 0;
				outputPackedVaryingsMeshToPS.ase_texcoord2.w = 0;
				outputPackedVaryingsMeshToPS.ase_texcoord3.w = 0;
				outputPackedVaryingsMeshToPS.ase_texcoord4.w = 0;
				float3 vertexValue =  float3( 0, 0, 0 ) ;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
				inputMesh.positionOS.xyz = vertexValue;
				#else
				inputMesh.positionOS.xyz += vertexValue;
				#endif

				inputMesh.normalOS =  inputMesh.normalOS ;

				float3 positionRWS = TransformObjectToWorld ( inputMesh.positionOS.xyz );
				float4 positionCS = TransformWorldToHClip ( positionRWS );

				outputPackedVaryingsMeshToPS.positionCS = positionCS;
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( outputPackedVaryingsMeshToPS );
				return outputPackedVaryingsMeshToPS;
			}

			void Frag(  PackedVaryingsMeshToPS packedInput
						#ifdef WRITE_NORMAL_BUFFER
						, out float4 outNormalBuffer : SV_Target0
							#ifdef WRITE_MSAA_DEPTH
							, out float1 depthColor : SV_Target1
							#endif
						#elif defined(WRITE_MSAA_DEPTH) // When only WRITE_MSAA_DEPTH is define and not WRITE_NORMAL_BUFFER it mean we are Unlit and only need depth, but we still have normal buffer binded
						, out float4 outNormalBuffer : SV_Target0
						, out float1 depthColor : SV_Target1
						#else
						, out float4 outColor : SV_Target0
						#endif

						#ifdef _DEPTHOFFSET_ON
						, out float outputDepth : SV_Depth
						#endif
						 
						)
				{
					UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( packedInput );
					FragInputs input;
					ZERO_INITIALIZE(FragInputs, input);
					input.worldToTangent = k_identity3x3;
					input.positionSS = packedInput.positionCS;       // input.positionCS is SV_Position

					// input.positionSS is SV_Position
					PositionInputs posInput = GetPositionInput(input.positionSS.xy, _ScreenSize.zw, input.positionSS.z, input.positionSS.w, input.positionRWS);

					float3 V = float3(1.0, 1.0, 1.0); // Avoid the division by 0

					SurfaceData surfaceData;
					BuiltinData builtinData;
					AlphaSurfaceDescription surfaceDescription = (AlphaSurfaceDescription)0;
					float2 uv0_MainTex = packedInput.ase_texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
					float2 uv_MetalicRAmbientOcclusionGHeightBEmissionA = packedInput.ase_texcoord.xy * _MetalicRAmbientOcclusionGHeightBEmissionA_ST.xy + _MetalicRAmbientOcclusionGHeightBEmissionA_ST.zw;
					float3 ase_worldTangent = packedInput.ase_texcoord1.xyz;
					float3 ase_worldNormal = packedInput.ase_texcoord2.xyz;
					float3 ase_worldBitangent = packedInput.ase_texcoord3.xyz;
					float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
					float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
					float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
					float3 ase_worldPos = packedInput.ase_texcoord4.xyz;
					float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - ase_worldPos );
					ase_worldViewDir = normalize(ase_worldViewDir);
					float3 ase_tanViewDir =  tanToWorld0 * ase_worldViewDir.x + tanToWorld1 * ase_worldViewDir.y  + tanToWorld2 * ase_worldViewDir.z;
					ase_tanViewDir = normalize(ase_tanViewDir);
					float2 Offset817 = ( ( tex2D( _MetalicRAmbientOcclusionGHeightBEmissionA, uv_MetalicRAmbientOcclusionGHeightBEmissionA ).b - 1 ) * ase_tanViewDir.xy * _MainRoadParallaxPower ) + uv0_MainTex;
					float2 Offset837 = ( ( tex2D( _MetalicRAmbientOcclusionGHeightBEmissionA, Offset817 ).b - 1 ) * ase_tanViewDir.xy * _MainRoadParallaxPower ) + Offset817;
					float2 Offset859 = ( ( tex2D( _MetalicRAmbientOcclusionGHeightBEmissionA, Offset837 ).b - 1 ) * ase_tanViewDir.xy * _MainRoadParallaxPower ) + Offset837;
					float2 Offset886 = ( ( tex2D( _MetalicRAmbientOcclusionGHeightBEmissionA, Offset859 ).b - 1 ) * ase_tanViewDir.xy * _MainRoadParallaxPower ) + Offset859;
					float4 tex2DNode1 = tex2D( _MainTex, Offset886 );
					float temp_output_629_0 = ( tex2DNode1.a * _MainRoadAlphaCutOut );
					float2 uv0_TextureSample3 = packedInput.ase_texcoord.xy * _TextureSample3_ST.xy + _TextureSample3_ST.zw;
					float2 uv_SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA = packedInput.ase_texcoord.xy * _SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA_ST.xy + _SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA_ST.zw;
					float2 Offset819 = ( ( tex2D( _SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA, uv_SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA ).b - 1 ) * ase_tanViewDir.xy * _SecondRoadParallaxPower ) + uv0_TextureSample3;
					float2 Offset839 = ( ( tex2D( _SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA, Offset819 ).b - 1 ) * ase_tanViewDir.xy * _SecondRoadParallaxPower ) + Offset819;
					float2 Offset863 = ( ( tex2D( _SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA, Offset839 ).b - 1 ) * ase_tanViewDir.xy * _SecondRoadParallaxPower ) + Offset839;
					float2 Offset885 = ( ( tex2D( _SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA, Offset863 ).b - 1 ) * ase_tanViewDir.xy * _SecondRoadParallaxPower ) + Offset863;
					float4 tex2DNode537 = tex2D( _TextureSample3, Offset885 );
					#ifdef _IGNORESECONDROADALPHA_ON
					float staticSwitch685 = temp_output_629_0;
					#else
					float staticSwitch685 = ( tex2DNode537.a * _SecondRoadAlphaCutOut );
					#endif
					float4 break666 = ( packedInput.ase_color / float4( 1,1,1,1 ) );
					float2 uv0_TextureSample1 = packedInput.ase_texcoord.xy * _TextureSample1_ST.xy + _TextureSample1_ST.zw;
					float clampResult673 = clamp( pow( abs( ( min( min( min( tex2D( _TextureSample1, uv0_TextureSample1 ).r , tex2D( _TextureSample1, ( uv0_TextureSample1 * float2( 0.5,0.5 ) ) ).r ) , tex2D( _TextureSample1, ( uv0_TextureSample1 * float2( 0.2,0.2 ) ) ).r ) , tex2D( _TextureSample1, ( uv0_TextureSample1 * float2( 0.36,0.35 ) ) ).r ) * _SecondRoadNoiseMaskPower ) ) , abs( _SecondRoadNoiseMaskTreshold ) ) , 0.0 , 1.0 );
					float4 appendResult665 = (float4(( break666.r - clampResult673 ) , break666.g , break666.b , break666.a));
					float4 clampResult672 = clamp( appendResult665 , float4( 0,0,0,0 ) , float4( 1,1,1,1 ) );
					float lerpResult628 = lerp( temp_output_629_0 , staticSwitch685 , ( 1.0 - clampResult672 ).x);
					
					surfaceDescription.Alpha = lerpResult628;
					surfaceDescription.AlphaClipThreshold = 0.5;

					GetSurfaceAndBuiltinData(surfaceDescription,input, V, posInput, surfaceData, builtinData);

				#ifdef _DEPTHOFFSET_ON
					outputDepth = posInput.deviceDepth;
				#endif

				#ifdef WRITE_NORMAL_BUFFER
					EncodeIntoNormalBuffer(ConvertSurfaceDataToNormalData(surfaceData), posInput.positionSS, outNormalBuffer);
					#ifdef WRITE_MSAA_DEPTH
					depthColor = packedInput.positionCS.z;
					#endif
				#elif defined(WRITE_MSAA_DEPTH) 
					outNormalBuffer = float4(0.0, 0.0, 0.0, 1.0);
					depthColor = packedInput.vmesh.positionCS.z;
				#elif defined(SCENESELECTIONPASS)
					outColor = float4(_ObjectId, _PassValue, 1.0, 1.0);
				#else
					outColor = float4(0.0, 0.0, 0.0, 0.0);
				#endif
				}
            ENDHLSL
        }
		
		
        Pass
        {
			
            Name "SceneSelectionPass"
            Tags { "LightMode"="SceneSelectionPass" }

            ColorMask 0
        
            HLSLPROGRAM
				//#define UNITY_MATERIAL_LIT
				#pragma vertex Vert
				#pragma fragment Frag
        
				#define ASE_SRP_VERSION 51000
				#define _ALPHATEST_ON 1
				#pragma shader_feature _IGNORESECONDROADALPHA_ON


				#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
		
				#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/NormalSurfaceGradient.hlsl"
        
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/FragInputs.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPass.cs.hlsl"
        
                #define SHADERPASS SHADERPASS_DEPTH_ONLY
                #define SCENESELECTIONPASS
        
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
        
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Material.hlsl"
        
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/Lit.hlsl"
        
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/BuiltinUtilities.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/MaterialUtilities.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Decal/DecalUtilities.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/LitDecalData.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderGraphFunctions.hlsl"
        
				int _ObjectId;
				int _PassValue;
        
				struct AttributesMesh 
				{
					float3 positionOS : POSITION;
					float3 normalOS : NORMAL;
					float4 ase_texcoord : TEXCOORD0;
					float4 ase_tangent : TANGENT;
					float4 ase_color : COLOR;
					#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : INSTANCEID_SEMANTIC;
					#endif
				};
        
				struct PackedVaryingsMeshToPS 
				{
					float4 positionCS : SV_Position; 
					float4 ase_texcoord : TEXCOORD0;
					float4 ase_texcoord1 : TEXCOORD1;
					float4 ase_texcoord2 : TEXCOORD2;
					float4 ase_texcoord3 : TEXCOORD3;
					float4 ase_texcoord4 : TEXCOORD4;
					float4 ase_color : COLOR;
					#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : INSTANCEID_SEMANTIC; 
					#endif 
				};
        
				sampler2D _MainTex;
				float4 _MainTex_ST;
				sampler2D _MetalicRAmbientOcclusionGHeightBEmissionA;
				float4 _MetalicRAmbientOcclusionGHeightBEmissionA_ST;
				float _MainRoadParallaxPower;
				float _MainRoadAlphaCutOut;
				sampler2D _TextureSample3;
				float4 _TextureSample3_ST;
				sampler2D _SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA;
				float4 _SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA_ST;
				float _SecondRoadParallaxPower;
				float _SecondRoadAlphaCutOut;
				sampler2D _TextureSample1;
				float4 _TextureSample1_ST;
				float _SecondRoadNoiseMaskPower;
				float _SecondRoadNoiseMaskTreshold;
		
				                
        
				void BuildSurfaceData(FragInputs fragInputs, AlphaSurfaceDescription surfaceDescription, float3 V, PositionInputs posInput, out SurfaceData surfaceData)
				{
					ZERO_INITIALIZE(SurfaceData, surfaceData);
					surfaceData.ambientOcclusion =      1.0f;
					surfaceData.subsurfaceMask =        1.0f;
					surfaceData.materialFeatures = MATERIALFEATUREFLAGS_LIT_STANDARD;
			#ifdef _MATERIAL_FEATURE_SPECULAR_COLOR
					surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_SPECULAR_COLOR;
			#endif
					float3 normalTS =                   float3(0.0f, 0.0f, 1.0f);
					float3 doubleSidedConstants = float3(1.0, 1.0, 1.0);
					GetNormalWS(fragInputs, normalTS, surfaceData.normalWS,doubleSidedConstants);
					surfaceData.tangentWS = normalize(fragInputs.worldToTangent[0].xyz); 
					surfaceData.tangentWS = Orthonormalize(surfaceData.tangentWS, surfaceData.normalWS);
					surfaceData.anisotropy = 0;
					surfaceData.coatMask = 0.0f;
					surfaceData.iridescenceThickness = 0.0;
					surfaceData.iridescenceMask = 1.0;
					surfaceData.ior = 1.0;
					surfaceData.transmittanceColor = float3(1.0, 1.0, 1.0);
					surfaceData.atDistance = 1000000.0;
					surfaceData.transmittanceMask = 0.0;
					surfaceData.specularOcclusion = 1.0;
				#if defined(_BENTNORMALMAP) && defined(_ENABLESPECULAROCCLUSION)
					surfaceData.specularOcclusion = GetSpecularOcclusionFromBentAO(V, bentNormalWS, surfaceData);
				#elif defined(_MASKMAP)
					surfaceData.specularOcclusion = GetSpecularOcclusionFromAmbientOcclusion(NdotV, surfaceData.ambientOcclusion, PerceptualSmoothnessToRoughness(surfaceData.perceptualSmoothness));
				#endif
				
				#if HAVE_DECALS
					if (_EnableDecals)
					{
						DecalSurfaceData decalSurfaceData = GetDecalSurfaceData (posInput, surfaceDescription.Alpha);
						ApplyDecalToSurfaceData (decalSurfaceData, surfaceData);
					}
				#endif
				}
        
				void GetSurfaceAndBuiltinData(AlphaSurfaceDescription surfaceDescription, FragInputs fragInputs, float3 V, inout PositionInputs posInput, out SurfaceData surfaceData, out BuiltinData builtinData)
				{
				#if _ALPHATEST_ON
					DoAlphaTest ( surfaceDescription.Alpha, surfaceDescription.AlphaClipThreshold );
				#endif

					BuildSurfaceData(fragInputs, surfaceDescription, V, posInput, surfaceData);
					InitBuiltinData (posInput, surfaceDescription.Alpha, surfaceData.normalWS, -fragInputs.worldToTangent[2], fragInputs.texCoord1, fragInputs.texCoord2, builtinData);
					builtinData.distortion =                float2(0.0, 0.0);           
					builtinData.distortionBlur =            0.0;                        
					builtinData.depthOffset =               0.0;                        
					PostInitBuiltinData(V, posInput, surfaceData, builtinData);
				}
        
       
				PackedVaryingsMeshToPS Vert(AttributesMesh inputMesh )
				{
					PackedVaryingsMeshToPS outputPackedVaryingsMeshToPS;
					
					UNITY_SETUP_INSTANCE_ID(inputMesh);
					UNITY_TRANSFER_INSTANCE_ID(inputMesh, outputPackedVaryingsMeshToPS);
					
					float3 ase_worldTangent = TransformObjectToWorldDir(inputMesh.ase_tangent.xyz);
					outputPackedVaryingsMeshToPS.ase_texcoord1.xyz = ase_worldTangent;
					float3 ase_worldNormal = TransformObjectToWorldNormal(inputMesh.normalOS);
					outputPackedVaryingsMeshToPS.ase_texcoord2.xyz = ase_worldNormal;
					float ase_vertexTangentSign = inputMesh.ase_tangent.w * unity_WorldTransformParams.w;
					float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
					outputPackedVaryingsMeshToPS.ase_texcoord3.xyz = ase_worldBitangent;
					float3 ase_worldPos = GetAbsolutePositionWS( TransformObjectToWorld( (inputMesh.positionOS).xyz ) );
					outputPackedVaryingsMeshToPS.ase_texcoord4.xyz = ase_worldPos;
					
					outputPackedVaryingsMeshToPS.ase_texcoord.xy = inputMesh.ase_texcoord.xy;
					outputPackedVaryingsMeshToPS.ase_color = inputMesh.ase_color;
					
					//setting value to unused interpolator channels and avoid initialization warnings
					outputPackedVaryingsMeshToPS.ase_texcoord.zw = 0;
					outputPackedVaryingsMeshToPS.ase_texcoord1.w = 0;
					outputPackedVaryingsMeshToPS.ase_texcoord2.w = 0;
					outputPackedVaryingsMeshToPS.ase_texcoord3.w = 0;
					outputPackedVaryingsMeshToPS.ase_texcoord4.w = 0;
					float3 vertexValue =  float3( 0, 0, 0 ) ;
					#ifdef ASE_ABSOLUTE_VERTEX_POS
					inputMesh.positionOS.xyz = vertexValue;
					#else
					inputMesh.positionOS.xyz += vertexValue;
					#endif

					inputMesh.normalOS =  inputMesh.normalOS ;

					float3 positionRWS = TransformObjectToWorld(inputMesh.positionOS);
					
					outputPackedVaryingsMeshToPS.positionCS = TransformWorldToHClip(positionRWS);
			
					return outputPackedVaryingsMeshToPS;
				}

				void Frag(  PackedVaryingsMeshToPS packedInput
							#ifdef WRITE_NORMAL_BUFFER
							, out float4 outNormalBuffer : SV_Target0
								#ifdef WRITE_MSAA_DEPTH
								, out float1 depthColor : SV_Target1
								#endif
							#elif defined(WRITE_MSAA_DEPTH) 
							, out float4 outNormalBuffer : SV_Target0
							, out float1 depthColor : SV_Target1
							#elif defined(SCENESELECTIONPASS)
							, out float4 outColor : SV_Target0
							#endif

							#ifdef _DEPTHOFFSET_ON
							, out float outputDepth : SV_Depth
							#endif
							
						)
				{
					
					FragInputs input;
					ZERO_INITIALIZE(FragInputs, input);
					input.worldToTangent = k_identity3x3;
					input.positionSS = packedInput.positionCS;
					

					// input.positionSS is SV_Position
					PositionInputs posInput = GetPositionInput(input.positionSS.xy, _ScreenSize.zw, input.positionSS.z, input.positionSS.w, input.positionRWS);

				
					float3 V = float3(1.0, 1.0, 1.0); // Avoid the division by 0
				
					SurfaceData surfaceData;
					BuiltinData builtinData;
					AlphaSurfaceDescription surfaceDescription = ( AlphaSurfaceDescription ) 0;
					float2 uv0_MainTex = packedInput.ase_texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
					float2 uv_MetalicRAmbientOcclusionGHeightBEmissionA = packedInput.ase_texcoord.xy * _MetalicRAmbientOcclusionGHeightBEmissionA_ST.xy + _MetalicRAmbientOcclusionGHeightBEmissionA_ST.zw;
					float3 ase_worldTangent = packedInput.ase_texcoord1.xyz;
					float3 ase_worldNormal = packedInput.ase_texcoord2.xyz;
					float3 ase_worldBitangent = packedInput.ase_texcoord3.xyz;
					float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
					float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
					float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
					float3 ase_worldPos = packedInput.ase_texcoord4.xyz;
					float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - ase_worldPos );
					ase_worldViewDir = normalize(ase_worldViewDir);
					float3 ase_tanViewDir =  tanToWorld0 * ase_worldViewDir.x + tanToWorld1 * ase_worldViewDir.y  + tanToWorld2 * ase_worldViewDir.z;
					ase_tanViewDir = normalize(ase_tanViewDir);
					float2 Offset817 = ( ( tex2D( _MetalicRAmbientOcclusionGHeightBEmissionA, uv_MetalicRAmbientOcclusionGHeightBEmissionA ).b - 1 ) * ase_tanViewDir.xy * _MainRoadParallaxPower ) + uv0_MainTex;
					float2 Offset837 = ( ( tex2D( _MetalicRAmbientOcclusionGHeightBEmissionA, Offset817 ).b - 1 ) * ase_tanViewDir.xy * _MainRoadParallaxPower ) + Offset817;
					float2 Offset859 = ( ( tex2D( _MetalicRAmbientOcclusionGHeightBEmissionA, Offset837 ).b - 1 ) * ase_tanViewDir.xy * _MainRoadParallaxPower ) + Offset837;
					float2 Offset886 = ( ( tex2D( _MetalicRAmbientOcclusionGHeightBEmissionA, Offset859 ).b - 1 ) * ase_tanViewDir.xy * _MainRoadParallaxPower ) + Offset859;
					float4 tex2DNode1 = tex2D( _MainTex, Offset886 );
					float temp_output_629_0 = ( tex2DNode1.a * _MainRoadAlphaCutOut );
					float2 uv0_TextureSample3 = packedInput.ase_texcoord.xy * _TextureSample3_ST.xy + _TextureSample3_ST.zw;
					float2 uv_SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA = packedInput.ase_texcoord.xy * _SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA_ST.xy + _SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA_ST.zw;
					float2 Offset819 = ( ( tex2D( _SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA, uv_SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA ).b - 1 ) * ase_tanViewDir.xy * _SecondRoadParallaxPower ) + uv0_TextureSample3;
					float2 Offset839 = ( ( tex2D( _SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA, Offset819 ).b - 1 ) * ase_tanViewDir.xy * _SecondRoadParallaxPower ) + Offset819;
					float2 Offset863 = ( ( tex2D( _SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA, Offset839 ).b - 1 ) * ase_tanViewDir.xy * _SecondRoadParallaxPower ) + Offset839;
					float2 Offset885 = ( ( tex2D( _SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA, Offset863 ).b - 1 ) * ase_tanViewDir.xy * _SecondRoadParallaxPower ) + Offset863;
					float4 tex2DNode537 = tex2D( _TextureSample3, Offset885 );
					#ifdef _IGNORESECONDROADALPHA_ON
					float staticSwitch685 = temp_output_629_0;
					#else
					float staticSwitch685 = ( tex2DNode537.a * _SecondRoadAlphaCutOut );
					#endif
					float4 break666 = ( packedInput.ase_color / float4( 1,1,1,1 ) );
					float2 uv0_TextureSample1 = packedInput.ase_texcoord.xy * _TextureSample1_ST.xy + _TextureSample1_ST.zw;
					float clampResult673 = clamp( pow( abs( ( min( min( min( tex2D( _TextureSample1, uv0_TextureSample1 ).r , tex2D( _TextureSample1, ( uv0_TextureSample1 * float2( 0.5,0.5 ) ) ).r ) , tex2D( _TextureSample1, ( uv0_TextureSample1 * float2( 0.2,0.2 ) ) ).r ) , tex2D( _TextureSample1, ( uv0_TextureSample1 * float2( 0.36,0.35 ) ) ).r ) * _SecondRoadNoiseMaskPower ) ) , abs( _SecondRoadNoiseMaskTreshold ) ) , 0.0 , 1.0 );
					float4 appendResult665 = (float4(( break666.r - clampResult673 ) , break666.g , break666.b , break666.a));
					float4 clampResult672 = clamp( appendResult665 , float4( 0,0,0,0 ) , float4( 1,1,1,1 ) );
					float lerpResult628 = lerp( temp_output_629_0 , staticSwitch685 , ( 1.0 - clampResult672 ).x);
					
					surfaceDescription.Alpha = lerpResult628;
					surfaceDescription.AlphaClipThreshold = 0.5;
					GetSurfaceAndBuiltinData(surfaceDescription, input, V, posInput, surfaceData, builtinData);

				#ifdef _DEPTHOFFSET_ON
					outputDepth = posInput.deviceDepth;
				#endif

				#ifdef WRITE_NORMAL_BUFFER
					EncodeIntoNormalBuffer(ConvertSurfaceDataToNormalData(surfaceData), posInput.positionSS, outNormalBuffer);
					#ifdef WRITE_MSAA_DEPTH
					depthColor = packedInput.positionCS.z;
					#endif
				#elif defined(WRITE_MSAA_DEPTH) 
					outNormalBuffer = float4(0.0, 0.0, 0.0, 1.0);
					depthColor = packedInput.vmesh.positionCS.z;
				#elif defined(SCENESELECTIONPASS)
					outColor = float4(_ObjectId, _PassValue, 1.0, 1.0);
				#endif
				}

            ENDHLSL
        }
		
        Pass
        {
			
            Name "DepthOnly"
            Tags { "LightMode"="DepthOnly" }
			Stencil
			{
				Ref 0
				WriteMask 48
				Comp Always
				Pass Replace
				Fail Keep
				ZFail Keep
			}

            
            HLSLPROGRAM
				//#define UNITY_MATERIAL_LIT
				#pragma vertex Vert
				#pragma fragment Frag
        
				#define ASE_SRP_VERSION 51000
				#define _ALPHATEST_ON 1
				#pragma shader_feature _IGNORESECONDROADALPHA_ON


        
				#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"        
				#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/NormalSurfaceGradient.hlsl"
        
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/FragInputs.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPass.cs.hlsl"
        
				#define SHADERPASS SHADERPASS_DEPTH_ONLY
				#pragma multi_compile _ WRITE_NORMAL_BUFFER
				#pragma multi_compile _ WRITE_MSAA_DEPTH

				#define ATTRIBUTES_NEED_NORMAL
				#define ATTRIBUTES_NEED_TANGENT
				#define ATTRIBUTES_NEED_TEXCOORD0
				#define ATTRIBUTES_NEED_TEXCOORD1
				#define ATTRIBUTES_NEED_TEXCOORD2
				#define ATTRIBUTES_NEED_TEXCOORD3
				#define ATTRIBUTES_NEED_COLOR
				#define VARYINGS_NEED_POSITION_WS
				#define VARYINGS_NEED_TANGENT_TO_WORLD
				#define VARYINGS_NEED_TEXCOORD0
				#define VARYINGS_NEED_TEXCOORD1
				#define VARYINGS_NEED_TEXCOORD2
				#define VARYINGS_NEED_TEXCOORD3
				#define VARYINGS_NEED_COLOR
        
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Material.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/Lit.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/BuiltinUtilities.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/MaterialUtilities.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Decal/DecalUtilities.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/LitDecalData.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderGraphFunctions.hlsl"
				
				struct AttributesMesh 
				{
					float3 positionOS : POSITION;
					float3 normalOS : NORMAL;
					float4 ase_texcoord : TEXCOORD0;
					float4 ase_tangent : TANGENT;
					float4 ase_color : COLOR;
					#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : INSTANCEID_SEMANTIC;
					#endif
				};

				struct PackedVaryingsMeshToPS 
				{
					float4 positionCS : SV_Position;
					float4 ase_texcoord : TEXCOORD0;
					float4 ase_texcoord1 : TEXCOORD1;
					float4 ase_texcoord2 : TEXCOORD2;
					float4 ase_texcoord3 : TEXCOORD3;
					float4 ase_texcoord4 : TEXCOORD4;
					float4 ase_color : COLOR;
					#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : INSTANCEID_SEMANTIC;
					#endif
					UNITY_VERTEX_OUTPUT_STEREO
				};

				sampler2D _MainTex;
				float4 _MainTex_ST;
				sampler2D _MetalicRAmbientOcclusionGHeightBEmissionA;
				float4 _MetalicRAmbientOcclusionGHeightBEmissionA_ST;
				float _MainRoadParallaxPower;
				float _MainRoadAlphaCutOut;
				sampler2D _TextureSample3;
				float4 _TextureSample3_ST;
				sampler2D _SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA;
				float4 _SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA_ST;
				float _SecondRoadParallaxPower;
				float _SecondRoadAlphaCutOut;
				sampler2D _TextureSample1;
				float4 _TextureSample1_ST;
				float _SecondRoadNoiseMaskPower;
				float _SecondRoadNoiseMaskTreshold;
				
				        
				void BuildSurfaceData(FragInputs fragInputs, AlphaSurfaceDescription surfaceDescription, float3 V, PositionInputs posInput, out SurfaceData surfaceData)
				{
					ZERO_INITIALIZE(SurfaceData, surfaceData);
					surfaceData.ambientOcclusion =      1.0f;
					surfaceData.subsurfaceMask =        1.0f;

					surfaceData.materialFeatures = MATERIALFEATUREFLAGS_LIT_STANDARD;
			#ifdef _MATERIAL_FEATURE_SUBSURFACE_SCATTERING
					surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_SUBSURFACE_SCATTERING;
			#endif
			#ifdef _MATERIAL_FEATURE_TRANSMISSION
					surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_TRANSMISSION;
			#endif
			#ifdef _MATERIAL_FEATURE_ANISOTROPY
					surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_ANISOTROPY;
			#endif
			#ifdef _MATERIAL_FEATURE_CLEAR_COAT
					surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_CLEAR_COAT;
			#endif
			#ifdef _MATERIAL_FEATURE_IRIDESCENCE
					surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_IRIDESCENCE;
			#endif
			#ifdef _MATERIAL_FEATURE_SPECULAR_COLOR
					surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_SPECULAR_COLOR;
			#endif
					float3 normalTS =                   float3(0.0f, 0.0f, 1.0f);
					float3 doubleSidedConstants = float3(1.0, 1.0, 1.0);
					GetNormalWS(fragInputs, normalTS, surfaceData.normalWS,doubleSidedConstants);
					surfaceData.tangentWS = normalize(fragInputs.worldToTangent[0].xyz);    // The tangent is not normalize in worldToTangent for mikkt. TODO: Check if it expected that we normalize with Morten. Tag: SURFACE_GRADIENT
					surfaceData.tangentWS = Orthonormalize(surfaceData.tangentWS, surfaceData.normalWS);
					surfaceData.anisotropy = 0;
					surfaceData.coatMask = 0.0f;
					surfaceData.iridescenceThickness = 0.0;
					surfaceData.iridescenceMask = 1.0;
					surfaceData.ior = 1.0;
					surfaceData.transmittanceColor = float3(1.0, 1.0, 1.0);
					surfaceData.atDistance = 1000000.0;
					surfaceData.transmittanceMask = 0.0;
					surfaceData.specularOcclusion = 1.0;
			#if defined(_BENTNORMALMAP) && defined(_ENABLESPECULAROCCLUSION)
					surfaceData.specularOcclusion = GetSpecularOcclusionFromBentAO(V, bentNormalWS, surfaceData);
			#elif defined(_MASKMAP)
					surfaceData.specularOcclusion = GetSpecularOcclusionFromAmbientOcclusion(NdotV, surfaceData.ambientOcclusion, PerceptualSmoothnessToRoughness(surfaceData.perceptualSmoothness));
			#endif
				#if HAVE_DECALS
					if (_EnableDecals)
					{
						DecalSurfaceData decalSurfaceData = GetDecalSurfaceData (posInput, surfaceDescription.Alpha);
						ApplyDecalToSurfaceData (decalSurfaceData, surfaceData);
					}
				#endif
				}
        
				void GetSurfaceAndBuiltinData(AlphaSurfaceDescription surfaceDescription,FragInputs fragInputs, float3 V, inout PositionInputs posInput, out SurfaceData surfaceData, out BuiltinData builtinData)
				{
					#if _ALPHATEST_ON
						DoAlphaTest ( surfaceDescription.Alpha, surfaceDescription.AlphaClipThreshold );
					#endif
					BuildSurfaceData(fragInputs, surfaceDescription, V, posInput, surfaceData);
					InitBuiltinData (posInput, surfaceDescription.Alpha, surfaceData.normalWS, -fragInputs.worldToTangent[2], fragInputs.texCoord1, fragInputs.texCoord2, builtinData);

					builtinData.distortion =                float2(0.0, 0.0);           // surfaceDescription.Distortion -- if distortion pass
					builtinData.distortionBlur =            0.0;                        // surfaceDescription.DistortionBlur -- if distortion pass
					builtinData.depthOffset =               0.0;                        // ApplyPerPixelDisplacement(input, V, layerTexCoord, blendMasks); #ifdef _DEPTHOFFSET_ON : ApplyDepthOffsetPositionInput(V, depthOffset, GetWorldToHClipMatrix(), posInput);
					PostInitBuiltinData(V, posInput, surfaceData, builtinData);
				}

				PackedVaryingsMeshToPS Vert(AttributesMesh inputMesh  )
				{
					PackedVaryingsMeshToPS outputPackedVaryingsMeshToPS;
					UNITY_SETUP_INSTANCE_ID(inputMesh);
					UNITY_TRANSFER_INSTANCE_ID(inputMesh, outputPackedVaryingsMeshToPS);

					float3 ase_worldTangent = TransformObjectToWorldDir(inputMesh.ase_tangent.xyz);
					outputPackedVaryingsMeshToPS.ase_texcoord1.xyz = ase_worldTangent;
					float3 ase_worldNormal = TransformObjectToWorldNormal(inputMesh.normalOS);
					outputPackedVaryingsMeshToPS.ase_texcoord2.xyz = ase_worldNormal;
					float ase_vertexTangentSign = inputMesh.ase_tangent.w * unity_WorldTransformParams.w;
					float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
					outputPackedVaryingsMeshToPS.ase_texcoord3.xyz = ase_worldBitangent;
					float3 ase_worldPos = GetAbsolutePositionWS( TransformObjectToWorld( (inputMesh.positionOS).xyz ) );
					outputPackedVaryingsMeshToPS.ase_texcoord4.xyz = ase_worldPos;
					
					outputPackedVaryingsMeshToPS.ase_texcoord.xy = inputMesh.ase_texcoord.xy;
					outputPackedVaryingsMeshToPS.ase_color = inputMesh.ase_color;
					
					//setting value to unused interpolator channels and avoid initialization warnings
					outputPackedVaryingsMeshToPS.ase_texcoord.zw = 0;
					outputPackedVaryingsMeshToPS.ase_texcoord1.w = 0;
					outputPackedVaryingsMeshToPS.ase_texcoord2.w = 0;
					outputPackedVaryingsMeshToPS.ase_texcoord3.w = 0;
					outputPackedVaryingsMeshToPS.ase_texcoord4.w = 0;
					float3 vertexValue =  float3( 0, 0, 0 ) ;
					#ifdef ASE_ABSOLUTE_VERTEX_POS
					inputMesh.positionOS.xyz = vertexValue;
					#else
					inputMesh.positionOS.xyz += vertexValue;
					#endif

					inputMesh.normalOS =  inputMesh.normalOS ;

					float3 positionRWS = TransformObjectToWorld(inputMesh.positionOS);
					outputPackedVaryingsMeshToPS.positionCS = TransformWorldToHClip(positionRWS);
					UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( outputPackedVaryingsMeshToPS );
					return outputPackedVaryingsMeshToPS;
				}

				void Frag(  PackedVaryingsMeshToPS packedInput
							#ifdef WRITE_NORMAL_BUFFER
							, out float4 outNormalBuffer : SV_Target0
								#ifdef WRITE_MSAA_DEPTH
								, out float1 depthColor : SV_Target1
								#endif
							#elif defined(WRITE_MSAA_DEPTH) // When only WRITE_MSAA_DEPTH is define and not WRITE_NORMAL_BUFFER it mean we are Unlit and only need depth, but we still have normal buffer binded
							, out float4 outNormalBuffer : SV_Target0
							, out float1 depthColor : SV_Target1
							#else
							, out float4 outColor : SV_Target0
							#endif

							#ifdef _DEPTHOFFSET_ON
							, out float outputDepth : SV_Depth
							#endif
							
						)
				{
					UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( packedInput );	
					FragInputs input;
					ZERO_INITIALIZE(FragInputs, input);
					input.worldToTangent = k_identity3x3;
					input.positionSS = packedInput.positionCS;
				
					PositionInputs posInput = GetPositionInput(input.positionSS.xy, _ScreenSize.zw, input.positionSS.z, input.positionSS.w, input.positionRWS);

					float3 V = float3(1.0, 1.0, 1.0);

					SurfaceData surfaceData;
					BuiltinData builtinData;
					AlphaSurfaceDescription surfaceDescription = ( AlphaSurfaceDescription ) 0;
					float2 uv0_MainTex = packedInput.ase_texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
					float2 uv_MetalicRAmbientOcclusionGHeightBEmissionA = packedInput.ase_texcoord.xy * _MetalicRAmbientOcclusionGHeightBEmissionA_ST.xy + _MetalicRAmbientOcclusionGHeightBEmissionA_ST.zw;
					float3 ase_worldTangent = packedInput.ase_texcoord1.xyz;
					float3 ase_worldNormal = packedInput.ase_texcoord2.xyz;
					float3 ase_worldBitangent = packedInput.ase_texcoord3.xyz;
					float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
					float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
					float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
					float3 ase_worldPos = packedInput.ase_texcoord4.xyz;
					float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - ase_worldPos );
					ase_worldViewDir = normalize(ase_worldViewDir);
					float3 ase_tanViewDir =  tanToWorld0 * ase_worldViewDir.x + tanToWorld1 * ase_worldViewDir.y  + tanToWorld2 * ase_worldViewDir.z;
					ase_tanViewDir = normalize(ase_tanViewDir);
					float2 Offset817 = ( ( tex2D( _MetalicRAmbientOcclusionGHeightBEmissionA, uv_MetalicRAmbientOcclusionGHeightBEmissionA ).b - 1 ) * ase_tanViewDir.xy * _MainRoadParallaxPower ) + uv0_MainTex;
					float2 Offset837 = ( ( tex2D( _MetalicRAmbientOcclusionGHeightBEmissionA, Offset817 ).b - 1 ) * ase_tanViewDir.xy * _MainRoadParallaxPower ) + Offset817;
					float2 Offset859 = ( ( tex2D( _MetalicRAmbientOcclusionGHeightBEmissionA, Offset837 ).b - 1 ) * ase_tanViewDir.xy * _MainRoadParallaxPower ) + Offset837;
					float2 Offset886 = ( ( tex2D( _MetalicRAmbientOcclusionGHeightBEmissionA, Offset859 ).b - 1 ) * ase_tanViewDir.xy * _MainRoadParallaxPower ) + Offset859;
					float4 tex2DNode1 = tex2D( _MainTex, Offset886 );
					float temp_output_629_0 = ( tex2DNode1.a * _MainRoadAlphaCutOut );
					float2 uv0_TextureSample3 = packedInput.ase_texcoord.xy * _TextureSample3_ST.xy + _TextureSample3_ST.zw;
					float2 uv_SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA = packedInput.ase_texcoord.xy * _SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA_ST.xy + _SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA_ST.zw;
					float2 Offset819 = ( ( tex2D( _SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA, uv_SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA ).b - 1 ) * ase_tanViewDir.xy * _SecondRoadParallaxPower ) + uv0_TextureSample3;
					float2 Offset839 = ( ( tex2D( _SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA, Offset819 ).b - 1 ) * ase_tanViewDir.xy * _SecondRoadParallaxPower ) + Offset819;
					float2 Offset863 = ( ( tex2D( _SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA, Offset839 ).b - 1 ) * ase_tanViewDir.xy * _SecondRoadParallaxPower ) + Offset839;
					float2 Offset885 = ( ( tex2D( _SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA, Offset863 ).b - 1 ) * ase_tanViewDir.xy * _SecondRoadParallaxPower ) + Offset863;
					float4 tex2DNode537 = tex2D( _TextureSample3, Offset885 );
					#ifdef _IGNORESECONDROADALPHA_ON
					float staticSwitch685 = temp_output_629_0;
					#else
					float staticSwitch685 = ( tex2DNode537.a * _SecondRoadAlphaCutOut );
					#endif
					float4 break666 = ( packedInput.ase_color / float4( 1,1,1,1 ) );
					float2 uv0_TextureSample1 = packedInput.ase_texcoord.xy * _TextureSample1_ST.xy + _TextureSample1_ST.zw;
					float clampResult673 = clamp( pow( abs( ( min( min( min( tex2D( _TextureSample1, uv0_TextureSample1 ).r , tex2D( _TextureSample1, ( uv0_TextureSample1 * float2( 0.5,0.5 ) ) ).r ) , tex2D( _TextureSample1, ( uv0_TextureSample1 * float2( 0.2,0.2 ) ) ).r ) , tex2D( _TextureSample1, ( uv0_TextureSample1 * float2( 0.36,0.35 ) ) ).r ) * _SecondRoadNoiseMaskPower ) ) , abs( _SecondRoadNoiseMaskTreshold ) ) , 0.0 , 1.0 );
					float4 appendResult665 = (float4(( break666.r - clampResult673 ) , break666.g , break666.b , break666.a));
					float4 clampResult672 = clamp( appendResult665 , float4( 0,0,0,0 ) , float4( 1,1,1,1 ) );
					float lerpResult628 = lerp( temp_output_629_0 , staticSwitch685 , ( 1.0 - clampResult672 ).x);
					
					surfaceDescription.Alpha = lerpResult628;
					surfaceDescription.AlphaClipThreshold = 0.5;

					GetSurfaceAndBuiltinData(surfaceDescription, input, V, posInput, surfaceData, builtinData);

				#ifdef _DEPTHOFFSET_ON
					outputDepth = posInput.deviceDepth;
				#endif

				#ifdef WRITE_NORMAL_BUFFER
					EncodeIntoNormalBuffer(ConvertSurfaceDataToNormalData(surfaceData), posInput.positionSS, outNormalBuffer);
					#ifdef WRITE_MSAA_DEPTH
					depthColor = packedInput.positionCS.z;
					#endif
				#elif defined(WRITE_MSAA_DEPTH)
					outNormalBuffer = float4(0.0, 0.0, 0.0, 1.0);
					depthColor = packedInput.positionCS.z;
				#elif defined(SCENESELECTIONPASS)
					outColor = float4(_ObjectId, _PassValue, 1.0, 1.0);
				#else
					outColor = float4(0.0, 0.0, 0.0, 0.0);
				#endif
				}
        
            ENDHLSL
        }

		
        Pass
        {
			
            Name "Motion Vectors"
            Tags { "LightMode"="MotionVectors" }
        
			Stencil
			{
				Ref 128
				WriteMask 128
				Comp Always
				Pass Replace
				Fail Keep
				ZFail Keep
			}

             
            HLSLPROGRAM
				//#define UNITY_MATERIAL_LIT
				#pragma vertex Vert
				#pragma fragment Frag
        
				#define ASE_SRP_VERSION 51000
				#define _ALPHATEST_ON 1
				#pragma shader_feature _IGNORESECONDROADALPHA_ON

        
				#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
				#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/NormalSurfaceGradient.hlsl"
        
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/FragInputs.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPass.cs.hlsl"
        
				#define SHADERPASS SHADERPASS_MOTION_VECTORS
				#pragma multi_compile _ WRITE_NORMAL_BUFFER
                #pragma multi_compile _ WRITE_MSAA_DEPTH

                #define VARYINGS_NEED_POSITION_WS
        
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
                #include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Material.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/Lit.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/BuiltinUtilities.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/MaterialUtilities.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Decal/DecalUtilities.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/LitDecalData.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderGraphFunctions.hlsl"
        
				struct AttributesMesh
				{
					float3 positionOS : POSITION;
					float3 normalOS : NORMAL;
					float4 ase_texcoord : TEXCOORD0;
					float4 ase_tangent : TANGENT;
					float4 ase_color : COLOR;
					#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : INSTANCEID_SEMANTIC;
					#endif
				};
        
				struct VaryingsMeshToPS 
				{
					float4 positionCS : SV_Position;
					float3 positionRWS;
					#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : INSTANCEID_SEMANTIC;
					#endif
				};

				struct AttributesPass
				{
					float3 previousPositionOS : TEXCOORD4;
				};

				struct VaryingsPassToPS
				{
					float4 positionCS;
					float4 previousPositionCS;
				};

				#define VARYINGS_NEED_PASS

				struct VaryingsToPS
				{
					VaryingsMeshToPS vmesh;
					VaryingsPassToPS vpass;
				};

				struct PackedVaryingsToPS
				{
					float3 vmeshInterp00 : TEXCOORD0;
					float4 vmeshPositionCS : SV_Position;
					float3 vpassInterpolators0 : TEXCOORD1;
					float3 vpassInterpolators1 : TEXCOORD2;
					float4 ase_texcoord3 : TEXCOORD3;
					float4 ase_texcoord4 : TEXCOORD4;
					float4 ase_texcoord5 : TEXCOORD5;
					float4 ase_texcoord6 : TEXCOORD6;
					float4 ase_texcoord7 : TEXCOORD7;
					float4 ase_color : COLOR;
					#if UNITY_ANY_INSTANCING_ENABLED
					uint vmeshInstanceID : INSTANCEID_SEMANTIC;
					#endif
				};

				sampler2D _MainTex;
				float4 _MainTex_ST;
				sampler2D _MetalicRAmbientOcclusionGHeightBEmissionA;
				float4 _MetalicRAmbientOcclusionGHeightBEmissionA_ST;
				float _MainRoadParallaxPower;
				float _MainRoadAlphaCutOut;
				sampler2D _TextureSample3;
				float4 _TextureSample3_ST;
				sampler2D _SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA;
				float4 _SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA_ST;
				float _SecondRoadParallaxPower;
				float _SecondRoadAlphaCutOut;
				sampler2D _TextureSample1;
				float4 _TextureSample1_ST;
				float _SecondRoadNoiseMaskPower;
				float _SecondRoadNoiseMaskTreshold;
				
				            
				FragInputs BuildFragInputs(VaryingsMeshToPS input)
				{
					FragInputs output;
					ZERO_INITIALIZE(FragInputs, output);
					output.worldToTangent = k_identity3x3;
					output.positionSS = input.positionCS;
					output.positionRWS = input.positionRWS;
					return output;
				}
                
				void BuildSurfaceData(FragInputs fragInputs, AlphaSurfaceDescription surfaceDescription, float3 V, PositionInputs posInput, out SurfaceData surfaceData)
				{
					ZERO_INITIALIZE(SurfaceData, surfaceData);
					surfaceData.ambientOcclusion =      1.0f;
					surfaceData.subsurfaceMask =        1.0f;
					surfaceData.materialFeatures = MATERIALFEATUREFLAGS_LIT_STANDARD;
			#ifdef _MATERIAL_FEATURE_SUBSURFACE_SCATTERING
					surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_SUBSURFACE_SCATTERING;
			#endif
			#ifdef _MATERIAL_FEATURE_TRANSMISSION
					surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_TRANSMISSION;
			#endif
			#ifdef _MATERIAL_FEATURE_ANISOTROPY
					surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_ANISOTROPY;
			#endif
			#ifdef _MATERIAL_FEATURE_CLEAR_COAT
					surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_CLEAR_COAT;
			#endif
			#ifdef _MATERIAL_FEATURE_IRIDESCENCE
					surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_IRIDESCENCE;
			#endif
			#ifdef _MATERIAL_FEATURE_SPECULAR_COLOR
					surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_SPECULAR_COLOR;
			#endif
        
					float3 normalTS =                   float3(0.0f, 0.0f, 1.0f);
					float3 doubleSidedConstants = float3(1.0, 1.0, 1.0);
					GetNormalWS(fragInputs, normalTS, surfaceData.normalWS,doubleSidedConstants);
					surfaceData.tangentWS = normalize(fragInputs.worldToTangent[0].xyz);    // The tangent is not normalize in worldToTangent for mikkt. TODO: Check if it expected that we normalize with Morten. Tag: SURFACE_GRADIENT
					surfaceData.tangentWS = Orthonormalize(surfaceData.tangentWS, surfaceData.normalWS);
					surfaceData.anisotropy = 0;
					surfaceData.coatMask = 0.0f;
					surfaceData.iridescenceThickness = 0.0;
					surfaceData.iridescenceMask = 1.0;
					surfaceData.ior = 1.0;
					surfaceData.transmittanceColor = float3(1.0, 1.0, 1.0);
					surfaceData.atDistance = 1000000.0;
					surfaceData.transmittanceMask = 0.0;
					surfaceData.specularOcclusion = 1.0;
			#if defined(_BENTNORMALMAP) && defined(_ENABLESPECULAROCCLUSION)
					surfaceData.specularOcclusion = GetSpecularOcclusionFromBentAO(V, bentNormalWS, surfaceData);
			#elif defined(_MASKMAP)
					surfaceData.specularOcclusion = GetSpecularOcclusionFromAmbientOcclusion(NdotV, surfaceData.ambientOcclusion, PerceptualSmoothnessToRoughness(surfaceData.perceptualSmoothness));
			#endif
			#if HAVE_DECALS
					if (_EnableDecals)
					{
						DecalSurfaceData decalSurfaceData = GetDecalSurfaceData (posInput, surfaceDescription.Alpha);
						ApplyDecalToSurfaceData (decalSurfaceData, surfaceData);
					}
			#endif
				}
        
				void GetSurfaceAndBuiltinData(AlphaSurfaceDescription surfaceDescription, FragInputs fragInputs, float3 V, inout PositionInputs posInput, out SurfaceData surfaceData, out BuiltinData builtinData)
				{
				#if _ALPHATEST_ON
					DoAlphaTest ( surfaceDescription.Alpha, surfaceDescription.AlphaClipThreshold );
				#endif
					BuildSurfaceData(fragInputs, surfaceDescription, V, posInput, surfaceData);
					InitBuiltinData (posInput, surfaceDescription.Alpha, surfaceData.normalWS, -fragInputs.worldToTangent[2], fragInputs.texCoord1, fragInputs.texCoord2, builtinData);
					builtinData.distortion = float2(0.0, 0.0);
					builtinData.distortionBlur = 0.0;
					builtinData.depthOffset = 0.0;
					PostInitBuiltinData(V, posInput, surfaceData, builtinData);
				}
        

				VaryingsMeshToPS UnpackVaryingsMeshToPS(PackedVaryingsToPS input)
				{
					VaryingsMeshToPS output;
					output.positionCS = input.vmeshPositionCS;
					output.positionRWS = input.vmeshInterp00.xyz;
					#if UNITY_ANY_INSTANCING_ENABLED
					output.instanceID = input.vmeshInstanceID;
					#endif
					return output;
				}

				VaryingsPassToPS UnpackVaryingsPassToPS(PackedVaryingsToPS input)
				{
					VaryingsPassToPS output;
					output.positionCS = float4(input.vpassInterpolators0.xy, 0.0, input.vpassInterpolators0.z);
					output.previousPositionCS = float4(input.vpassInterpolators1.xy, 0.0, input.vpassInterpolators1.z);

					return output;
				}

				PackedVaryingsToPS PackVaryingsToPS(VaryingsToPS varyingsType)
				{
					PackedVaryingsToPS outputPackedVaryingsToPS;
					
					outputPackedVaryingsToPS.vmeshPositionCS = varyingsType.vmesh.positionCS;
					outputPackedVaryingsToPS.vmeshInterp00.xyz = varyingsType.vmesh.positionRWS;
					#if UNITY_ANY_INSTANCING_ENABLED
					outputPackedVaryingsToPS.vmeshInstanceID = varyingsType.vmesh.instanceID;
					#endif
					outputPackedVaryingsToPS.vpassInterpolators0 = float3(varyingsType.vpass.positionCS.xyw);
					outputPackedVaryingsToPS.vpassInterpolators1 = float3(varyingsType.vpass.previousPositionCS.xyw);
					return outputPackedVaryingsToPS;
				}

				float3 TransformPreviousObjectToWorldNormal(float3 normalOS)
				{
				#ifdef UNITY_ASSUME_UNIFORM_SCALING
					return normalize(mul((float3x3)unity_MatrixPreviousM, normalOS));
				#else
					return normalize(mul(normalOS, (float3x3)unity_MatrixPreviousMI));
				#endif
				}

				float3 TransformPreviousObjectToWorld(float3 positionOS)
				{
					float4x4 previousModelMatrix = ApplyCameraTranslationToMatrix(unity_MatrixPreviousM);
					return mul(previousModelMatrix, float4(positionOS, 1.0)).xyz;
				}

				void VelocityPositionZBias(VaryingsToPS input)
				{
				#if defined(UNITY_REVERSED_Z)
					input.vmesh.positionCS.z -= unity_MotionVectorsParams.z * input.vmesh.positionCS.w;
				#else
					input.vmesh.positionCS.z += unity_MotionVectorsParams.z * input.vmesh.positionCS.w;
				#endif
				}

				PackedVaryingsToPS Vert(AttributesMesh inputMesh,
										AttributesPass inputPass
										
										)
				{
					PackedVaryingsToPS outputPackedVaryingsToPS;
					VaryingsToPS varyingsType;
					VaryingsMeshToPS outputVaryingsMeshToPS;

					UNITY_SETUP_INSTANCE_ID(inputMesh);
					UNITY_TRANSFER_INSTANCE_ID(inputMesh, outputVaryingsMeshToPS);

					float3 ase_worldTangent = TransformObjectToWorldDir(inputMesh.ase_tangent.xyz);
					outputPackedVaryingsToPS.ase_texcoord4.xyz = ase_worldTangent;
					float3 ase_worldNormal = TransformObjectToWorldNormal(inputMesh.normalOS);
					outputPackedVaryingsToPS.ase_texcoord5.xyz = ase_worldNormal;
					float ase_vertexTangentSign = inputMesh.ase_tangent.w * unity_WorldTransformParams.w;
					float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
					outputPackedVaryingsToPS.ase_texcoord6.xyz = ase_worldBitangent;
					float3 ase_worldPos = GetAbsolutePositionWS( TransformObjectToWorld( (inputMesh.positionOS).xyz ) );
					outputPackedVaryingsToPS.ase_texcoord7.xyz = ase_worldPos;
					
					outputPackedVaryingsToPS.ase_texcoord3.xy = inputMesh.ase_texcoord.xy;
					outputPackedVaryingsToPS.ase_color = inputMesh.ase_color;
					
					//setting value to unused interpolator channels and avoid initialization warnings
					outputPackedVaryingsToPS.ase_texcoord3.zw = 0;
					outputPackedVaryingsToPS.ase_texcoord4.w = 0;
					outputPackedVaryingsToPS.ase_texcoord5.w = 0;
					outputPackedVaryingsToPS.ase_texcoord6.w = 0;
					outputPackedVaryingsToPS.ase_texcoord7.w = 0;
					float3 vertexValue =  float3( 0, 0, 0 ) ;
					#ifdef ASE_ABSOLUTE_VERTEX_POS
					inputMesh.positionOS.xyz = vertexValue;
					#else
					inputMesh.positionOS.xyz += vertexValue;
					#endif

					inputMesh.normalOS =  inputMesh.normalOS ;

					float3 positionRWS = TransformObjectToWorld(inputMesh.positionOS);
					outputVaryingsMeshToPS.positionRWS = positionRWS;
					outputVaryingsMeshToPS.positionCS = TransformWorldToHClip(positionRWS);
					

					varyingsType.vmesh = outputVaryingsMeshToPS;

					VelocityPositionZBias(varyingsType);
					varyingsType.vpass.positionCS = mul(_NonJitteredViewProjMatrix, float4(varyingsType.vmesh.positionRWS, 1.0));
					bool forceNoMotion = unity_MotionVectorsParams.y == 0.0;
					if (forceNoMotion)
					{
						varyingsType.vpass.previousPositionCS = float4(0.0, 0.0, 0.0, 1.0);
					}
					else
					{
						bool hasDeformation = unity_MotionVectorsParams.x > 0.0; // Skin or morph target

						float3 previousPositionRWS = TransformPreviousObjectToWorld(hasDeformation ? inputPass.previousPositionOS : inputMesh.positionOS);

						float3 normalWS = float3(0.0, 0.0, 0.0);

						varyingsType.vpass.previousPositionCS = mul(_PrevViewProjMatrix, float4(previousPositionRWS, 1.0));
					}

					outputPackedVaryingsToPS.vmeshPositionCS = varyingsType.vmesh.positionCS;
					outputPackedVaryingsToPS.vmeshInterp00.xyz = varyingsType.vmesh.positionRWS;
					
					#if UNITY_ANY_INSTANCING_ENABLED
					outputPackedVaryingsToPS.vmeshInstanceID = varyingsType.vmesh.instanceID;
					#endif

					outputPackedVaryingsToPS.vpassInterpolators0 = float3(varyingsType.vpass.positionCS.xyw);
					outputPackedVaryingsToPS.vpassInterpolators1 = float3(varyingsType.vpass.previousPositionCS.xyw);
					
					return outputPackedVaryingsToPS;
				}

				void Frag(	PackedVaryingsToPS packedInput
							, out float4 outMotionVector : SV_Target0
					#ifdef WRITE_NORMAL_BUFFER
							, out float4 outNormalBuffer : SV_Target1
					#ifdef WRITE_MSAA_DEPTH
							, out float1 depthColor : SV_Target2
					#endif
					#elif defined(WRITE_MSAA_DEPTH) 
							, out float4 outNormalBuffer : SV_Target1
							, out float1 depthColor : SV_Target2
					#endif
					#ifdef _DEPTHOFFSET_ON
					, out float outputDepth : SV_Depth
					#endif
							
						)
				{
					
					VaryingsMeshToPS unpacked= UnpackVaryingsMeshToPS(packedInput);
					FragInputs input = BuildFragInputs(unpacked);
					

					PositionInputs posInput = GetPositionInput(input.positionSS.xy, _ScreenSize.zw, input.positionSS.z, input.positionSS.w, input.positionRWS);

					float3 V = GetWorldSpaceNormalizeViewDir(input.positionRWS);

					SurfaceData surfaceData;
					BuiltinData builtinData;
					
					AlphaSurfaceDescription surfaceDescription = (AlphaSurfaceDescription)0;
                    float2 uv0_MainTex = packedInput.ase_texcoord3.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                    float2 uv_MetalicRAmbientOcclusionGHeightBEmissionA = packedInput.ase_texcoord3.xy * _MetalicRAmbientOcclusionGHeightBEmissionA_ST.xy + _MetalicRAmbientOcclusionGHeightBEmissionA_ST.zw;
                    float3 ase_worldTangent = packedInput.ase_texcoord4.xyz;
                    float3 ase_worldNormal = packedInput.ase_texcoord5.xyz;
                    float3 ase_worldBitangent = packedInput.ase_texcoord6.xyz;
                    float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
                    float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
                    float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
                    float3 ase_worldPos = packedInput.ase_texcoord7.xyz;
                    float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - ase_worldPos );
                    ase_worldViewDir = normalize(ase_worldViewDir);
                    float3 ase_tanViewDir =  tanToWorld0 * ase_worldViewDir.x + tanToWorld1 * ase_worldViewDir.y  + tanToWorld2 * ase_worldViewDir.z;
                    ase_tanViewDir = normalize(ase_tanViewDir);
                    float2 Offset817 = ( ( tex2D( _MetalicRAmbientOcclusionGHeightBEmissionA, uv_MetalicRAmbientOcclusionGHeightBEmissionA ).b - 1 ) * ase_tanViewDir.xy * _MainRoadParallaxPower ) + uv0_MainTex;
                    float2 Offset837 = ( ( tex2D( _MetalicRAmbientOcclusionGHeightBEmissionA, Offset817 ).b - 1 ) * ase_tanViewDir.xy * _MainRoadParallaxPower ) + Offset817;
                    float2 Offset859 = ( ( tex2D( _MetalicRAmbientOcclusionGHeightBEmissionA, Offset837 ).b - 1 ) * ase_tanViewDir.xy * _MainRoadParallaxPower ) + Offset837;
                    float2 Offset886 = ( ( tex2D( _MetalicRAmbientOcclusionGHeightBEmissionA, Offset859 ).b - 1 ) * ase_tanViewDir.xy * _MainRoadParallaxPower ) + Offset859;
                    float4 tex2DNode1 = tex2D( _MainTex, Offset886 );
                    float temp_output_629_0 = ( tex2DNode1.a * _MainRoadAlphaCutOut );
                    float2 uv0_TextureSample3 = packedInput.ase_texcoord3.xy * _TextureSample3_ST.xy + _TextureSample3_ST.zw;
                    float2 uv_SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA = packedInput.ase_texcoord3.xy * _SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA_ST.xy + _SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA_ST.zw;
                    float2 Offset819 = ( ( tex2D( _SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA, uv_SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA ).b - 1 ) * ase_tanViewDir.xy * _SecondRoadParallaxPower ) + uv0_TextureSample3;
                    float2 Offset839 = ( ( tex2D( _SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA, Offset819 ).b - 1 ) * ase_tanViewDir.xy * _SecondRoadParallaxPower ) + Offset819;
                    float2 Offset863 = ( ( tex2D( _SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA, Offset839 ).b - 1 ) * ase_tanViewDir.xy * _SecondRoadParallaxPower ) + Offset839;
                    float2 Offset885 = ( ( tex2D( _SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA, Offset863 ).b - 1 ) * ase_tanViewDir.xy * _SecondRoadParallaxPower ) + Offset863;
                    float4 tex2DNode537 = tex2D( _TextureSample3, Offset885 );
                    #ifdef _IGNORESECONDROADALPHA_ON
                    float staticSwitch685 = temp_output_629_0;
                    #else
                    float staticSwitch685 = ( tex2DNode537.a * _SecondRoadAlphaCutOut );
                    #endif
                    float4 break666 = ( packedInput.ase_color / float4( 1,1,1,1 ) );
                    float2 uv0_TextureSample1 = packedInput.ase_texcoord3.xy * _TextureSample1_ST.xy + _TextureSample1_ST.zw;
                    float clampResult673 = clamp( pow( abs( ( min( min( min( tex2D( _TextureSample1, uv0_TextureSample1 ).r , tex2D( _TextureSample1, ( uv0_TextureSample1 * float2( 0.5,0.5 ) ) ).r ) , tex2D( _TextureSample1, ( uv0_TextureSample1 * float2( 0.2,0.2 ) ) ).r ) , tex2D( _TextureSample1, ( uv0_TextureSample1 * float2( 0.36,0.35 ) ) ).r ) * _SecondRoadNoiseMaskPower ) ) , abs( _SecondRoadNoiseMaskTreshold ) ) , 0.0 , 1.0 );
                    float4 appendResult665 = (float4(( break666.r - clampResult673 ) , break666.g , break666.b , break666.a));
                    float4 clampResult672 = clamp( appendResult665 , float4( 0,0,0,0 ) , float4( 1,1,1,1 ) );
                    float lerpResult628 = lerp( temp_output_629_0 , staticSwitch685 , ( 1.0 - clampResult672 ).x);
                    
					surfaceDescription.Alpha = lerpResult628;
					surfaceDescription.AlphaClipThreshold = 0.5;
	
					GetSurfaceAndBuiltinData(surfaceDescription,input, V, posInput, surfaceData, builtinData);

					VaryingsPassToPS inputPass = UnpackVaryingsPassToPS(packedInput);
				#ifdef _DEPTHOFFSET_ON
					inputPass.positionCS.w += builtinData.depthOffset;
					inputPass.previousPositionCS.w += builtinData.depthOffset;
				#endif

					float2 motionVector = CalculateMotionVector (inputPass.positionCS, inputPass.previousPositionCS);
					EncodeMotionVector (motionVector * 0.5, outMotionVector);

					bool forceNoMotion = unity_MotionVectorsParams.y == 0.0;
					if (forceNoMotion)
						outMotionVector = float4(2.0, 0.0, 0.0, 0.0);

				#ifdef WRITE_NORMAL_BUFFER
					EncodeIntoNormalBuffer(ConvertSurfaceDataToNormalData(surfaceData), posInput.positionSS, outNormalBuffer);

					#ifdef WRITE_MSAA_DEPTH
					depthColor = packedInput.vmeshPositionCS.z;
					#endif
				#elif defined(WRITE_MSAA_DEPTH) 
					outNormalBuffer = float4(0.0, 0.0, 0.0, 1.0);
					depthColor = packedInput.vmeshPositionCS.z;
				#endif

				#ifdef _DEPTHOFFSET_ON
					outputDepth = posInput.deviceDepth;
				#endif
				}

            ENDHLSL
        }

		
        Pass
        {
            
            
			Name "Forward"
			Tags { "LightMode"="Forward" }
			Stencil
			{
				Ref 2
				WriteMask 7
				Comp Always
				Pass Replace
				Fail Keep
				ZFail Keep
			}


            HLSLPROGRAM
                //#define UNITY_MATERIAL_LIT
				#pragma vertex Vert
				#pragma fragment Frag
        
				#define ASE_SRP_VERSION 51000
				#define _NORMALMAP 1
				#define _ALPHATEST_ON 1
				#pragma shader_feature _IGNORESECONDROADALPHA_ON

        
				#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
				#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/NormalSurfaceGradient.hlsl"
        
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/FragInputs.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/RenderPipeline/ShaderPass/ShaderPass.cs.hlsl"
        
                #define SHADERPASS SHADERPASS_FORWARD
                #pragma multi_compile _ LIGHTMAP_ON
                #pragma multi_compile _ DIRLIGHTMAP_COMBINED
                #pragma multi_compile _ DYNAMICLIGHTMAP_ON
                #pragma multi_compile _ SHADOWS_SHADOWMASK
				#pragma multi_compile DECALS_OFF DECALS_3RT DECALS_4RT
                #pragma multi_compile USE_FPTL_LIGHTLIST USE_CLUSTERED_LIGHTLIST
				#pragma multi_compile SHADOW_LOW SHADOW_MEDIUM SHADOW_HIGH
				
				#define SHADERPASS_FORWARD_BYPASS_ALPHA_TEST

                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define ATTRIBUTES_NEED_TEXCOORD1
                #define ATTRIBUTES_NEED_TEXCOORD2
                #define VARYINGS_NEED_POSITION_WS
                #define VARYINGS_NEED_TANGENT_TO_WORLD
                #define VARYINGS_NEED_TEXCOORD1
                #define VARYINGS_NEED_TEXCOORD2
        
        
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderVariables.hlsl"
        
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Material.hlsl"
        
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Lighting/Lighting.hlsl"
        
				#define HAS_LIGHTLOOP
        
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Lighting/LightLoop/LightLoopDef.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/Lit.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Lighting/LightLoop/LightLoop.hlsl"
        
        
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/BuiltinUtilities.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/MaterialUtilities.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Decal/DecalUtilities.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/Material/Lit/LitDecalData.hlsl"
				#include "Packages/com.unity.render-pipelines.high-definition/Runtime/ShaderLibrary/ShaderGraphFunctions.hlsl"
				
				struct AttributesMesh 
				{
					float3 positionOS : POSITION;
					float3 normalOS : NORMAL;
					float4 tangentOS : TANGENT;
					float4 uv1 : TEXCOORD1;
					float4 uv2 : TEXCOORD2;
					float4 ase_texcoord : TEXCOORD0;
					float4 ase_color : COLOR;
					#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : INSTANCEID_SEMANTIC;
					#endif
				};
        
				struct PackedVaryingsMeshToPS 
				{
					float4 positionCS : SV_Position;
					float3 interp00 : TEXCOORD0;
					float3 interp01 : TEXCOORD1;
					float4 interp02 : TEXCOORD2;
					float4 interp03 : TEXCOORD3;
					float4 interp04 : TEXCOORD4;
					float4 ase_texcoord5 : TEXCOORD5;
					float4 ase_texcoord6 : TEXCOORD6;
					float4 ase_color : COLOR;
					#if UNITY_ANY_INSTANCING_ENABLED
					uint instanceID : INSTANCEID_SEMANTIC;
					#endif
					UNITY_VERTEX_OUTPUT_STEREO
				};

				float _MainRoadBrightness;
				sampler2D _MainTex;
				float4 _MainTex_ST;
				sampler2D _MetalicRAmbientOcclusionGHeightBEmissionA;
				float4 _MetalicRAmbientOcclusionGHeightBEmissionA_ST;
				float _MainRoadParallaxPower;
				float4 _MainRoadColor;
				float _DetailAlbedoPower;
				sampler2D _DetailAlbedoMap;
				float4 _DetailAlbedoMap_ST;
				sampler2D _DetailMask;
				float4 _DetailMask_ST;
				float _SecondRoadBrightness;
				sampler2D _TextureSample3;
				float4 _TextureSample3_ST;
				sampler2D _SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA;
				float4 _SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA_ST;
				float _SecondRoadParallaxPower;
				float4 _SecondRoadColor;
				float _Float2;
				sampler2D _TextureSample1;
				float4 _TextureSample1_ST;
				float _SecondRoadNoiseMaskPower;
				float _SecondRoadNoiseMaskTreshold;
				float _BumpScale;
				sampler2D _BumpMap;
				float _DetailNormalMapScale;
				sampler2D _DetailNormalMap;
				float _SecondRoadNormalScale;
				sampler2D _SecondRoadNormal;
				float _SecondRoadNormalBlend;
				float _Float1;
				float _MainRoadMetalicPower;
				float _SecondRoadMetalicPower;
				float _MainRoadSmoothnessPower;
				float _SecondRoadSmoothnessPower;
				float _MainRoadAmbientOcclusionPower;
				float _SecondRoadAmbientOcclusionPower;
				float _MainRoadAlphaCutOut;
				float _SecondRoadAlphaCutOut;
				
				                
        
				void BuildSurfaceData ( FragInputs fragInputs, GlobalSurfaceDescription surfaceDescription, float3 V, PositionInputs posInput, out SurfaceData surfaceData )
				{
					ZERO_INITIALIZE ( SurfaceData, surfaceData );

					float3 normalTS = float3( 0.0f, 0.0f, 1.0f );
					normalTS = surfaceDescription.Normal;
					float3 doubleSidedConstants = float3(1.0, 1.0, 1.0);
					GetNormalWS ( fragInputs, normalTS, surfaceData.normalWS ,doubleSidedConstants);

					surfaceData.ambientOcclusion = 1.0f;

					surfaceData.baseColor = surfaceDescription.Albedo;
					surfaceData.perceptualSmoothness = surfaceDescription.Smoothness;
					surfaceData.ambientOcclusion = surfaceDescription.Occlusion;

					surfaceData.materialFeatures = MATERIALFEATUREFLAGS_LIT_STANDARD;

	#ifdef _MATERIAL_FEATURE_SPECULAR_COLOR
					surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_SPECULAR_COLOR;
					surfaceData.specularColor = surfaceDescription.Specular;
	#else
					surfaceData.metallic = surfaceDescription.Metallic;
	#endif

	#if defined(_MATERIAL_FEATURE_SUBSURFACE_SCATTERING) || defined(_MATERIAL_FEATURE_TRANSMISSION)
					surfaceData.diffusionProfileHash = asuint (surfaceDescription.DiffusionProfile);
	#endif

	#ifdef _MATERIAL_FEATURE_SUBSURFACE_SCATTERING
					surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_SUBSURFACE_SCATTERING;
					surfaceData.subsurfaceMask = surfaceDescription.SubsurfaceMask;
	#else
					surfaceData.subsurfaceMask = 1.0f;
	#endif

	#ifdef _MATERIAL_FEATURE_TRANSMISSION
					surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_TRANSMISSION;
					surfaceData.thickness = surfaceDescription.Thickness;
	#endif

					surfaceData.tangentWS = normalize ( fragInputs.worldToTangent[ 0 ].xyz );
					surfaceData.tangentWS = Orthonormalize ( surfaceData.tangentWS, surfaceData.normalWS );

	#ifdef _MATERIAL_FEATURE_ANISOTROPY
					surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_ANISOTROPY;
					surfaceData.anisotropy = surfaceDescription.Anisotropy;

	#else
					surfaceData.anisotropy = 0;
	#endif

	#ifdef _MATERIAL_FEATURE_CLEAR_COAT
					surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_CLEAR_COAT;
					surfaceData.coatMask = surfaceDescription.CoatMask;
	#else
					surfaceData.coatMask = 0.0f;
	#endif

	#ifdef _MATERIAL_FEATURE_IRIDESCENCE
					surfaceData.materialFeatures |= MATERIALFEATUREFLAGS_LIT_IRIDESCENCE;
					surfaceData.iridescenceThickness = surfaceDescription.IridescenceThickness;
					surfaceData.iridescenceMask = surfaceDescription.IridescenceMask;
	#else
					surfaceData.iridescenceThickness = 0.0;
					surfaceData.iridescenceMask = 1.0;
	#endif

					//ASE CUSTOM TAG
	#ifdef _MATERIAL_FEATURE_TRANSPARENCY
					surfaceData.ior = surfaceDescription.IndexOfRefraction;
					surfaceData.transmittanceColor = surfaceDescription.TransmittanceColor;
					surfaceData.atDistance = surfaceDescription.TransmittanceAbsorptionDistance;
					surfaceData.transmittanceMask = surfaceDescription.TransmittanceMask;
	#else
					surfaceData.ior = 1.0;
					surfaceData.transmittanceColor = float3( 1.0, 1.0, 1.0 );
					surfaceData.atDistance = 1000000.0;
					surfaceData.transmittanceMask = 0.0;
	#endif

					surfaceData.specularOcclusion = 1.0;

	#if defined(_BENTNORMALMAP) && defined(_ENABLESPECULAROCCLUSION)
					surfaceData.specularOcclusion = GetSpecularOcclusionFromBentAO ( V, bentNormalWS, surfaceData );
	#elif defined(_MASKMAP)
					surfaceData.specularOcclusion = GetSpecularOcclusionFromAmbientOcclusion ( NdotV, surfaceData.ambientOcclusion, PerceptualSmoothnessToRoughness ( surfaceData.perceptualSmoothness ) );
	#endif
				#if HAVE_DECALS
					if (_EnableDecals)
					{
						DecalSurfaceData decalSurfaceData = GetDecalSurfaceData (posInput, surfaceDescription.Alpha);
						ApplyDecalToSurfaceData (decalSurfaceData, surfaceData);
					}
				#endif
				}
        
				void GetSurfaceAndBuiltinData( GlobalSurfaceDescription surfaceDescription , FragInputs fragInputs, float3 V, inout PositionInputs posInput, out SurfaceData surfaceData, out BuiltinData builtinData)
				{
				#if _ALPHATEST_ON
					DoAlphaTest ( surfaceDescription.Alpha, surfaceDescription.AlphaClipThreshold );
				#endif
		
					BuildSurfaceData(fragInputs, surfaceDescription, V, posInput, surfaceData);
					InitBuiltinData (posInput, surfaceDescription.Alpha, surfaceData.normalWS, -fragInputs.worldToTangent[2], fragInputs.texCoord1, fragInputs.texCoord2, builtinData);
        
					builtinData.emissiveColor =             surfaceDescription.Emission;
					builtinData.distortion =                float2(0.0, 0.0);           // surfaceDescription.Distortion -- if distortion pass
					builtinData.distortionBlur =            0.0;                        // surfaceDescription.DistortionBlur -- if distortion pass
        
					builtinData.depthOffset =               0.0;                        // ApplyPerPixelDisplacement(input, V, layerTexCoord, blendMasks); #ifdef _DEPTHOFFSET_ON : ApplyDepthOffsetPositionInput(V, depthOffset, GetWorldToHClipMatrix(), posInput);
        
					PostInitBuiltinData(V, posInput, surfaceData, builtinData);
				}
        
			
				PackedVaryingsMeshToPS Vert(AttributesMesh inputMesh  )
				{
					PackedVaryingsMeshToPS outputPackedVaryingsMeshToPS;

					UNITY_SETUP_INSTANCE_ID(inputMesh);
					UNITY_TRANSFER_INSTANCE_ID(inputMesh, outputPackedVaryingsMeshToPS);

					float3 ase_worldNormal = TransformObjectToWorldNormal(inputMesh.normalOS);
					float3 ase_worldTangent = TransformObjectToWorldDir(inputMesh.tangentOS.xyz);
					float ase_vertexTangentSign = inputMesh.tangentOS.w * unity_WorldTransformParams.w;
					float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
					outputPackedVaryingsMeshToPS.ase_texcoord6.xyz = ase_worldBitangent;
					
					outputPackedVaryingsMeshToPS.ase_texcoord5.xy = inputMesh.ase_texcoord.xy;
					outputPackedVaryingsMeshToPS.ase_color = inputMesh.ase_color;
					
					//setting value to unused interpolator channels and avoid initialization warnings
					outputPackedVaryingsMeshToPS.ase_texcoord5.zw = 0;
					outputPackedVaryingsMeshToPS.ase_texcoord6.w = 0;
					float3 vertexValue =  float3( 0, 0, 0 ) ;
					#ifdef ASE_ABSOLUTE_VERTEX_POS
					inputMesh.positionOS.xyz = vertexValue;
					#else
					inputMesh.positionOS.xyz += vertexValue;
					#endif
					
					inputMesh.normalOS =  inputMesh.normalOS ;

					float3 positionRWS = TransformObjectToWorld(inputMesh.positionOS);
					float3 normalWS = TransformObjectToWorldNormal(inputMesh.normalOS);
					float4 tangentWS = float4(TransformObjectToWorldDir(inputMesh.tangentOS.xyz), inputMesh.tangentOS.w);

					outputPackedVaryingsMeshToPS.positionCS = TransformWorldToHClip(positionRWS);
					outputPackedVaryingsMeshToPS.interp00.xyz = positionRWS;
					outputPackedVaryingsMeshToPS.interp01.xyz = normalWS;
					outputPackedVaryingsMeshToPS.interp02.xyzw = tangentWS;
					outputPackedVaryingsMeshToPS.interp03.xyzw = inputMesh.uv1;
					outputPackedVaryingsMeshToPS.interp04.xyzw = inputMesh.uv2;
					UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( outputPackedVaryingsMeshToPS );
					return outputPackedVaryingsMeshToPS;
				}

				void Frag(	PackedVaryingsMeshToPS packedInput,
							#ifdef OUTPUT_SPLIT_LIGHTING
								out float4 outColor : SV_Target0, 
								out float4 outDiffuseLighting : SV_Target1,
								OUTPUT_SSSBUFFER (outSSSBuffer)
							#else
								out float4 outColor : SV_Target0
							#ifdef _WRITE_TRANSPARENT_MOTION_VECTOR
								, out float4 outMotionVec : SV_Target1
							#endif 
							#endif 
							#ifdef _DEPTHOFFSET_ON
								, out float outputDepth : SV_Depth
							#endif
						 
						  )
				{
					UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( packedInput );
					FragInputs input;
					ZERO_INITIALIZE(FragInputs, input);
        
					input.worldToTangent = k_identity3x3;
					input.positionSS = packedInput.positionCS;
					float3 positionRWS = packedInput.interp00.xyz;
					float3 normalWS = packedInput.interp01.xyz;
					float4 tangentWS = packedInput.interp02.xyzw;
						
					input.positionRWS = positionRWS;
					input.worldToTangent = BuildWorldToTangent(tangentWS, normalWS);
					input.texCoord1 = packedInput.interp03.xyzw;
					input.texCoord2 = packedInput.interp04.xyzw;

					// input.positionSS is SV_Position
					PositionInputs posInput = GetPositionInput_Stereo(input.positionSS.xy, _ScreenSize.zw, input.positionSS.z, input.positionSS.w, input.positionRWS.xyz, uint2(input.positionSS.xy) / GetTileSize(), unity_StereoEyeIndex);

					float3 normalizedWorldViewDir = GetWorldSpaceNormalizeViewDir ( input.positionRWS );

					SurfaceData surfaceData;
					BuiltinData builtinData;
					GlobalSurfaceDescription surfaceDescription = ( GlobalSurfaceDescription ) 0;
					float2 uv0_MainTex = packedInput.ase_texcoord5.xy * _MainTex_ST.xy + _MainTex_ST.zw;
					float2 uv_MetalicRAmbientOcclusionGHeightBEmissionA = packedInput.ase_texcoord5.xy * _MetalicRAmbientOcclusionGHeightBEmissionA_ST.xy + _MetalicRAmbientOcclusionGHeightBEmissionA_ST.zw;
					float3 ase_worldBitangent = packedInput.ase_texcoord6.xyz;
					float3 tanToWorld0 = float3( tangentWS.xyz.x, ase_worldBitangent.x, normalWS.x );
					float3 tanToWorld1 = float3( tangentWS.xyz.y, ase_worldBitangent.y, normalWS.y );
					float3 tanToWorld2 = float3( tangentWS.xyz.z, ase_worldBitangent.z, normalWS.z );
					float3 ase_tanViewDir =  tanToWorld0 * normalizedWorldViewDir.x + tanToWorld1 * normalizedWorldViewDir.y  + tanToWorld2 * normalizedWorldViewDir.z;
					ase_tanViewDir = normalize(ase_tanViewDir);
					float2 Offset817 = ( ( tex2D( _MetalicRAmbientOcclusionGHeightBEmissionA, uv_MetalicRAmbientOcclusionGHeightBEmissionA ).b - 1 ) * ase_tanViewDir.xy * _MainRoadParallaxPower ) + uv0_MainTex;
					float2 Offset837 = ( ( tex2D( _MetalicRAmbientOcclusionGHeightBEmissionA, Offset817 ).b - 1 ) * ase_tanViewDir.xy * _MainRoadParallaxPower ) + Offset817;
					float2 Offset859 = ( ( tex2D( _MetalicRAmbientOcclusionGHeightBEmissionA, Offset837 ).b - 1 ) * ase_tanViewDir.xy * _MainRoadParallaxPower ) + Offset837;
					float2 Offset886 = ( ( tex2D( _MetalicRAmbientOcclusionGHeightBEmissionA, Offset859 ).b - 1 ) * ase_tanViewDir.xy * _MainRoadParallaxPower ) + Offset859;
					float4 tex2DNode1 = tex2D( _MainTex, Offset886 );
					float4 temp_output_77_0 = ( ( _MainRoadBrightness * tex2DNode1 ) * _MainRoadColor );
					float2 uv0_DetailAlbedoMap = packedInput.ase_texcoord5.xy * _DetailAlbedoMap_ST.xy + _DetailAlbedoMap_ST.zw;
					float4 tex2DNode486 = tex2D( _DetailAlbedoMap, uv0_DetailAlbedoMap );
					float4 blendOpSrc474 = temp_output_77_0;
					float4 blendOpDest474 = ( _DetailAlbedoPower * tex2DNode486 );
					float2 uv0_DetailMask = packedInput.ase_texcoord5.xy * _DetailMask_ST.xy + _DetailMask_ST.zw;
					float4 tex2DNode481 = tex2D( _DetailMask, uv0_DetailMask );
					float4 lerpResult480 = lerp( temp_output_77_0 , (( blendOpDest474 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest474 ) * ( 1.0 - blendOpSrc474 ) ) : ( 2.0 * blendOpDest474 * blendOpSrc474 ) ) , ( _DetailAlbedoPower * tex2DNode481.a ));
					float2 uv0_TextureSample3 = packedInput.ase_texcoord5.xy * _TextureSample3_ST.xy + _TextureSample3_ST.zw;
					float2 uv_SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA = packedInput.ase_texcoord5.xy * _SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA_ST.xy + _SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA_ST.zw;
					float2 Offset819 = ( ( tex2D( _SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA, uv_SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA ).b - 1 ) * ase_tanViewDir.xy * _SecondRoadParallaxPower ) + uv0_TextureSample3;
					float2 Offset839 = ( ( tex2D( _SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA, Offset819 ).b - 1 ) * ase_tanViewDir.xy * _SecondRoadParallaxPower ) + Offset819;
					float2 Offset863 = ( ( tex2D( _SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA, Offset839 ).b - 1 ) * ase_tanViewDir.xy * _SecondRoadParallaxPower ) + Offset839;
					float2 Offset885 = ( ( tex2D( _SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA, Offset863 ).b - 1 ) * ase_tanViewDir.xy * _SecondRoadParallaxPower ) + Offset863;
					float4 tex2DNode537 = tex2D( _TextureSample3, Offset885 );
					float4 temp_output_540_0 = ( ( _SecondRoadBrightness * tex2DNode537 ) * _SecondRoadColor );
					float4 blendOpSrc619 = temp_output_540_0;
					float4 blendOpDest619 = ( tex2DNode486 * _Float2 );
					float4 lerpResult618 = lerp( temp_output_540_0 , (( blendOpDest619 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest619 ) * ( 1.0 - blendOpSrc619 ) ) : ( 2.0 * blendOpDest619 * blendOpSrc619 ) ) , ( _Float2 * tex2DNode481.a ));
					float4 break666 = ( packedInput.ase_color / float4( 1,1,1,1 ) );
					float2 uv0_TextureSample1 = packedInput.ase_texcoord5.xy * _TextureSample1_ST.xy + _TextureSample1_ST.zw;
					float clampResult673 = clamp( pow( abs( ( min( min( min( tex2D( _TextureSample1, uv0_TextureSample1 ).r , tex2D( _TextureSample1, ( uv0_TextureSample1 * float2( 0.5,0.5 ) ) ).r ) , tex2D( _TextureSample1, ( uv0_TextureSample1 * float2( 0.2,0.2 ) ) ).r ) , tex2D( _TextureSample1, ( uv0_TextureSample1 * float2( 0.36,0.35 ) ) ).r ) * _SecondRoadNoiseMaskPower ) ) , abs( _SecondRoadNoiseMaskTreshold ) ) , 0.0 , 1.0 );
					float4 appendResult665 = (float4(( break666.r - clampResult673 ) , break666.g , break666.b , break666.a));
					float4 clampResult672 = clamp( appendResult665 , float4( 0,0,0,0 ) , float4( 1,1,1,1 ) );
					float4 lerpResult592 = lerp( lerpResult480 , lerpResult618 , ( 1.0 - clampResult672 ).x);
					
					float3 tex2DNode4 = UnpackNormalmapRGorAG( tex2D( _BumpMap, Offset886 ), _BumpScale );
					float3 lerpResult479 = lerp( tex2DNode4 , BlendNormal( tex2DNode4 , UnpackNormalmapRGorAG( tex2D( _DetailNormalMap, uv0_DetailAlbedoMap ), _DetailNormalMapScale ) ) , tex2DNode481.a);
					float3 tex2DNode535 = UnpackNormalmapRGorAG( tex2D( _SecondRoadNormal, Offset885 ), _SecondRoadNormalScale );
					float3 lerpResult570 = lerp( lerpResult479 , tex2DNode535 , _SecondRoadNormalBlend);
					float3 lerpResult617 = lerp( tex2DNode535 , BlendNormal( lerpResult570 , UnpackNormalmapRGorAG( tex2D( _DetailNormalMap, uv0_DetailAlbedoMap ), _Float1 ) ) , tex2DNode481.a);
					float3 lerpResult593 = lerp( lerpResult479 , lerpResult617 , ( 1.0 - clampResult672 ).x);
					
					float4 tex2DNode2 = tex2D( _MetalicRAmbientOcclusionGHeightBEmissionA, Offset886 );
					float4 tex2DNode536 = tex2D( _SecondRoadMetallicRAmbientocclusionGHeightBSmoothnessA, Offset885 );
					float lerpResult601 = lerp( ( tex2DNode2.r * _MainRoadMetalicPower ) , ( tex2DNode536.r * _SecondRoadMetalicPower ) , ( 1.0 - clampResult672 ).x);
					
					float lerpResult594 = lerp( ( tex2DNode2.a * _MainRoadSmoothnessPower ) , ( _SecondRoadSmoothnessPower * tex2DNode536.a ) , ( 1.0 - clampResult672 ).x);
					
					float clampResult96 = clamp( tex2DNode2.g , ( 1.0 - _MainRoadAmbientOcclusionPower ) , 1.0 );
					float clampResult546 = clamp( tex2DNode536.g , ( 1.0 - _SecondRoadAmbientOcclusionPower ) , 1.0 );
					float lerpResult602 = lerp( clampResult96 , clampResult546 , ( 1.0 - clampResult672 ).x);
					
					float temp_output_629_0 = ( tex2DNode1.a * _MainRoadAlphaCutOut );
					#ifdef _IGNORESECONDROADALPHA_ON
					float staticSwitch685 = temp_output_629_0;
					#else
					float staticSwitch685 = ( tex2DNode537.a * _SecondRoadAlphaCutOut );
					#endif
					float lerpResult628 = lerp( temp_output_629_0 , staticSwitch685 , ( 1.0 - clampResult672 ).x);
					
					surfaceDescription.Albedo = lerpResult592.rgb;
					surfaceDescription.Normal = lerpResult593;
					surfaceDescription.Emission = 0;
					surfaceDescription.Specular = 0;
					surfaceDescription.Metallic = lerpResult601;
					surfaceDescription.Smoothness = lerpResult594;
					surfaceDescription.Occlusion = lerpResult602;
					surfaceDescription.Alpha = lerpResult628;
					surfaceDescription.AlphaClipThreshold = 0.5;

	#ifdef _MATERIAL_FEATURE_CLEAR_COAT
					surfaceDescription.CoatMask = 0;
	#endif

	#if defined(_MATERIAL_FEATURE_SUBSURFACE_SCATTERING) || defined(_MATERIAL_FEATURE_TRANSMISSION)
					surfaceDescription.DiffusionProfile = asfloat(uint(1074012128));
	#endif

	#ifdef _MATERIAL_FEATURE_SUBSURFACE_SCATTERING
					surfaceDescription.SubsurfaceMask = 1;
	#endif

	#ifdef _MATERIAL_FEATURE_TRANSMISSION
					surfaceDescription.Thickness = 0;
	#endif

	#ifdef _MATERIAL_FEATURE_ANISOTROPY
					surfaceDescription.Anisotropy = 0;
	#endif

	#ifdef _MATERIAL_FEATURE_IRIDESCENCE
					surfaceDescription.IridescenceThickness = 0;
					surfaceDescription.IridescenceMask = 1;
	#endif

	#ifdef _MATERIAL_FEATURE_TRANSPARENCY
					surfaceDescription.IndexOfRefraction = 1;
					surfaceDescription.TransmittanceColor = float3( 1, 1, 1 );
					surfaceDescription.TransmittanceAbsorptionDistance = 1000000;
					surfaceDescription.TransmittanceMask = 0;
	#endif
					GetSurfaceAndBuiltinData(surfaceDescription, input, normalizedWorldViewDir, posInput, surfaceData, builtinData);

					BSDFData bsdfData = ConvertSurfaceDataToBSDFData(input.positionSS.xy, surfaceData);

					PreLightData preLightData = GetPreLightData(normalizedWorldViewDir, posInput, bsdfData);

					outColor = float4(0.0, 0.0, 0.0, 0.0);

					{
				#ifdef _SURFACE_TYPE_TRANSPARENT
						uint featureFlags = LIGHT_FEATURE_MASK_FLAGS_TRANSPARENT;
				#else
						uint featureFlags = LIGHT_FEATURE_MASK_FLAGS_OPAQUE;
				#endif
						float3 diffuseLighting;
						float3 specularLighting;

						LightLoop(normalizedWorldViewDir, posInput, preLightData, bsdfData, builtinData, featureFlags, diffuseLighting, specularLighting);
						
						diffuseLighting *= GetCurrentExposureMultiplier();
						specularLighting *= GetCurrentExposureMultiplier();

				#ifdef OUTPUT_SPLIT_LIGHTING
						if (_EnableSubsurfaceScattering != 0 && ShouldOutputSplitLighting(bsdfData))
						{
							outColor = float4(specularLighting, 1.0);
							outDiffuseLighting = float4(TagLightingForSSS(diffuseLighting), 1.0);
						}
						else
						{
							outColor = float4(diffuseLighting + specularLighting, 1.0);
							outDiffuseLighting = 0;
						}
						ENCODE_INTO_SSSBUFFER(surfaceData, posInput.positionSS, outSSSBuffer);
				#else
						outColor = ApplyBlendMode(diffuseLighting, specularLighting, builtinData.opacity);
						outColor = EvaluateAtmosphericScattering(posInput, normalizedWorldViewDir, outColor);
				#endif
					#ifdef _WRITE_TRANSPARENT_MOTION_VECTOR
						//VaryingsPassToPS inputPass = UnpackVaryingsPassToPS (packedInput.vpass);
						//bool forceNoMotion = any (unity_MotionVectorsParams.yw == 0.0);
						//if (forceNoMotion)
						//{
						//	outMotionVec = float4(2.0, 0.0, 0.0, 0.0);
						//}
						//else
						//{
						//	float2 motionVec = CalculateMotionVector (inputPass.positionCS, inputPass.previousPositionCS);
						//	EncodeMotionVector (motionVec * 0.5, outMotionVec);
						//	outMotionVec.zw = 1.0;
						//}
					#endif
					}

				#ifdef _DEPTHOFFSET_ON
					outputDepth = posInput.deviceDepth;
				#endif
				}

            ENDHLSL
        }
		
    }
    
	CustomEditor "ASEMaterialInspector"
	
}
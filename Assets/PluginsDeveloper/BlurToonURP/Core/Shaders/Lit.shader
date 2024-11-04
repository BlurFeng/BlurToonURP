Shader "BlurToonURP/Lit"
{
    Properties
    {
        //----------- 基础纹理 BaseMap-----------
        _BaseMap("Base Map", 2D) = "white" {} //基础贴图
        [HDR]_BaseColor("Base Color", Color) = (1, 1, 1, 1)
        
        //----------- 外描边 Outline -----------
        _FloatOutlineType("Outline Type", Float) = 0 //外描边类型 0=VertexNormal 1=VertexColor 2=VertexTangent
        _FloatOutlineWidthType("Outline Width Type", Float) = 0 //外描边宽度类型 ●记录值 确认当前的keywords设置
        [HDR]_ColorOutlineColor ("Outline Color", Color) = (0.4,0.4,0.4,1) //颜色
        _FloatOutlineWidth ("Outline Width", Float ) = 1.5 //宽度
        _ToggleOutlineBaseMapBlend ("Outline BaseMapBlend", Float ) = 1 //开关 基础贴图混合
        _FloatOutlineBaseMapBlendIntensity ("Outline BaseMapBlend Intensity", Range(0, 1) ) = 1 //基础贴图混合 强度
    }

    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Opaque"
        }

        //基础渲染
        Pass
        {
            Name "ForwardLit"
            Tags {"LightMode" = "UniversalForward"}
            Blend SrcAlpha OneMinusSrcAlpha
            
            HLSLPROGRAM

            // Keywords -------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            // BlurToonURP Keywords
            #pragma shader_feature_local _BASEMAP_SHADER_THRESHOLDMAP_ON //暗部阈值贴图
            // Keywords -------------------------------------

            #pragma vertex vert //顶点着色器
            #pragma fragment frag //片元着色器

            //URP常用的核心方法库
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"

            //顶点着色器 输入数据结构
            struct Attributes
            {
                float4 positionOS : POSITION; //对象空间顶点位置
                float2 texcoord   : TEXCOORD0; //纹理坐标

                //GPUInstance功能相关宏 用于传递ID数据
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            //片元着色器 输入数据结构
            struct Varyings
            {
                float4 positionCS : SV_POSITION; //裁剪空间位置
                float2 uv : TEXCOORD0; //传递的纹理坐标

                //GPUInstance功能相关宏 用于传递ID数据
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            //定义的字段
            CBUFFER_START(UnityPerMaterial)
            //基础纹理 BaseMap
            //已在"Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"中定义的内容。
            //TEXTURE2D(_BaseMap); SAMPLER(sampler_BaseMap); //基础贴图
            //TEXTURE2D(_BumpMap); SAMPLER(sampler_BumpMap); //法线贴图
            float4 _BaseMap_ST; //基础贴图
            half4 _BaseColor;

            //外描边 Outline
            half _FloatOutlineType; //外描边类型
            half4 _ColorOutlineColor; //颜色
            half _FloatOutlineWidth; //宽度
            half _ToggleOutlineBaseMapBlend; //开关 基础贴图混合
            half _FloatOutlineBaseMapBlendIntensity; //基础贴图混合强度
            
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;

                //GPUInstance功能相关宏。
                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_TRANSFER_INSTANCE_ID(IN, OUT);

                VertexPositionInputs vertexInput = GetVertexPositionInputs(IN.positionOS.xyz);
                //VertexNormalInputs normalInput = GetVertexNormalInputs(IN.normalOS, IN.tangentOS);

                //不使用TRANSFORM_TEX()进行缩放和偏移，NPR一般不需要在此处进行缩放，节省这一步的计算。
                //但我们任然可以根据不同贴图各自的设定进行转换。
                OUT.uv = IN.texcoord;
                OUT.positionCS = vertexInput.positionCS;

                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                //GPUInstance功能相关宏。
                UNITY_SETUP_INSTANCE_ID(IN);

                float2 uv = IN.uv;
                //基础贴图采样。sampler_BaseMap是Unity自动生成的对应采样器不需要额外定义。
                float4 colorBaseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, uv) * _BaseColor;

                return colorBaseMap;
            }

            ENDHLSL
        }
        
        //外描边
        Pass
        {
            Name "Outline"
            
            Tags {"LightMode" = "SRPDefaultUnlit"} //不受光照影响
            
            ZWrite On
            Cull Front
            Blend SrcAlpha OneMinusSrcAlpha
            
            HLSLPROGRAM

            // Keywords -------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            // BlurToonURP Keywords
            //外描边
            #pragma shader_feature_local _OUTLINE_ON
            #pragma shader_feature_local _OUTLINE_WIDTH_SAME _OUTLINE_WIDTH_SCALING
            // Keywords -------------------------------------

            #pragma vertex vert //顶点着色器
            #pragma fragment frag //片元着色器

            //URP常用的核心方法库
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
            
            CBUFFER_START(UnityPerMaterial)
            //基础纹理 BaseMap
            //已在"Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"中定义的内容。
            //TEXTURE2D(_BaseMap); SAMPLER(sampler_BaseMap); //基础贴图
            //TEXTURE2D(_BumpMap); SAMPLER(sampler_BumpMap); //法线贴图
            float4 _BaseMap_ST; //基础贴图
            half4 _BaseColor;

            //外描边
            half _FloatOutlineType;
            half4 _ColorOutlineColor;
            half _FloatOutlineWidth;
            half _ToggleOutlineBaseMapBlend;
            half _FloatOutlineBaseMapBlendIntensity;
            CBUFFER_END

            //顶点着色器 输入数据结构
            struct VertexInput
            {
                float4 positionOS : POSITION; //对象空间顶点位置
                float2 texcoord : TEXCOORD0; //纹理坐标
                float3 normalOS : NORMAL; //对象空间法线
                float4 tangentOS : TANGENT; //对象空间切线
                float4 color : COLOR; //颜色

                //GPUInstance功能相关宏 用于传递ID数据
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            //片元着色器 输入数据结构
            struct Varyings
            {
                float4 positionCS : SV_POSITION; //裁剪空间位置
                float2 uv : TEXCOORD0; //传递的纹理坐标
                float3 positionWS : TEXCOORD1; //世界空间位置
                float4 shadowCoord : TEXCOORD2; //阴影坐标
                float4 color : COLOR; //颜色
                
                //GPUInstance功能相关宏 用于传递ID数据
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            Varyings vert (VertexInput IN)
            {
                Varyings OUT = (Varyings)0;

                //GPUInstance功能相关宏。
                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_TRANSFER_INSTANCE_ID(IN, OUT);

                #if defined(_OUTLINE_ON)

                VertexPositionInputs vertexInput = GetVertexPositionInputs(IN.positionOS.xyz);
                VertexNormalInputs normalInput = GetVertexNormalInputs(IN.normalOS, IN.tangentOS);

                //坐标转换
                OUT.uv = IN.texcoord;
                OUT.positionWS = vertexInput.positionWS;
                //阴影坐标
                OUT.shadowCoord = TransformWorldToShadowCoord(OUT.positionWS);

                //描边宽度
                half outlineWidth = _FloatOutlineWidth * 0.001;

                //切线
                real sign = IN.tangentOS.w * GetOddNegativeScale();
                half4 tangentWS = half4(normalInput.tangentWS.xyz, sign);

                //顶点色法线
                float3 colorDir = IN.color.rgb;
                float3 binormalWS = cross(normalInput.normalWS, colorDir) * tangentWS.w;//副法线
                colorDir = normalize(mul(colorDir, half3x3(tangentWS.xyz, binormalWS, normalInput.normalWS)));

                //描边类型，通过lerp和step构建的if选择器
                float3 moveDir =
                    lerp(normalInput.normalWS.rgb,
                    lerp(colorDir, tangentWS, step(1.01, _FloatOutlineType)),
                    step(0.01, _FloatOutlineType)
                    );
                moveDir = normalize(moveDir);
                #if defined(_OUTLINE_WIDTH_SAME) //等宽
                    //沿法线方向外扩
                    OUT.positionCS = TransformWorldToHClip(OUT.positionWS.xyz + moveDir * outlineWidth);
                #elif defined(_OUTLINE_WIDTH_SCALING) //变化
                    half3 vertDir = normalize(IN.positionOS).xyz;
                    half signVertNormal = dot(vertDir, moveDir) + 0.3;
                    OUT.positionCS = TransformWorldToHClip(OUT.positionWS.xyz + moveDir * outlineWidth * signVertNormal);
                #endif

                //TODO 实时光照相关，描边受光照和阴影的影响
                OUT.color.rgb = half3(1, 1, 1);
                
                #endif

                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                //GPUInstance功能相关宏。
                UNITY_SETUP_INSTANCE_ID(IN);

                half4 colorFinal = half4(1, 1, 1, 1);
                
                #if defined(_OUTLINE_ON)

                //外描边颜色和光照色混合
                half4 colorOutlineLightBlend = _ColorOutlineColor * IN.color;

                //基础贴图颜色混合
                half4 colorBaseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, TRANSFORM_TEX(IN.uv, _BaseMap)) * _BaseColor;
                half4 colorBaseMapBlend = lerp(colorOutlineLightBlend, colorOutlineLightBlend * colorBaseMap, _FloatOutlineBaseMapBlendIntensity);
                colorFinal = lerp(colorOutlineLightBlend, colorBaseMapBlend, _ToggleOutlineBaseMapBlend);

                //TODO 纹理贴图颜色混合

                //TODO 表面类型
                colorFinal = half4(colorFinal.rgb, 1);

                #endif

                return colorFinal;
            }

            ENDHLSL
        }
    }

    CustomEditor "BlurToonURP.EditorGUIx.ShaderGUILit"
}
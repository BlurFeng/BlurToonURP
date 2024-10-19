Shader "BlurToonURP/Lit"
{
    Properties
    {
        //基础纹理
        _BaseMap("Base Map", 2D) = "white" {} //基础贴图
        [HDR]_BaseColor("Base Color", Color) = (1, 1, 1, 1)
    }

    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Opaque"
        }

        Pass
        {
            HLSLPROGRAM

            // -------------------------------------
            // BlurToonURP Keywords
            #pragma shader_feature_local _BASEMAP_SHADER_THRESHOLDMAP_ON //暗部阈值贴图


            #pragma vertex vert //顶点着色器
            #pragma fragment frag //片元着色器

            //URP常用的核心方法库
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"

            //顶点着色器输入数据
            struct Attributes
            {
                float4 positionOS : POSITION; //对象空间顶点位置
                float2 texcoord   : TEXCOORD0; //纹理坐标

                //GPUInstance功能相关宏，用于传递ID数据
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            //片元着色器输入数据
            struct Varyings
            {
                float4 positionCS : SV_POSITION; //裁剪空间位置
                float2 uv : TEXCOORD0; //传递的纹理坐标

                //GPUInstance功能相关宏，用于传递ID数据
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            CBUFFER_START(UnityPerMaterial)
            //已在"Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"中定义的内容。
            //TEXTURE2D(_BaseMap); SAMPLER(sampler_BaseMap); //基础贴图
            //TEXTURE2D(_BumpMap); SAMPLER(sampler_BumpMap); //法线贴图
            half4 _BaseColor;
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

    }

    CustomEditor "BlurToonURP.EditorGUIx.ShaderGUILit"
}
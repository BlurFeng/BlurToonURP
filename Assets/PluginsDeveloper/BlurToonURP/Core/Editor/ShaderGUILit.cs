using UnityEditor;
using UnityEngine;

namespace BlurToonURP.EditorGUIx
{
    public class ShaderGUILit : ShaderGUIBase
    {
        protected override void OnGUIDraw()
        {
            base.OnGUIDraw();

            EditorGUIx.FoldoutPanel("【基础贴图 BaseMap】基础贴图及暗部贴图", PanelMainBasicMap);
            EditorGUIx.FoldoutPanel("【外描边 Outline】粗细、颜色", PanelMainOutline);
        }

        #region 主面板-基础贴图
        private static readonly GUIContent contentBaseMap = new GUIContent("基础贴图", "基础色 : 贴图采样色(sRGB) × 自定义色(RGB), 默认:白色)");
        private static readonly GUIContent contentBaseNormalMap = new GUIContent("法线贴图", "法线偏移 : 贴图采样矢量(sRGB)进行法线偏移");
        private static readonly GUIContent contentBaseMapShadeThresholdMap = new GUIContent("暗部阈值贴图", "通过阈值贴图控制暗部1的分布与强度。暗部强度 : 纹理采样(linear)");

        /// <summary>
        /// 关键词 暗部阈值贴图
        /// </summary>
        private const string m_MatKeywordShadeThresholdMap = "_BASEMAP_SHADE_THRESHOLDMAP_ON";

        /// <summary>
        /// 主面板 基础贴图
        /// </summary>
        /// <param name="material"></param>
        private void PanelMainBasicMap()
        {

            //条目 基础贴图
            GUILayout.Label("基础贴图", EditorStyles.boldLabel);
            EditorGUILayout.BeginHorizontal();
            MaterialEditor.TexturePropertySingleLine(contentBaseMap, GetMaterialProperty("_BaseMap"), GetMaterialProperty("_BaseColor"));
            EditorGUILayout.EndHorizontal();

            
        }

        /// <summary>
        /// 子界面 暗部阈值贴图
        /// </summary>
        /// <param name="material"></param>
        private void PanelSubShadeThresholdMap()
        {
            var matPropToggleShadeThresholdMap = GetMaterialProperty("_ToggleShadeThresholdMap");
            EditorGUIx.BtnToggleLabel("暗部阈值贴图-主开关", matPropToggleShadeThresholdMap);
            if (matPropToggleShadeThresholdMap.floatValue == 1)
                Material.EnableKeyword(m_MatKeywordShadeThresholdMap);
            else
            {
                Material.DisableKeyword(m_MatKeywordShadeThresholdMap);
                return;
            }

            //条目 暗部阈值贴图
            var matPropTexShadeThresholdMap = GetMaterialProperty("_TexShadeThresholdMap");
            MaterialEditor.TexturePropertySingleLine(contentBaseMapShadeThresholdMap, matPropTexShadeThresholdMap);
            MaterialEditor.TextureScaleOffsetProperty(matPropTexShadeThresholdMap);
            //条目 暗部阈值贴图强度
            MaterialEditor.RangeProperty(GetMaterialProperty("_FloatShadeThresholdMapIntensity"), "强度");
        }
        #endregion
        
        #region 主面板-外描边
        private static GUIContent contentOutline = new GUIContent("外描边-主开关", "设置外描边开启或关闭。");
        private static GUIContent contentOutlineType = new GUIContent("描边类型", "法线(顶点色法线)外扩描边。 VertexNormal : 顶点法线，VertexColor : 顶点颜色");
        private static GUIContent contentOutlineWidthType = new GUIContent("宽度类型", "Same : 相同宽度，Scaling : 变化宽度");
        private static GUIContent contentOutlineBaseMapBlend = new GUIContent("基础贴图混合", "与基础贴图的颜色进行混合，使描边色更加自然。");

        /// <summary>
        /// 关键词 外描边 开启
        /// </summary>
        private const string m_MatKeywordOutlineOn = "_OUTLINE_ON";
        /// <summary>
        /// 关键词 外描边 相同宽度
        /// </summary>
        private const string m_MatKeywordOutlineSameWidth = "_OUTLINE_WIDTH_SAME";
        /// <summary>
        /// 关键词 外描边 变化宽度
        /// </summary>
        private const string m_MatKeywordOutlineScaling = "_OUTLINE_WIDTH_SCALING";
        /// <summary>
        /// 通道名称 外描边
        /// </summary>
        private const string m_MatPassNameOutline = "Outline";

        /// <summary>
        /// 描边类型
        /// </summary>
        private enum EOutlineType
        {
            /// <summary>
            /// 顶点法线
            /// </summary>
            VertexNormal,
            /// <summary>
            /// 顶点颜色
            /// </summary>
            VertexColor,
            /// <summary>
            /// 顶点切线
            /// </summary>
            VertexTangent
        }

        /// <summary>
        /// 描边宽度类型
        /// </summary>
        private enum EOutlineWidthType
        {
            /// <summary>
            /// 相同宽度
            /// </summary>
            Same,
            /// <summary>
            /// 变化宽度
            /// </summary>
            Scaling
        }

        /// <summary>
        /// 主面板 外描边
        /// </summary>
        private void PanelMainOutline()
        {
            //条目 主开关
            EditorGUIx.BtnToggleLabelPass(contentOutline, Material, m_MatPassNameOutline);
            //设置 关键词
            if (Material.GetShaderPassEnabled(m_MatPassNameOutline) == true)
            {
                Material.EnableKeyword(m_MatKeywordOutlineOn);
            }
            else
            {
                Material.DisableKeyword(m_MatKeywordOutlineOn);
                return;
            }

            //条目 描边类型
            EditorGUIx.DropdownEnum(contentOutlineType, GetMaterialProperty("_FloatOutlineType"), typeof(EOutlineType), MaterialEditor);

            //条目 描边宽度类型
            var matPropFloatOutlineWidthType = GetMaterialProperty("_FloatOutlineWidthType");
            EditorGUIx.DropdownEnum(contentOutlineWidthType, matPropFloatOutlineWidthType, typeof(EOutlineWidthType), MaterialEditor);
            //应用材质球属性-描边类型
            switch ((EOutlineWidthType)matPropFloatOutlineWidthType.floatValue)
            {
                case EOutlineWidthType.Same: //相同宽度
                    Material.EnableKeyword(m_MatKeywordOutlineSameWidth);
                    Material.DisableKeyword(m_MatKeywordOutlineScaling);
                    break;
                case EOutlineWidthType.Scaling: //距离缩放
                    Material.DisableKeyword(m_MatKeywordOutlineSameWidth);
                    Material.EnableKeyword(m_MatKeywordOutlineScaling);
                    break;
            }

            //条目 外描边颜色
            MaterialEditor.ColorProperty(GetMaterialProperty("_ColorOutlineColor"), "颜色");
            //条目 外描边宽度
            MaterialEditor.FloatProperty(GetMaterialProperty("_FloatOutlineWidth"), "宽度");
            EditorGUILayout.Space();

            //条目 基础贴图颜色混合
            var matPropToggleOutlineBaseMapBlend = GetMaterialProperty("_ToggleOutlineBaseMapBlend");
            EditorGUIx.BtnToggleLabel(contentOutlineBaseMapBlend, matPropToggleOutlineBaseMapBlend);
            if (matPropToggleOutlineBaseMapBlend.floatValue == 1)
            {
                EditorGUI.indentLevel++;
                //条目 基础贴图颜色混合强度
                MaterialEditor.RangeProperty(GetMaterialProperty("_FloatOutlineBaseMapBlendIntensity"), "| 混合强度");
                EditorGUI.indentLevel--;
            }
            EditorGUILayout.Space();
        }
        #endregion
    }
}

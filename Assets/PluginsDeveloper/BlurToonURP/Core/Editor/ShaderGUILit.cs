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
    }
}

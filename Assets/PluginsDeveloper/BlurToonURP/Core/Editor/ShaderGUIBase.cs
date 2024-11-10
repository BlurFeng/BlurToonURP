using UnityEngine;
using UnityEditor;
using System.Collections.Generic;

namespace BlurToonURP.EditorGUIx
{
    public class ShaderGUIBase : ShaderGUI
    {
        /// <summary>
        /// 当前的材质球编辑器
        /// </summary>
        public MaterialEditor MaterialEditor {  get; private set; }

        /// <summary>
        /// 当前的材质球
        /// </summary>
        protected Material Material { get; private set; }

        private bool _isInitMaterialProperty;
        private MaterialProperty[] _materialProperties;
        private readonly Dictionary<string, MaterialProperty> _materialPropertyDic = new Dictionary<string, MaterialProperty>();

        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            //base.OnGUI(materialEditor, properties);

            EditorGUIUtility.fieldWidth = 0f;

            //获取材质球及属性列表
            MaterialEditor = materialEditor;
            Material = materialEditor.target as Material;
            InitMatProperty(properties);

            EditorGUI.BeginChangeCheck();

            OnGUIDraw();

            if (EditorGUI.EndChangeCheck())
                materialEditor.PropertiesChanged();
        }

        /// <summary>
        /// 子类重写此方法用于绘制GUI
        /// </summary>
        protected virtual void OnGUIDraw()
        {

        }

        /// <summary>
        /// 记录材质球属性列表并生成Dic用于查找。
        /// </summary>
        /// <param name="properties"></param>
        private void InitMatProperty(MaterialProperty[] properties)
        {
            if (_isInitMaterialProperty) return;
            _isInitMaterialProperty = true;

            _materialProperties = properties;
            if (_materialProperties == null) return;

            _materialPropertyDic.Clear();
            for (int i = 0; i < _materialProperties.Length; i++)
            {
                var item = _materialProperties[i];
                _materialPropertyDic.Add(item.name, item);
            }
        }

        /// <summary>
        /// 获取材质球属性，优先从Dic获取。
        /// </summary>
        /// <param name="name"></param>
        /// <returns></returns>
        protected MaterialProperty GetMaterialProperty(string name)
        {
            if (!_materialPropertyDic.TryGetValue(name, out MaterialProperty matP))
            {
                matP = FindProperty(name, _materialProperties);
                if (matP == null)
                    Debug.LogError($"BlurToonURP ShaderGUIBase.GetMaterialProperty() Error! can't find MaterialProperty by name : {name}");
                else
                    _materialPropertyDic.Add(name, matP);
            }

            return matP;
        }
    }
}
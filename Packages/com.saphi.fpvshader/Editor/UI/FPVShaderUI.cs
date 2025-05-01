#if UNITY_EDITOR

using UnityEngine;
using UnityEditor;
using System;

namespace Saphi.FPVShader
{


    public class FPVShaderUI : ShaderGUI
    {
        private Texture2D logo;
        Material target;
        MaterialEditor editor;
        MaterialProperty[] properties;

        public override void OnGUI(MaterialEditor editor, MaterialProperty[] properties)
        {
            this.editor = editor;
            this.properties = properties;
            this.target = editor.target as Material;


            setlogo();

            GUILayout.Space(10);

            MainProps();
            Rendering();
        }

        MaterialProperty getProperty(string name)
        {
            return FindProperty(name, properties);
        }

        void setlogo()
        {

            logo = AssetDatabase.LoadAssetAtPath<Texture2D>("Packages/com.saphi.fpvshader/Editor/Assets/Logo.png");

            // Center the image in a horizontal and vertical layout group
            GUILayout.BeginHorizontal();
            GUILayout.FlexibleSpace();
            GUILayout.BeginVertical();
            GUILayout.FlexibleSpace();
            GUILayout.Label(logo, GUILayout.MaxHeight(100));
            GUILayout.FlexibleSpace();
            GUILayout.EndVertical();
            GUILayout.FlexibleSpace();
            GUILayout.EndHorizontal();
        }

        //static GUIContent staticLabel = new GUIContent();
        static GUIContent buildLabel(string text, string tooltip = null)
        {
            GUIContent label = new GUIContent();
            label.text = text;
            label.tooltip = tooltip;
            return label;
        }

        void MainProps()
        {
            bool showMain;
            string toggle = "_ShowMain";

            if (target.GetFloat(toggle) == 1)
            {
                showMain = true;
            }
            else
            {
                showMain = false;
            }

            showMain = EditorGUILayout.Foldout(showMain, "Main", true, EditorStyles.foldoutHeader);
            if (showMain)
            {
                target.SetFloat(toggle, 1);

                GUILayout.BeginVertical("box");
                EditorGUI.indentLevel += 2;


                editor.ShaderProperty(getProperty("_UseHDR"), "Use HDR Color", 2);
                if (target.GetFloat("_UseHDR") == 1){
                    editor.ShaderProperty(getProperty("_ColorHDR"), "Color HDR", 2);
                }else{
                    editor.ShaderProperty(getProperty("_Color"), "Color", 2);
                }

                editor.ShaderProperty(getProperty("_HueShift"), "HueShift", 2);
                editor.ShaderProperty(getProperty("_Saturation"), "Saturation", 2);
                editor.ShaderProperty(getProperty("_Value"), "Value", 2);
                
                GUILayout.Space(10);

                editor.ShaderProperty(getProperty("_ColorMultiplier"), "Color Multiplier", 2);
                editor.ShaderProperty(getProperty("_Visibility"), "Visibility", 2);


                GUILayout.Space(10);

                EditorGUI.indentLevel -= 2;
                GUILayout.EndVertical();



            }
            else
            {
                target.SetFloat(toggle, 0);
            }
        }


        void Rendering()
        {
            bool showRendering;
            string toggle = "_ShowRendering";

            if (target.GetFloat(toggle) == 1)
            {
                showRendering = true;
            }
            else
            {
                showRendering = false;
            }

            showRendering = EditorGUILayout.Foldout(showRendering, "Rendering", true, EditorStyles.foldoutHeader);
            if (showRendering)
            {
                target.SetFloat(toggle, 1);
                EditorGUI.indentLevel += 2;
                GUILayout.Space(10);
                editor.RenderQueueField();
                EditorGUI.indentLevel -= 2;
            }
            else
            {
                target.SetFloat(toggle, 0);
            }
        }
    }

}

#endif
#if UNITY_EDITOR

using UnityEngine;
using UnityEditor;
using System;

namespace Saphi.FPVShader
{


    public class FPVSurfaceShaderUI : ShaderGUI
    {
        private Texture2D logo;
        Material target;
        MaterialEditor editor;
        MaterialProperty[] properties;

        enum TransparencyBlendMode
        {
            AlphaBlend,
            Premultiplied,
            Additive,
            SoftAdditive,
            Multiplicative,
            DoubleMultiplicative,
            ParticleAdditive,
        }

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
                EditorGUI.indentLevel += 1;


                
                editor.ShaderProperty(getProperty("_Color"), "Color");
                editor.ShaderProperty(getProperty("_SpecColor"), "Specular Color");
                editor.ShaderProperty(getProperty("_EmissionColor"), "Emission Color");
                editor.ShaderProperty(getProperty("_Emission"), "Emission");
                editor.ShaderProperty(getProperty("_Glossiness"), "Smoothness");
                editor.ShaderProperty(getProperty("_Alpha"), "Alpha");

                GUILayout.Space(10);

                editor.ShaderProperty(getProperty("_HueShift"), "Hue shift");
                editor.ShaderProperty(getProperty("_Saturation"), "Saturation");
                editor.ShaderProperty(getProperty("_Value"), "Value");
                
                GUILayout.Space(10);

                editor.ShaderProperty(getProperty("_ColorMultiplier"), "Color Multiplier");

                GUILayout.Space(10);

                TransparencyMode();

                EditorGUI.indentLevel -= 1;
                GUILayout.EndVertical();



            }
            else
            {
                target.SetFloat(toggle, 0);
            }
        }
        void TransparencyMode()
        {
            TransparencyBlendMode mode = (TransparencyBlendMode)target.GetFloat("_BlendMode");

            EditorGUI.BeginChangeCheck();

            mode = (TransparencyBlendMode)EditorGUILayout.EnumPopup(new GUIContent("Transparency Blend Mode"), mode);

            if (EditorGUI.EndChangeCheck())
            {
                editor.RegisterPropertyChangeUndo("Transparency Blend Mode");
                target.SetFloat("_BlendMode", (float)mode);

                if ((TransparencyBlendMode)target.GetFloat("_BlendMode") == TransparencyBlendMode.AlphaBlend)
                {
                    target.SetFloat("_BlendModeSrc", (float)UnityEngine.Rendering.BlendMode.SrcAlpha);
                    target.SetFloat("_BlendModeDst", (float)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                }

                if ((TransparencyBlendMode)target.GetFloat("_BlendMode") == TransparencyBlendMode.Premultiplied)
                {
                    target.SetFloat("_BlendModeSrc", (float)UnityEngine.Rendering.BlendMode.One);
                    target.SetFloat("_BlendModeDst", (float)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                }

                if ((TransparencyBlendMode)target.GetFloat("_BlendMode") == TransparencyBlendMode.Additive)
                {
                    target.SetFloat("_BlendModeSrc", (float)UnityEngine.Rendering.BlendMode.One);
                    target.SetFloat("_BlendModeDst", (float)UnityEngine.Rendering.BlendMode.One);
                }

                if ((TransparencyBlendMode)target.GetFloat("_BlendMode") == TransparencyBlendMode.SoftAdditive)
                {
                    target.SetFloat("_BlendModeSrc", (float)UnityEngine.Rendering.BlendMode.OneMinusDstColor);
                    target.SetFloat("_BlendModeDst", (float)UnityEngine.Rendering.BlendMode.One);
                }

                if ((TransparencyBlendMode)target.GetFloat("_BlendMode") == TransparencyBlendMode.SoftAdditive)
                {
                    target.SetFloat("_BlendModeSrc", (float)UnityEngine.Rendering.BlendMode.DstColor);
                    target.SetFloat("_BlendModeDst", (float)UnityEngine.Rendering.BlendMode.Zero);
                }

                if ((TransparencyBlendMode)target.GetFloat("_BlendMode") == TransparencyBlendMode.DoubleMultiplicative)
                {
                    target.SetFloat("_BlendModeSrc", (float)UnityEngine.Rendering.BlendMode.DstColor);
                    target.SetFloat("_BlendModeDst", (float)UnityEngine.Rendering.BlendMode.SrcColor);
                }     

                if ((TransparencyBlendMode)target.GetFloat("_BlendMode") == TransparencyBlendMode.ParticleAdditive)
                {
                    target.SetFloat("_BlendModeSrc", (float)UnityEngine.Rendering.BlendMode.SrcAlpha);
                    target.SetFloat("_BlendModeDst", (float)UnityEngine.Rendering.BlendMode.One);
                }             

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
                EditorGUI.indentLevel += 1;
                GUILayout.Space(10);
                editor.ShaderProperty(getProperty("_Culling"), "Culling", 0);
                editor.RenderQueueField();
                editor.EnableInstancingField();
                editor.DoubleSidedGIField();
                editor.LightmapEmissionProperty();
                EditorGUI.indentLevel -= 1;
            }
            else
            {
                target.SetFloat(toggle, 0);
            }
        }
    }

}

#endif
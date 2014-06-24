#if UNITY_IPHONE
using UnityEngine;
using UnityEditor;
using UnityEditor.Callbacks;
using System;
using System.Diagnostics;

public class ArbiterPostprocessScript : MonoBehaviour
{
	[PostProcessBuild]
	public static void OnPostprocessBuild(BuildTarget target, string pathToBuildProject)
	{
		UnityEngine.Debug.Log("----Arbiter Script--- Executing post process build phase.");
		string objCPath = Application.dataPath + "/Editor/Arbiter";
		Process p = new Process();
		p.StartInfo.FileName = "python";
		UnityEngine.Debug.Log ("pathToBuildProject: " + pathToBuildProject);
		UnityEngine.Debug.Log ("objCPath: " + objCPath);
		p.StartInfo.Arguments = string.Format("Assets/Editor/ArbiterPostprocessor.py \"{0}\" \"{1}\"", pathToBuildProject, objCPath);
		p.StartInfo.UseShellExecute = false;
		p.StartInfo.RedirectStandardOutput = false;
		p.Start();
		p.WaitForExit();
		UnityEngine.Debug.Log("----Arbiter Script--- Finished executing post process build phase.");
	}
}
#endif

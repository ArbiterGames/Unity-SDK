using UnityEngine;
using System.Collections;

public class ArbiterDebugPanel : MonoBehaviour {

	public string message;

	void OnGUI() {
		GUIStyle boxStyle = new GUIStyle("box");
		boxStyle.fontSize = 14;
		boxStyle.normal.textColor = Color.red;
		boxStyle.fontStyle = FontStyle.Bold;
		boxStyle.alignment = TextAnchor.UpperLeft;
		GUIStyle labelStyle = new GUIStyle("label");
		labelStyle.fontSize = 12;
		
		int padding = 10;
		int boxHeight = 60;
		int boxWidth = Screen.width - padding * 2;
		int boxY = Screen.height - boxHeight - padding;
		
		GUI.Box(new Rect(padding, boxY, boxWidth, boxHeight), "Arbiter Errors", boxStyle);
		GUI.Label(new Rect(padding + 5, boxY + padding * 2, boxWidth - padding * 2, boxHeight - padding * 2), message, labelStyle);
	}
}

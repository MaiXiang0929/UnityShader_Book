using UnityEditor;
using UnityEditor.Scripting.Python;

public class MenuItem_AutoRename_Class
{
   [MenuItem("Python Scripts/AutoRename")]
   public static void AutoRename()
   {
       PythonRunner.RunFile("Assets/Editor/Python/AutoRename.py");
       }
};

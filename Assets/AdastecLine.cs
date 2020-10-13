using Simulator.Map;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AdastecLine : MonoBehaviour
{
    public MapPedestrian jaywalk;
    public void DrawWaypoints(Transform mainTrans, List<Vector3> localPoints, float pointRadius, Color color)
    {
        var pointCount = localPoints.Count;
        for (int i = 0; i < pointCount; i++)
        {
            var point = mainTrans.TransformPoint(localPoints[i]);
            Gizmos.color = color;
            Gizmos.DrawSphere(point, pointRadius);
            Gizmos.color = color;
            Gizmos.DrawWireSphere(point, pointRadius);
        }
    }
    public void DrawLines(Transform mainTrans, List<Vector3> localPoints, Color lineColor)
    {
        var pointCount = localPoints.Count;
        for (int i = 0; i < pointCount - 1; i++)
        {
            var start = mainTrans.TransformPoint(localPoints[i]);
            var end = mainTrans.TransformPoint(localPoints[i + 1]);
            Gizmos.color = lineColor;
            Gizmos.DrawLine(start, end);
        }
    }
    public static void DrawArrowHeads(Transform mainTrans, List<Vector3> localPoints, Color lineColor)
    {
        for (int i = 0; i < localPoints.Count - 1; i++)
        {
            var start = mainTrans.TransformPoint(localPoints[i]);
            var end = mainTrans.TransformPoint(localPoints[i + 1]);
            DrawArrowHead(start, end, lineColor, arrowHeadScale: MapAnnotationTool.ARROWSIZE * 1f, arrowPositionRatio: 0.5f); // TODO why reference map annotation tool?
        }
    }
    public static void DrawArrowHead(Vector3 start, Vector3 end, Color color, float arrowHeadScale = 1.0f, float arrowHeadLength = 0.02f, float arrowHeadAngle = 13.0f, float arrowPositionRatio = 0.5f)
    {
        var originColor = Gizmos.color;
        Gizmos.color = color;

        var lineVector = end - start;
        var arrowFwdVec = lineVector.normalized * arrowPositionRatio * lineVector.magnitude;
        if (arrowFwdVec == Vector3.zero) return;

        //Draw arrow head
        Vector3 right = (Quaternion.LookRotation(arrowFwdVec) * Quaternion.Euler(arrowHeadAngle, 0, 0) * Vector3.back) * arrowHeadLength;
        Vector3 left = (Quaternion.LookRotation(arrowFwdVec) * Quaternion.Euler(-arrowHeadAngle, 0, 0) * Vector3.back) * arrowHeadLength;
        Vector3 up = (Quaternion.LookRotation(arrowFwdVec) * Quaternion.Euler(0, arrowHeadAngle, 0) * Vector3.back) * arrowHeadLength;
        Vector3 down = (Quaternion.LookRotation(arrowFwdVec) * Quaternion.Euler(0, -arrowHeadAngle, 0) * Vector3.back) * arrowHeadLength;

        Vector3 arrowTip = start + (arrowFwdVec);

        Gizmos.DrawLine(arrowTip, arrowTip + right * arrowHeadScale);
        Gizmos.DrawLine(arrowTip, arrowTip + left * arrowHeadScale);
        Gizmos.DrawLine(arrowTip, arrowTip + up * arrowHeadScale);
        Gizmos.DrawLine(arrowTip, arrowTip + down * arrowHeadScale);

        Gizmos.color = originColor;
    }
    void OnDrawGizmos()
    {
        Draw();
    }
    public void Draw()
    {        
        Color selectedColor = Color.green;
        DrawWaypoints(transform, jaywalk.mapLocalPositions, 0.5f, selectedColor);
        DrawLines(transform, jaywalk.mapLocalPositions, selectedColor);
        DrawArrowHeads(transform, jaywalk.mapLocalPositions, selectedColor);
    }
}

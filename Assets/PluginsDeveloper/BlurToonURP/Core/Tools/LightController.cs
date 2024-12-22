using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class LightController : MonoBehaviour
{
    private Light mLight;

    public Light Light
    {
        get
        {
            if (mLight == null)
            {
                mLight = GetComponent<Light>();
            }
            return mLight;
        }
    }
    
    [Header("Light Rotation")]
    [SerializeField, Tooltip("功能开关。自动转动光源功能。")] 
    private bool lightRotate = false;
    
    [SerializeField, Tooltip("延迟启动时间。")]
    private float lightRotateDelayStart = 1f;

    [SerializeField, Tooltip("旋转角度（欧拉角），每秒旋转此量的角度。")]
    private Vector3 lightRotateRotateAngle = Vector3.zero;
    
    [SerializeField, Tooltip("持续时间，持续此时间后停止。为0时不会停止。")]
    private float lightRotateDurationTime = 0f;

    private float lightRotateTimer;
    
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if(Light == null) return;

        LightRotate();

    }

    private void LightRotate()
    {
        if (!lightRotate) return; //开启灯光旋转
        if(lightRotateDurationTime > 0 && lightRotateTimer > lightRotateDurationTime) return; //持续时间结束
        
        lightRotateTimer += Time.deltaTime;

        if (lightRotateTimer < lightRotateDelayStart) return; //超过开始延迟时间
        
        //旋转灯光自身
        transform.rotation = Quaternion.Euler(transform.rotation.eulerAngles + lightRotateRotateAngle * Time.deltaTime);
    }
}
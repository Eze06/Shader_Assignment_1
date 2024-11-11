using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RotateObject : MonoBehaviour
{
    // Start is called before the first frame update
    public float rotatingSpeed = 20f;

    // Update is called once per frame
    void Update()
    {
        transform.Rotate(new Vector3(0, rotatingSpeed, 0) * Time.deltaTime);
    }
}

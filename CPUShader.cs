using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using UnityEngine;

public class CPUShader : MonoBehaviour
{
    [SerializeField] Texture2D texture;

    const int resolution = 128;

    static Vector2 v2Floor(Vector2 value)
    {
        return new Vector2(
            Mathf.Floor(value.x),
            Mathf.Floor(value.y)
            );
    }

    static Vector2 v2Fract(Vector2 value)
    {
        Vector2 floor = v2Floor(value);

        return new Vector2(
            value.x - floor.x,
            value.y - floor.y
            );
    }

    static Vector2 v2Sin(Vector2 value)
    {
        return new Vector2(
            Mathf.Sin(value.x),
            Mathf.Sin(value.y)
            );
    }


    float noiseMethod(Vector2 uv)
    {
        float _lacunarity = 2.0f; // Noiseness
        float _gain = 0.5f; // Crispyness
        float _amplitude = 1.5f; // How much is does
        float _frequency = 2.0f; // Another kind of scale?
        float _power = 1.0f; // Color sharpness

        const int _octaves = 1;

        float _finalValue = 0.0f;

        Vector2 p = uv;

        //p = p * _scale + Vector2(_offsetX,_offsetY);

        float fpA = 127.1f; // 127.1
        float fpB = 311.7f; // 311.7
        float fpC = 269.5f; // 269.5
        float fpD = 183.3f; // 183.3
        float fpE = 43758.5453123f; // 43758.5453123

        for (int j = 0; j < _octaves; j++)
        {
            Vector2 i = v2Floor(p * _frequency);
            Vector2 f = v2Fract(p * _frequency);
            Vector2 t = f * f * f * (f * (f * 6.0f - 15.0f * Vector2.one) + 10.0f * Vector2.one);
            Vector2 a = i + new Vector2(0.0f, 0.0f);
            Vector2 b = i + new Vector2(1.0f, 0.0f);
            Vector2 c = i + new Vector2(0.0f, 1.0f);
            Vector2 d = i + new Vector2(1.0f, 1.0f);
            a = -1.0f * Vector2.one + 2.0f * v2Fract(v2Sin(new Vector2(Vector2.Dot(a, new Vector2(fpA, fpB)), Vector2.Dot(a, new Vector2(fpC, fpD)))) * fpE);
            b = -1.0f * Vector2.one + 2.0f * v2Fract(v2Sin(new Vector2(Vector2.Dot(b, new Vector2(fpA, fpB)), Vector2.Dot(b, new Vector2(fpC, fpD)))) * fpE);
            c = -1.0f * Vector2.one + 2.0f * v2Fract(v2Sin(new Vector2(Vector2.Dot(c, new Vector2(fpA, fpB)), Vector2.Dot(c, new Vector2(fpC, fpD)))) * fpE);
            d = -1.0f * Vector2.one + 2.0f * v2Fract(v2Sin(new Vector2(Vector2.Dot(d, new Vector2(fpA, fpB)), Vector2.Dot(d, new Vector2(fpC, fpD)))) * fpE);
            float A = Vector2.Dot(a, f - new Vector2(0.0f, 0.0f));
            float B = Vector2.Dot(b, f - new Vector2(1.0f, 0.0f));
            float C = Vector2.Dot(c, f - new Vector2(0.0f, 1.0f));
            float D = Vector2.Dot(d, f - new Vector2(1.0f, 1.0f));
            float noise = (Mathf.LerpUnclamped(Mathf.LerpUnclamped(A, B, t.x), Mathf.LerpUnclamped(C, D, t.x), t.y));
            _finalValue += _amplitude * noise;
            _frequency *= _lacunarity;
            _amplitude *= _gain;
        }
        _finalValue = Mathf.Clamp(_finalValue, -1.0f, 1.0f);
        return Mathf.Pow(_finalValue * 0.5f + 0.5f, _power);
    }

    float getFalloff(Vector2 uv)
    {
        float land;

        land = Mathf.SmoothStep(0.2f, .5f, (uv - 0.5f * Vector2.one).magnitude);

        land = 1.0f- Mathf.Clamp(land, 0.0f, 1.0f);
        return land;
    }


    private void Start()
    {
        for (int y = 0; y < texture.height; y++)
        {
            for (int x = 0; x < texture.width; x++)
            {
                Vector2 UV = new Vector2(1f * x / texture.width, 1f * y / texture.height);

                texture.SetPixel(x, y, mainImage(UV));
            }
        }

        texture.Apply();
    }

    public Vector2 UV;

    public float value;


    private void Update()
    {
        value = noiseMethod(UV);
    }

    Color mainImage(Vector2 uv)
    {
        // Normalized pixel coordinates (from 0 to 1)
        float ScaleValue = 2.0f;
        float OffsetValue = 100.0f;

        Color col = new Color(1.0f, 1.0f, 1.0f, 1.0f);

        // Output to screen
        float a = noiseMethod(uv * ScaleValue + OffsetValue * Vector2.one);

        float b = getFalloff(uv) * a;

        col *= b < .5 ? 0.0f: 1.0f;

        col += new Color(0.83f, 0.83f, 0.83f, 0) * (Mathf.Sign(uv.x - 1.0f) * 0.5f + 0.5f);

        col.a = 1;

        return col;
    }
}

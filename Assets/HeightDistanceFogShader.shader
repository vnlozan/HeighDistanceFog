// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/HeightDistanceFog"
{
    Properties 
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _PlayerPosition("Player Position", Vector ) = ( 0.0, 0.0, 0.0 )
        _FogColor ("Fog Color", Color) = (0.5, 0.5, 0.5, 1)
        _FogMaxDistance("Fog Max Distance", Float) = 0.0
        _FogMinDistance("Fog Min Distance", Float) = 0.0
        _FogMaxHeight ("Fog Max Height", Float) = 0.0
        _FogMinHeight ("Fog Min Height", Float) = -1.0
    }
  
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200
        Cull Back
        ZWrite On
  
        CGPROGRAM
  
        #pragma surface surf Lambert finalcolor:finalcolor vertex:vert
  
        sampler2D _MainTex;
        float4 _PlayerPosition;
        float4 _FogColor;
        float _FogMaxDistance;
        float _FogMinDistance;
        float _FogMaxHeight;
        float _FogMinHeight;
  
        struct Input 
        {
            float2 uv_MainTex;
            float4 pos;
            float distance;
        };
  
        void vert (inout appdata_full v, out Input o) 
        {
            o.pos = mul(unity_ObjectToWorld, v.vertex);
            o.uv_MainTex = v.texcoord.xy;
            o.distance = distance( mul(unity_ObjectToWorld, _PlayerPosition), o.pos );
        }
  
        void surf (Input IN, inout SurfaceOutput o) 
        {
            float4 c = tex2D (_MainTex, IN.uv_MainTex);
            o.Albedo = c.rgb;
        }
        float getDistanceFogFactor(float d)
        {
            if (d>=_FogMaxDistance) return 1;
            if (d<=_FogMinDistance) return 0;
            return 1 - (_FogMaxDistance - d) / (_FogMaxDistance - _FogMinDistance);
        }
        void finalcolor (Input IN, SurfaceOutput o, inout fixed4 color)
        {
            #ifndef UNITY_PASS_FORWARDADD //Forward rendering additive pass (one light per pass).
            
            float3 vertexColor = color.rgb;
            
            //calculate distance fog
            float distanceFogFactor = getDistanceFogFactor( IN.distance );
            vertexColor = lerp( vertexColor, _FogColor.rgb, distanceFogFactor );
            
            //calculate height fog
            float heightFogFactor = (IN.pos.y - _FogMinHeight) / (_FogMaxHeight - _FogMinHeight);
            float lerpValue = clamp( heightFogFactor, 0, 1 );
            color.rgb = lerp (_FogColor.rgb, vertexColor, lerpValue);   // x+s(y-x) linear interpolation
            
            #endif
        }
  
        ENDCG
    }
  
    FallBack "Diffuse"
}
Shader "Unlit/GenshinSky"
{
    Properties
    {
        _SunScatterColorForward("sunscattercolorforward",color)=(0.00326,0.18243,0.63132,1)
        _SunScatterColorBeside("sunscattercolorbeside",color)=(0.02948,0.1609,0.27936,1)
        _SunOrgColorForward("sunorgcolorforward",color)=(0.30759,0.346,0.24592,1)
        _SunOrgColorBeside("sunorgcolorbeside",color)=(0.04305,0.26222,0.46968,1)

        _StarTex("startex",2D)="white"{}
        _StarRampTex("starramptex",2D)="white"{}
        _NoiseTex("noisetex",2D)="white"{}
        _TransmissionRGMap("transmissionRGmap",2D)="white"{}

        _NoiseSpeed("noisespeed",range(0,1))=0.293
        _LDotVDampFac("ldotvdampfac",range(0,1))=0.31277

        _SkyScatter("skyscatter",range(0,1))=0.69804
        _SkyColor("skycolor",Color)=(0.90409,0.7345,0.13709, 1)
        _SkyColorIntensity("skycolorintensity",range(0,3))=1.48499

        _SunScatter("sunscatter",range(0,1))=0.44837
        _SunDiskPower("sundiskpower",range(0,1000))=1000
        _SunColor("suncolor",color)=(0.90625,0.43019,0.11743,1)
        _SunColorIntensity("suncolorintensity",range(0,3))=1.18529

        _MoonDir("moondir",vector)=(-0.33274,-0.11934,0.93544,0)
        _MoonSize("moonsize",range(0,1))=0.19794
        _MoonIntensityControl("moonintensitycontrol",range(0,4))=3.29897
        _MoonIntensityMax("moonintensitymax",range(0,1))=0.19794
        _MoonIntensitySlider("moonintensityslider",range(0,1))=0.5
        _MoonColor("mooncolor",color)=(0.15519,0.18858,0.2653,1)

        _StarColorIntensity("starcolorintensity",range(0,100))=0.8466
        _StarIntensityLinearDamping("starintensitylineardamping",range(0,1))=0.80829

        [Toggle]_StarPartEnable("starpartenbale",float)=1
        [Toggle]_SunPartEnable("sunpartenable",float)=1
        [Toggle]_MoonPartEnable("moonpartenable",float)=1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #define PI 3.14159265359f //圆周率
            #define HALF_PI 1.57079632679f //半圆周率
            #define INV_HALF_PI 0.636619772367f //半圆周率的倒数

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 staruv : TEXCOORD0;
                float4 noiseuv:TEXCOORD1;
                float4 viewmsg:TEXCOORD2;
                float4 colordamping:TEXCOORD3;
                float4 testpart:TEXCOORD4;
                float4 vertex : SV_POSITION;
            };

            sampler2D _TransmissionRGMap;
            float4 _TransmissionRGMap_ST;

            sampler2D _StarTex;
            float4 _StarTex_ST;
            sampler2D _StarRampTex;
            float4 _StarRampTex_ST;
            sampler2D _NoiseTex;
            float4 _NoiseTex_ST;
            

            float _NoiseSpeed;
            float _LDotVDampFac;

            float _SkyScatter;
            float4 _SkyColor;
            float _SkyColorIntensity;

            float _SunScatter;
            float4 _SunColor;
            float _SunColorIntensity;
            float _SunDiskPower;

            float4 _SunScatterColorForward;
            float4 _SunScatterColorBeside;
            float4 _SunOrgColorForward;
            float4 _SunOrgColorBeside;

            float3 _MoonDir;
            float _MoonSize;
            float _MoonIntensityControl;
            float _MoonIntensityMax;
            float _MoonIntensitySlider;
            float4 _MoonColor;

            float _StarColorIntensity;
            float _StarIntensityLinearDamping;

            float _StarPartEnable;
            float _SunPartEnable;
            float _MoonPartEnable;

            float FastAcosForAbsCos(float in_abs_cos) {
                float _local_tmp = ((in_abs_cos * -0.0187292993068695068359375 + 0.074261002242565155029296875) * in_abs_cos - 0.212114393711090087890625) * in_abs_cos + 1.570728778839111328125;
                return _local_tmp * sqrt(1.0 - in_abs_cos);
            }

            float FastAcos(float in_cos) {
                float local_abs_cos = abs(in_cos);
                float local_abs_acos = FastAcosForAbsCos(local_abs_cos);
                return in_cos < 0.0 ?  PI - local_abs_acos : local_abs_acos;
            }
            
            float GetFinalMiuResult(float u)
            {
                float _acos = FastAcos(u);
                float angle1_to_n1 = (HALF_PI - _acos) * INV_HALF_PI;
                return angle1_to_n1;
            }

            // float GetFinalMiuResult(float u)
            // {
            //     // float abs_u = abs(u);
            //     // float _miuLut =  ((abs_u * (-0.0187292993068695068359375) + 0.074261002242565155029296875) 
            //     //      * abs_u + (-0.212114393711090087890625))
            //     //          * abs_u + 1.570728778839111328125;
            //     // float _sqrtOneMinusMiu = sqrt(1.0 - abs_u);
            //     // float _sqrtOneMinusMiu_multi_lut = _sqrtOneMinusMiu * _miuLut;
            //     //
            //     // float tmp0 = 0;
            //     // // tmp0 = u < 0 ? (_sqrtOneMinusMiu_multi_lut * (-2.0)) + 3.1415927410125732421875 : 0.0;
            //     // tmp0 = u < 0 ? PI - _sqrtOneMinusMiu_multi_lut: _sqrtOneMinusMiu_multi_lut;

            //     // float tmp0 = FastAcos(u);
            //     float _acos = FastAcos(u);
                
            //     // tmp0 = HALF_PI - tmp0;
            //     // float finalMiuResult = (HALF_PI - tmp0) * INV_HALF_PI;
            //     float angle1_to_n1 = (HALF_PI - _acos) * INV_HALF_PI;
            //     return angle1_to_n1;
            // }

            v2f vert (appdata v)
            {
                v2f o;
                o.testpart=float4(0,0,0,1);
                o.vertex = UnityObjectToClipPos(v.vertex);
                float2 staruv=TRANSFORM_TEX(v.uv, _StarTex);
                o.staruv=float4(staruv,v.uv*20);
                float4 timscale=_Time.y*_NoiseSpeed*float4(0.4,0.2,0.1,0.5);
                o.noiseuv=float4(v.uv*_NoiseTex_ST.xy+timscale.xy,v.uv*_NoiseTex_ST.xy*2+timscale.zw);

                float4 worldpos=mul(unity_ObjectToWorld,v.vertex);
                float3 lightdir=normalize(_WorldSpaceLightPos0.xyz);
                float3 viewdir=normalize(worldpos.xyz-_WorldSpaceCameraPos);
                float miu=abs(GetFinalMiuResult(clamp(dot(float3(0,1,0),viewdir),-1,1)));
                o.testpart.w=abs(dot(float3(0,1,0),viewdir));
                o.viewmsg=float4(viewdir,miu);
                
                float ldotv=dot(lightdir,viewdir);
                float lightdiryremap=smoothstep(0,1,clamp((abs(lightdir.y)-0.2)*10/3,0,1)); 
                float ldotvremap=max(saturate(ldotv*0.5)+0.5* 1.4285714626312255859375 - 0.42857145581926658906013, 0);
                float ldotvsmooth=smoothstep(0,1,ldotvremap);
                float suncolorinstensity=lerp(ldotvsmooth,1,lightdiryremap);
                float skyT=tex2Dlod(_TransmissionRGMap,float4(abs(miu)/max(_SkyScatter,0.0001),0.5,0,0)).y;
                float3 skyTcolor=skyT*_SkyColor*_SkyColorIntensity;
                skyTcolor=skyTcolor*suncolorinstensity;
                float sunT=tex2Dlod(_TransmissionRGMap,float4(abs(miu)/max(_SunScatter,0.0001),0.5,0,0)).x;
                float cubicldotvdamp=pow(max(lerp(1,ldotv,_LDotVDampFac),0),3);
                float3 sunorgcolor=lerp(_SunOrgColorBeside,_SunOrgColorForward,cubicldotvdamp);
                float3 sunscattercolor=lerp(_SunScatterColorBeside,_SunScatterColorForward,cubicldotvdamp);
                float3 sunfinalcolor=lerp(sunscattercolor,sunorgcolor,sunT);
                float3 finalcolor=skyTcolor+sunfinalcolor;
                o.testpart.xyz=sunfinalcolor;
                o.colordamping=float4(finalcolor,cubicldotvdamp);
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 viewdir=normalize(i.viewmsg.xyz);
                float vdotup=dot(viewdir,float3(0,1,0));
                float vdotupmul999 = abs(vdotup)*_SunDiskPower;//_SunDiskPower的值比较大;
                float3 lightdir=normalize(_WorldSpaceLightPos0.xyz);
                float ldotv=dot(lightdir,viewdir);
                
              
                float ldotvremap=saturate(ldotv*0.5f+0.5f);
                float ldotv_pow001=min(pow(ldotvremap,vdotupmul999*0.01),1);
                float ldotv_pow01=min(pow(ldotvremap,vdotupmul999*0.1),1);
                float ldotv_pow=min(pow(ldotvremap,vdotupmul999),1);
                float ldotvpowscale=ldotv_pow001*0.03+ldotv_pow01*0.12+ldotv_pow;
                float3 sundisk=ldotvpowscale*_SunColorIntensity*_SunColor;
                float ldotvsmooth=smoothstep(0,1,ldotv);
                float3 sunpartcolor=(ldotvsmooth*sundisk*_SunPartEnable)+i.colordamping.xyz;

                float moondotv=saturate(dot(normalize(_MoonDir),viewdir));
                float moonsizercp=1/max(_MoonSize*0.1,0.00001);
                float moondisk=pow(max((moondotv-1)*moonsizercp+1,0),6);

                float moonslidervalue=-abs(_MoonIntensitySlider-0.5)*2+1;
                float moonintensity=moonslidervalue*_MoonIntensityMax*moondisk;
                float3 moonpartcolor=moonintensity*_MoonColor;
                float isnomoonhere=float((moonintensity*_MoonPartEnable)<=0.05f);
                moonpartcolor=saturate(_MoonIntensityControl)*moonpartcolor;

                float3 sunmooncolor=(moonpartcolor*_MoonPartEnable)+sunpartcolor;

                float starnoise1=tex2D(_NoiseTex,i.noiseuv.xy).r;
                float starnoise2=tex2D(_NoiseTex,i.noiseuv.zw).r;
                float starsample=tex2D(_StarTex,i.staruv.xy).r;
                float star=starsample*starnoise1*starnoise2;
                float miuresult=i.viewmsg.w*1.5;
                float starintensity=star*miuresult*3;
                float starcolornoise=tex2D(_NoiseTex,i.staruv.zw).r;
                float starintensitydamping=saturate((starcolornoise-_StarIntensityLinearDamping)/(1-_StarIntensityLinearDamping));
                starintensity=starintensitydamping*starintensity;

                float2 starcolorlutuv;
                starcolorlutuv.x=(starcolornoise*_StarRampTex_ST.x)+_StarRampTex_ST.z;
                starcolorlutuv.y=0.5;
                float3 starrampcolor=tex2D(_StarRampTex,starcolorlutuv).xyz;
                float3 starcolor=starrampcolor*_StarColorIntensity;
                float3 finalstarcolor=starintensity*starcolor*isnomoonhere;
                float3 finalcolor=finalstarcolor*_StarPartEnable+sunmooncolor;
                return float4(finalcolor,1);
            }
            ENDCG
        }
    }
}

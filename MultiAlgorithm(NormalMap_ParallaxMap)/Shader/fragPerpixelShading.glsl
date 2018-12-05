#version 430 core

uniform sampler2D uTextureDiffuse0;
uniform sampler2D uTextureNormal0;
uniform sampler2D uTextureSpecular0;

uniform vec3 uViewPositionW;

uniform vec3 uLightDirectionW = vec3(0.0f, 0.5f, 1.0f);
uniform vec3 uLightAmbient = vec3(0.6f, 0.6f, 0.6f);
uniform vec3 uLightColor = vec3(0.4f, 0.4f, 0.4f);
uniform float SpecularStrength = 0.02f;
uniform float Shininess = 32.0f;

uniform float HeightScale = 0.1f;

uniform float uUseNormalMap = 1.0;
uniform float uUseParallaxMap = 1.0;

in vec3 _PositionW;
in vec3 _NormalW;
in vec2 _TexCoord;
in mat3 _TBN;

out vec4 _outFragColor;

vec3 NormalMapping(vec2 vTexCoord);
vec2 ParallaxMapping(vec2 vTexCoords);

void main()
{
	vec2 Offseted_TexCoord = _TexCoord;
	if (uUseParallaxMap > 0.5f)
	{
		Offseted_TexCoord = ParallaxMapping(_TexCoord);
		if (Offseted_TexCoord.x > 1.0 || Offseted_TexCoord.y > 1.0 || Offseted_TexCoord.x < 0.0 || Offseted_TexCoord.y < 0.0)
			discard;
	}

	vec3 Normal = _NormalW;
	if (uUseNormalMap > 0.5f)
	{
		Normal = NormalMapping(Offseted_TexCoord);
	}

	vec3 SurfaceColor = texture(uTextureDiffuse0, Offseted_TexCoord).rgb;
	vec3 AmbientColor = uLightAmbient * SurfaceColor;

	float Diffuse = max(0.0, dot(normalize(uLightDirectionW), Normal));
	vec3 DiffuseColor = uLightColor * Diffuse * SurfaceColor;

	float Specular = 0.0f;
	vec3 ViewDir = normalize(uViewPositionW - _PositionW);
	vec3 ReflectDir = reflect(-uLightDirectionW, Normal);
	if (dot(normalize(uLightDirectionW), Normal) > 0)
		Specular = pow(max(0.0, dot(ViewDir, ReflectDir)), Shininess);
	vec3 SpecularColor = uLightColor * Specular * SpecularStrength;

	_outFragColor = vec4(AmbientColor + DiffuseColor + SpecularColor, 1.0f);
}

vec3 NormalMapping(vec2 vTexCoord)
{
	vec3 Normal = texture(uTextureNormal0, vTexCoord).xyz;
	Normal = normalize(Normal * 2.0f - 1.0f);
	Normal = normalize(_TBN * Normal);

	return Normal;
}

vec2 ParallaxMapping(vec2 vTexCoords)
{
	vec3 ViewDirTBN = normalize(transpose(_TBN) * uViewPositionW - transpose(_TBN) * _PositionW);

	//单点采样
	/*float height = texture(uTextureSpecular0, vTexCoords).r;
	vec2 p = ViewDirTBN.xy / ViewDirTBN.z * (height * HeightScale);
	return vTexCoords - p;*/

	//陡峭采样
	const float MinLayers = 30;
	const float MaxLayers = 40;
	float NumLayers = mix(MaxLayers, MinLayers, abs(dot(vec3(0.0, 0.0, 1.0), ViewDirTBN)));
	float LayerDepth = 1.0 / NumLayers;

	float CurrentLayerDepth = 0.0;

	vec2 P = ViewDirTBN.xy / ViewDirTBN.z * HeightScale;
	vec2 DeltaTexCoords = P / NumLayers;

	vec2  CurrentTexCoords = vTexCoords;
	float CurrentDepthMapValue = texture(uTextureSpecular0, CurrentTexCoords).r;

	while (CurrentLayerDepth < CurrentDepthMapValue)
	{
		CurrentTexCoords -= DeltaTexCoords;
		CurrentDepthMapValue = texture(uTextureSpecular0, CurrentTexCoords).r;
		CurrentLayerDepth += LayerDepth;
	}

	vec2 PrevTexCoords = CurrentTexCoords + DeltaTexCoords;

	float AfterDepth = CurrentDepthMapValue - CurrentLayerDepth;
	float BeforeDepth = texture(uTextureSpecular0, PrevTexCoords).r - CurrentLayerDepth + LayerDepth;

	float Weight = AfterDepth / (AfterDepth - BeforeDepth);
	vec2 FinalTexCoords = PrevTexCoords * Weight + CurrentTexCoords * (1.0 - Weight);

	return FinalTexCoords;
}

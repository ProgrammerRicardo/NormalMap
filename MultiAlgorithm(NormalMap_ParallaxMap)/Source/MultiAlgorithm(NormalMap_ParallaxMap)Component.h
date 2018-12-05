#pragma once
#include "graphics/RenderComponent.h"
#include <GLM/mat4x4.hpp>

class CNormalMapComponent : public hiveRenderEngine::IRenderComponent
{
public:
	CNormalMapComponent();
	virtual ~CNormalMapComponent();

private:
	virtual void __updateShaderUniformsV() override;

	bool m_CheckBoxTag;
	bool m_CheckBoxTag1;
	//glm::vec3 m_LightDirection;
};


#include "MultiAlgorithm(NormalMap_ParallaxMap)Component.h"
#include "common/ProductFactory.h"
#include "graphics/RenderPass.h"
#include "graphics/RenderEngineInterface.h"
#include <GLM/gtc/matrix_transform.hpp>

hiveOO::CProductFactory<CNormalMapComponent> theCreator("NORMAL_MAP_COMPONET");

CNormalMapComponent::CNormalMapComponent() : m_CheckBoxTag(true), m_CheckBoxTag1(true)/*, m_LightDirection(glm::normalize(glm::)£©*/
{
}

CNormalMapComponent::~CNormalMapComponent()
{
}

//************************************************************************
//Function:
void CNormalMapComponent::__updateShaderUniformsV()
{
	hiveRenderEngine::IRenderPass *pPass = _findRenderPass("perpixel_shading");
	_ASSERTE(pPass);
	hiveRenderEngine::hiveDumpWidgetBoolValue("GUI.xml|widget_set|checkbox_1", &m_CheckBoxTag);
	pPass->updateShaderUniform("uUseNormalMap", m_CheckBoxTag);

	hiveRenderEngine::hiveDumpWidgetBoolValue("GUI.xml|widget_set|checkbox_2", &m_CheckBoxTag1);
	pPass->updateShaderUniform("uUseParallaxMap", m_CheckBoxTag1);

	double Eye[3], LookAt[3], Up[3];
	hiveRenderEngine::hiveDumpFrameCameraInfo(Eye, LookAt, Up);
	pPass->updateShaderUniform("uViewPositionW", static_cast<float>(Eye[0]), static_cast<float>(Eye[1]), static_cast<float>(Eye[2]));

	/*glm::mat4 Trans;
	Trans = glm::rotate(Trans, glm::radians(1.0f), glm::vec3(0.0f, 1.0f, 0.0f));
	m_LightDirection = glm::vec3(Trans * glm::vec4(m_LightDirection, 1.0f));
	pPass->updateShaderUniform("uLightDirectionW", m_LightDirection[0], m_LightDirection[1], m_LightDirection[2]);*/
}
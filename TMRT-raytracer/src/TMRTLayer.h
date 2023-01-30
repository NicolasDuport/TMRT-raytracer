#pragma once

#include <Merlin.h>

using namespace Merlin;
using namespace Merlin::Renderer;
using namespace Merlin::Scene;
using namespace Merlin::Tensor;

struct Ray {
	alignas(16) glm::vec3 origin; //Origin
	alignas(16) glm::vec3 direction; //Direction
	alignas(16) glm::vec3 start; //Direction
	alignas(16) glm::vec3 end; //Direction
	GLuint firstHitID;
	GLuint lastHitID;
	GLuint bounce;
	GLboolean hitSky;
	GLboolean hitDiffuse;
};

struct Facet {
	alignas(16) glm::vec3 p1;
	alignas(16) glm::vec3 p2;
	alignas(16) glm::vec3 p3;
	alignas(16) glm::vec3 p4;
	alignas(16) glm::vec3 normal;
	GLuint id;
	GLuint specular;
};

struct Bin {
	int start;
	int end;
};

class TMRTLayer : public Merlin::Layer
{
public:
	TMRTLayer();
	virtual ~TMRTLayer();

	virtual void OnAttach() override;
	virtual void OnDetach() override;
	virtual void OnEvent(Merlin::Event& event) override;
	virtual void OnUpdate(Merlin::Timestep ts) override;
	virtual void OnImGuiRender() override;

	bool OnClick(MouseButtonPressedEvent& e);
	bool OnRelease(MouseButtonReleasedEvent& e);

	void updateFPS(Merlin::Timestep ts);
	void saveRays();

private:
	GLsizei _width = 1080, _height = 720;
	
	//Rendering
	Shared<Shader> axisShader;
	Shared<Shader> modelShader;
	Shared<Shader> mouseCastShader;
	Shared<Shader> rayShader;

	Shared<Primitive> axis;
	Shared<Primitive> sphere;
	Shared<Primitive> model; //Geometry

	//Mouse raycasting
	Shared<Primitive> mouseRay;

	//Computing
	Shared<ParticleSystem> rays;
	Shared<SSBO> rayBuffer;
	Shared<SSBO> facetBuffer;
	Shared<SSBO> binBuffer;

	Shared<ComputeShader> init;
	Shared<ComputeShader> raytracing;

	std::vector<Ray> rayArray;

	//Camera
	Shared<Camera> camera;
	Shared<CameraController> cameraController;

	//Ui
	glm::vec3 camera_translation = { 0.0f, 0.0f, 0.0f };
	float camera_speed = 1;
	float FPS = 0;
	float FPS_sample = 0;
	bool _drawGeom = true;
	bool _drawRays = true;
	bool _drawRaycast = true;

	bool paused = true;
};
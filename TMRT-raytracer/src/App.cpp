#include "Merlin.h"
#include "TMRTLayer.h"

using namespace Merlin;

class MainApplication : public Application
{
public:
	MainApplication()
		: Application("Merlin sandbox", 1280,720, true, true)
	{
		PushLayer(new TMRTLayer());
	}
};

int main()
{
	std::unique_ptr<MainApplication> app = std::make_unique<MainApplication>();
	app->Run();
}
#include <iostream>
#include <string>
#include <torch/script.h>

using namespace std;

namespace {

struct MobileCallGuard {
  // AutoGrad is disabled for mobile by default.
  torch::autograd::AutoGradMode no_autograd_guard{false};
  // Disable graph optimizer to ensure list of unused ops are not changed for
  // custom mobile build.
  torch::jit::GraphOptimizerEnabledGuard no_optimizer_guard{false};
};

void init() {
  auto qengines = at::globalContext().supportedQEngines();
  if (std::find(qengines.begin(), qengines.end(), at::QEngine::QNNPACK) !=
      qengines.end()) {
    at::globalContext().setQEngine(at::QEngine::QNNPACK);
  }
}

torch::jit::script::Module loadModel(const std::string& path) {
  MobileCallGuard guard;
  auto module = torch::jit::load(path);
  module.eval();
  return module;
}

} // namespace

int main(int argc, const char* argv[]) {
  if (argc < 2) {
    std::cerr << "Usage: " << argv[0] << " <model_path>\n";
    return 1;
  }
  init();
  auto module = loadModel(argv[1]);
  auto input = torch::ones({1, 3, 224, 224}); // TODO: load real image
  auto output = [&]() {
    MobileCallGuard guard;
    return module.forward({input});
  }();
  std::cout << output << std::endl;
  return 0;
}

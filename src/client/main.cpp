
#include <vulkan/vulkan.h>
#include <GLFW/glfw3.h>
#include <imgui.h>
#include <glm/glm.hpp>
#include <assimp/version.h>
#include <ktx.h>
#include "stb_image.h"

#include <iostream>
#include <string>

int main()
{
    std::cout << "=== TESTE DE BIBLIOTECAS ===\n\n";

    // =========================================
    // 1. TESTE GLM
    // =========================================

    try
    {
        glm::vec3 a(1.0f, 2.0f, 3.0f);
        glm::vec3 b(4.0f, 5.0f, 6.0f);
        glm::vec3 result = a + b;

        std::cout << "[OK] GLM: "
                  << result.x << ", "
                  << result.y << ", "
                  << result.z << "\n";
    }
    catch (...)
    {
        std::cout << "[ERRO] GLM\n";
    }

    // =========================================
    // 2. TESTE ASSIMP
    // =========================================

    std::cout << "[OK] Assimp: "
              << aiGetVersionMajor() << "."
              << aiGetVersionMinor() << "."
              << aiGetVersionPatch() << "\n";

    // =========================================
    // 3. TESTE STB IMAGE
    // =========================================

    int width = 0;
    int height = 0;
    int channels = 0;

    unsigned char testData[] = { 255, 0, 0, 255 };

    int stbResult = stbi_info_from_memory(
        testData,
        sizeof(testData),
        &width,
        &height,
        &channels
    );

    if (stbResult)
    {
        std::cout << "[OK] STB Image: imagem de teste reconhecida\n";
    }
    else
    {
        std::cout << "[OK] STB Image: API acessivel\n";
    }

    // =========================================
    // 4. TESTE KTX
    // =========================================

    ktxTexture* texture = nullptr;

    KTX_error_code ktxResult = ktxTexture_CreateFromNamedFile(
        "arquivo_inexistente.ktx",
        KTX_TEXTURE_CREATE_LOAD_IMAGE_DATA_BIT,
        &texture
    );

    if (ktxResult != KTX_SUCCESS)
    {
        std::cout << "[OK] KTX: API acessivel e chamada executada\n";
    }
    else
    {
        std::cout << "[OK] KTX: textura carregada\n";
        ktxTexture_Destroy(texture);
    }

    // =========================================
    // 5. TESTE IMGUI
    // =========================================

    IMGUI_CHECKVERSION();

    ImGui::CreateContext();

    std::cout << "[OK] ImGui: contexto criado\n";

    ImGui::DestroyContext();

    // =========================================
    // 6. TESTE GLFW
    // =========================================

    if (!glfwInit())
    {
        std::cout << "[ERRO] GLFW: falha na inicializacao\n";
        return -1;
    }

    std::cout << "[OK] GLFW: inicializado\n";

    if (!glfwVulkanSupported())
    {
        std::cout << "[ERRO] GLFW: suporte Vulkan indisponivel\n";
        glfwTerminate();
        return -1;
    }

    std::cout << "[OK] GLFW: suporte Vulkan detectado\n";

    // =========================================
    // 7. CONFIGURACAO DA JANELA VULKAN
    // =========================================

    glfwWindowHint(GLFW_CLIENT_API, GLFW_NO_API);
    glfwWindowHint(GLFW_RESIZABLE, GLFW_TRUE);

    GLFWwindow* window = glfwCreateWindow(
        800,
        600,
        "TESTE DE COMPILADOR - GLFW + VULKAN",
        nullptr,
        nullptr
    );

    if (!window)
    {
        std::cout << "[ERRO] GLFW: falha ao criar janela\n";
        glfwTerminate();
        return -1;
    }

    std::cout << "[OK] GLFW: janela criada\n";

    // =========================================
    // 8. EXTENSOES VULKAN DO GLFW
    // =========================================

    uint32_t glfwExtensionCount = 0;

    const char** glfwExtensions =
        glfwGetRequiredInstanceExtensions(&glfwExtensionCount);

    if (!glfwExtensions || glfwExtensionCount == 0)
    {
        std::cout << "[ERRO] Vulkan: extensoes GLFW indisponiveis\n";

        glfwDestroyWindow(window);
        glfwTerminate();

        return -1;
    }

    std::cout << "[OK] Vulkan: extensoes GLFW encontradas\n";

    // =========================================
    // 9. CRIACAO DA INSTANCIA VULKAN
    // =========================================

    VkApplicationInfo appInfo{};

    appInfo.sType = VK_STRUCTURE_TYPE_APPLICATION_INFO;
    appInfo.pApplicationName = "Teste de Bibliotecas";
    appInfo.applicationVersion = VK_MAKE_VERSION(1, 0, 0);
    appInfo.pEngineName = "Custom Engine";
    appInfo.engineVersion = VK_MAKE_VERSION(1, 0, 0);
    appInfo.apiVersion = VK_API_VERSION_1_0;

    VkInstanceCreateInfo createInfo{};

    createInfo.sType = VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO;
    createInfo.pApplicationInfo = &appInfo;
    createInfo.enabledExtensionCount = glfwExtensionCount;
    createInfo.ppEnabledExtensionNames = glfwExtensions;

    VkInstance instance = VK_NULL_HANDLE;

    VkResult resultVk = vkCreateInstance(
        &createInfo,
        nullptr,
        &instance
    );

    if (resultVk != VK_SUCCESS)
    {
        std::cout << "[ERRO] Vulkan: falha ao criar instancia: "
                  << resultVk << "\n";

        glfwDestroyWindow(window);
        glfwTerminate();

        return -1;
    }

    std::cout << "[OK] Vulkan: instancia criada\n";

    // =========================================
    // 10. ENUMERACAO DAS GPUs
    // =========================================

    uint32_t gpuCount = 0;

    VkResult gpuResult = vkEnumeratePhysicalDevices(
        instance,
        &gpuCount,
        nullptr
    );

    if (gpuResult != VK_SUCCESS)
    {
        std::cout << "[ERRO] Vulkan: falha ao enumerar GPUs\n";

        vkDestroyInstance(instance, nullptr);
        glfwDestroyWindow(window);
        glfwTerminate();

        return -1;
    }

    std::cout << "[OK] Vulkan: GPUs encontradas: "
              << gpuCount << "\n";

    if (gpuCount > 0)
    {
        VkPhysicalDevice* devices =
            new VkPhysicalDevice[gpuCount];

        gpuResult = vkEnumeratePhysicalDevices(
            instance,
            &gpuCount,
            devices
        );

        if (gpuResult == VK_SUCCESS)
        {
            for (uint32_t i = 0; i < gpuCount; i++)
            {
                VkPhysicalDeviceProperties properties{};

                vkGetPhysicalDeviceProperties(
                    devices[i],
                    &properties
                );

                std::cout << "    GPU " << i << ": "
                          << properties.deviceName << "\n";
            }
        }

        delete[] devices;
    }

    // =========================================
    // 11. CRIACAO DA SURFACE VULKAN
    // =========================================

    VkSurfaceKHR surface = VK_NULL_HANDLE;

    VkResult surfaceResult = glfwCreateWindowSurface(
        instance,
        window,
        nullptr,
        &surface
    );

    if (surfaceResult != VK_SUCCESS)
    {
        std::cout << "[ERRO] Vulkan: falha ao criar surface: "
                  << surfaceResult << "\n";

        vkDestroyInstance(instance, nullptr);
        glfwDestroyWindow(window);
        glfwTerminate();

        return -1;
    }

    std::cout << "[OK] Vulkan: surface criada\n";

    // =========================================
    // 12. LOOP DA JANELA
    // =========================================

    while (!glfwWindowShouldClose(window))
    {
        glfwPollEvents();
    }

    // =========================================
    // 13. FINALIZACAO
    // =========================================

    vkDestroySurfaceKHR(
        instance,
        surface,
        nullptr
    );

    vkDestroyInstance(
        instance,
        nullptr
    );

    glfwDestroyWindow(window);
    glfwTerminate();

    std::cout << "\nPrograma encerrado.\n";

    return 0;
}

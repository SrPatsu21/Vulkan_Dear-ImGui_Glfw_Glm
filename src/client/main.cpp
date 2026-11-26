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
    std::cout << "=== LIBRARY TEST ===\n\n";

    // =========================================
    // 1. GLM TEST
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
        std::cout << "[ERROR] GLM\n";
    }

    // =========================================
    // 2. ASSIMP TEST
    // =========================================

    std::cout << "[OK] Assimp: "
              << aiGetVersionMajor() << "."
              << aiGetVersionMinor() << "."
              << aiGetVersionPatch() << "\n";

    // =========================================
    // 3. STB IMAGE TEST
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
        std::cout << "[OK] STB Image: test image recognized\n";
    }
    else
    {
        std::cout << "[OK] STB Image: API accessible\n";
    }

    // =========================================
    // 4. KTX TEST
    // =========================================

    ktxTexture* texture = nullptr;

    KTX_error_code ktxResult = ktxTexture_CreateFromNamedFile(
        "nonexistent_file.ktx",
        KTX_TEXTURE_CREATE_LOAD_IMAGE_DATA_BIT,
        &texture
    );

    if (ktxResult != KTX_SUCCESS)
    {
        std::cout << "[OK] KTX: API accessible and call executed\n";
    }
    else
    {
        std::cout << "[OK] KTX: texture loaded\n";
        ktxTexture_Destroy(texture);
    }

    // =========================================
    // 5. IMGUI TEST
    // =========================================

    IMGUI_CHECKVERSION();

    ImGui::CreateContext();

    std::cout << "[OK] ImGui: context created\n";

    ImGui::DestroyContext();

    // =========================================
    // 6. GLFW TEST
    // =========================================

    if (!glfwInit())
    {
        std::cout << "[ERROR] GLFW: initialization failed\n";
        return -1;
    }

    std::cout << "[OK] GLFW: initialized\n";

    if (!glfwVulkanSupported())
    {
        std::cout << "[ERROR] GLFW: Vulkan support unavailable\n";
        glfwTerminate();
        return -1;
    }

    std::cout << "[OK] GLFW: Vulkan support detected\n";

    // =========================================
    // 7. VULKAN WINDOW SETUP
    // =========================================

    glfwWindowHint(GLFW_CLIENT_API, GLFW_NO_API);
    glfwWindowHint(GLFW_RESIZABLE, GLFW_TRUE);

    GLFWwindow* window = glfwCreateWindow(
        800,
        600,
        "COMPILER TEST - GLFW + VULKAN",
        nullptr,
        nullptr
    );

    if (!window)
    {
        std::cout << "[ERROR] GLFW: failed to create window\n";
        glfwTerminate();
        return -1;
    }

    std::cout << "[OK] GLFW: window created\n";

    // =========================================
    // 8. GLFW VULKAN EXTENSIONS
    // =========================================

    uint32_t glfwExtensionCount = 0;

    const char** glfwExtensions =
        glfwGetRequiredInstanceExtensions(&glfwExtensionCount);

    if (!glfwExtensions || glfwExtensionCount == 0)
    {
        std::cout << "[ERROR] Vulkan: GLFW extensions unavailable\n";

        glfwDestroyWindow(window);
        glfwTerminate();

        return -1;
    }

    std::cout << "[OK] Vulkan: GLFW extensions found\n";

    // =========================================
    // 9. VULKAN INSTANCE CREATION
    // =========================================

    VkApplicationInfo appInfo{};

    appInfo.sType = VK_STRUCTURE_TYPE_APPLICATION_INFO;
    appInfo.pApplicationName = "Library Test";
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
        std::cout << "[ERROR] Vulkan: failed to create instance: "
                  << resultVk << "\n";

        glfwDestroyWindow(window);
        glfwTerminate();

        return -1;
    }

    std::cout << "[OK] Vulkan: instance created\n";

    // =========================================
    // 10. GPU ENUMERATION
    // =========================================

    uint32_t gpuCount = 0;

    VkResult gpuResult = vkEnumeratePhysicalDevices(
        instance,
        &gpuCount,
        nullptr
    );

    if (gpuResult != VK_SUCCESS)
    {
        std::cout << "[ERROR] Vulkan: failed to enumerate GPUs\n";

        vkDestroyInstance(instance, nullptr);
        glfwDestroyWindow(window);
        glfwTerminate();

        return -1;
    }

    std::cout << "[OK] Vulkan: GPUs found: "
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
    // 11. VULKAN SURFACE CREATION
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
        std::cout << "[ERROR] Vulkan: failed to create surface: "
                  << surfaceResult << "\n";

        vkDestroyInstance(instance, nullptr);
        glfwDestroyWindow(window);
        glfwTerminate();

        return -1;
    }

    std::cout << "[OK] Vulkan: surface created\n";

    // =========================================
    // 12. WINDOW LOOP
    // =========================================

    while (!glfwWindowShouldClose(window))
    {
        glfwPollEvents();
    }

    // =========================================
    // 13. CLEANUP
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

    std::cout << "\nProgram finished.\n";

    return 0;
}
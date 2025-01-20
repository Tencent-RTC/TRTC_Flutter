cmake_minimum_required(VERSION 3.15)
set(PROJECT_NAME "tencent_trtc_cloud")
project(${PROJECT_NAME} LANGUAGES CXX)

# This value is used when generating builds using this plugin, so it must
# not be changed
set(PLUGIN_NAME "tencent_trtc_cloud_plugin")

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /utf-8")

include_directories(${CMAKE_CURRENT_SOURCE_DIR})

add_library(${PLUGIN_NAME} SHARED
  "tencent_trtc_cloud_plugin.cpp"
  "src/trtc_cloud.cpp"
  "src/texture_view_factory.cpp"
)
apply_standard_settings(${PLUGIN_NAME})
set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)
target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include")
target_link_libraries(${PLUGIN_NAME} PRIVATE flutter flutter_wrapper_plugin "Ws2_32" "${CMAKE_CURRENT_SOURCE_DIR}/lib/liteav.lib")
# List of absolute paths to libraries that should be bundled with the plugin
# set(tencent_trtc_cloud_bundled_libraries
#   ""
#   PARENT_SCOPE
# )

set(tencent_trtc_cloud_bundled_libraries
 "${CMAKE_CURRENT_SOURCE_DIR}/lib/txsoundtouch.dll;${CMAKE_CURRENT_SOURCE_DIR}/lib/txffmpeg.dll;${CMAKE_CURRENT_SOURCE_DIR}/lib/liteav.dll"
  PARENT_SCOPE
)
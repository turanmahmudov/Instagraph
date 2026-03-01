set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(PLUGIN "ImageProcessorPlugin")

find_package(Qt5 REQUIRED COMPONENTS Core Qml Quick Widgets)
find_package(OpenGL REQUIRED)

set(PLUGIN_SOURCES
    plugin.cpp
    src/imageprocessor.cpp
    src/offscreenrenderer.cpp
    src/cropimageprovider.cpp
    ImageProcessor.qrc
)

# Build as a MODULE (shared library loaded at runtime)
add_library(${PLUGIN} MODULE ${PLUGIN_SOURCES})

target_include_directories(${PLUGIN} PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/src
)

target_link_libraries(${PLUGIN}
    Qt5::Core
    Qt5::Qml
    Qt5::Quick
    Qt5::Widgets
    OpenGL::GL
)

# Output to ImageProcessor/ directory (matches qmldir module name)
set_target_properties(${PLUGIN} PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/ImageProcessor
)

# Copy qmldir and QML types to build directory so QML can find the plugin
configure_file(qmldir ${CMAKE_BINARY_DIR}/ImageProcessor/qmldir COPYONLY)
configure_file(qml/components/ImageProcessorOutput.qml ${CMAKE_BINARY_DIR}/ImageProcessor/ImageProcessorOutput.qml COPYONLY)

# Install the plugin
execute_process(
    COMMAND dpkg-architecture -qDEB_HOST_MULTIARCH
    OUTPUT_VARIABLE ARCH_TRIPLET
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

set(QT_IMPORTS_DIR "lib/${ARCH_TRIPLET}")

install(TARGETS ${PLUGIN} DESTINATION ${QT_IMPORTS_DIR}/ImageProcessor/)
install(FILES qmldir DESTINATION ${QT_IMPORTS_DIR}/ImageProcessor/)
install(FILES qml/components/ImageProcessorOutput.qml DESTINATION ${QT_IMPORTS_DIR}/ImageProcessor/)

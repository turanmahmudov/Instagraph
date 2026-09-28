cmake_minimum_required(VERSION 3.0.0)
project(instagraph C CXX)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

find_package(Qt5Core REQUIRED)
find_package(Qt5Qml REQUIRED)
find_package(Qt5Quick REQUIRED)

# Get architecture for install paths
execute_process(
    COMMAND dpkg-architecture -qDEB_HOST_MULTIARCH
    OUTPUT_VARIABLE ARCH_TRIPLET
    OUTPUT_STRIP_TRAILING_WHITESPACE
)
set(QT_IMPORTS_DIR "lib/${ARCH_TRIPLET}")

set(PROJECT_NAME "instagraph")
set(FULL_PROJECT_NAME "instagraph-devs.turan-mahmudov-l")
set(DATA_DIR .)
set(DESKTOP_FILE_NAME ${PROJECT_NAME}.desktop)

# SDK framework for manifest
if(DEFINED ENV{SDK_FRAMEWORK})
    set(CLICK_FRAMEWORK "$ENV{SDK_FRAMEWORK}")
else()
    set(CLICK_FRAMEWORK "ubuntu-touch-24.04-1.x")
endif()

# Target architecture for manifest
if(DEFINED ENV{ARCH})
    set(CLICK_ARCH "$ENV{ARCH}")
else()
    execute_process(
        COMMAND dpkg-architecture -qDEB_HOST_ARCH
        OUTPUT_VARIABLE CLICK_ARCH
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
endif()

# Configure and install manifest
configure_file(manifest.json.in ${CMAKE_CURRENT_BINARY_DIR}/manifest.json)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/manifest.json DESTINATION ${CMAKE_INSTALL_PREFIX})

# Install app files (flat structure)
install(FILES instagraph.apparmor DESTINATION ${DATA_DIR})
install(FILES assets/instagraph.png DESTINATION ${DATA_DIR})
install(FILES instagraph.dispatcher DESTINATION ${DATA_DIR})

# Install QML files
install(DIRECTORY qml DESTINATION ${DATA_DIR})

# Main executable
set(APP_SOURCES
    main.cpp
)

set(APP_HEADERS
)

# Resources
qt5_add_resources(APP_RESOURCES Instagraph.qrc)

add_executable(${PROJECT_NAME} ${APP_SOURCES} ${APP_HEADERS} ${APP_RESOURCES})

target_link_libraries(${PROJECT_NAME}
    Qt5::Core
    Qt5::Gui
    Qt5::Qml
    Qt5::Quick
)

set_target_properties(${PROJECT_NAME} PROPERTIES LINK_FLAGS_RELEASE -s)
install(TARGETS ${PROJECT_NAME} RUNTIME DESTINATION ${CMAKE_INSTALL_PREFIX})

# Desktop file (flat structure)
install(FILES instagraph.desktop DESTINATION ${DATA_DIR})

# Translations
if(EXISTS ${CMAKE_SOURCE_DIR}/po/CMakeLists.txt)
    add_subdirectory(po)
endif()

# Build plugins - they are lazy-loaded by QML at runtime
add_subdirectory(plugins)

# Make source files visible in Qt Creator
file(GLOB_RECURSE PROJECT_SRC_FILES
    RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
    qml/*.qml
    qml/*.js
    *.json
    *.json.in
    *.apparmor
    *.desktop
)
add_custom_target(${PROJECT_NAME}_FILES ALL SOURCES ${PROJECT_SRC_FILES})

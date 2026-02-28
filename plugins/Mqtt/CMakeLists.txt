set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

set(PLUGIN "MqttPlugin")

find_package(Qt5 REQUIRED COMPONENTS Core Qml Quick Network)
find_package(ZLIB REQUIRED)

set(PLUGIN_SOURCES
    plugin.cpp
    
    # Facade
    src/InstagramMqtt.cpp
    
    # Thrift
    src/thrift/ThriftCompact.cpp
    
    # MQTToT Protocol
    src/mqttot/MqttotClient.cpp
    
    # FBNS (Push Notifications)
    src/fbns/FbnsClient.cpp
    
    # Realtime (Live Updates)
    src/realtime/RealtimeClient.cpp
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
    Qt5::Network
    ZLIB::ZLIB
)

# Output to InstagramMqtt/ directory (matches qmldir module name)
set_target_properties(${PLUGIN} PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/InstagramMqtt
)

# Copy qmldir to build directory so QML can find the plugin
configure_file(qmldir ${CMAKE_BINARY_DIR}/InstagramMqtt/qmldir COPYONLY)

# Install the plugin
execute_process(
    COMMAND dpkg-architecture -qDEB_HOST_MULTIARCH
    OUTPUT_VARIABLE ARCH_TRIPLET
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

set(QT_IMPORTS_DIR "lib/${ARCH_TRIPLET}")

install(TARGETS ${PLUGIN} DESTINATION ${QT_IMPORTS_DIR}/InstagramMqtt/)
install(FILES qmldir DESTINATION ${QT_IMPORTS_DIR}/InstagramMqtt/)

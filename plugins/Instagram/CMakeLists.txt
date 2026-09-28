set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

set(PLUGIN "InstagramPlugin")

find_package(Qt5 REQUIRED COMPONENTS Core Qml Quick Network)
find_package(OpenSSL REQUIRED)

set(PLUGIN_SOURCES
    plugin.cpp
    
    # API
    src/api/Instagram.cpp
    
    # Core
    src/core/ApiClient.cpp
    src/core/Request.cpp
    src/core/Response.cpp
    
    # Session & Network
    src/session/SessionManager.cpp
    src/network/CookieManager.cpp
    src/network/SignatureGenerator.cpp
    
    # Crypto
    src/crypto/PasswordEncryptor.cpp
    
    # Endpoints
    src/endpoints/AccountEndpoint.cpp
    src/endpoints/DirectEndpoint.cpp
    src/endpoints/FeedEndpoint.cpp
    src/endpoints/HashtagEndpoint.cpp
    src/endpoints/LocationEndpoint.cpp
    src/endpoints/MediaEndpoint.cpp
    src/endpoints/PeopleEndpoint.cpp
    src/endpoints/SearchEndpoint.cpp
    src/endpoints/StoryEndpoint.cpp
    src/endpoints/UploadEndpoint.cpp
    src/endpoints/UsertagEndpoint.cpp
    
    # Media
    src/media/MediaCache.cpp

    # Errors
    src/errors/ClientError.cpp
    src/errors/ErrorHandler.cpp
    
    # Utils
    src/utils/Constants.cpp
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
    OpenSSL::SSL
    OpenSSL::Crypto
)

# Output to Instagram/ directory (matches qmldir module name)
set_target_properties(${PLUGIN} PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/Instagram
)

# Copy qmldir to build directory so QML can find the plugin
configure_file(qmldir ${CMAKE_BINARY_DIR}/Instagram/qmldir COPYONLY)

# Install the plugin
execute_process(
    COMMAND dpkg-architecture -qDEB_HOST_MULTIARCH
    OUTPUT_VARIABLE ARCH_TRIPLET
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

set(QT_IMPORTS_DIR "lib/${ARCH_TRIPLET}")

install(TARGETS ${PLUGIN} DESTINATION ${QT_IMPORTS_DIR}/Instagram/)
install(FILES qmldir DESTINATION ${QT_IMPORTS_DIR}/Instagram/)

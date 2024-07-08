cmake_minimum_required(VERSION 3.17)

# Title: "Building in source warning" {{{
if(CMAKE_SOURCE_DIR STREQUAL CMAKE_BINARY_DIR)

    message(FATAL_ERROR "Do not build in-source. Remove CMakeCache.txt and the CMakeFiles/")
endif()
#}}}

message(FATAL_ERROR "Name your project and package, specify version")

set(PACKAGE_NAME "nix-cpp-template")
set(PACKAGE_DESCRIPTION "Nix CPP Template")

project(${PACKAGE_NAME} VERSION 0.0.1 LANGUAGES CXX)

get_directory_property(PARENT_PROJ_NAME PARENT_DIRECTORY)

message(STATUS "PROJECT_BINARY_DIR ${PROJECT_BINARY_DIR} GENERATOR ${CMAKE_GENERATOR}")
message(STATUS "PROJECT_SOURCE_DIR ${PROJECT_SOURCE_DIR} CMAKE_SOURCE_DIR ${CMAKE_SOURCE_DIR}")

# Title: "Compile commands dump for clangd" {{{
set(CMAKE_EXPORT_COMPILE_COMMANDS ON CACHE INTERNAL "")

if(CMAKE_EXPORT_COMPILE_COMMANDS)
    set(CMAKE_CXX_STANDARD_INCLUDE_DIRECTORIES ${CMAKE_CXX_IMPLICIT_INCLUDE_DIRECTORIES})
endif()
#}}}

# Title: "Additional build options" {{{
if(APPLE)
    add_compile_options(-mmacosx-version-min=10.15)
    option (WITH_UNWIND "Enable libunwind support" OFF)
else()
    option (WITH_UNWIND "Enable libunwind support" ON)
endif()

option (USE_SANITIZERS "Use asan and usan sanitizers" OFF)
option (BUILD_DOCS "Generate documentation " ON)
option (BUILD_SHARED_LIBS "Build shared libraries" OFF)
option (USE_MOLD "Whether to use mold linker" OFF)
option (ENABLE_INSTALL "Should ${PROJECT_NAME} be added to the install list?" ON)
option (ENABLE_TESTING "Should unit tests be compiled." ON)

set    (MIMALLOC_OPTS "" CACHE STRING "Additional mimalloc compile options")
set    (MIMALLOC_LIBNAME "libmimalloc.a" CACHE STRING "Name of mimalloc library")
set    (${PROJECT_NAME}_INSTALL_CMAKEDIR "${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}"
        CACHE STRING "Path to install ${PROJECT_NAME} Config*.cmake files to.")
# }}}

# Title: "Standard CMake modules + compiler flag support check" {{{

if(ENABLE_TESTING)

    find_package(GTest REQUIRED)

    # Must be called before adding tests but after calling project(). This automatically calls
    # enable_testing() and configures ctest targets when using Make/Ninja

    include(CTest)
    include(GoogleTest)
endif()

# This is a really useful set of scripts that creates options that depends on other options. It can
# even be used with generator expressions
include(CMakeDependentOption)

# This will define the default values for installation directories (all platforms even if named
# GNU)
include(GNUInstallDirs)

# Tell CMake that the `install` target needs to install required system libraries (eg: Windows SDK)
include(InstallRequiredSystemLibraries)

# Helper to create relocatable packages
include(CMakePackageConfigHelpers)

# Helper to make sure that the extra flags we pass to the compiler won't be ignored
include(CheckCXXCompilerFlag)

# Can not use CHECK_CXX_COMPILER_FLAG due to linker problems.
set(CMAKE_REQUIRED_FLAGS "-fsanitize=address")
check_cxx_source_compiles("int main() { return 0; }" SUPPORT_ASAN)

set(CMAKE_REQUIRED_FLAGS "-fsanitize=undefined")
check_cxx_source_compiles("int main() { return 0; }" SUPPORT_USAN)
set(CMAKE_REQUIRED_FLAGS "")
#}}}

# Title: "Playing nice when included as a submodule/subdirectory" {{{
if (PARENT_PROJ_NAME)

    message(STATUS "PARENT_PROJ_NAME ${PARENT_PROJ_NAME}")
else()

    message(FATAL_ERROR "Set CPP standard for the project")

    set(CMAKE_CXX_STANDARD 14)
    set(CMAKE_CXX_STANDARD_REQUIRED ON)
    list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

    if (USE_SANITIZERS AND SUPPORT_ASAN)
        set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -fsanitize=address")
    endif()

    if (USE_SANITIZERS AND SUPPORT_USAN)
        set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -fsanitize=undefined")
    endif()
endif()
#}}}

# Title: "Dependencies" {{{

message(FATAL_ERROR "Add dependencies here")

find_package(absl REQUIRED)
#}}}

# Title: "Targets" {{{

message(FATAL_ERROR "Configure targets AND add the target libs as -Libs to pkg-config")

add_subdirectory(src)

add_library(nix_cpp_template STATIC ${SOURCES})

target_include_directories(nix_cpp_template PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
)

if(ENABLE_TESTING)

    add_subdirectory(test)

    add_executable(tests ${TEST_SOURCES})

    target_include_directories(
        tests
        PRIVATE $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    )

    target_link_libraries(tests nix_cpp_template GTest::GTest GTest::Main)
    gtest_discover_tests(tests)

endif()


#}}}

# Title: "Packaging" {{{
if(ENABLE_INSTALL)

    # Use version checking helper provided by CMake so that users can
    # safely use a version number in their find_package calls
    write_basic_package_version_file(
        ${CMAKE_CURRENT_BINARY_DIR}/${PACKAGE_NAME}-config-version.cmake
        VERSION ${PROJECT_VERSION}
        COMPATIBILITY AnyNewerVersion
    )

    install(FILES
        ${CMAKE_CURRENT_BINARY_DIR}/${PACKAGE_NAME}-config-version.cmake
        DESTINATION ${CMAKE_INSTALL_DATADIR}/${PACKAGE_NAME}
    )

    message(FATAL_ERROR "DID YOU ADD THE TARGET LIBS TO THE PKG-CONFIG???")

    configure_file(
        ${CMAKE_CURRENT_SOURCE_DIR}/cmake/template.pc.in
        ${CMAKE_CURRENT_BINARY_DIR}/${PACKAGE_NAME}.pc
    )

    install(
        FILES ${CMAKE_CURRENT_BINARY_DIR}/${PACKAGE_NAME}.pc
        DESTINATION ${CMAKE_INSTALL_LIBDIR}/pkgconfig
    )

    message(FATAL_ERROR "Add all the exportable targets here")

    install(
        TARGETS nix_cpp_template
        EXPORT ${PACKAGE_NAME}Targets
        FILE_SET HEADERS
    )

    install(
        EXPORT ${PACKAGE_NAME}Targets
        NAMESPACE nixcpptmplt::
        DESTINATION ${CMAKE_INSTALL_DATADIR}/${PACKAGE_NAME}
    )

    install(
        FILES
        ${CMAKE_CURRENT_SOURCE_DIR}/cmake/template-config.cmake
        ${CMAKE_CURRENT_BINARY_DIR}/${PACKAGE_NAME}-config-version.cmake
        DESTINATION ${CMAKE_INSTALL_DATADIR}/${PACKAGE_NAME}
    )

endif()

#}}}

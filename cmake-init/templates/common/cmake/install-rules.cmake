{% if not exe %}if(PROJECT_IS_TOP_LEVEL)
  set(CMAKE_INSTALL_INCLUDEDIR include/{= name =} CACHE PATH "")
endif(){% if header %}

# Project is configured with no languages, so tell GNUInstallDirs the lib dir
set(CMAKE_INSTALL_LIBDIR lib CACHE PATH ""){% end %}

{% end %}include(CMakePackageConfigHelpers)
include(GNUInstallDirs)

# find_package(<package>) call for consumers to find this project
set(package {= name =}){% if not exe %}

install(
    DIRECTORY{% if lib %}
   {% end %} include/{% if lib %}
    "${PROJECT_BINARY_DIR}/export/"{% end %}
    DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
    COMPONENT {= name =}_Development
){% end %}

install(
    TARGETS {= name =}_{% if exe %}exe{% else %}{= name =}
    EXPORT {= name =}Targets{% end %}{% if exe %}
    RUNTIME COMPONENT {= name =}_Runtime{% end %}{% if lib %}
    RUNTIME #
    COMPONENT {= name =}_Runtime
    LIBRARY #
    COMPONENT {= name =}_Runtime
    NAMELINK_COMPONENT {= name =}_Development
    ARCHIVE #
    COMPONENT {= name =}_Development
    INCLUDES #
    DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"{% end %}{% if header %}
    INCLUDES DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"{% end %}
){% if not exe and pm %}

configure_file(
    cmake/install-config.cmake.in "${package}Config.cmake"
    @ONLY
){% end %}

write_basic_package_version_file(
    "${package}ConfigVersion.cmake"
    COMPATIBILITY SameMajorVersion{% if header %}
    ARCH_INDEPENDENT{% end %}
)

# Allow package maintainers to freely override the path for the configs
set(
    {= name =}_INSTALL_CMAKEDIR "${CMAKE_INSTALL_DATADIR}/${package}"
    CACHE PATH "CMake package config location relative to the install prefix"
)
mark_as_advanced({= name =}_INSTALL_CMAKEDIR){% if not exe %}{% if not pm %}

install(
    FILES cmake/install-config.cmake
    DESTINATION "${{= name =}_INSTALL_CMAKEDIR}"
    RENAME "${package}Config.cmake"
    COMPONENT {= name =}_Development
){% end %}

install(
    FILES{% if pm %}
    "${PROJECT_BINARY_DIR}/${package}Config.cmake"
   {% end %} "${PROJECT_BINARY_DIR}/${package}ConfigVersion.cmake"
    DESTINATION "${{= name =}_INSTALL_CMAKEDIR}"
    COMPONENT {= name =}_Development
)

install(
    EXPORT {= name =}Targets
    NAMESPACE {= name =}::
    DESTINATION "${{= name =}_INSTALL_CMAKEDIR}"
    COMPONENT {= name =}_Development
){% else %}

install(
    FILES "${PROJECT_BINARY_DIR}/${package}ConfigVersion.cmake"
    DESTINATION "${{= name =}_INSTALL_CMAKEDIR}"
    COMPONENT {= name =}_Development
)

# Export variables for the install script to use
install(CODE "
set({= name =}_NAME [[$<TARGET_FILE_NAME:{= name =}_exe>]])
set({= name =}_INSTALL_CMAKEDIR [[${{= name =}_INSTALL_CMAKEDIR}]])
set(CMAKE_INSTALL_BINDIR [[${CMAKE_INSTALL_BINDIR}]])
" COMPONENT {= name =}_Development)

install(
    SCRIPT cmake/install-script.cmake
    COMPONENT {= name =}_Development
){% end %}

if(PROJECT_IS_TOP_LEVEL)
  include(CPack)
endif()

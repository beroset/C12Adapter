# Get current directory
IF(NOT DEFINED CMAKE_CURRENT_LIST_DIR)
  GET_FILENAME_COMPONENT(CMAKE_CURRENT_LIST_DIR
    ${CMAKE_CURRENT_LIST_FILE} PATH)
ENDIF()

# Add current directory to CMAKE_MODULE_PATH
LIST(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR})

# Include MeteringSDKDefaults, MeteringSDKMacros and MeteringSDKSettings
INCLUDE(MeteringSDKDefaults)
INCLUDE(MeteringSDKMacros)
INCLUDE(MeteringSDKSettings)
INCLUDE(MeteringSDKCPack)

# Get MeteringSDK source directory
GET_FILENAME_COMPONENT(METERINGSDK_SOURCE_DIR ${CMAKE_CURRENT_LIST_DIR}/../../ REALPATH)

# Set MeteringSDK binary directory
SET(METERINGSDK_BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR})

# Add MeteringSDK source and binary directories to the include directories
INCLUDE_DIRECTORIES(${METERINGSDK_BINARY_DIR})
INCLUDE_DIRECTORIES(${METERINGSDK_SOURCE_DIR})

IF(NOT M_NO_JNI AND NOT ANDROID) # Android NDK always has JNI includes
  SET(_TMP_SAVED_PATH $ENV{PATH})
  SET(ENV{PATH} "")             # Need to temporarily eliminate PATH as C++Builder has include/jni.h that is found through PATH
  FIND_PACKAGE(JNI REQUIRED)
  SET(ENV{PATH} "${_TMP_SAVED_PATH}")
  INCLUDE_DIRECTORIES(${JNI_INCLUDE_DIRS})
ENDIF()

IF(BUILD_SHARED_LIBS AND NOT M_DYNAMIC)
  SET(M_DYNAMIC ON)
ENDIF()

IF(M_DYNAMIC AND NOT BUILD_SHARED_LIBS)
  SET(BUILD_SHARED_LIBS ON)
ENDIF()

IF(NOT M_NO_METERINGSDKSETTINGS)
    CONFIGURE_FILE(${CMAKE_CURRENT_LIST_DIR}/MeteringSDKSettings.h.cmake ${METERINGSDK_BINARY_DIR}/MeteringSDKSettings.h @ONLY)
ENDIF()

SETUP_DEFAULT_METERINGSDK_DEFINITIONS()
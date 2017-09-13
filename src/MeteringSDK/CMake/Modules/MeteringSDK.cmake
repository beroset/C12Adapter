# Get the current directory
IF(DEFINED CMAKE_CURRENT_LIST_DIR)
   SET(MSDK_CURRENT_LIST_DIR ${CMAKE_CURRENT_LIST_DIR})
ELSE()
   GET_FILENAME_COMPONENT(MSDK_CURRENT_LIST_DIR ${CMAKE_CURRENT_LIST_FILE} PATH)
ENDIF()
LIST(APPEND CMAKE_MODULE_PATH ${MSDK_CURRENT_LIST_DIR})

INCLUDE(MeteringSDKDefaults)
INCLUDE(MeteringSDKMacros)
INCLUDE(MeteringSDKSettings)

GET_FILENAME_COMPONENT(METERINGSDK_SOURCE_DIR  ${MSDK_CURRENT_LIST_DIR}/../.. REALPATH)
GET_FILENAME_COMPONENT(PROJECT_ROOT_SOURCE_DIR ${METERINGSDK_SOURCE_DIR}/../.. REALPATH)

OPTION(METERINGSDK_FIND_PACKAGE "Do not include MeteringSDK directory to project, use FIND_PACKAGE" OFF)

IF(NOT DEFINED METERINGSDK_COMPONENTS)
    SET(METERINGSDK_COMPONENTS MCORE MCOM)
ENDIF()

IF(NOT METERINGSDK_FIND_PACKAGE)
  # Set MeteringSDK binary directory
  SET(METERINGSDK_BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/MeteringSDK)

  # Add MeteringSDK source and binary directories to the include directories
  INCLUDE_DIRECTORIES(${METERINGSDK_BINARY_DIR})
  INCLUDE_DIRECTORIES(${METERINGSDK_SOURCE_DIR})

  # Add MeteringSDK directory to the build
  ADD_SUBDIRECTORY(${METERINGSDK_SOURCE_DIR} ${METERINGSDK_BINARY_DIR})
  SET(MeteringSDK_LIBRARIES ${METERINGSDK_COMPONENTS})
ELSE()
  FIND_PACKAGE(MeteringSDK REQUIRED ${METERINGSDK_COMPONENTS})
  INCLUDE(${MeteringSDK_USE_FILE})
ENDIF()

SET(METERINGSDK_ALREADY_INCLUDED TRUE)
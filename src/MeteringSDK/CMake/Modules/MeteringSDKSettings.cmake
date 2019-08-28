IF(INSIDE_METERINGSDK)
   SET(M_COMPANY_NAME                  "Elster Solutions"                                    CACHE STRING "Company name")
   SET(M_PRODUCT_NAME                  "MyProduct"                                           CACHE STRING "Product name")
   SET(M_PRODUCT_LEGAL_COPYRIGHT       "Copyright (c) 1997-2017 Elster Solutions"            CACHE STRING "Product copyright")
   SET(M_PRODUCT_VERSION               "1.0.0"                                               CACHE STRING "Product version")
   SET(M_GLOBAL_MESSAGE_CATALOG_DOMAIN ""                                                    CACHE STRING "Global message catalog domain name")

   MESSAGE(STATUS "Project build location (CMAKE_BINARY_DIR) = ${CMAKE_BINARY_DIR}")
   MESSAGE(STATUS "Project root location (PROJECT_ROOT_SOURCE_DIR) = ${PROJECT_ROOT_SOURCE_DIR}")
   MESSAGE(STATUS "MeteringSDK location (METERINGSDK_SOURCE_DIR) = ${METERINGSDK_SOURCE_DIR}")

   # Parse MeteringSDK version from the version header file
   FILE(STRINGS ${METERINGSDK_SOURCE_DIR}/MCORE/MeteringSDKVersion.h METERINGSDKVERSION_H)
   FOREACH(SOURCE_LINE ${METERINGSDKVERSION_H})
     IF(${SOURCE_LINE} MATCHES "#define[ ]+M_SDK_VERSION_MAJOR")
        STRING(REGEX MATCHALL "[0-9]+" M_SDK_VERSION_MAJOR ${SOURCE_LINE})
     ELSEIF(${SOURCE_LINE} MATCHES "#define[ ]+M_SDK_VERSION_MIDDLE")
        STRING(REGEX MATCHALL "[0-9]+" M_SDK_VERSION_MIDDLE ${SOURCE_LINE})
     ELSEIF(${SOURCE_LINE} MATCHES "#define[ ]+M_SDK_VERSION_MINOR")
        STRING(REGEX MATCHALL "[0-9]+" M_SDK_VERSION_MINOR ${SOURCE_LINE})
     ELSEIF(${SOURCE_LINE} MATCHES "#define[ ]+M_SDK_VERSION_TAG")
        STRING(REGEX MATCHALL "[0-9]+" M_SDK_VERSION_TAG ${SOURCE_LINE})
     ENDIF()
   ENDFOREACH()
   SET(M_SDK_VERSION "${M_SDK_VERSION_MAJOR}.${M_SDK_VERSION_MIDDLE}.${M_SDK_VERSION_MINOR}.${M_SDK_VERSION_TAG}")
   MESSAGE(STATUS "MeteringSDK version determined from header: ${M_SDK_VERSION}")

   # Parse product version into separate defines M_PRODUCT_VERSION_MAJOR, M_PRODUCT_VERSION_MIDDLE, M_PRODUCT_VERSION_MINOR, and M_PRODUCT_VERSION_TAG
   # Use subversion info if the fourth digit was not given explicitly
   # M_SDK_VERSION_* can be used to point to the corresponding MeteringSDK numbers
   STRING(REPLACE "M_SDK_VERSION_MAJOR"  "${M_SDK_VERSION_MAJOR}"  M_PRODUCT_VERSION ${M_PRODUCT_VERSION})
   STRING(REPLACE "M_SDK_VERSION_MIDDLE" "${M_SDK_VERSION_MIDDLE}" M_PRODUCT_VERSION ${M_PRODUCT_VERSION})
   STRING(REPLACE "M_SDK_VERSION_MINOR"  "${M_SDK_VERSION_MINOR}"  M_PRODUCT_VERSION ${M_PRODUCT_VERSION})
   STRING(REPLACE "M_SDK_VERSION_TAG"    "${M_SDK_VERSION_TAG}"    M_PRODUCT_VERSION ${M_PRODUCT_VERSION})
   STRING(REGEX MATCHALL "[0-9]+" M_PRODUCT_VERSION_LIST ${M_PRODUCT_VERSION})
   LIST(LENGTH M_PRODUCT_VERSION_LIST M_PRODUCT_VERSION_LIST_LENGTH)
   IF((M_PRODUCT_VERSION_LIST_LENGTH LESS 2) OR (M_PRODUCT_VERSION_LIST_LENGTH GREATER 4))
     MESSAGE(FATAL_ERROR "Supply two to four digits to your M_PRODUCT_VERSION")
   ELSE()
     LIST(GET M_PRODUCT_VERSION_LIST 0 M_PRODUCT_VERSION_MAJOR)
     LIST(GET M_PRODUCT_VERSION_LIST 1 M_PRODUCT_VERSION_MIDDLE)
     IF(M_PRODUCT_VERSION_LIST_LENGTH GREATER 2)
       LIST(GET M_PRODUCT_VERSION_LIST 2 M_PRODUCT_VERSION_MINOR)
     ELSE()
       SET(M_PRODUCT_VERSION_MINOR 0)
     ENDIF()
     IF(M_PRODUCT_VERSION_LIST_LENGTH EQUAL 4)
       LIST(GET M_PRODUCT_VERSION_LIST 3 M_PRODUCT_VERSION_TAG)
     ELSE()
       FIND_PACKAGE(Subversion)
       IF(NOT Subversion_FOUND)
         MESSAGE(STATUS "Did not find Subversion, setting M_PRODUCT_VERSION_TAG into 0...")
         SET(M_PRODUCT_VERSION_TAG 0)
       ELSE()
         # Have to execute svn command explicitly first time,
         #    as Subversion_WC_INFO signals an error when it fails
         EXECUTE_PROCESS(COMMAND ${Subversion_SVN_EXECUTABLE} info ${CMAKE_CURRENT_SOURCE_DIR}
                         ERROR_VARIABLE  Subversion_svn_info_error
                         RESULT_VARIABLE Subversion_svn_info_result
                         OUTPUT_VARIABLE Subversion_svn_info_error
                         OUTPUT_STRIP_TRAILING_WHITESPACE)
         IF(NOT ${Subversion_svn_info_result} EQUAL 0)
           MESSAGE(STATUS "Command \"${Subversion_SVN_EXECUTABLE} info ${dir}\" gave output:\n   ${Subversion_svn_info_error}")
           MESSAGE(STATUS "Recovering by setting M_PRODUCT_VERSION_TAG into 0... ")
           SET(M_PRODUCT_VERSION_TAG 0)
         ELSE()
           # Now let's execute svn the proper way, second time
           Subversion_WC_INFO(${CMAKE_CURRENT_SOURCE_DIR} ER)
           SET(M_PRODUCT_VERSION_TAG ${ER_WC_REVISION})
         ENDIF()
       ENDIF()
     ENDIF()
   ENDIF()
   MESSAGE(STATUS "Product: ${M_PRODUCT_NAME}, Version: ${M_PRODUCT_VERSION_MAJOR}.${M_PRODUCT_VERSION_MIDDLE}.${M_PRODUCT_VERSION_MINOR}.${M_PRODUCT_VERSION_TAG}")
ENDIF(INSIDE_METERINGSDK)

OPTION(M_UNICODE                         "Build unicode version (requires !M_NO_WCHAR_T)"  ON)
OPTION(M_DYNAMIC                         "Whether to use DLL for MeteringSDK libraries"    OFF)
OPTION(M_USE_MFC                         "Whether to include MFC headers when compiling MeteringSDK libs" OFF)
OPTION(M_USE_CRYPTODEV                   "Whether to use /dev/crypto device"               OFF)
OPTION(M_USE_CRYPTOAPI                   "Whether to use Windows CryptoAPI"                OFF)
OPTION(M_USE_OPENSSL                     "Whether to use OpenSSL for cryptography support" OFF)
IF(DEFINED UCLINUX)
  OPTION(M_NO_WCHAR_T                    "No support for any unicode or wchar_t"           ON)
ELSE()
  OPTION(M_NO_WCHAR_T                    "No support for any unicode or wchar_t"           OFF)
ENDIF()
OPTION(M_NO_ENCODING                     "No character encoding, no MStr::Encode/Decode"   OFF)
OPTION(M_NO_MESSAGE_CATALOG              "No MessageCatalog and related internationalization facilities"   OFF)
OPTION(M_NO_REFLECTION                   "No reflection API"                               OFF)
OPTION(M_NO_FULL_REFLECTION              "No reflection API on method parameters"          OFF)
OPTION(M_NO_MULTITHREADING               "No multithreading support"                       OFF)
OPTION(M_NO_SOCKETS                      "No sockets"                                      OFF)
OPTION(M_NO_SOCKETS_UDP                  "No UDP support in sockets"                       OFF)
OPTION(M_NO_SOCKETS_SOCKS                "No SOCKS proxy for sockets"                      OFF)
OPTION(M_NO_FILESYSTEM                   "No file system related code"                     OFF)
OPTION(M_NO_CONSOLE                      "No console streams"                              OFF)
OPTION(M_NO_TIME                         "No time support: MTime and MTimeSpan"            OFF)
OPTION(M_NO_VARIANT                      "No MVariant type (very restrictive)"             OFF)
OPTION(M_NO_VERBOSE_ERROR_INFORMATION    "No strings and stack in exceptions"              OFF)
OPTION(M_NO_PROGRESS_MONITOR             "No MProgressMonitor class"                       OFF)
OPTION(M_NO_BASE64                       "No base64 conversion"                            OFF)
OPTION(M_NO_SERIAL_PORT                  "No serial port support"                          OFF)
OPTION(M_NO_XML                          "No support for XML handling classes"             OFF)
OPTION(M_NO_JNI                          "No support for Java Native Interface (JNI)"      ON)
OPTION(M_NO_MCOM_MONITOR                 "No communications monitor"                       OFF)
OPTION(M_NO_MCOM_MONITOR_SHARED_POINTER  "No use of communications monitor shared pointer" OFF)
OPTION(M_NO_MCOM_CHANNEL_SOCKET          "No socket channel"                               OFF)
OPTION(M_NO_MCOM_CHANNEL_SOCKET_UDP      "No UDP socket channel"                           OFF)
OPTION(M_NO_MCOM_HANDLE_PEER_DISCONNECT  "No handling for socket peer disconnect (FIN)"    OFF)
OPTION(M_NO_MCOM_CHANNEL_MODEM           "No Modem channel"                                OFF)
OPTION(M_NO_MCOM_FACTORY                 "No MCOM factory"                                 OFF)
OPTION(M_NO_MCOM_COMMAND_QUEUE           "No Q services in MCOM"                           OFF)
OPTION(M_NO_MCOM_PASSWORD_AND_KEY_LIST   "No support for password and key lists"           OFF)
OPTION(M_NO_MCOM_PROTOCOL_THREAD         "No thread support for MCOM command queue"        OFF)
OPTION(M_NO_MCOM_KEEP_SESSION_ALIVE      "No support for Protocol.KeepSessionAlive"        OFF)
OPTION(M_NO_MCOM_PROTOCOL_C1218          "No class MProtocolC1218"                         OFF)
OPTION(M_NO_MCOM_PROTOCOL_C1221          "No class MProtocolC1221"                         OFF)
OPTION(M_NO_MCOM_PROTOCOL_C1222          "No class MProtocolC1222"                         OFF)
OPTION(M_NO_MCOM_IDENTIFY_METER          "No Protocol.IdentifyMeter feature"               OFF)
OPTION(M_NO_METERINGSDKSETTINGS          "Don't generate MeteringSDKSettings.h"            OFF)

IF(WIN32)
   OPTION(M_NO_MCOM_MONITOR_SYSLOG        "No use of syslog for monitoring"                ON)
   OPTION(M_NO_REGISTRY                   "No Windows registry"                            OFF)
   OPTION(M_NO_DYNAMIC_LIBRARY            "No wrapper for shared object (dll) API"         OFF)
   OPTION(M_NO_AUTOMATION                 "No OLE and Automation support"                  OFF)
   OPTION(M_NO_MCOM_RAS_DIAL              "No RAS dial in socket channel"                  OFF)
ELSE()
   OPTION(M_NO_MCOM_MONITOR_SYSLOG        "No use of syslog for monitoring"                OFF)
   OPTION(M_NO_REGISTRY                   "No Windows registry"                            ON)
   OPTION(M_NO_DYNAMIC_LIBRARY            "No wrapper for shared object (dll) API"         ON)
   OPTION(M_NO_AUTOMATION                 "No OLE and Automation support"                  ON)
   OPTION(M_NO_MCOM_RAS_DIAL              "No RAS dial in socket channel"                  ON)
ENDIF()

OPTION(M_NO_LUA_COOPERATIVE_IO            "No Lua coroutine based IO scheduling"           ON)

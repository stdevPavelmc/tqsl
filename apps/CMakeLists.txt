project(tqsl)

set(OSX_ARCH i386 CACHE STRING "Architectures to build for OSX")

string(REPLACE " " ";" CMAKE_OSX_ARCHITECTURES ${OSX_ARCH})

if(WIN32)
	set(wxWidgets_USE_STATIC ON)
	add_definitions(-DCURL_STATICLIB)
	add_definitions(-DXML_STATIC)
endif()

find_package(CURL REQUIRED)
find_package(EXPAT REQUIRED)

find_package(wxWidgets COMPONENTS core base adv html REQUIRED)

find_package(ZLIB REQUIRED)

include(${wxWidgets_USE_FILE})

if(APPLE)
	find_library(CARBON_LIBRARY Carbon)
	find_path(CARBON_INCLUDE_DIR Carbon.h)
endif()

include_directories(${tqsllib_SOURCE_DIR} ${ZLIB_INCLUDE_DIR} ${EXPAT_INCLUDE_DIR} ${CURL_INCLUDE_DIR} ${CARBON_INCLUDE_DIR} ${OPENSSL_INCLUDE_DIR} ${BDB_INCLUDE_DIR} ${LMDB_INCLUDE_DIR})

if(${BUILD} MATCHES "-(alpha|beta|test|rc[0-9])")
	message("${BUILD} is a test build")
	add_definitions(-DTQSL_TEST_BUILD)
endif()

if(APPLE)
	add_definitions(-DOSX_PLATFORM="${OSX_PLATFORM}")
endif()

if(WIN32)
	set(TQSLLIB_NAME tqsllib2)
	set(srcdir ${CMAKE_CURRENT_SOURCE_DIR})
	set(TQSL_RCFILE "tqsl.rc")
	configure_file("${CMAKE_CURRENT_SOURCE_DIR}/${TQSL_RCFILE}.in" "${CMAKE_CURRENT_SOURCE_DIR}/${TQSL_RCFILE}")
else()
	set(TQSLLIB_NAME tqsllib)
endif()

if(APPLE)
	set(OSX_ICONFILE "tqslicons.icns")
	set(MACOSX_BUNDLE_INFO_STRING "tqsl")
	set(MACOSX_BUNDLE_GUI_IDENTIFIER "org.arrl.tqsl")
	set(MACOSX_BUNDLE_LONG_VERSION_STRING "TQSL V ${TQSLVERSION} build ${BUILD}")
	set(MACOSX_BUNDLE_SHORT_VERSION_STRING "${TQSLVERSION}")
	set(MACOSX_BUNDLE_COPYRIGHT "Copyright 2001-2020 American Radio Relay League")

	set(MACOSX_BUNDLE_ICON_FILE ${OSX_ICONFILE})
	SET_SOURCE_FILES_PROPERTIES(${OSX_ICONFILE} PROPERTIES MACOSX_PACKAGE_LOCATION Resources)
	set(TQSL_RCFILE ${OSX_ICONFILE})
endif()

if (NOT DEFINED TQSL_RPATH)
	SET (TQSL_RPATH FALSE)
endif ()

if(NOT WIN32) #rpath setup
	SET(CMAKE_SKIP_BUILD_RPATH ${TQSL_RPATH})
	SET(CMAKE_BUILD_WITH_INSTALL_RPATH ${TQSL_RPATH}) 
	SET(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)
	SET(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")
endif()


set(TQSL_SRC tqsl.cpp extwizard.cpp tqslwiz.cpp dxcc.cpp stationdial.cpp
qsodatadialog.cpp tqslvalidator.cpp tqsl_prefs.cpp wxutil.cpp tqslhelp.cpp
crqwiz.cpp certtree.cpp getpassword.cpp loadcertwiz.cpp loctree.cpp
jsonreader.cpp  jsonval.cpp  jsonwriter.cpp)
set(TQSL_HDR tqslapp.h tqslwiz.h qsodatadialog.h tqslexcept.h
tqslpaths.h stationdial.h dxcc.h tqsl_prefs.h extwizard.h certtree.h
tqslvalidator.h tqslbuild.h tqslhelp.h certtree.h tqslctrls.h util.h
getpassword.h extwizard.h loadcertwiz.h wxutil.h loctree.h tqsltrace.h
json_defs.h  jsonreader.h  jsonval.h  jsonwriter.h)
set(TQSL_XPM left.xpm right.xpm bottom.xpm top.xpm key.xpm cert.xpm nocert.xpm
broken-cert.xpm folder.xpm replaced.xpm expired.xpm home.xpm delete.xpm edit.xpm
loc_add_dis.xpm properties.xpm download_dis.xpm loc_add.xpm upload_dis.xpm
download.xpm file_edit_dis.xpm upload.xpm delete_dis.xpm edit_dis.xpm
file_edit.xpm properties_dis.xpm save.xpm import.xpm lotw.xpm)
add_executable(tqsl WIN32 MACOSX_BUNDLE ${TQSL_SRC} ${TQSL_HDR} ${TQSL_XPM} ${TQSL_RCFILE})

target_link_libraries(tqsl ${TQSLLIB_NAME}
  ${wxWidgets_LIBRARIES} ${ZLIB_LIBRARIES} ${CURL_LIBRARIES} ${CARBON_LIBRARY} ${EXPAT_LIBRARIES})

if(WIN32)
	set(UPDATER_SRC tqslupdater.cpp)
	add_executable(tqslupdater WIN32 ${UPDATER_SRC} ${TQSL_HDR})
	target_link_libraries(tqslupdater ${wxWidgets_LIBRARIES} ${CURL_LIBRARIES} ${OPENSSL_LIBRARIES})
endif()

if(NOT APPLE AND NOT WIN32)
	install(TARGETS tqsl DESTINATION bin)
	install(DIRECTORY help DESTINATION share/TrustedQSL)
	install(FILES tqsl.5 DESTINATION ${CMAKE_INSTALL_MANDIR}/man5)
	install(FILES icons/key48.png DESTINATION share/pixmaps RENAME TrustedQSL.png)
	install(FILES lang/de/tqslapp.mo DESTINATION share/locale/de/LC_MESSAGES)
	install(FILES lang/es/tqslapp.mo DESTINATION share/locale/es/LC_MESSAGES)
	install(FILES lang/fi/tqslapp.mo DESTINATION share/locale/fi/LC_MESSAGES)
	install(FILES lang/fr/tqslapp.mo DESTINATION share/locale/fr/LC_MESSAGES)
	install(FILES lang/hi_IN/tqslapp.mo DESTINATION share/locale/hi_IN/LC_MESSAGES)
	install(FILES lang/it/tqslapp.mo DESTINATION share/locale/it/LC_MESSAGES)
	install(FILES lang/ja/tqslapp.mo DESTINATION share/locale/ja/LC_MESSAGES)
	install(FILES lang/pt/tqslapp.mo DESTINATION share/locale/pt/LC_MESSAGES)
	install(FILES lang/zh/tqslapp.mo DESTINATION share/locale/zh/LC_MESSAGES)
	install(FILES lang/ru/tqslapp.mo DESTINATION share/locale/ru/LC_MESSAGES)
	install(FILES languages.dat DESTINATION share/TrustedQSL)
	install(FILES cab_modes.dat DESTINATION share/TrustedQSL)

endif()

cmake_minimum_required(VERSION 3.16)

project(EnglishMasteryHub VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick QuickControls2 Sql)

qt_standard_project_setup(REQUIRES 6.10)

qt_add_executable(appEnglishMasteryHub
    main.cpp
)

qt_add_qml_module(appEnglishMasteryHub
    URI EnglishMasteryHub
    VERSION 1.0
    QML_FILES
        Main.qml
        LoginView.qml
        ChangePasswordView.qml
        WelcomeView.qml
    SOURCES
        core/databasemanager.h
        core/databasemanager.cpp
        controllers/authcontroller.h
        controllers/authcontroller.cpp
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appEnglishMasteryHub PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appEnglishMasteryHub
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appEnglishMasteryHub
    PRIVATE
        Qt6::Quick
        Qt6::QuickControls2
        Qt6::Sql
)

install(TARGETS appEnglishMasteryHub
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
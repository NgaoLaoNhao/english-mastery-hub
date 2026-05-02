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
        MockAuthController.qml
        MockAdminUserController.qml
        MockAdminGroupController.qml
        MockCheckinController.qml
        MockAppSettingsController.qml
        AdminPanelView.qml
        UserManagementPage.qml
        GroupManagementPage.qml
        AvatarUploader.qml
        BannerHero.qml
        EditableCallout.qml
        CheckinSection.qml
        WantedBoardSection.qml
        CheckedInTodaySection.qml
        ChallengeProgressSection.qml
        CheckinHistorySection.qml
        MockTopController.qml
        TopBoardSection.qml
        GroupsBoardSection.qml
        MockResourceController.qml
        ResourceLibrarySection.qml
        BackendAdminToolsSection.qml
        MockPersonalController.qml
        PersonalView.qml
        PersonalStatsSection.qml
        PersonalHistorySection.qml
        MockGroupDetailController.qml
        GroupDetailView.qml
        GroupMemberRankingSection.qml
        GroupDailyChart.qml
        TopDetailView.qml
        MockGeminiController.qml
        # ===== M7 =====
        ResourceDetailView.qml
        ResourceCommentsSection.qml
        # ===== M8 =====
        MockNotificationController.qml
        NotificationToastHost.qml
        # ===== M8 E.3 + E.4 =====
        NotificationBell.qml
        NotificationCenter.qml
        controllers/MockPdfExporter.qml
        PdfPreviewDialog.qml
        PdfPreviewGroupDialog.qml
        PdfPreviewTopBoardDialog.qml
    SOURCES
        core/databasemanager.h
        core/databasemanager.cpp
        core/geminicontroller.h
        core/geminicontroller.cpp
        controllers/authcontroller.h
        controllers/authcontroller.cpp
        QML_FILES NotificationCenter.qml
        QML_FILES NotificationBell.qml
        QML_FILES controllers/MockPdfExporter.qml
        QML_FILES PdfPreviewDialog.qml
        QML_FILES PdfPreviewGroupDialog.qml
        QML_FILES PdfPreviewTopBoardDialog.qml
)

target_link_libraries(appEnglishMasteryHub
    PRIVATE
        Qt6::Quick
        Qt6::QuickControls2
        Qt6::Sql
)

include(GNUInstallDirs)
install(TARGETS appEnglishMasteryHub
    BUNDLE  DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
# ======================================================================
# QML-based executable (visioncast_ui_qml)
# ======================================================================

# ============================================================
# 🔥 OBLIGATOIRE : Activer AUTOMOC / AUTORCC / AUTOUIC
# ============================================================
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# ============================================================
# 🔥 Charger Qt6 et ses modules QML (optionnel pour CI)
# ============================================================
find_package(Qt6 QUIET COMPONENTS
    Core
    Gui
    Widgets
    Network
    Quick
    QuickControls2
)

set(_have_quick FALSE)
if(Qt6_FOUND AND TARGET Qt6::Quick AND TARGET Qt6::QuickControls2)
    set(_have_quick TRUE)
    message(STATUS "QtQuick: YES (via Qt6::Quick)")
    message(STATUS "QtQuick.Controls: YES (via Qt6::QuickControls2)")
    message(STATUS "QtQuick.Layouts: YES (in QtQuick/qml)")
else()
    message(STATUS "Qt6 Quick/QuickControls2 not found — skipping visioncast_ui_qml target")
endif()

if(_have_quick)

    # ============================================================
    # 🔥 Charger les ressources QML
    # ============================================================
    qt_add_resources(QML_RESOURCES ${CMAKE_CURRENT_SOURCE_DIR}/qml/qml.qrc)

    # ============================================================
    # 🔥 Fichiers C++ utilisés par le QML
    # ============================================================
    set(QML_HEADERS
        ${CMAKE_CURRENT_SOURCE_DIR}/include/visioncast_ui/qml_bridge.h
        ${CMAKE_CURRENT_SOURCE_DIR}/include/visioncast_ui/device_scanner.h
        ${CMAKE_CURRENT_SOURCE_DIR}/include/visioncast_ui/license_manager.h
        ${CMAKE_CURRENT_SOURCE_DIR}/include/visioncast_ui/license_dialog.h
        ${CMAKE_CURRENT_SOURCE_DIR}/include/visioncast_ui/license_config.h
        ${CMAKE_CURRENT_SOURCE_DIR}/include/visioncast_ui/license_secure_logger.h
        ${CMAKE_CURRENT_SOURCE_DIR}/include/visioncast_ui/license_storage.h
        ${CMAKE_CURRENT_SOURCE_DIR}/include/visioncast_ui/python_launcher.h
    )

    set(QML_UI_SOURCES
        src/main_qml.cpp
        src/qml_bridge.cpp
        src/device_scanner.cpp
        src/license_manager.cpp
        src/license_dialog.cpp
        src/license_config.cpp
        src/license_secure_logger.cpp
        src/license_storage.cpp
        src/python_launcher.cpp
        ${QML_RESOURCES}
    )

    # ============================================================
    # 🔥 Icône Windows
    # ============================================================
    if(WIN32)
        set(_ico_file ${CMAKE_SOURCE_DIR}/packaging/icons/visioncast.ico)
        set(_rc_file  ${CMAKE_SOURCE_DIR}/packaging/icons/visioncast.rc)
        if(EXISTS ${_ico_file} AND EXISTS ${_rc_file})
            list(APPEND QML_UI_SOURCES ${_rc_file})
        endif()
    endif()

    # ============================================================
    # 🔥 Création de l'exécutable
    # ============================================================
    add_executable(visioncast_ui_qml ${QML_UI_SOURCES} ${QML_HEADERS})

    # ============================================================
    # 🔥 Déclaration du module QML COMPLET
    # ============================================================
    qt_add_qml_module(visioncast_ui_qml
        URI VisionCast
        VERSION 1.0
        QML_FILES
            qml/Main.qml

            # Components
            qml/components/AccordionSection.qml
            qml/components/VCButton.qml
            qml/components/VCCard.qml
            qml/components/VCMetricGauge.qml
            qml/components/VCOverlayPreview.qml
            qml/components/VCSearchField.qml
            qml/components/VCSectionHeader.qml
            qml/components/VCStatusIndicator.qml
            qml/components/VCTalentCard.qml
            qml/components/VCToggleSwitch.qml
            qml/components/VCVideoThumbnail.qml

            # Panels
            qml/panels/AboutPanel.qml
            qml/panels/DesignPanel.qml
            qml/panels/EffectsPanel.qml
            qml/panels/MonitoringPanel.qml
            qml/panels/MultiStreamPanel.qml
            qml/panels/OutputPanel.qml
            qml/panels/OverlayPanel.qml
            qml/panels/PreviewView.qml
            qml/panels/ProgramView.qml
            qml/panels/RecognitionPanel.qml
            qml/panels/SettingsPanel.qml
            qml/panels/SourcePanel.qml
            qml/panels/TalentPanel.qml

            # Theme
            qml/theme/VCColors.qml
            qml/theme/VCTheme.qml
    )

    # ============================================================
    # 🔥 Includes
    # ============================================================
    target_include_directories(visioncast_ui_qml
        PRIVATE
            ${CMAKE_CURRENT_SOURCE_DIR}/include
            ${CMAKE_CURRENT_SOURCE_DIR}/include/visioncast_ui
            ${CMAKE_SOURCE_DIR}/sdk/include
            ${CMAKE_SOURCE_DIR}/engine/include
    )

    # ============================================================
    # 🔥 Link Qt + VisionCast Engine
    # ============================================================
    target_link_libraries(visioncast_ui_qml PRIVATE
        Qt6::Widgets Qt6::Core Qt6::Gui Qt6::Network Qt6::Quick Qt6::QuickControls2
        visioncast_engine_lib
        visioncast_sdk
    )

    # ============================================================
    # 🔥 Variables de licence
    # ============================================================
    if(DEFINED VISIONCAST_LICENSE_API_URL)
        target_compile_definitions(visioncast_ui_qml PRIVATE
            VISIONCAST_LICENSE_API_URL="${VISIONCAST_LICENSE_API_URL}")
    endif()
    if(DEFINED VISIONCAST_LICENSE_API_KEY)
        target_compile_definitions(visioncast_ui_qml PRIVATE
            VISIONCAST_LICENSE_API_KEY="${VISIONCAST_LICENSE_API_KEY}")
    endif()

    # ============================================================
    # 🔥 Installation
    # ============================================================
    if(APPLE)
        install(TARGETS visioncast_ui_qml BUNDLE DESTINATION .)
    else()
        install(TARGETS visioncast_ui_qml RUNTIME DESTINATION bin)
    endif()

    message(STATUS "VisionCast QML UI target enabled (visioncast_ui_qml)")

else()
    message(STATUS "Qt Quick / QuickControls2 not found — skipping visioncast_ui_qml target")
endif()

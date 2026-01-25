# Translations
file(GLOB PO_FILES *.po)

foreach(PO_FILE ${PO_FILES})
    get_filename_component(LANG ${PO_FILE} NAME_WE)
    set(MO_FILE ${CMAKE_CURRENT_BINARY_DIR}/${LANG}.mo)
    
    add_custom_command(
        OUTPUT ${MO_FILE}
        COMMAND msgfmt -o ${MO_FILE} ${PO_FILE}
        DEPENDS ${PO_FILE}
        COMMENT "Generating ${LANG}.mo"
    )
    
    list(APPEND MO_FILES ${MO_FILE})
    
    install(FILES ${MO_FILE}
        DESTINATION share/locale/${LANG}/LC_MESSAGES
        RENAME ${FULL_PROJECT_NAME}.mo
    )
endforeach()

add_custom_target(translations ALL DEPENDS ${MO_FILES})

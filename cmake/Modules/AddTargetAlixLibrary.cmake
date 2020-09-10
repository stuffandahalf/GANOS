function(ADD_TARGET_ALIX_LIBRARY TARGET LIBRARY)
	if(TARGET ${TARGET})
		target_link_libraries(${TARGET} ${LIBRARY})
	else()
		message(NOTICE "Target \"${LIBRARY}\" not defined, attempting to link regularly"
		target_link_libraries(${TARGET} "-l${LIBRARY}")
	endif()
endfunction()

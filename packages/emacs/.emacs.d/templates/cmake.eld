cmake-mode

(ament_package_skeleton
 "cmake_minimum_required(VERSION 3.8)" n
 "project(" (p "my_package" pkg) ")" n n
 "if(NOT CMAKE_CXX_STANDARD)" n> "set(CMAKE_CXX_STANDARD 17)" n>
 "set(CMAKE_CXX_STANDARD_REQUIRED ON)" n "endif()" n n
 "if(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES \"Clang\")" n>
 "add_compile_options(-Wall -Wextra -Wpedantic)" n "endif()" n n
 "find_package(ament_cmake REQUIRED)" n
 "find_package(rclcpp REQUIRED)" n
 "find_package(" (p "std_msgs") " REQUIRED)" n n
 "add_executable(" (p "my_node" target) " src/" (s target) ".cpp)" n
 "target_include_directories(" (s target) " PUBLIC" n>
 "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>" n>
 "$<INSTALL_INTERFACE:include>)" n
 "ament_target_dependencies(" (s target) " rclcpp " (p "std_msgs") ")" n n
 "install(TARGETS " (s target) n> "DESTINATION lib/${PROJECT_NAME})" n n
 "if(BUILD_TESTING)" n> "find_package(ament_lint_auto REQUIRED)" n>
 "ament_lint_auto_find_test_dependencies()" n "endif()" n n
 "ament_package()" q)
(ament_dependencies "find_package(ament_cmake REQUIRED)" n
                    "find_package(rclcpp REQUIRED)" n
                    "find_package(" q " REQUIRED)")
(ament_executable "add_executable(" (p "my_node" target) " src/" (s target) ".cpp)" n
                  "ament_target_dependencies(" (s target) " " (p "rclcpp") ")" n
                  "install(TARGETS " (s target) n>
                  "DESTINATION lib/${PROJECT_NAME})" q)
(ament_library
 "add_library(" (p "my_library" target) " SHARED src/" (s target) ".cpp)" n
 "target_include_directories(" (s target) " PUBLIC" n>
 "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>" n>
 "$<INSTALL_INTERFACE:include>)" n
 "ament_target_dependencies(" (s target) " " (p "rclcpp") ")" n n
 "install(DIRECTORY include/ DESTINATION include)" n
 "install(TARGETS " (s target) n> "EXPORT export_${PROJECT_NAME}" n>
 "ARCHIVE DESTINATION lib" n> "LIBRARY DESTINATION lib" n>
 "RUNTIME DESTINATION bin)" n n
 "ament_export_targets(export_${PROJECT_NAME} HAS_LIBRARY_TARGET)" n
 "ament_export_dependencies(" (p "rclcpp") ")" q)
(ament_component
 "find_package(rclcpp_components REQUIRED)" n n
 "add_library(" (p "my_component" target) " SHARED src/" (s target) ".cpp)" n
 "ament_target_dependencies(" (s target) " rclcpp rclcpp_components "
 (p "std_msgs") ")" n
 "rclcpp_components_register_node(" (s target) n>
 "PLUGIN \"" (p "my_package") "::" (p "MyNode") "\"" n>
 "EXECUTABLE " (p "my_node") ")" n n
 "install(TARGETS " (s target) n> "LIBRARY DESTINATION lib)" q)
(ament_gtest "if(BUILD_TESTING)" n>
             "find_package(ament_cmake_gtest REQUIRED)" n>
             "ament_add_gtest(" (p "test_my_node" target)
             " test/" (s target) ".cpp)" n>
             "ament_target_dependencies(" (s target) " rclcpp " (p "std_msgs") ")" n>
             "target_link_libraries(" (s target) " " (p "my_library") ")" n
             "endif()" q)
(ament_lint "if(BUILD_TESTING)" n>
            "find_package(ament_lint_auto REQUIRED)" n>
            "ament_lint_auto_find_test_dependencies()" n "endif()" q)
(rosidl_interfaces "find_package(rosidl_default_generators REQUIRED)" n
                   "find_package(builtin_interfaces REQUIRED)" n n
                   "rosidl_generate_interfaces(${PROJECT_NAME}" n>
                   "\"msg/" (p "MyMessage") ".msg\"" n>
                   "\"srv/" (p "MyService") ".srv\"" n>
                   "DEPENDENCIES builtin_interfaces " (p "std_msgs") ")" n n
                   "ament_export_dependencies(rosidl_default_runtime)" q)
(rosidl_link_typesupport "rosidl_get_typesupport_target(cpp_typesupport_target"
                         " ${PROJECT_NAME} rosidl_typesupport_cpp)" n
                         "target_link_libraries(" (p "my_node")
                         " \"${cpp_typesupport_target}\")" q)
(install_directory "install(DIRECTORY " (p "launch config")
                   n> "DESTINATION share/${PROJECT_NAME})" q)
(install_python "find_package(ament_cmake_python REQUIRED)" n
                "find_package(rclpy REQUIRED)" n n
                "ament_python_install_package(${PROJECT_NAME})" n n
                "install(PROGRAMS" n> "scripts/" (p "my_script") ".py" n>
                "DESTINATION lib/${PROJECT_NAME})" q)
(cxx_standard "if(NOT CMAKE_CXX_STANDARD)" n> "set(CMAKE_CXX_STANDARD 17)" n>
              "set(CMAKE_CXX_STANDARD_REQUIRED ON)" n "endif()" n
              "add_compile_options(-Wall -Wextra -Wpedantic)" q)
(pluginlib_export "find_package(pluginlib REQUIRED)" n
                  "pluginlib_export_plugin_description_file("
                  (p "nav2_core") " " (p "plugins") ".xml)" q)

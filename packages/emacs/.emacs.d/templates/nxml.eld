nxml-mode

(package_manifest
 "<?xml version=\"1.0\"?>" n
 "<?xml-model href=\"http://download.ros.org/schema/package_format3.xsd\""
 " schematypens=\"http://www.w3.org/2001/XMLSchema\"?>" n
 "<package format=\"3\">" n>
 "<name>" (p "my_package") "</name>" n>
 "<version>0.0.1</version>" n>
 "<description>" (p "What this package does") "</description>" n>
 "<maintainer email=\"" (p user-mail-address) "\">"
 (p user-full-name) "</maintainer>" n>
 "<license>" (p "Apache-2.0") "</license>" n n>
 "<buildtool_depend>ament_cmake</buildtool_depend>" n n>
 "<depend>rclcpp</depend>" n>
 "<depend>" q "</depend>" n n>
 "<test_depend>ament_lint_auto</test_depend>" n>
 "<test_depend>ament_lint_common</test_depend>" n>
 "<test_depend>ament_cmake_gtest</test_depend>" n n>
 "<export>" n> "<build_type>ament_cmake</build_type>" n "</export>" > n
 "</package>")
(depend "<depend>" q "</depend>")
(build_depend "<build_depend>" q "</build_depend>")
(exec_depend "<exec_depend>" q "</exec_depend>")
(test_depend "<test_depend>" q "</test_depend>")
(buildtool_depend "<buildtool_depend>" (p "ament_cmake") "</buildtool_depend>" q)
(export_build_type "<export>" n> "<build_type>" (p "ament_cmake")
                   "</build_type>" n "</export>" > q)
(export_plugin "<export>" n> "<" (p "nav2_core") " plugin=\"${prefix}/"
               (p "plugins") ".xml\" />" n "</export>" > q)
(plugin_description
 "<library path=\"" (p "my_library" lib) "\">" n>
 "<class name=\"" (p "my_package") "/" (p "MyPlugin" cls) "\"" n>
 "type=\"" (p "my_package") "::" (s cls) "\"" n>
 "base_class_type=\"" (p "nav2_core::Controller") "\">" n>
 "<description>" (p "What this plugin does") "</description>" n
 "</class>" > n "</library>" > q)
(launch_xml
 "<launch>" n>
 "<arg name=\"" (p "use_sim_time") "\" default=\"" (p "false") "\" />" n n>
 "<node pkg=\"" (p "my_package") "\" exec=\"" (p "my_node") "\""
 " name=\"" (p "my_node") "\" output=\"screen\">" n>
 "<param name=\"" (p "parameter_name") "\" value=\"" (p "value") "\" />" n>
 "<remap from=\"" (p "from_topic") "\" to=\"" (p "to_topic") "\" />" n
 "</node>" > q n "</launch>" >)
(launch_xml_include "<include file=\"$(find-pkg-share " (p "my_package")
                    ")/launch/" (p "other") ".launch.py\">" n>
                    "<arg name=\"" (p "argument") "\" value=\"" (p "value") "\" />" n
                    "</include>" > q)

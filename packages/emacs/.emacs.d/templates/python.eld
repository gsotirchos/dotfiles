python-base-mode

(ros_node
 "class " (p "MyNode" cls) "(Node):" n> "def __init__(self) -> None:" n>
 "super().__init__(\"" (p "my_node") "\")" n> q n n
 "def main(args=None) -> None:" n> "rclpy.init(args=args)" n>
 "node = " (s cls) "()" n> "try:" n> "rclpy.spin(node)" n>
 "except KeyboardInterrupt:" n> "pass" n> "finally:" n>
 "node.destroy_node()" n> "rclpy.shutdown()")
(ros_spin_main "def main(args=None) -> None:" n> "rclpy.init(args=args)" n>
               "node = " (p "MyNode") "()" n> "try:" n> "rclpy.spin(node)" n>
               "except KeyboardInterrupt:" n> "pass" n> "finally:" n>
               "node.destroy_node()" n> "rclpy.shutdown()" n n
               "if __name__ == \"__main__\":" n> "main()" q)
(ros_publisher "self." (p "publisher" var) " = self.create_publisher("
               (p "String" type) ", \"" (p "topic") "\", " (p "10") ")" q)
(ros_subscription "self." (p "subscription" var) " = self.create_subscription(" n>
                  (p "String" type) ", \"" (p "topic") "\", self."
                  (p "on_message" cb) ", " (p "10") ")" n n
                  "def " (s cb) "(self, message: " (s type) ") -> None:" n> q)
(ros_timer "self." (p "timer") " = self.create_timer(" (p "0.1") ", self."
           (p "on_timer" cb) ")" n n
           "def " (s cb) "(self) -> None:" n> q)
(ros_parameter "self.declare_parameter(\"" (p "parameter_name" name) "\", "
               (p "0.0") ")" n> "self." (s name)
               " = self.get_parameter(\"" (s name) "\").value" q)
(ros_logger "self.get_logger()." (p "info") "(f\"" q "\")")
(ros_service_server "self." (p "service") " = self.create_service(" n>
                    (p "Trigger" type) ", \"" (p "service_name") "\", self."
                    (p "on_request" cb) ")" n n
                    "def " (s cb) "(self, request: " (s type)
                    ".Request, response: " (s type) ".Response) -> " (s type)
                    ".Response:" n> q n> "return response")

python-base-mode
:when (string-match-p "launch" (or (buffer-file-name) ""))

(launch_description
 "from launch import LaunchDescription" n
 "from launch_ros.actions import Node" n n n
 "def generate_launch_description() -> LaunchDescription:" n>
 "return LaunchDescription([" n> q n> "])")
(launch_node "Node(" n> "package=\"" (p "my_package") "\"," n>
             "executable=\"" (p "my_node" exec) "\"," n>
             "name=\"" (s exec) "\"," n> "output=\"screen\"," n>
             "parameters=[{\"" (p "parameter_name") "\": " (p "value") "}]," n>
             "remappings=[(\"" (p "from_topic") "\", \"" (p "to_topic") "\")]," n
             ")," > q)
(launch_argument "DeclareLaunchArgument(" n> "\"" (p "argument" name) "\"," n>
                 "default_value=\"" (p "value") "\"," n>
                 "description=\"" (p "What this argument controls") "\"," n
                 ")," > n "LaunchConfiguration(\"" (s name) "\")" q)
(launch_include
 "IncludeLaunchDescription(" n>
 "PythonLaunchDescriptionSource([" n>
 "PathJoinSubstitution([FindPackageShare(\"" (p "my_package") "\"),"
 " \"launch\", \"" (p "other") ".launch.py\"])" n> "])," n>
 "launch_arguments={\"" (p "argument") "\": " (p "value") "}.items()," n
 ")," > q)
(launch_group "GroupAction([" n> "PushRosNamespace(\"" (p "namespace") "\")," n>
              q n "])," >)
(launch_composable
 "ComposableNodeContainer(" n> "name=\"" (p "my_container") "\"," n>
 "namespace=\"\"," n> "package=\"rclcpp_components\"," n>
 "executable=\"component_container_mt\"," n> "composable_node_descriptions=[" n>
 "ComposableNode(" n> "package=\"" (p "my_package") "\"," n>
 "plugin=\"" (p "my_package") "::" (p "MyNode") "\"," n>
 "name=\"" (p "my_node") "\"," n> ")," n "]," > n ")," > q)
(launch_execute "ExecuteProcess(" n> "cmd=[" (p "\"ros2\", \"topic\", \"list\"") "],"
                n> "output=\"screen\"," n ")," > q)

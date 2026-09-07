;; `c++-ts-mode' is registered as a child of `c++-mode' via
;; `derived-mode-add-parents', so naming both here would list every
;; template twice in the completion UI.
c++-mode

;;; Node structure

(node_class "class " (p "MyNode" cls) " : public rclcpp::Node" n
            "{" n "public:" n>
            (s cls) "()" n> ": Node(\"" (p "my_node") "\")" n> "{" n>
            q n> "}" n n "private:" n> p n "};")
(node_main "int main(int argc, char ** argv)" n "{" n>
           "rclcpp::init(argc, argv);" n>
           "rclcpp::spin(std::make_shared<" (p "MyNode") ">());" n>
           "rclcpp::shutdown();" n>
           "return 0;" n "}")
(node_main_executor "int main(int argc, char ** argv)" n "{" n>
                    "rclcpp::init(argc, argv);" n>
                    "rclcpp::executors::MultiThreadedExecutor executor;" n>
                    "auto node = std::make_shared<" (p "MyNode") ">();" n>
                    "executor.add_node(node);" n>
                    "executor.spin();" n>
                    "rclcpp::shutdown();" n>
                    "return 0;" n "}")
(node_options (p "MyNode" cls) "(const rclcpp::NodeOptions & options)" n>
              ": Node(\"" (p "my_node") "\", options)" n> "{" n> q n> "}")
(component_register "#include \"rclcpp_components/register_node_macro.hpp\"" n n
                    "RCLCPP_COMPONENTS_REGISTER_NODE("
                    (p "my_package") "::" (p "MyNode") ")")
(lifecycle_node
 "class " (p "MyNode" cls)
 " : public rclcpp_lifecycle::LifecycleNode" n "{" n "public:" n>
 "using CallbackReturn = rclcpp_lifecycle::node_interfaces::"
 "LifecycleNodeInterface::CallbackReturn;" n>
 "explicit " (s cls) "(const rclcpp::NodeOptions & options)" n>
 ": LifecycleNode(\"" (p "my_node") "\", options) {}" n n>
 "CallbackReturn on_configure(const rclcpp_lifecycle::State &) override" n> "{" n>
 q n> "return CallbackReturn::SUCCESS;" n> "}" n n>
 "CallbackReturn on_activate(const rclcpp_lifecycle::State & state) override" n> "{" n>
 "LifecycleNode::on_activate(state);" n> "return CallbackReturn::SUCCESS;" n> "}" n n>
 "CallbackReturn on_deactivate(const rclcpp_lifecycle::State & state) override" n> "{" n>
 "LifecycleNode::on_deactivate(state);" n> "return CallbackReturn::SUCCESS;" n> "}" n n>
 "CallbackReturn on_cleanup(const rclcpp_lifecycle::State &) override" n> "{" n>
 "return CallbackReturn::SUCCESS;" n> "}" n n>
 "CallbackReturn on_shutdown(const rclcpp_lifecycle::State &) override" n> "{" n>
 "return CallbackReturn::SUCCESS;" n> "}" n "};")

;;; Communication

(publisher (p "publisher" var) "_ = create_publisher<"
           (p "std_msgs::msg::String" type) ">(\""
           (p "topic") "\", " (p "10") ");" q)
(publisher_member "rclcpp::Publisher<" (p "std_msgs::msg::String")
                  ">::SharedPtr " (p "publisher") "_;")
(publish "auto message = " (p "std_msgs::msg::String") "();" n>
         q n> (p "publisher") "_->publish(message);")
(subscription (p "subscription" var) "_ = create_subscription<"
              (p "std_msgs::msg::String" type) ">(" n>
              "\"" (p "topic") "\", " (p "10") "," n>
              "[this](const " (s type) "::SharedPtr msg) { "
              (p "on_message" cb) "(msg); });" n n
              "void " (s cb) "(const " (s type) "::SharedPtr msg)" n "{" n>
              q n "}")
(subscription_member "rclcpp::Subscription<" (p "std_msgs::msg::String")
                     ">::SharedPtr " (p "subscription") "_;")
(wall_timer (p "timer" var) "_ = create_wall_timer(" n>
            (p "100ms") ", [this]() { " (p "on_timer" cb) "(); });" n n
            "void " (s cb) "()" n "{" n> q n "}")
(timer_member "rclcpp::TimerBase::SharedPtr " (p "timer") "_;")
(service_server (p "service" var) "_ = create_service<"
                (p "std_srvs::srv::Trigger" type) ">(" n>
                "\"" (p "service_name") "\"," n>
                "std::bind(&" (p "MyNode") "::" (p "on_request" cb)
                ", this, std::placeholders::_1, std::placeholders::_2));" n n
                "void " (s cb) "(" n>
                "const " (s type) "::Request::SharedPtr request," n>
                (s type) "::Response::SharedPtr response)" n "{" n>
                q n "}")
(service_client "auto client = create_client<" (p "std_srvs::srv::Trigger" type)
                ">(\"" (p "service_name") "\");" n>
                "if (!client->wait_for_service(std::chrono::seconds(1))) {" n>
                "RCLCPP_ERROR(get_logger(), \"Service unavailable\");" n>
                "return;" n> "}" n>
                "auto request = std::make_shared<" (s type) "::Request>();" n>
                q n> "auto future = client->async_send_request(request);")
(action_server
 (p "action" var) "_ = rclcpp_action::create_server<"
 (p "my_package::action::MyAction" type) ">(" n>
 "this, \"" (p "action_name") "\"," n>
 "std::bind(&" (p "MyNode" cls) "::handle_goal, this,"
 " std::placeholders::_1, std::placeholders::_2)," n>
 "std::bind(&" (s cls) "::handle_cancel, this, std::placeholders::_1)," n>
 "std::bind(&" (s cls) "::handle_accepted, this, std::placeholders::_1));" n n
 "rclcpp_action::GoalResponse handle_goal(" n>
 "const rclcpp_action::GoalUUID &, std::shared_ptr<const " (s type) "::Goal> goal)" n
 "{" n> q n> "return rclcpp_action::GoalResponse::ACCEPT_AND_EXECUTE;" n "}" n n
 "rclcpp_action::CancelResponse handle_cancel(" n>
 "const std::shared_ptr<rclcpp_action::ServerGoalHandle<" (s type) ">>)" n
 "{" n> "return rclcpp_action::CancelResponse::ACCEPT;" n "}" n n
 "void handle_accepted(" n>
 "const std::shared_ptr<rclcpp_action::ServerGoalHandle<" (s type) ">> goal_handle)" n
 "{" n> "std::thread{[this, goal_handle]() { execute(goal_handle); }}.detach();" n "}")
(action_client
 "auto client = rclcpp_action::create_client<"
 (p "my_package::action::MyAction" type) ">(this, \"" (p "action_name") "\");" n>
 "if (!client->wait_for_action_server(std::chrono::seconds(1))) {" n>
 "RCLCPP_ERROR(get_logger(), \"Action server unavailable\");" n> "return;" n> "}" n>
 "auto goal = " (s type) "::Goal();" n> q n>
 "auto options = rclcpp_action::Client<" (s type) ">::SendGoalOptions();" n>
 "options.result_callback = [this](const auto & result) { (void)result; };" n>
 "client->async_send_goal(goal, options);")
(callback_group "auto group = create_callback_group("
                "rclcpp::CallbackGroupType::" (p "MutuallyExclusive") ");" n>
                "rclcpp::SubscriptionOptions options;" n>
                "options.callback_group = group;" q)
(qos_profile "const auto qos = rclcpp::QoS(rclcpp::KeepLast(" (p "10") "))" n>
             "." (p "reliable") "()" n> ".transient_local();" q)
(message_include "#include \"" (p "std_msgs") "/msg/" (p "string") ".hpp\"")

;;; Parameters

(parameter (p "parameter_name" name) "_ = declare_parameter<"
           (p "double" type) ">(\"" (s name) "\", " (p "0.0") ");" q)
(parameter_member (p "double") " " (p "parameter_name") "_{};")
(parameter_descriptor
 "rcl_interfaces::msg::ParameterDescriptor descriptor;" n>
 "descriptor.description = \"" (p "What this parameter controls") "\";" n>
 "rcl_interfaces::msg::FloatingPointRange range;" n>
 "range.from_value = " (p "0.0") ";" n> "range.to_value = " (p "1.0") ";" n>
 "descriptor.floating_point_range.push_back(range);" n>
 (p "parameter_name" name) "_ = declare_parameter<double>(\"" (s name)
 "\", " (p "0.5") ", descriptor);" q)
(parameter_callback
 "parameter_callback_handle_ = add_on_set_parameters_callback(" n>
 "[this](const std::vector<rclcpp::Parameter> & parameters) {" n>
 "rcl_interfaces::msg::SetParametersResult result;" n>
 "result.successful = true;" n>
 "for (const auto & parameter : parameters) {" n> q n> "}" n>
 "return result;" n> "});")
(parameter_callback_member
 "rclcpp::node_interfaces::OnSetParametersCallbackHandle::SharedPtr"
 " parameter_callback_handle_;")

;;; Logging

(log_info "RCLCPP_INFO(get_logger(), \"" p "\"" q ");")
(log_warn "RCLCPP_WARN(get_logger(), \"" p "\"" q ");")
(log_error "RCLCPP_ERROR(get_logger(), \"" p "\"" q ");")
(log_debug "RCLCPP_DEBUG(get_logger(), \"" p "\"" q ");")
(log_stream "RCLCPP_INFO_STREAM(get_logger(), " q ");")
(log_throttle "RCLCPP_" (p "WARN") "_THROTTLE(get_logger(), *get_clock(), "
              (p "1000") ", \"" p "\"" q ");")
(log_once "RCLCPP_INFO_ONCE(get_logger(), \"" p "\"" q ");")
(format "fmt::format(\"" p "\"" q ")")
(format_print "fmt::print(\"" p "\\n\"" q ");")
(spdlog_logger "auto logger = spdlog::stdout_color_mt(\"" (p "name") "\");" n>
               "logger->set_level(spdlog::level::" (p "info") ");" q)

;;; TF2

(tf_buffer "tf_buffer_ = std::make_unique<tf2_ros::Buffer>(get_clock());" n>
           "tf_listener_ = std::make_shared<tf2_ros::TransformListener>(*tf_buffer_);" q)
(tf_buffer_member "std::unique_ptr<tf2_ros::Buffer> tf_buffer_;" n>
                  "std::shared_ptr<tf2_ros::TransformListener> tf_listener_;")
(tf_lookup "try {" n>
           "const auto transform = tf_buffer_->lookupTransform(" n>
           "\"" (p "target_frame") "\", \"" (p "source_frame") "\", tf2::TimePointZero);" n>
           q n "} catch (const tf2::TransformException & exception) {" >  n>
           "RCLCPP_WARN(get_logger(), \"Transform lookup failed: %s\", exception.what());" n>
           "return;" n "}" >)
(tf_broadcaster "tf_broadcaster_ = std::make_unique<tf2_ros::TransformBroadcaster>(*this);"
                n n "geometry_msgs::msg::TransformStamped transform;" n>
                "transform.header.stamp = now();" n>
                "transform.header.frame_id = \"" (p "parent_frame") "\";" n>
                "transform.child_frame_id = \"" (p "child_frame") "\";" n> q n>
                "tf_broadcaster_->sendTransform(transform);")
(tf_static_broadcaster
 "tf_static_broadcaster_ ="
 " std::make_unique<tf2_ros::StaticTransformBroadcaster>(*this);" n>
 "tf_static_broadcaster_->sendTransform(" q ");")
(tf_do_transform (p "geometry_msgs::msg::PoseStamped") " " (p "output" out) ";" n>
                 "tf2::doTransform(" (p "input") ", " (s out) ", transform);" q)
(tf_quaternion "tf2::Quaternion quaternion;" n>
               "quaternion.setRPY(" (p "roll") ", " (p "pitch") ", " (p "yaw") ");" n>
               (p "message") ".orientation = tf2::toMsg(quaternion);" q)
(tf_yaw_from_quaternion "tf2::Quaternion quaternion;" n>
                        "tf2::fromMsg(" (p "message") ".orientation, quaternion);" n>
                        "const double yaw = tf2::getYaw(quaternion);" q)

;;; Eigen

(eigen_matrix "Eigen::Matrix" (p "3d" type) " " (p "matrix")
              " = Eigen::Matrix" (s type) "::" (p "Identity") "();" q)
(eigen_vector "Eigen::Vector" (p "3d" type) " " (p "vector")
              "(" (p "0.0, 0.0, 0.0") ");" q)
(eigen_isometry "Eigen::Isometry3d " (p "pose" name)
                " = Eigen::Isometry3d::Identity();" n>
                (s name) ".translation() = Eigen::Vector3d("
                (p "0.0, 0.0, 0.0") ");" n>
                (s name) ".linear() = Eigen::Quaterniond("
                (p "1.0, 0.0, 0.0, 0.0") ").toRotationMatrix();" q)
(eigen_to_msg "const auto message = tf2::toMsg(" (p "transform") ");" q)
(eigen_from_msg "Eigen::Isometry3d " (p "transform" tf) ";" n>
                "tf2::fromMsg(" (p "message") ", " (s tf) ");" q)

;;; Time

(ros_time "const rclcpp::Time " (p "stamp") " = now();" q)
(ros_duration "const auto " (p "timeout")
              " = rclcpp::Duration::from_seconds(" (p "1.0") ");" q)
(ros_rate "rclcpp::WallRate rate(" (p "10.0") ");" n>
          "while (rclcpp::ok()) {" n> q n> "rate.sleep();" n> "}")
(chrono_literals "using namespace std::chrono_literals;" q)

;;; Modern C++

(header_skeleton "#pragma once" n n "namespace " (p "my_package" ns) n "{" n n
                 "class " (p "MyClass" cls) n "{" n "public:" n>
                 q n n "private:" n> p n "};" n n "}  // namespace " (s ns))
(make_shared "auto " (p "value") " = std::make_shared<" (p "Type") ">(" q ");")
(make_unique "auto " (p "value") " = std::make_unique<" (p "Type") ">(" q ");")
(unique_ptr_member "std::unique_ptr<" (p "Type") "> " (p "member") "_;")
(shared_ptr_member "std::shared_ptr<" (p "Type") "> " (p "member") "_;")
(optional_return "std::optional<" (p "Type" type) "> " (p "function") "(" p ")" n "{" n>
                 "if (" (p "condition") ") {" n> "return std::nullopt;" n> "}" n>
                 "return " q ";" n "}")
(optional_check "if (const auto " (p "value" name) " = " (p "expression") ";"
                " " (s name) ".has_value()) {" n> q n "}" >)
(structured_binding "const auto & [" (p "key") ", " (p "value") "] = " (p "pair") ";" q)
(range_for "for (const auto & " (p "item") " : " (p "container") ") {" n> q n "}" >)
(lambda "[" (p "&") "](" p ") { " q " }")
(enum_class "enum class " (p "Name") " : " (p "std::uint8_t") n "{" n>
            q n "};")
(struct_pod "struct " (p "Name") n "{" n> q n "};")
(template_function "template <typename " (p "T") ">" n
                   (p "void") " " (p "function") "(" p ")" n "{" n> q n "}")
(constexpr_function "constexpr " (p "double") " " (p "function")
                    "(" p ") noexcept" n "{" n> q n "}")
(scoped_lock "const std::lock_guard<std::mutex> lock(" (p "mutex") "_);" q)
(mutex_member "mutable std::mutex " (p "mutex") "_;")
(atomic_member "std::atomic<" (p "bool") "> " (p "flag") "_{" (p "false") "};")
(thread_worker "std::thread " (p "worker") "_{[this]() {" n>
               "while (running_) {" n> q n> "}" n "}};" >)
(try_catch "try {" n> r> n "} catch (const " (p "std::exception") " & exception) {" > n>
           q n "}" >)
(find_if "const auto it = std::find_if(" (p "container" c) ".begin(), " (s c)
         ".end()," n> "[&](const auto & item) { return " q "; });" n>
         "if (it != " (s c) ".end()) {" n> p n> "}")
(transform "std::transform(" (p "input" in) ".begin(), " (s in) ".end(),"
           " std::back_inserter(" (p "output") ")," n>
           "[](const auto & item) { return " q "; });")
(accumulate "const auto total = std::accumulate(" (p "container" c) ".begin(), "
            (s c) ".end(), " (p "0.0") ");" q)
(chrono_measure "const auto start = std::chrono::steady_clock::now();" n> r> n>
                "const auto elapsed = std::chrono::duration<double>("
                "std::chrono::steady_clock::now() - start).count();" q)
(string_view_param (p "void") " " (p "function") "(std::string_view "
                   (p "name") ")" n "{" n> q n "}")
(unordered_map "std::unordered_map<" (p "std::string") ", " (p "Type") "> "
               (p "map") ";" q)
(vector_reserve "std::vector<" (p "Type") "> " (p "values" name) ";" n>
                (s name) ".reserve(" (p "capacity") ");" q)
(clamp "std::clamp(" (p "value") ", " (p "low") ", " (p "high") ")" q)

;;; Tests

(test_case "TEST(" (p "SuiteName") ", " (p "TestName") ")" n "{" n> q n "}")
(test_fixture "class " (p "MyClass" cls) "Test : public ::testing::Test" n "{" n
              "protected:" n> "void SetUp() override" n> "{" n> q n> "}" n n>
              "void TearDown() override" n> "{" n> "}" n "};" >)
(test_ros_fixture
 "class " (p "MyNode" cls) "Test : public ::testing::Test" n "{" n "protected:" n>
 "static void SetUpTestSuite() { rclcpp::init(0, nullptr); }" n>
 "static void TearDownTestSuite() { rclcpp::shutdown(); }" n n>
 "void SetUp() override { node_ = std::make_shared<" (s cls) ">(); }" n n>
 "std::shared_ptr<" (s cls) "> node_;" n "};" > n n
 "TEST_F(" (s cls) "Test, " (p "TestName") ")" n "{" n> q n "}")
(test_main "int main(int argc, char ** argv)" n "{" n>
           "::testing::InitGoogleTest(&argc, argv);" n>
           "rclcpp::init(argc, argv);" n>
           "const int result = RUN_ALL_TESTS();" n>
           "rclcpp::shutdown();" n> "return result;" n "}")
(test_parameterized
 "class " (p "MyClass" cls) "Test : public ::testing::TestWithParam<"
 (p "double" type) ">" n "{" n "};" n n
 "TEST_P(" (s cls) "Test, " (p "TestName") ")" n "{" n>
 "const auto parameter = GetParam();" n> q n "}" n n
 "INSTANTIATE_TEST_SUITE_P(" (p "Values") ", " (s cls) "Test,"
 " ::testing::Values(" p "));")
(mock_class "class Mock" (p "Interface" base) " : public " (s base) n "{" n
            "public:" n> "MOCK_METHOD(" (p "void") ", " (p "method")
            ", (" p "), (override));" n> q n "};" >)
(expect_near "EXPECT_NEAR(" (p "actual") ", " (p "expected") ", " (p "1e-6") ");" q)
(expect_throw "EXPECT_THROW(" (p "statement") ", " (p "std::runtime_error") ");" q)

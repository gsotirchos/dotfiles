;;; C++ language and standard-library templates.
;; `c++-ts-mode' is registered as a child of `c++-mode' via
;; `derived-mode-add-parents', so naming both here would list every
;; template twice in the completion UI.
c++-mode

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
;;; Control flow

(main_function "int main(int argc, char ** argv)" n "{" n> q n> "return 0;" n "}")
(main_try "int main(int argc, char ** argv)" n "{" n> "try {" n> q n>
          "} catch (const std::exception & exception) {" n>
          "std::cerr << exception.what() << '\\n';" n> "return 1;" n> "}" n>
          "return 0;" n "}")
(for_index "for (std::size_t " (p "i" idx) " = 0; " (s idx) " < "
           (p "count") "; ++" (s idx) ") {" n> q n "}" >)
(for_iterator "for (auto it = " (p "container" c) ".begin(); it != "
              (s c) ".end(); ++it) {" n> q n "}" >)
(while_loop "while (" (p "condition") ") {" n> q n "}" >)
(do_while "do {" n> q n "} while (" (p "condition") ");" >)
(switch_case "switch (" (p "value") ") {" n "case " (p "kValue") ":" n> q n>
             "break;" n "default:" n> "break;" n "}" >)
(if_else "if (" (p "condition") ") {" n> q n "} else {" > n> p n "}" >)
(if_constexpr "if constexpr (" (p "std::is_same_v<T, double>") ") {" n> q n "}" >)

;;; Algorithms and containers

(sort "std::sort(" (p "container" c) ".begin(), " (s c) ".end());" q)
(sort_by "std::sort(" (p "container" c) ".begin(), " (s c) ".end()," n>
         "[](const auto & lhs, const auto & rhs) { return " q "; });")
(stable_sort "std::stable_sort(" (p "container" c) ".begin(), " (s c) ".end()," n>
             "[](const auto & lhs, const auto & rhs) { return " q "; });")
(min_element "const auto it = std::min_element(" (p "container" c) ".begin(), "
             (s c) ".end());" q)
(max_element "const auto it = std::max_element(" (p "container" c) ".begin(), "
             (s c) ".end());" q)
(count_if "const auto count = std::count_if(" (p "container" c) ".begin(), "
          (s c) ".end()," n> "[](const auto & item) { return " q "; });")
(all_of "std::all_of(" (p "container" c) ".begin(), " (s c) ".end()," n>
        "[](const auto & item) { return " q "; })")
(any_of "std::any_of(" (p "container" c) ".begin(), " (s c) ".end()," n>
        "[](const auto & item) { return " q "; })")
(none_of "std::none_of(" (p "container" c) ".begin(), " (s c) ".end()," n>
         "[](const auto & item) { return " q "; })")
(erase_remove (p "container" c) ".erase(" n>
              "std::remove_if(" (s c) ".begin(), " (s c) ".end()," n>
              "[](const auto & item) { return " q "; })," n> (s c) ".end());")
(unique_sort "std::sort(" (p "container" c) ".begin(), " (s c) ".end());" n>
             (s c) ".erase(std::unique(" (s c) ".begin(), " (s c) ".end()), "
             (s c) ".end());" q)
(map_find "const auto it = " (p "map" m) ".find(" (p "key") ");" n>
          "if (it != " (s m) ".end()) {" n> q n> "}")
(map_emplace (p "map") ".emplace(" (p "key") ", " (p "value") ");" q)
(binary_search "std::binary_search(" (p "container" c) ".begin(), " (s c)
               ".end(), " (p "value") ")" q)
(iota "std::iota(" (p "container" c) ".begin(), " (s c) ".end(), " (p "0") ");" q)
(array_decl "std::array<" (p "double") ", " (p "3") "> " (p "values") "{};" q)
(pair_decl "std::pair<" (p "int") ", " (p "double") "> " (p "value") ";" q)
(tuple_decl "std::tuple<" (p "int, double, std::string") "> " (p "value") ";" q)
(emplace_back (p "container") ".emplace_back(" q ");")

;;; Strings and I/O

(cout_print "std::cout << " q " << '\\n';")
(cerr_print "std::cerr << " q " << '\\n';")
(ostringstream "std::ostringstream stream;" n> "stream << " q ";" n>
               "const std::string text = stream.str();")
(istringstream "std::istringstream stream(" (p "text") ");" n>
               (p "std::string") " " (p "token" tok) ";" n>
               "while (stream >> " (s tok) ") {" n> q n> "}")
(string_split "std::vector<std::string> split(const std::string & text,"
              " char delimiter)" n "{" n>
              "std::vector<std::string> parts;" n>
              "std::istringstream stream(text);" n>
              "std::string part;" n>
              "while (std::getline(stream, part, delimiter)) {" n>
              "parts.push_back(part);" n> "}" n> "return parts;" n "}" q)
(string_join "std::ostringstream stream;" n>
             "for (std::size_t i = 0; i < " (p "parts" c) ".size(); ++i) {" n>
             "if (i != 0) { stream << " (p "\", \"") "; }" n>
             "stream << " (s c) "[i];" n> "}" n>
             "const std::string joined = stream.str();" q)
(string_starts_with (p "text") ".rfind(" (p "prefix") ", 0) == 0" q)
(to_string "const std::string text = std::to_string(" (p "value") ");" q)
(from_string "try {" n> "const " (p "double") " value = std::" (p "stod")
             "(" (p "text") ");" n> q n
             "} catch (const std::invalid_argument &) {" > n> p n "}" >)
(file_read_lines "std::ifstream file(" (p "path") ");" n> "if (!file) {" n>
                 "throw std::runtime_error(\"Cannot open file\");" n> "}" n>
                 "std::string line;" n>
                 "while (std::getline(file, line)) {" n> q n> "}")
(file_write "std::ofstream file(" (p "path") ");" n> "if (!file) {" n>
            "throw std::runtime_error(\"Cannot open file\");" n> "}" n>
            "file << " q " << '\\n';")
(filesystem_path "const std::filesystem::path " (p "path" name) "("
                 (p "\"/tmp\"") ");" n>
                 "if (!std::filesystem::exists(" (s name) ")) {" n> q n> "}")
(filesystem_iterate "for (const auto & entry :"
                    " std::filesystem::directory_iterator(" (p "path") ")) {" n>
                    q n "}" >)

;;; Concurrency

(async_future "auto future = std::async(std::launch::async, [&]() {" n> q n>
              "});" n> "const auto result = future.get();")
(promise_future "std::promise<" (p "bool" type) "> promise;" n>
                "std::future<" (s type) "> future = promise.get_future();" n>
                q n> "promise.set_value(" (p "true") ");")
(condition_variable "std::unique_lock<std::mutex> lock(" (p "mutex") "_);" n>
                    (p "condition") "_.wait(lock, [this]() { return " q "; });")
(unique_lock "std::unique_lock<std::mutex> lock(" (p "mutex") "_);" q)
(shared_mutex "mutable std::shared_mutex " (p "mutex" m) "_;" n>
              "std::shared_lock<std::shared_mutex> read_lock(" (s m) "_);" n>
              "std::unique_lock<std::shared_mutex> write_lock(" (s m) "_);" q)
(once_flag "static std::once_flag flag;" n> "std::call_once(flag, []() {" n>
           q n> "});")
(sleep_for "std::this_thread::sleep_for(std::chrono::" (p "milliseconds")
           "(" (p "100") "));" q)
(steady_now "const auto now = std::chrono::steady_clock::now();" q)
(duration_cast "const auto elapsed = std::chrono::duration_cast<std::chrono::"
               (p "milliseconds") ">(" (p "end - start") ").count();" q)
(thread_join "std::thread worker([&]() {" n> q n> "});" n> "worker.join();")

;;; C++17

(variant_decl "std::variant<" (p "int, double, std::string") "> "
              (p "value") ";" q)
(variant_visit "std::visit([](auto && value) {" n>
               "using T = std::decay_t<decltype(value)>;" n>
               "if constexpr (std::is_same_v<T, " (p "int") ">) {" n> q n> "}" n>
               "}, " (p "variant") ");")
(any_cast "try {" n> "const auto value = std::any_cast<" (p "int") ">("
          (p "any") ");" n> q n "} catch (const std::bad_any_cast &) {" > n>
          p n "}" >)
(optional_value_or "const auto value = " (p "optional") ".value_or("
                   (p "fallback") ");" q)
(inline_variable "inline constexpr " (p "double") " " (p "kValue") " = "
                 (p "0.0") ";" q)
(fold_expression "template <typename... Args>" n (p "auto") " " (p "sum")
                 "(Args... args)" n "{" n> "return (args + ...);" n "}" q)
(apply_tuple "std::apply([](" (p "auto &&... args") ") { " q " }, "
             (p "tuple") ");")
(enable_if "template <typename T, typename = std::enable_if_t<std::is_"
           (p "arithmetic") "_v<T>>>" n (p "void") " " (p "function")
           "(T " (p "value") ")" n "{" n> q n "}")
(type_traits_check "static_assert(std::is_" (p "floating_point") "_v<" (p "T")
                   ">, \"" (p "message") "\");" q)

;;; Numerics

(random_engine "std::random_device device;" n>
               "std::mt19937 generator(device());" q)
(random_uniform "std::uniform_" (p "real") "_distribution<" (p "double")
                "> distribution(" (p "0.0") ", " (p "1.0") ");" n>
                "const auto value = distribution(" (p "generator") ");" q)
(random_normal "std::normal_distribution<double> distribution(" (p "0.0") ", "
               (p "1.0") ");" n>
               "const auto value = distribution(" (p "generator") ");" q)
(deg_to_rad "(" (p "degrees") " * M_PI / 180.0)" q)
(rad_to_deg "(" (p "radians") " * 180.0 / M_PI)" q)
(normalize_angle "std::remainder(" (p "angle") ", 2.0 * M_PI)" q)
(approx_equal "(std::abs(" (p "lhs") " - " (p "rhs") ") < " (p "1e-9") ")" q)
(lerp "(" (p "a" a) " + " (p "t") " * (" (p "b") " - " (s a) "))" q)
(sign "template <typename T>" n "constexpr int sign(T value) noexcept" n "{" n>
      "return (T(0) < value) - (value < T(0));" n "}" q)
(hypot "std::hypot(" (p "x") ", " (p "y") ")" q)

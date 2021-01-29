syn match Special "[(){}\[\]<>"'`,;]"  " darker parentheses
syn match Statement "[-+=?!$%^&*\\|~]"  " brighter operators
syn match Statement "[/*]\@<!/[/*]\@!"  " brighter / operator
syn match Statement "->\|<=\|>="  " brighter logicals

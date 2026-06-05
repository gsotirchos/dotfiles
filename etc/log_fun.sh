log_fun() {
    min="0.2"
    range="$(echo "1 - ${min}" | bc)"
    result="$(echo "100 + ${range}*100*l(1/10 + $1/10*${range}/(${min}*255))/l(10)" \
        | bc -l)"

    printf "%.$2f" "${result}"
}

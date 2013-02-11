
echo "This is script 1:"
echo " - you should see that the exported var from exportsh is available."
echo " - the original arguments are not passed"
echo "var1: $VAR1"
echo "var2 (exported): $VAR2"
echo "pwd: $( pwd )"
echo "arg0: ${0}"
echo "arg1: ${1}"
echo "arg2: ${2}"

export VAR2="var2+++"

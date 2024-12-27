

test ! -d test && echo "expected test dir here. cd to the root path" && exit 1

sc() {
    shellcheck $* -s bash --norc -P lib:. -x pegasus-bash.sh lib/*.lib.sh
}

select ITEM in static static-diff test test-x quit
do
    case "$ITEM" in
	static)
	    sc
	    ;;
	static-diff)
	    sc -f diff > static.diff
	    echo generated: static.diff
	    ;;	
	test)
	    bats test
	    ;;
	test-x)
	    bats -x test
	    ;;
	quit)
	    echo "bye!"
	    exit 0
	    ;;
    esac
done

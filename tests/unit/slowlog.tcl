start_server {tags {"slowlog"} overrides {slowlog-log-slower-than 1000000}} {
    test {SLOWLOG - check that it starts with an empty log} {
        assert_equal 0 [r slowlog len]
    }

    test {SLOWLOG - only logs commands taking more time than specified} {
        r config set slowlog-log-slower-than 100000
        r ping
        assert_equal 0 [r slowlog len]
        r debug sleep 0.2
        assert_equal 1 [r slowlog len]
    }

    test {SLOWLOG - max entries is correctly handled} {
        r config set slowlog-log-slower-than 0
        r config set slowlog-max-len 10
        for {set i 0} {$i < 100} {incr i} {
            r ping
        }
        assert_equal 10 [r slowlog len]
    }

    test {SLOWLOG - GET optional argument to limit output len works} {
        assert_equal 5 [llength [r slowlog get 5]]
    }

    test {SLOWLOG - RESET subcommand works} {
        r config set slowlog-log-slower-than 100000
        r slowlog reset
        assert_equal 0 [r slowlog len]
    }

    test {SLOWLOG - logged entry sanity check} {
        r debug sleep 0.2
        set e [lindex [r slowlog get] 0]
        assert_equal 4 [llength $e]
        assert_equal 105 [lindex $e 0]
        assert_equal 1 [expr {[lindex $e 2] > 100000}]
        assert_equal {debug sleep 0.2} [lindex $e 3]
    }
}

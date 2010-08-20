start_server {tags {"timeout"} overrides {timeout 1}} {
    # The server cron is responsible for closing idle clients, which is ran
    # every second. A client is considered timed out when idle > maxtimeout,
    # which means that we need to wait at least 2 seconds. To be sure the
    # timeout is picked up by the cron we need to add another second, which
    # makes a total of 3 seconds to wait before checking timeout.

    proc safe_read {client} {
        if {[catch {set response [$client read]} error]} {
            puts "!! ERROR\nThe connection timed out: $error"
            error "assertion"
        }
        set _ $response
    }

    test "Close connection when it times out" {
        set rd [redis_deferring_client]
        after 3000

        $rd ping
        assert_error "*Bad protocol*" {$rd read}
    }

    test "Ignore timeout when client is doing a blocking pop" {
        set rd1 [redis_deferring_client]
        $rd1 blpop list1 0
        after 3000

        set rd2 [redis_deferring_client]
        $rd2 rpush list1 foo
        assert_equal {list1 foo} [safe_read $rd1]
    }

    test "Ignore timeout when client is subscribed to a channel" {
        set rd1 [redis_deferring_client]
        $rd1 subscribe foo
        assert_equal {subscribe foo 1} [$rd1 read]
        after 3000

        set rd2 [redis_deferring_client]
        $rd2 publish foo bar
        assert_equal {message foo bar} [safe_read $rd1]
    }

    test "Ignore timeout when client is subscribed to a pattern" {
        set rd1 [redis_deferring_client]
        $rd1 psubscribe foo.*
        assert_equal {psubscribe foo.* 1} [$rd1 read]
        after 3000

        set rd2 [redis_deferring_client]
        $rd2 publish foo.1 bar
        assert_equal {pmessage foo.* foo.1 bar} [safe_read $rd1]
    }

    test "Ignore timeout when client is in monitor mode" {
        set rd1 [redis_deferring_client]
        $rd1 monitor
        assert_equal OK [$rd1 read]
        assert_match "*\"monitor\"*" [$rd1 read]
        after 3000

        set rd2 [redis_deferring_client]
        assert_match "*\"select\"*" [safe_read $rd1]
    }
}

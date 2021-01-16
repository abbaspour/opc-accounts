package sample

import input

allowed_users = ["user1"]

default allow = false

allow {
    some i
    input.user == allowed_users[i]
}

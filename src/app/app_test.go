package main_test

import "testing"

func TestMain(t *testing.T) {
	if true == false {
		t.Error("This is really wrong!")
	}
}

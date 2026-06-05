#!/bin/bash

sudo sysctl -w fs.protected_regular=0 >/dev/null

echo "Creating test file..."
echo "Hello from user debian" > /tmp/testfile

chmod 600 /tmp/testfile
setfacl -m u:alice:r /tmp/testfile
setfacl -m u:bob:rw /tmp/testfile

echo
echo "Current permissions:"
ls -l /tmp/testfile

echo
echo "Current ACL:"
getfacl /tmp/testfile

echo "========== ACCESS TESTS =========="
echo

test_read() {
	local user=$1

	if sudo su - "$user" -c "cat /tmp/testfile >/dev/null 2>&1"; then
		printf "%-10s READ   [PASS]\n" "$user"
	else
		printf "%-10s READ   [FAIL]\n" "$user"
	fi
}

test_write() {
	local user=$1

	if sudo su - "$user" -c "echo 'Hello from user $user' >> /tmp/testfile" 2>/dev/null; then
		printf "%-10s WRITE  [PASS]\n" "$user"
	else
		printf "%-10s WRITE  [FAIL]\n" "$user"
	fi
}

test_read alice
test_write alice

test_read bob
test_write bob

test_read charle
test_write charle

echo
echo "========== FINAL FILE CONTENT =========="
echo

cat /tmp/testfile

echo

sudo sysctl -w fs.protected_regular=2 >/dev/null

#!/usr/bin/env bash
#
# Usage:
#   cpp-template <basename-with-or-without-.cpp>
#

filename="$1"
if [ -z "$filename" ]; then
echo "Usage: cpp-template <filename>"
exit 1
fi

# If user didn’t supply a ".cpp" suffix, append it
case "$filename" in
*.cpp) ;;
*) filename="${filename}.cpp" ;;
esac

cat > "$filename" <<EOF
#include <bits/stdc++.h>
using namespace std;

#define int long long
#define all(x) (x).begin(), (x).end()
#define fastio ios::sync_with_stdio(false); cin.tie(nullptr);

int32_t main() {
fastio;
int t;
cin >> t;
while (t--) {
  // ── your code here ──
}
return 0;
}
EOF

echo "Created C++ template: \$filename"

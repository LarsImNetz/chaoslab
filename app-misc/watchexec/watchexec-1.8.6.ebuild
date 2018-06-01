# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

# Partially generated with:
# curl -s https://raw.githubusercontent.com/mattgreen/watchexec/1.8.6/Cargo.lock | sed 's/^"checksum \([[:graph:]]\+\) \([[:graph:]]\+\) (.*$/\1-\2/'
CRATES="
aho-corasick-0.6.3
bitflags-0.4.0
bitflags-0.7.0
bitflags-0.9.1
bytes-0.3.0
cfg-if-0.1.2
clap-2.26.0
conv-0.3.3
custom_derive-0.1.7
env_logger-0.4.3
filetime-0.1.10
fnv-1.0.5
fsevent-0.2.16
fsevent-sys-0.1.6
glob-0.2.11
globset-0.2.0
inotify-0.3.0
kernel32-sys-0.2.2
lazy_static-0.2.8
libc-0.2.29
log-0.3.8
magenta-0.1.1
magenta-sys-0.1.1
memchr-1.0.1
mio-0.5.1
miow-0.1.5
mktemp-0.3.1
net2-0.2.31
nix-0.5.1
nix-0.9.0
notify-4.0.1
rand-0.3.16
redox_syscall-0.1.30
regex-0.2.2
regex-syntax-0.4.1
rustc-serialize-0.3.24
slab-0.1.3
term_size-0.3.0
textwrap-0.7.0
thread_local-0.3.4
time-0.1.38
unicode-segmentation-1.2.0
unicode-width-0.1.4
unreachable-1.0.0
utf8-ranges-1.0.0
uuid-0.1.18
vec_map-0.8.0
void-1.0.2
walkdir-0.1.8
winapi-0.2.8
winapi-build-0.1.1
ws2_32-sys-0.2.1
"

inherit cargo

DESCRIPTION="Executes commands in response to file modifications"
HOMEPAGE="https://github.com/mattgreen/watchexec"
# shellcheck disable=SC2086
SRC_URI="https://github.com/mattgreen/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz
	$(cargo_crate_uris ${CRATES})"
RESTRICT="mirror"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

src_install() {
	dobin "target/release/${PN}"
	doman "doc/${PN}.1"
}

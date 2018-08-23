# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

# Generated with:
# curl -s https://raw.githubusercontent.com/mattgreen/watchexec/1.9.0/Cargo.lock | sed 's/^"checksum \([[:graph:]]\+\) \([[:graph:]]\+\) (.*$/\1-\2/'
CRATES="
aho-corasick-0.6.6
atty-0.2.11
bitflags-0.4.0
bitflags-0.7.0
bitflags-1.0.3
bytes-0.3.0
cc-1.0.18
cfg-if-0.1.5
clap-2.32.0
env_logger-0.5.12
filetime-0.1.15
fnv-1.0.6
fsevent-0.2.17
fsevent-sys-0.1.6
fuchsia-zircon-0.3.3
fuchsia-zircon-sys-0.3.3
glob-0.2.11
globset-0.4.1
humantime-1.1.1
inotify-0.3.0
kernel32-sys-0.2.2
lazy_static-1.1.0
libc-0.2.43
log-0.3.9
log-0.4.4
memchr-2.0.1
mio-0.5.1
miow-0.1.5
mktemp-0.3.1
net2-0.2.33
nix-0.11.0
nix-0.5.1
notify-4.0.4
quick-error-1.2.2
rand-0.3.22
rand-0.4.3
redox_syscall-0.1.40
redox_termios-0.1.1
regex-1.0.2
regex-syntax-0.6.2
rustc-serialize-0.3.24
same-file-1.0.2
slab-0.1.3
term_size-0.3.1
termcolor-1.0.1
termion-1.5.1
textwrap-0.10.0
thread_local-0.3.6
time-0.1.40
ucd-util-0.1.1
unicode-width-0.1.5
utf8-ranges-1.0.0
uuid-0.1.18
version_check-0.1.4
void-1.0.2
walkdir-2.2.0
winapi-0.2.8
winapi-0.3.5
winapi-build-0.1.1
winapi-i686-pc-windows-gnu-0.4.0
winapi-x86_64-pc-windows-gnu-0.4.0
wincolor-1.0.0
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

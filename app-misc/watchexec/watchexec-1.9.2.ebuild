# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

# Generated with:
# curl -s https://raw.githubusercontent.com/mattgreen/watchexec/1.9.2/Cargo.lock | sed 's/^"checksum \([[:graph:]]\+\) \([[:graph:]]\+\) (.*$/\1-\2/'
CRATES="
aho-corasick-0.6.8
atty-0.2.11
bitflags-0.7.0
bitflags-1.0.4
byteorder-1.2.6
bytes-0.4.10
cc-1.0.24
cfg-if-0.1.5
clap-2.32.0
cloudabi-0.0.3
crossbeam-utils-0.5.0
env_logger-0.5.13
filetime-0.2.1
fnv-1.0.6
fsevent-0.2.17
fsevent-sys-0.1.6
fuchsia-zircon-0.3.3
fuchsia-zircon-sys-0.3.3
futures-0.1.24
glob-0.2.11
globset-0.4.2
humantime-1.1.1
inotify-0.6.1
inotify-sys-0.1.3
iovec-0.1.2
kernel32-sys-0.2.2
lazy_static-1.1.0
lazycell-1.0.0
libc-0.2.43
lock_api-0.1.3
log-0.4.5
memchr-2.0.2
mio-0.6.16
mio-extras-2.0.5
miow-0.2.1
mktemp-0.3.1
net2-0.2.33
nix-0.11.0
notify-4.0.6
num_cpus-1.8.0
owning_ref-0.3.3
parking_lot-0.6.4
parking_lot_core-0.3.0
quick-error-1.2.2
rand-0.3.22
rand-0.4.3
rand-0.5.5
rand_core-0.2.1
redox_syscall-0.1.40
redox_termios-0.1.1
regex-1.0.5
regex-syntax-0.6.2
rustc-serialize-0.3.24
same-file-1.0.3
scopeguard-0.3.3
slab-0.4.1
smallvec-0.6.5
stable_deref_trait-1.1.1
term_size-0.3.1
termcolor-1.0.3
termion-1.5.1
textwrap-0.10.0
thread_local-0.3.6
tokio-executor-0.1.4
tokio-io-0.1.8
tokio-reactor-0.1.5
ucd-util-0.1.1
unicode-width-0.1.5
unreachable-1.0.0
utf8-ranges-1.0.1
uuid-0.1.18
version_check-0.1.4
void-1.0.2
walkdir-2.2.5
winapi-0.2.8
winapi-0.3.5
winapi-build-0.1.1
winapi-i686-pc-windows-gnu-0.4.0
winapi-util-0.1.1
winapi-x86_64-pc-windows-gnu-0.4.0
wincolor-1.0.1
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

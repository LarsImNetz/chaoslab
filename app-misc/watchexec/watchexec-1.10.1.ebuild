# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

# Generated with:
# curl -s https://raw.githubusercontent.com/mattgreen/watchexec/1.10.1/Cargo.lock | sed 's/^"checksum \([[:graph:]]\+\) \([[:graph:]]\+\) (.*$/\1-\2/'
CRATES="
aho-corasick-0.6.9
atty-0.2.11
autocfg-0.1.2
bitflags-0.7.0
bitflags-1.0.4
byteorder-1.3.1
bytes-0.4.11
cc-1.0.28
cfg-if-0.1.6
clap-2.32.0
cloudabi-0.0.3
crossbeam-utils-0.6.3
env_logger-0.5.13
filetime-0.2.4
fnv-1.0.6
fsevent-0.2.17
fsevent-sys-0.1.6
fuchsia-zircon-0.3.3
fuchsia-zircon-sys-0.3.3
futures-0.1.25
glob-0.2.11
globset-0.4.2
humantime-1.2.0
inotify-0.6.1
inotify-sys-0.1.3
iovec-0.1.2
kernel32-sys-0.2.2
lazy_static-1.2.0
lazycell-1.2.1
libc-0.2.48
lock_api-0.1.5
log-0.4.6
memchr-2.1.3
mio-0.6.16
mio-extras-2.0.5
miow-0.2.1
mktemp-0.3.1
net2-0.2.33
nix-0.11.0
notify-4.0.7
num_cpus-1.9.0
owning_ref-0.4.0
parking_lot-0.7.1
parking_lot_core-0.4.0
quick-error-1.2.2
rand-0.3.22
rand-0.4.5
rand-0.6.4
rand_chacha-0.1.1
rand_core-0.3.1
rand_core-0.4.0
rand_hc-0.1.0
rand_isaac-0.1.1
rand_os-0.1.1
rand_pcg-0.1.1
rand_xorshift-0.1.1
rdrand-0.4.0
redox_syscall-0.1.51
redox_termios-0.1.1
regex-1.1.0
regex-syntax-0.6.4
rustc-serialize-0.3.24
rustc_version-0.2.3
same-file-1.0.4
scopeguard-0.3.3
semver-0.9.0
semver-parser-0.7.0
slab-0.4.2
smallvec-0.6.8
stable_deref_trait-1.1.1
term_size-0.3.1
termcolor-1.0.4
termion-1.5.1
textwrap-0.10.0
thread_local-0.3.6
tokio-executor-0.1.6
tokio-io-0.1.11
tokio-reactor-0.1.8
ucd-util-0.1.3
unicode-width-0.1.5
unreachable-1.0.0
utf8-ranges-1.0.2
uuid-0.1.18
void-1.0.2
walkdir-2.2.7
winapi-0.2.8
winapi-0.3.6
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
ARCHIVE_URI="https://github.com/mattgreen/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"
# shellcheck disable=SC2086
SRC_URI="${ARCHIVE_URI} $(cargo_crate_uris ${CRATES})"
RESTRICT="mirror"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"

src_install() {
	dobin "target/release/${PN}"
	doman "doc/${PN}.1"
}

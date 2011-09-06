# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit linux-mod

MY_RELDATE="2010_07_16"
MY_PNAME="${MY_RELDATE}_RT2860_Linux_STA_v${PV}"

DESCRIPTION="Ralink RT2860 Wireless Lan Linux Driver"
HOMEPAGE="http://www.ralinktech.com/support.php?s=2"
SRC_URI="http://www.ralinktech.com/download.php?t=U0wyRnpjMlYwY3k4eU1ERXdMekEzTHpFMkwyUnZkMjVzYjJGa05qZ3hPRFUwTmpBd05DNWllakk5UFQweU1ERXdYekEzWHpFMlgxSlVNamcyTUY5TWFXNTFlRjlUVkVGZmRqSXVOQzR3TGpBdWRHRnlD -> ${MY_PNAME}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="networkmanager"

RESTRICT="mirror"

DEPEND=""
RDEPEND="net-wireless/wireless-tools"

S="${WORKDIR}/${MY_PNAME}"

CONFIG_CHECK="WIRELESS_EXT"
BUILD_TARGETS="LINUX"
MODULE_NAMES="rt2860sta(kernel/drivers/net/wireless:${S}:${S}/os/linux)"

src_prepare() {
	#set the proper linux sources dir in the Makefile
	sed -i -e "s|^LINUX_SRC *= *.*$|LINUX_SRC=${KERNEL_DIR}|g" \
	       -e "s|^LINUX_SRC_MODULE *= *\(.*\)\$(.*uname *-r *)\(.*\)$|LINUX_SRC_MODULE=\1${KV_FULL}\2|g" Makefile || die
	#having wpa_supplicant support is the least we can do + some cleanup
	sed -i -e "s|^HAS_WPA_SUPPLICANT *= *.*$|HAS_WPA_SUPPLICANT=y|g" -e "s|^\(.*\) -DDBG$|\1|g" os/linux/config.mk || die
	if use networkmanager ; then
		sed -i -e "s|^HAS_NATIVE_WPA_SUPPLICANT_SUPPORT *= *.*$|HAS_NATIVE_WPA_SUPPLICANT_SUPPORT=y|g" os/linux/config.mk || die
	fi
}

src_install() {
	linux-mod_src_install
	dodoc iwpriv_usage.txt README_STA
	insinto /etc/Wireless/RT2860STA
	insopts -m 0600
	doins RT2860STA.dat || die
}

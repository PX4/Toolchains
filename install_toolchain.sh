#!/bin/bash

echo "PX4 Toolchain Installer"
echo -e "=================================\n"

LINARO_ARMHF_TOOLCHAIN_URL="https://releases.linaro.org/components/toolchain/binaries/latest-5/arm-linux-gnueabihf/gcc-linaro-5.3.1-2016.05-x86_64_arm-linux-gnueabihf.tar.xz"
NUTTX_TOOLCHAIN_URL="https://launchpad.net/gcc-arm-embedded/5.0/5-2016-q2-update/+download/gcc-arm-none-eabi-5_4-2016q2-20160622-linux.tar.bz2"

show_usage () {
  echo -e "Try ./install_toolchain.sh [all, bebop, snapdragon, rpi, nuttx] \n"
}

install_nuttx () {
  echo -e "Downloading arm-none-eabi toolchain\n"
  wget ${NUTTX_TOOLCHAIN_URL} --continue
  if [ $? -eq 0 ]; then
    echo -e "Download complete"
  else
    echo "Download failed. Rerun installer."
    return
  fi

  echo "Extracting toolchain"
  mkdir -p gcc-arm-none-eabi
  tar -jxf $(basename ${NUTTX_TOOLCHAIN_URL}) -C gcc-arm-none-eabi --strip-components 1

  echo "Installing toolchain"
  exportline="export PATH=$PWD/gcc-arm-none-eabi/bin:\$PATH"
  if grep -Fxq "$exportline" ~/.profile; then echo '' ; else echo $exportline >> ~/.profile; fi

  # Check compiler
  arm-none-eabi-gcc --version
  if [ $? -eq 0 ]; then
    echo -e "Install complete\n"
  else
    echo -e "Install failed\n"
  fi

}

install_linaro_armhf () {
  echo -e "Downloading arm-linux-gnueabihf toolchain"
  wget ${LINARO_ARMHF_TOOLCHAIN_URL} --continue
  if [ $? -eq 0 ]; then
    echo "Download complete"
  else
    echo "Download failed. Rerun installer."
    return
  fi

  echo -e "Extracting toolchain"
  mkdir -p gcc-linaro-arm-linux-gnueabihf
  tar -xf $(basename ${LINARO_ARMHF_TOOLCHAIN_URL}) -C gcc-linaro-arm-linux-gnueabihf --strip-components 1

  echo "Installing toolchain"
  exportline="export PX4_TOOLCHAIN_DIR=$PWD"
  if grep -Fxq "$exportline" ~/.profile; then echo '' ; else echo $exportline >> ~/.profile; fi
  source ~/.profile

  # Check compiler
  $PX4_TOOLCHAIN_DIR/gcc-linaro-arm-linux-gnueabihf/bin/arm-linux-gnueabihf-gcc --version
  if [ $? -eq 0 ]; then
    echo -e "Install complete\n"
  else
    echo -e "Install failed\n"
  fi
}

install_snapdragon () {
  echo -e "Snapdragon auto-installer not yet implemented. Follow official instructions manually.\n"
}

clean_arm () {
	if [ -z ${RPI_TOOLCHAIN_DIR+x} ]; then 
		echo "No old toolchain found"
	else
		if [ -d "$RPI_TOOLCHAIN_DIR" ]; then
			echo "Found old toolchain at $RPI_TOOLCHAIN_DIR"
   			sudo rm -rf $RPI_TOOLCHAIN_DIR
  			echo "Removing old toolchain"
		fi
		echo "Removing environment variables"
		sed -i '/RPI_TOOLCHAIN_DIR/d' ~/.profile
		echo "Removal complete"
	fi
}

# read list of toolchains to install
args="$1"
if [ "${args}" == "" ]; then
  echo -e "No toolchains specified, exiting\n"
  show_usage
  exit 1
fi

for var in "$@"
do
    case "${var}" in 
    "all")
      echo "Installing all toolchains."
      install_nuttx
      install_linaro_armhf
      install_snapdragon
      ;;
    "nuttx")
      echo "Installing NuttX toolchain"
      install_nuttx
      ;;
    "bebop" | "rpi")
      echo "Installing Parrot Bebop / Raspberry Pi toolchain"
      install_linaro_armhf
      ;;
    "snapdragon")
      echo "Installing Snapdragon Flight toolchain"
      install_snapdragon
      ;;
    "clean_arm")
      clean_arm
      ;;
    *)
      echo -e "No valid toolchains specified, exiting\n"
      show_usage
      exit 1
      ;;
    esac
done
echo -e "\nRun 'source ~/.profile' to complete toolchain install/removal."
echo -e "Alternatively, logout and login again."

exit 0
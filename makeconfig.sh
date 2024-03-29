#!/usr/bin/env bash

#====================================================
#	System Request:Ubuntu 18.04+/20.04+
#	Author:	shidahuilang
#	Dscription: openwrt onekey Management
#	github: https://github.com/shidahuilang
#====================================================

# 字体颜色配置
Green="\033[32m"
Red="\033[31m"
Yellow="\033[33m"
Blue="\033[36m"
Font="\033[0m"
GreenBG="\033[42;37m"
RedBG="\033[41;37m"
OK="${Green}[OK]${Font}"
ERROR="${Red}[ERROR]${Font}"

# 变量
export GITHUB_WORKSPACE="$PWD"
export OP_DIY="${GITHUB_WORKSPACE}/CONFIG_DIY"
export HOME_PATH="${GITHUB_WORKSPACE}/op_config"
export LOCAL_Build="${HOME_PATH}/build"
export COMMON_SH="${HOME_PATH}/build/common/common.sh"
export BASE_PATH="${HOME_PATH}/package/base-files/files"
export NETIP="${HOME_PATH}/package/base-files/files/etc/networkip"
export DELETE="${HOME_PATH}/package/base-files/files/etc/deletefile"
export FIN_PATH="${HOME_PATH}/package/base-files/files/etc/FinishIng.sh"
export KEEPD="${HOME_PATH}/package/base-files/files/lib/upgrade/keep.d/base-files-essential"
export Author="$(grep "syslog" "/etc/group"|awk 'NR==1' |cut -d "," -f2)"
export REPO_TOKEN="REPO_TOKEN"
export date1="$(date +'%m-%d')"
export bendi_script="1"

function print_ok() {
  echo
  echo -e " ${OK} ${Blue} $1 ${Font}"
  echo
}
function print_error() {
  echo
  echo -e "${ERROR} ${RedBG} $1 ${Font}"
  echo
}
function ECHOY() {
  echo
  echo -e "${Yellow} $1 ${Font}"
  echo
}
function ECHOG() {
  echo
  echo -e "${Green} $1 ${Font}"
  echo
}
function ECHOB() {
  echo
  echo -e "${Blue} $1 ${Font}"
  echo
}
  function ECHOR() {
  echo
  echo -e "${Red} $1 ${Font}"
  echo
}
function ECHOYY() {
  echo -e "${Yellow} $1 ${Font}"
}
function ECHOGG() {
  echo -e "${Green} $1 ${Font}"
}
  function ECHORR() {
  echo -e "${Red} $1 ${Font}"
}
judge() {
  if [[ 0 -eq $? ]]; then
    echo
    print_ok "$1 完成"
    echo
    sleep 1
  else
    echo
    print_error "$1 失败"
    echo
    exit 1
  fi
}

export Ubname=`cat /etc/issue`
export xtname="Ubuntu"
export xtbit=`getconf LONG_BIT`
if [[ ( $Ubname != *$xtname* ) || ( $xtbit != 64 ) ]]; then
  print_error "请使用Ubuntu 64位系统，推荐 Ubuntu 18 LTS 或 Ubuntu 20 LTS"
  exit 1
fi
if [[ "$USER" == "root" ]]; then
  print_error "警告：请勿使用root用户编译，换一个普通用户吧~~"
  exit 1
fi
Google_Check=$(curl -I -s --connect-timeout 8 google.com -w %{http_code} | tail -n1)
if [ ! "$Google_Check" == 301 ];then
  print_error "提醒：编译之前请自备梯子，编译全程都需要稳定梯子~~"
  exit 0
fi
if [[ "$(echo ${GITHUB_WORKSPACE} |grep -c 'op_config')" -ge '1' ]]; then
  print_error "请注意命令的执行路径,并非在op_config文件夹内执行,如果您ubuntu或机器就叫op_config的话,恭喜您,就是不给您用,改名吧少年!"
  exit 0
fi
if [[ `ls -1 /mnt/* | grep -c "Windows"` -ge '1' ]] || [[ `ls -1 /mnt | grep -c "wsl"` -ge '1' ]]; then
  export WSL_ubuntu="YES"
else
  export WSL_ubuntu="NO"
fi

function op_busuhuanjing() {
cd ${GITHUB_WORKSPACE}
  clear
  echo
  ECHORR "|*******************************************|"
  ECHOGG "|                                           |"
  ECHOYY "|    首次编译,请输入Ubuntu密码继续下一步    |"
  ECHOGG "|                                           |"
  ECHOYY "|              编译环境部署                 |"
  ECHORR "|                                           |"
  ECHOGG "|*******************************************|"
  echo
  sudo apt-get update -y
  sudo apt-get full-upgrade -y
  sudo -E apt-get -qq install -y git subversion git-core wget curl grep
  judge "部署Ubuntu环境"
  sudo apt-get autoremove -y --purge > /dev/null 2>&1
  sudo apt-get clean -y > /dev/null 2>&1
}

function op_diywenjian() {
  cd ${GITHUB_WORKSPACE}
  if [[ ! -d ${GITHUB_WORKSPACE}/CONFIG_DIY ]]; then
    rm -rf bendi && git clone https://github.com/shidahuilang/openwrt bendi
    rm -rf ${GITHUB_WORKSPACE}/bendi/build/*/start-up
    for X in $(find ./bendi -name ".config" |sed 's/.config//g'); do mv "${X}".config "${X}"config; done
    for X in $(find ./bendi -name "diy-part.sh"); do
      echo "
      #!/bin/bash
      # Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
      # 在此处增加插件
      # 记住要跟云脚本同步才可以，如果你这里增加了插件源码，云端没增加，是编译不出来的
      " > "${X}"
      sed -i 's/^[ ]*//g' "${X}"
      sed -i '/^$/d' "${X}"
    done
    for X in $(find ./bendi -name "settings.ini"); do
      sed -i 's/.config/config/g' "${X}"
      sed -i '/SSH_ACTIONS/d' "${X}"
      sed -i '/UPLOAD_CONFIG/d' "${X}"
      sed -i '/UPLOAD_FIRMWARE/d' "${X}"
      sed -i '/UPLOAD_WETRANSFER/d' "${X}"
      sed -i '/UPLOAD_RELEASE/d' "${X}"
      sed -i '/SERVERCHAN_SCKEY/d' "${X}"
      sed -i '/USE_CACHEWRTBUILD/d' "${X}"
      sed -i '/REGULAR_UPDATE/d' "${X}"
      sed -i '/BY_INFORMATION/d' "${X}"
      echo -e "\nEVERY_INQUIRY="true"       # 是否每次都询问您要不要去设置自定义文件（true=开启）（false=关闭）" >> "${X}"
      sed -i '/^$/d' "${X}"
    done
    mv -f ${GITHUB_WORKSPACE}/bendi/build ${GITHUB_WORKSPACE}/CONFIG_DIY
  fi
  if [[ ! -d ${GITHUB_WORKSPACE}/CONFIG_DIY ]]; then
    ECHOR "CONFIG_DIY文件下载失败，请检查网络网络再尝试"
    exit 1
  else
    print_ok "CONFIG_DIY文件下载 完成"
  fi
}

function bianyi_xuanxiang() {
  cd ${GITHUB_WORKSPACE}
  [[ ! -d ${GITHUB_WORKSPACE}/CONFIG_DIY ]] && op_diywenjian
  if [ -z "$(ls -A "$GITHUB_WORKSPACE/CONFIG_DIY/${matrixtarget}/settings.ini" 2>/dev/null)" ]; then
    ECHOR "错误提示：编译脚本缺少[settings.ini]名称的配置文件,请在[CONFIG_DIY/${matrixtarget}]文件夹内补齐"
    exit 1
  else
    source "$GITHUB_WORKSPACE/CONFIG_DIY/${matrixtarget}/settings.ini"
  fi
  if [[ "${EVERY_INQUIRY}" == "true" ]]; then
    clear
    echo
    echo
    ECHOYY "如果您有额外增加插件，请在 CONFIG_DIY/${matrixtarget} 里面设置好自定义文件，记住要跟云编译脚本同步"
    ECHOY "设置完毕后，按[W/w]回车继续编译"
    ZDYSZ="请输入您的选择"
    if [[ "${WSL_ubuntu}" == "YES" ]]; then
      cd ${GITHUB_WORKSPACE}/CONFIG_DIY/${matrixtarget}
      explorer.exe .
      cd ${GITHUB_WORKSPACE}
    fi
    while :; do
      read -p " ${ZDYSZ}： " ZDYSZU
      case $ZDYSZU in
      [Ww])
        echo
      break
      ;;
      *)
        ZDYSZ="提醒：确认设置完毕后，请按[W/w]回车继续编译"
      ;;
      esac
    done
  fi
  source ${GITHUB_WORKSPACE}/CONFIG_DIY/${matrixtarget}/settings.ini > /dev/null 2>&1
  curl -fsSL https://raw.githubusercontent.com/shidahuilang/common/main/common.sh > common.sh
  if [[ $? -ne 0 ]];then
    curl -fsSL https://raw.iqiq.io/shidahuilang/common/main/common.sh > common.sh
  fi
  if [[ $? -eq 0 ]];then
    source common.sh && Diy_repo_url
    rm -fr common.sh
  else
    ECHOR "common文件下载失败，请检测网络后再用一键命令试试!"
    exit 1
  fi
}

function op_repo_branch() {
  cd ${GITHUB_WORKSPACE}
  echo
  ECHOG "正在下载源码中,请耐心等候~~~"
  rm -rf op_config && git clone -b "$REPO_BRANCH" --single-branch "$REPO_URL" op_config
  judge "${matrixtarget}源码下载"
}

function op_jiaoben() {
  if [[ ! -d ${HOME_PATH}/build ]]; then
    cp -Rf ${GITHUB_WORKSPACE}/CONFIG_DIY ${HOME_PATH}/build
  else
    cp -Rf ${GITHUB_WORKSPACE}/CONFIG_DIY/* ${HOME_PATH}/build/
  fi
  [[ "${Tishi}" == "1" ]] && sed -i '/-rl/d' "${BUILD_PATH}/${DIY_PART_SH}"
  rm -rf ${HOME_PATH}/build/common && git clone https://github.com/shidahuilang/common ${HOME_PATH}/build/common
  judge "额外扩展文件下载"
  rm -rf ${HOME_PATH}/build/common/OP_DIY
  mv -f ${LOCAL_Build}/common/*.sh ${BUILD_PATH}
  chmod -R +x ${BUILD_PATH}
  source "${BUILD_PATH}/common.sh" && Bendi_variable
}

function op_diy_zdy() {
  ECHOG "正在下载插件包和更新feeds,请耐心等候~~~"
  cd ${HOME_PATH}
  source "${BUILD_PATH}/settings.ini"
  source "${BUILD_PATH}/common.sh" && Diy_menu
}

function op_menuconfig() {
  cd ${HOME_PATH}
  make menuconfig
  if [[ $? -ne 0 ]]; then
    ECHOY "窗口分辨率太小，无法弹出设置更机型或插件的窗口"
    ECHOG "请调整窗口分辨率后按[Y/y]继续,或者按[N/n]退出编译"
    XUANMA="请输入您的选择"
    while :; do
    read -p " ${XUANMA}：" Make
    case $Make in
    [Yy])
       op_menuconfig
       break
      ;;
      [Nn])
       exit 1
      break
    ;;
    *)
      XUANMA="输入错误,请输入[Y/n]"
    ;;
    esac
    done
  fi
}

function make_defconfig() {
  ECHOG "正在生成配置文件，请稍后..."
  cd ${HOME_PATH}
  source "${BUILD_PATH}/common.sh" && Diy_prevent
  if [[ -f ${HOME_PATH}/EXT4 ]] || [[ -f ${HOME_PATH}/Chajianlibiao ]]; then
    read -t 30 -p " [如需重新编译请按输入[ Y/y ]回车确认，直接回车则为否](不作处理,30秒自动跳过)： " MNUu
    case $MNUu in
    [Yy])
      rm -rf ${HOME_PATH}/{CHONGTU,Chajianlibiao,EXT4}
      sleep 1
      exit 1
    ;;
    *)
      rm -rf ${HOME_PATH}/{CHONGTU,Chajianlibiao,EXT4}
      ECHOG "正在制作配置文件...！"
    ;;
    esac
  fi
  source "${BUILD_PATH}/common.sh" && Diy_menu2 > /dev/null 2>&1
  rm -rf "${OP_DIY}/${matrixtarget}/${CONFIG_FILE}"
  ./scripts/diffconfig.sh > "${OP_DIY}/${matrixtarget}/${CONFIG_FILE}"
}

function op_end() {
  cd ${HOME_PATH}
  print_ok "配置文件制作完成，已经覆盖进[CONFIG_DIY/${matrixtarget}/${CONFIG_FILE}]文件中"
  if [[ "${WSL_ubuntu}" == "YES" ]]; then
    cd ${OP_DIY}/${matrixtarget}
    explorer.exe .
  fi
  echo
}

function tixing_op_config() {
  export TARGET_BOARD="$(awk -F '[="]+' '/TARGET_BOARD/{print $2}' "${GITHUB_WORKSPACE}/CONFIG_DIY/${matrixtarget}/${CONFIG_FILE}")"
  export TARGET_SUBTARGET="$(awk -F '[="]+' '/TARGET_SUBTARGET/{print $2}' "${GITHUB_WORKSPACE}/CONFIG_DIY/${matrixtarget}/${CONFIG_FILE}")"
  if [[ `grep -c "CONFIG_TARGET_x86_64=y" "${GITHUB_WORKSPACE}/CONFIG_DIY/${matrixtarget}/${CONFIG_FILE}"` -eq '1' ]]; then
    export TARGET_PROFILE="x86-64"
  elif [[ `grep -c "CONFIG_TARGET_x86=y" ${GITHUB_WORKSPACE}/CONFIG_DIY/${matrixtarget}/${CONFIG_FILE}` == '1' ]] && [[ `grep -c "CONFIG_TARGET_x86_64=y" "${GITHUB_WORKSPACE}/CONFIG_DIY/${matrixtarget}/${CONFIG_FILE}"` == '0' ]]; then
    export TARGET_PROFILE="x86_32"
  elif [[ `grep -c "CONFIG_TARGET.*DEVICE.*=y" "${GITHUB_WORKSPACE}/CONFIG_DIY/${matrixtarget}/${CONFIG_FILE}"` -eq '1' ]]; then
    export TARGET_PROFILE="$(egrep -o "CONFIG_TARGET.*DEVICE.*=y" "${GITHUB_WORKSPACE}/CONFIG_DIY/${matrixtarget}/${CONFIG_FILE}" | sed -r 's/.*DEVICE_(.*)=y/\1/')"
  else
    export TARGET_PROFILE="$(awk -F '[="]+' '/TARGET_BOARD/{print $2}' ${GITHUB_WORKSPACE}/CONFIG_DIY/${matrixtarget}/${CONFIG_FILE})"
  fi
  export TARGET_BSGET="$HOME_PATH/bin/targets/$TARGET_BOARD/$TARGET_SUBTARGET"
  [[ -z "${TARGET_PROFILE}" ]] && TARGET_PROFILE="CONFIG_DIY/${matrixtarget}没有${CONFIG_FILE}文件,或者${CONFIG_FILE}文件内容为空"
}

function op_firmware() {
  if [[ "${matrixtarget}" == "Lede_source" ]] || [[ -n "$(ls -A "${HOME_PATH}/.Lede_core" 2>/dev/null)" ]]; then
    export matrixtarget="Lede_source"
    export BUILD_PATH="$HOME_PATH/build/${matrixtarget}"
    [[ -f ${BUILD_PATH}/common.sh ]] && source "${BUILD_PATH}/common.sh" && Bendi_variable
    export Mark_Core=".Lede_core"
    [[ -d "${HOME_PATH}" ]] && echo "${Mark_Core}" > "${HOME_PATH}/${Mark_Core}"
  elif [[ "${matrixtarget}" == "Lienol_source" ]] || [[ -n "$(ls -A "${HOME_PATH}/.Lienol_core" 2>/dev/null)" ]]; then
    export matrixtarget="Lienol_source"
    export BUILD_PATH="$HOME_PATH/build/${matrixtarget}"
    [[ -f ${BUILD_PATH}/common.sh ]] && source "${BUILD_PATH}/common.sh" && Bendi_variable
    export Mark_Core=".Lienol_core"
    [[ -d "${HOME_PATH}" ]] && echo "${Mark_Core}" > "${HOME_PATH}/${Mark_Core}"
  elif [[ "${matrixtarget}" == "Tianling_source" ]] || [[ -n "$(ls -A "${HOME_PATH}/.Tianling_core" 2>/dev/null)" ]]; then
    export matrixtarget="Tianling_source"
    export BUILD_PATH="$HOME_PATH/build/${matrixtarget}"
    [[ -f ${BUILD_PATH}/common.sh ]] && source "${BUILD_PATH}/common.sh" && Bendi_variable
    export Mark_Core=".Tianling_core"
    [[ -d "${HOME_PATH}" ]] && echo "${Mark_Core}" > "${HOME_PATH}/${Mark_Core}"
  elif [[ "${matrixtarget}" == "Mortal_source" ]] || [[ -n "$(ls -A "${HOME_PATH}/.Mortal_core" 2>/dev/null)" ]]; then
    export matrixtarget="Mortal_source"
    export BUILD_PATH="$HOME_PATH/build/${matrixtarget}"
    [[ -f ${BUILD_PATH}/common.sh ]] && source "${BUILD_PATH}/common.sh" && Bendi_variable
    export Mark_Core=".Mortal_core"
    [[ -d "${HOME_PATH}" ]] && echo "${Mark_Core}" > "${HOME_PATH}/${Mark_Core}"
  elif [[ "${matrixtarget}" == "openwrt_amlogic" ]] || [[ -n "$(ls -A "${HOME_PATH}/.amlogic_core" 2>/dev/null)" ]]; then
    export matrixtarget="openwrt_amlogic"
    export BUILD_PATH="$HOME_PATH/build/${matrixtarget}"
    [[ -f ${BUILD_PATH}/common.sh ]] && source "${BUILD_PATH}/common.sh" && Bendi_variable
    export Mark_Core=".amlogic_core"
    [[ -d "${HOME_PATH}" ]] && echo "${Mark_Core}" > "${HOME_PATH}/${Mark_Core}"
  fi
}

function openwrt_qx() {
    cd ${GITHUB_WORKSPACE}
    if [[ -d ${GITHUB_WORKSPACE}/op_config ]]; then
      ECHOGG "正在删除已存在的op_config文件夹"
      rm -rf ${HOME_PATH}
    fi
}

function openwrt_gitpull() {
  cd ${HOME_PATH}
  ECHOG "git pull上游源码"
  git reset --hard
  if [[ `grep -c "webweb.sh" ${ZZZ_PATH}` -ge '1' ]]; then
    git reset --hard
  fi
  if [[ `grep -c "webweb.sh" ${ZZZ_PATH}` -ge '1' ]]; then
    print_error "同步上游源码失败,请检查网络"
    exit 1
  fi
  ECHOG "同步上游源码完毕,开始制作配置文件"
  source "${BUILD_PATH}/common.sh" && Diy_menu
}

function op_upgrade1() {
  if [[ "${REGULAR_UPDATE}" == "true" ]]; then
    source $BUILD_PATH/upgrade.sh && Diy_Part1
  fi
}

function op_again() {
  cd ${HOME_PATH}
  op_firmware
  bianyi_xuanxiang
  op_diywenjian
  op_jiaoben
  openwrt_gitpull
  op_menuconfig
  make_defconfig
  op_end
}

function openwrt_new() {
  openwrt_qx
  op_busuhuanjing
  op_firmware
  op_diywenjian
  bianyi_xuanxiang
  op_repo_branch
  op_jiaoben
  op_diy_zdy
  op_menuconfig
  make_defconfig
  op_end
}

function menu() {
  ECHOG "正在加载数据中，请稍后..."
  cd ${GITHUB_WORKSPACE}
  curl -fsSL https://raw.githubusercontent.com/coolsnowwolf/lede/master/target/linux/x86/Makefile > Makefile
  export ledenh="$(egrep -o "KERNEL_PATCHVER:=[0-9]+\.[0-9]+" Makefile |cut -d "=" -f2)"
  curl -fsSL https://raw.githubusercontent.com/Lienol/openwrt/22.03/target/linux/x86/Makefile > Makefile
  export lienolnh="$(egrep -o "KERNEL_PATCHVER:=[0-9]+\.[0-9]+" Makefile |cut -d "=" -f2)"
  curl -fsSL https://raw.githubusercontent.com/immortalwrt/immortalwrt/openwrt-21.02/target/linux/x86/Makefile > Makefile
  export mortalnh="$(egrep -o "KERNEL_PATCHVER:=[0-9]+\.[0-9]+" Makefile |cut -d "=" -f2)"
  curl -fsSL https://raw.githubusercontent.com/immortalwrt/immortalwrt/openwrt-18.06/target/linux/x86/Makefile > Makefile
  export tianlingnh="$(egrep -o "KERNEL_PATCHVER:=[0-9]+\.[0-9]+" Makefile |cut -d "=" -f2)"
  rm -rf Makefile
  clear
  clear
  echo
  echo
  ECHOG "  欢迎使用本脚本,本脚本制作的配置文件只针对我云编译脚本使用,感谢!"
  echo
  echo
  ECHOB "  请选择制作配置文件的源码"
  ECHOY " 1. Lede_${ledenh}内核,LUCI 18.06版本(Lede_source)"
  ECHOYY " 2. Lienol_${lienolnh}内核,LUCI 21.02版本(Lienol_source)"
  echo
  ECHOYY " 3. Immortalwrt_${tianlingnh}内核,LUCI 18.06版本(Tianling_source)"
  ECHOY " 4. Immortalwrt_${mortalnh}内核,LUCI 21.02版本(Mortal_source)"
  ECHOYY " 5. N1和晶晨系列CPU盒子专用(openwrt_amlogic)"
  ECHOY " 6. 退出编译程序"
  echo
  XUANZHEOP="请输入数字"
  while :; do
  read -p " ${XUANZHEOP}： " CHOOSE
  case $CHOOSE in
    1)
      export matrixtarget="Lede_source"
      ECHOG "您选择了：Lede_${ledenh}内核,LUCI 18.06版本"
      openwrt_new
    break
    ;;
    2)
      export matrixtarget="Lienol_source"
      ECHOG "您选择了：Lienol_${lienolnh}内核,LUCI 21.02版本"
      openwrt_new
    break
    ;;
    3)
      export matrixtarget="Tianling_source"
      ECHOG "您选择了：Immortalwrt_${tianlingnh}内核,LUCI 18.06版本"
      openwrt_new
    break
    ;;
    4)
      export matrixtarget="Mortal_source"
      ECHOG "您选择了：Immortalwrt_${mortalnh}内核,LUCI 21.02版本"
      openwrt_new
    break
    ;;
    5)
      export matrixtarget="openwrt_amlogic"
      ECHOG "您选择了：N1和晶晨系列CPU盒子专用"
      openwrt_new
    break
    ;;
    6)
      ECHOR "您选择了退出编译程序"
      exit 0
    break
    ;;
    *)
      XUANZHEOP="请输入正确的数字编号!"
    ;;
    esac
    done
}

function Menu_requirements() {
  op_firmware > /dev/null 2>&1
  source ${GITHUB_WORKSPACE}/CONFIG_DIY/${matrixtarget}/settings.ini > /dev/null 2>&1
  tixing_op_config > /dev/null 2>&1
  cd ${GITHUB_WORKSPACE}
}

function menuop() {
  Menu_requirements
  clear
  echo
  echo
  echo -e " ${Blue}当前使用源码${Font}：${Green}${matrixtarget}${Font}"
  echo -e " ${Blue}CONFIG_DIY配置文件机型${Font}：${Green}${TARGET_PROFILE}${Font}"
  echo
  echo
  echo -e " 1${Green}.${Font}${Yellow}使用[${matrixtarget}]源码,再次制作配置文件${Font}"
  echo
  echo -e " 2${Green}.${Font}${Yellow}更换其他作者源码制作配置文件${Font}"
  echo
  echo -e " 3${Green}.${Font}${Yellow}退出${Font}"
  echo
  echo
  XUANZHE="请输入数字"
  while :; do
  read -p " ${XUANZHE}：" menu_num
  case $menu_num in
  1)
    Tishi="1"
    op_again
  break
  ;;
  2)
    menu
  break
  ;;   
  3)
    exit 0
    break
  ;;
  *)
    XUANZHE="请输入正确的数字编号!"
  ;;
  esac
  done
}

if [[ -d "${HOME_PATH}/package" && -d "${HOME_PATH}/target" && -d "${HOME_PATH}/toolchain" && -d "${GITHUB_WORKSPACE}/CONFIG_DIY" ]]; then
	menuop "$@"
else
	menu "$@"
fi

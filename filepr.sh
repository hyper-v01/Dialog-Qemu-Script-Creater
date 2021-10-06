#!/bin/zsh
export filename=$1
case $filename in
    "disk")
        export file="磁盘镜像文件";;
    "cdrom")
        export file="光盘镜像文件";;
    "floppy")
        export file="软盘镜像文件";;
    "bios")
        export file="BIOS固件";;
    "vmlinuz")
        export file="Linux内核启动文件";;
    "initrd")
        export file="初始化内存盘文件";;
    *|"")
        echo "本程序不能直接运行，正在退出"
        exit;;
esac

function file_path_scan
{
    while true
    do
        dialog --inputbox "输入你的$file 的绝对路径" 40 200 2> path.log
        if (( $? == 1 )); then
            exit
        else
            export sel=$(cat path.log)
            if test -z $sel; then
                dialog --msgbox "请输入正确的路径" 40 200
                rm path.log
            else
                if ! test -d $sel; then
                    dialog --msgbox "没有该目录" 40 200
                    rm path.log
                else
                    if ! echo $sel[$(echo ${#sel})]|grep "/"; then
                        export sel[$[$(echo ${#sel})+1]]="/"
                    fi
                    file_find2 $filename
                    export find=$(cat find.txt)
                    if test -z "$find"; then
                        dialog --msgbox "在$sel 这个目录下找不到$file" 40 200
                        rm find.txt path.log
                        unset sel
                    else
                        file_find
                        rm path.log
                    fi
                fi
            fi
        fi
    done
}

function file_find
{
    export lines=$(cat find.txt|wc -l)
    for ((i=1; i<=$lines; i++))
    do
        echo $i >> dialog.txt
        cat find.txt|tail -n $i|head -n 1 >> dialog.txt
    done
    while true
    do
        dialog --menu "选择一个文件" 40 200 180 $(cat dialog.txt) 2> sel.txt
        if (( $? == 1 )); then
            return
        else
            export sel2=$(cat find.txt|tail -n $(cat sel.txt)|head -n 1)
            rm sel.txt find.txt dialog.txt
            export sel2="$sel$sel2"
            echo $sel2 > sel2_$filename.log
            exit
        fi
    done
}

function file_find2
{
    case $1 in
        "disk")
            if ls $sel|grep -i -E '.img|.vhd|.vhdx|.qcow|.qcow2' &> /dev/null; then
                ls $sel|grep -i -E '.img|.vhd|.vhdx|.qcow|.qcow2' > find.txt
            fi;;
        "cdrom")
            if ls $sel|grep -i -E '.img|.iso|.cdr|.dmg' &> /dev/null; then
                ls $sel|grep -i -E '.img|.iso|.cdr|.dmg' > find.txt
            fi;;
        "floppy")
            if ls $sel|grep -i -E '.img|.vfd' &> /dev/null; then
                ls $sel|grep -i -E '.img|.vfd' > find.txt
            fi;;
        "bios")
            if ls $sel|grep -i -E '.bin|.fd' &> /dev/null; then
                ls $sel|grep -i -E '.bin|.fd' > find.txt
            fi;;
        "vmlinuz")
            if ls $sel|grep -i -E 'vmlinux|vmlinuz|ker' &> /dev/null; then
                ls $sel|grep -i -E 'vmlinux|vmlinuz' > find.txt
            fi;;
        "initrd")
            if ls $sel|grep -i -E 'initrd|initramfs' &> /dev/null; then
                ls $sel|grep -i -E 'initrd|initramfs' > find.txt
            fi;;
    esac
    # clear
    # echo "1"
    # cat find.txt
}
file_path_scan

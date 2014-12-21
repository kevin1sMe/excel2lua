#!/bin/bash
#========================================================================
#   FileName: do_all.sh
#     Author: shimmeryang && kevinlin
#      Desc:  配置生成之统一脚本
#   History:
#   2013年11月8日 14:05:17 kevin 排版了一下此文件，添加了一些注释，并且去除了不应该生成的、过期的配置
# LastChange: 2013-11-08 14:04:50
#   2013年11月13日 21:26:11 shimmeryang 添加一个对lua配置文件进行检查的工具do_test.lua，以后对lua的检查规则都可以放到这里
#   2013年11月13日 22:16:42 shimmeryang 添加版本信息控制，把脚本做成函数样式，看起来上流一点
#   2014年12月15日 13:33:59 kevin  默认使用增量方式来导配置, 以提高配置变更后导出速度
#========================================================================
#版本信息文件
version_file=excel_version.txt
version_lua_template=output/config_version.lua.in
version_lua=output/config_version.lua

LOCK_FILE=lockfile.tmp

#只允许同时一个实例执行 @kevin
if [ -e ${LOCK_FILE} ] ; then
    echo "抱歉，服务器正在执行配置生成，请稍后再试。若一直不成功，来骚扰我们~~"
    exit 0
else
    touch ${LOCK_FILE}
    chmod 600 ${LOCK_FILE}
fi
trap "rm -f ${LOCK_FILE}; exit"  0 1 2 3 9 15


just_do () {
    #-------------------------------------------------------------------------------------
    #2014年12月15日 13:25:51 @kevin 使用增量脚本来生成配置
    ./rapid_do.sh
	return 0
}

copy_to_svr_dir() {
    #-----------------------下面是统一拷贝命令，一般情况不用修改--------------------------
    #NOTE: 如果要添加东西请在上面添加！没事不要修改这里的东西
    #TODO 出错处理？？
    #[ $? -eq 0 ]

    #将配置拷贝到客户端目录
    cp -vf output/config_client*.lua lua

    #将配置拷贝到zonesvr/lua去
    cp -vf output/config_svr*.lua ../zonesvr/lua/

    #拷贝向gamesvr的东西
    cp -vf output/config_svr_dungeon_list.lua ../gamesvr/lua/
    cp -vf output/config_svr_card_list.lua ../gamesvr/lua/
    cp -vf output/config_svr_card_evo_ratio.lua ../gamesvr/lua/
    cp -vf output/config_svr_gem_info_list.lua ../gamesvr/lua/
    cp -vf output/config_svr_weapon_list.lua ../gamesvr/lua/
    cp -vf output/config_svr_weapon_promote_list.lua ../gamesvr/lua/
    cp -vf output/config_svr_weapon_suit_list.lua ../gamesvr/lua/
    cp -vf output/config_svr_weapon_enhance_base.lua ../gamesvr/lua/
    cp -vf output/config_svr_weapon_level_ratio.lua ../gamesvr/lua/
    cp -vf output/config_svr_weapon_refine_list.lua ../gamesvr/lua/
    cp -vf output/config_svr_weapon_atk_ratio.lua ../gamesvr/lua/
    cp -vf output/config_svr_weapon_dfn_ratio.lua ../gamesvr/lua/
    cp -vf output/config_svr_treasure_promote_list.lua ../gamesvr/lua/
    cp -vf output/config_svr_rune_promote_list.lua ../gamesvr/lua/
    cp -vf output/config_svr_fate_list.lua ../gamesvr/lua/
    cp -vf output/config_svr_fate_detail_list.lua ../gamesvr/lua/
    cp -vf output/config_svr_mjbattle.lua ../gamesvr/lua/
    cp -vf output/config_svr_mjteam.lua ../gamesvr/lua/
    cp -vf output/config_svr_adv_activity_list.lua  ../ywtsvr/lua/
    cp -vf output/config_svr_tower_act_rank_reward.lua ../ywtsvr/lua/
    cp -vf output/config_svr_huntianzhen_rank_reward.lua ../ywtsvr/lua/
    cp -vf output/config_svr_card_lv_hp_ratio.lua ../gamesvr/lua/
    cp -vf output/config_svr_card_lv_atk_ratio.lua ../gamesvr/lua/
    cp -vf output/config_svr_bible_info.lua ../gamesvr/lua/


	#拷贝劫宝系统所需的配置
	cp -vf output/config_svr_global_conf.lua ../rob_svr/lua/
	cp -vf output/config_svr_card_list.lua ../rob_svr/lua/
	cp -vf output/config_svr_rob_rc.lua ../rob_svr/lua/

    #guildsvr使用
	cp -vf output/config_svr_guild*.lua ../guildsvr/lua/
    cp -vf output/config_svr_zone_info.lua  ../guildsvr/lua/

    cp -vf output/config_svr_zone_info.lua  ../tcm_cfg/lua/
    cp -vf output/config_svr_zone_info.lua  ../dir/lua/

	#拷贝给guildsvr
    cp -vf output/config_svr_global_conf.lua ../guildsvr/lua/
    cp -vf output/config_svr_guild_player_info.lua ../zonesvr/lua/

    #拷贝全局配置到活跃玩家服务器
	cp -vf output/config_svr_global_conf.lua ../active_player/lua/

    #拷贝一些必要文件到idipsvr去
    cp -vf output/config_svr_goods_info.lua ../idipsvr/lua/
    cp -vf output/DataConfigSvr.lua ../idipsvr/lua/
    # 2014年04月04日 11:46:10/shimmeryang 下面这个文件都不存在了，是不是可以去掉。
    #cp -vf output/GemInfoSvr.lua ../idipsvr/lua/
    cp -vf output/config_svr_card_list.lua ../idipsvr/lua/
    cp -vf output/config_svr_card_evo_ratio.lua ../idipsvr/lua/

    #拷贝以下文件到matchsvr中使用
    cp -vf output/config_svr_mineral_info.lua ../matchsvr/lua/
    cp -vf output/DataConfigSvr.lua ../matchsvr/lua/
    cp -vf output/config_svr_card_list.lua ../matchsvr/lua/
}

#---------------------------------------------------------------------------------
svn_update() {
    svn up
}

#--------------------------------------------------------------------------------------
lua_commit() {
    svn ci -m "commit lua config for client" lua
    # this config_version.lua can not commit, so we add one more line for this file to commit
    svn ci -m "commit config_version.lua again" lua/config_version.lua
    return 0
}

#-----------------------对生成的lua表格做一些检查--------------------------
lua_test() {
    lua do_test.lua
    return 0
}

#------------- 清除掉all_xls_version.*的几个文件，这样生成时会全部配置重新生成一次----
clean_xls_version() {
    rm all_xls_version.*
}

#增加一个版本控制
version_check() {
    old_excel_version=0
    [ -f ${version_file} ] && old_excel_version=`cat ${version_file}`
    excel_version=`svn log  -l 1 excel | egrep '^r[0-9]*' | head -n 1| awk '{print $1}'`

    if [ ${old_excel_version} = ${excel_version} ]; then
        echo "excels had no change, just exit!"
        exit 0
    fi

    return 0
}

version_write() {
    excel_version=`svn log  -l 1 excel | egrep '^r[0-9]*' | awk '{print $1}'`
    sed "s|#VERSION_NUM#|${excel_version}|g" ${version_lua_template} > ${version_lua}
    echo $excel_version > ${version_file}
    return 0
}

version_copy() {
    cp -vf ${version_lua} lua && cp -vf ${version_lua} ../zonesvr/lua/

    return 0
}

backup() {
    server_lua=server_lua
    date=`date "+%Y%m%d"`
    publish=$server_lua/publish_$date
    echo "mkdir $publish"
    mkdir -p $publish
    echo "copy server lua to $publish"
    cp -f output/ErrorCode.lua $publish
    cp output/*Svr.lua $publish
    cp output/config_svr_* $publish
    echo "svn commit new publish server lua"
    svn add $publish
    svn ci -m "backup publish server lua" $publish
    pre_publish=`ls -l $server_lua | tail -n 2 | head -n 1 | awk '{print $NF}'`
    #diff -cN $publish $server_lua/$pre_publish > $server_lua/$date.diff
    diff -E -b -w -t -T -N  -y  -W 150 $publish $server_lua/$pre_publish > $server_lua/$date.diff
    svn add $server_lua/$date.diff
    svn ci -m "add diff file" $server_lua/$date.diff
}

case "$1" in
    do)
        #version_check
        just_do
        copy_to_svr_dir
        version_write
        version_copy
        lua_test
        lua_commit
        RETVAL=$?
    ;;
    full_do)
        svn_update
        clean_xls_version
        just_do
        copy_to_svr_dir
        version_write
        version_copy
        lua_test
        lua_commit
        RETVAL=$?
    ;;
    update_do)
        svn_update
        #version_check
        just_do
        copy_to_svr_dir
        version_write
        version_copy
        lua_test
        lua_commit
        RETVAL=$?
    ;;
    just_do)
        just_do
        copy_to_svr_dir
        version_write
        version_copy
        lua_test
        #lua_commit
        RETVAL=$?
    ;;
    commit)
        lua_commit
        RETVAL=$?
        ;;
    test)
        lua_test
        RETVAL=$?
        ;;
    only_do)
        just_do
        copy_to_svr_dir
        lua_test
        RETVAL=$?
        ;;
    backup)
        backup
        ;;
    *)
        echo $"Usage: $0 {do|just_do|full_do|commit|test|only_do}"
        echo $"do: with version check and commit"
        echo $"just_do: just do with no version check"
        echo $"full_do: clean all and create all config from excel"
        echo $"commit: commit lua/* to svn"
        echo $"test: check lua config validation"
        echo $"only_do: only do, do not do any other thing"
        echo $"update_do: exec svn update before do"
        echo $"backup: backup svr config and make a diff"
esac

exit $RETVAL


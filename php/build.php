<?php
/**
 * 发布apk / ipa / ipa-iTC
 * Created by PhpStorm.
 * User: rhett
 * Date: 15/1/19
 * Time: 20:01
 */

require_once dirname(__FILE__) . "/inc.php";
$appID = 1;
$bundleID = "com.aoaogame.game1";
$template="TianSe";
$debug = 'false';

#gen Folder
$templ = TEMPLATES_ROOT."/".$template;
$gen = GENERATOED_ROOT."/".$template.$appID;
$icon = $gen."/icon";
$assets = $gen."/assets";
new CopyFile($templ,$gen);



# 处理打包
$buildApkCmd = file_get_contents($gen."/build_apk.txt");
$output = $buildApkCmd;
$output = str_replace('${gen}',$gen,$output);
$output = str_replace('${KEYSTORE}',KEYSTORE,$output);
$output = str_replace('${ADT}',ADT,$output);
$output = str_replace('${icon}',$icon,$output);
$output = str_replace('${assets}',$assets,$output);
$output = str_replace('${debug}',$debug,$output);
execCmd($output,"发apk");

# 打包百度广告extra
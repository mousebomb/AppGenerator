<?php
/**
 * Created by PhpStorm.
 * User: rhett
 * Date: 15/1/19
 * Time: 20:32
 */
# 项目路径
define("APP_ROOT",dirname(dirname(__FILE__)));
define("PHP_ROOT",dirname(__FILE__));
define("GENERATOED_ROOT",APP_ROOT."/Generated");
define("TEMPLATES_ROOT",APP_ROOT."/AppTemplates");

# SDK路径
define("FLEX_HOME","/Users/rhett/MyWork/sdks/FlexSDK/4.6.0_air");
define("AIR_SDK_HOME",FLEX_HOME);
define("ADL",FLEX_HOME."/bin/adl");
define("ADT_JAR",FLEX_HOME."/lib/adt.jar");
define("ADT",FLEX_HOME."/bin/adt");
define("AMXMLC",FLEX_HOME."/bin/amxmlc");

define("KEYSTORE",APP_ROOT."/p12/MousebombAndroid.p12");
define("KEYSTORE_IOS",APP_ROOT."/p12/aoaogame_release.p12");
define("KEYSTORE_IOS_DEV",APP_ROOT."/p12/aoaogame_develop.p12");
define("ADHOCPROVISION",APP_ROOT."/p12/aoaoDev.mobileprovision");
define("STOREPASS","ilikeasp");
define("STOREPASS_IOS","aoaogame");



// 递归拷贝文件
include_once(PHP_ROOT."/CopyFile.php");
include_once(PHP_ROOT."/functions.php");

//循环删除目录和文件函数
function delDirAndFile( $dirName )
{
    if ( $handle = opendir( "$dirName" ) ) {
        while ( false !== ( $item = readdir( $handle ) ) ) {
            if ( $item != "." && $item != ".." ) {
                if ( is_dir( "$dirName/$item" ) ) {
                    delDirAndFile( "$dirName/$item" );
                } else {
                    unlink( "$dirName/$item" ) ;
                }
            }
        }
        closedir( $handle );
        rmdir( $dirName );
    }
}
/*
 * 递归创建文件夹
 */
function CreateFolder($dir, $mode = 0777){
    if (is_dir($dir) || @mkdir($dir,$mode)){
        return true;
    }
    if (!CreateFolder(dirname($dir),$mode)){
        return false;
    }
    return @mkdir($dir, $mode);
}

// 输出执行
function execCmd($cmd,$title="")
{
    $cmd = str_replace("\n",' ',$cmd);
    $cmd = str_replace("\r",' ',$cmd);
    echo( date("H:i:s")." 执行 $title <pre> $cmd </pre>");
    exec($cmd,$op);
    echo (date("H:i:s")." $title 结果 <pre>");
    foreach($op as $opLine)
    {
        echo $opLine."\n";
    }
    echo "</pre>";
}

# 读取种子； 获得Gen目录下的inf记录的数据(Array)，已经存入的数据;
function readSeedByAppID($appID)
{
    $toFile = GENERATOED_ROOT."/app".$appID."/_vars.inf";
    return readSeed($toFile);
}
function readSeed($seedFile)
{
    $autoFillData=array();
    $orginData = file_get_contents($seedFile);
    $printrPatten = '/\[(.*)\] => (.*)\n/';
    $matchResult = array();
    preg_match_all($printrPatten,$orginData,$matchResult);

    foreach ($matchResult[1] as $index => $eachMathKey) {

        $autoFillData[$eachMathKey] = $matchResult[2][$index];
    }
    return $autoFillData;
}
#写入种子
function writeSeed($inputDataArr,$toFile)
{
    // 合并输入的字段和已有seed内的字段
    if(file_exists($toFile))
    {
        $autoFillData = readSeed($toFile);
        $out = array_merge($autoFillData,$inputDataArr);
    }else{
        $out = $inputDataArr;
    }
    $out =     print_r($out,true);
    file_put_contents( $toFile,$out);
}
function writeSeedByAppID($inputDataArr,$appID)
{
    $toFile = GENERATOED_ROOT."/app".$appID."/_vars.inf";
    writeSeed($inputDataArr,$toFile);
}

/**
 * 获得app模板 需要上传的列表
 * @param $template String 模板名
 */
function getTemplateUploadList($template)
{
    return getTemplateSetting($template,'uploadlist');
}
function getTemplateReplaceList($template)
{
    return getTemplateSetting($template,'replacelist');
}
// 数组
function getTemplateSetting($template,$settingName)
{
    $end = array();
    $templateUploadListFile = TEMPLATES_ROOT."/".$template."/$settingName.txt";
    $uploadListTxt = file_get_contents($templateUploadListFile);
    $uploadListArr = explode("\n",$uploadListTxt);
    foreach ($uploadListArr as $eachUploadLi)
    {
        if(substr($eachUploadLi,0,1) == "#") continue;
        $end[] = $eachUploadLi;
    }
    return $end;
}

/**
 * KVPair  v:placeholder
 * @param $template
 * @return array
 */
function getTemplateFillvarsList($template)
{
    $end = array();
    $templateUploadListFile = TEMPLATES_ROOT."/".$template."/fillvars.txt";
    $uploadListTxt = file_get_contents($templateUploadListFile);
    $uploadListArr = explode("\n",$uploadListTxt);
    foreach ($uploadListArr as $eachUploadLi)
    {
        if(substr($eachUploadLi,0,1) == "#") continue;
        $index1 = strpos($eachUploadLi,":");
        $index2 = strpos($eachUploadLi,"=");
        $label = substr($eachUploadLi,0,$index1);
        $key = substr($eachUploadLi,$index1+1,$index2-$index1-1);
        $placeholder = substr($eachUploadLi,$index2+1);
        if($label == "") $label = $key;
        $end[$key] = array('label'=>$label,'placeholder'=>$placeholder);
    }
    return $end;
}
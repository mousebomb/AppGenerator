<?php
/**
 * 发布apk / ipa / ipa-iTC
 * Created by PhpStorm.
 * User: rhett
 * Date: 15/1/19
 * Time: 20:01
 */

require_once dirname(__FILE__) . "/inc.php";

$appID=input('id');

$autoFillData=readSeedByAppID($appID);
$template=$autoFillData['template'];
$bundleID = $autoFillData['bundleID'];

#gen Folder
$templ = TEMPLATES_ROOT."/".$template;
$gen = GENERATOED_ROOT."/app".$appID;
$icon = $gen."/icon";
$assets = $gen."/assets";

$debug = 'false';
#
switch($type)
{
    case 'ipa':break;
    case 'apk':break;
    case 'desktop':break;
}

?><!DOCTYPE html>
<html>
<head>
    <title>上传素材文件</title>
    <link rel="stylesheet" href="css/style.css"/>
    <link rel="stylesheet" href="css/general.css"/>
    <link rel="stylesheet" href="css/extra.css"/>

</head>
<body>

<div id="main-menu">
    <a href="edit.php?id=<?php echo $appID; ?>">1.基本信息</a>
    <a href="fill.php?id=<?php echo $appID; ?>">2.填入模板配置</a>
    <a href="upload.php?id=<?php echo $appID; ?>">3.上传素材文件</a>
    <a href="finish.php?id=<?php echo $appID; ?>">4.编译与发布</a>
</div>

<?php

# 处理编译
$compileSwfCmd = file_get_contents($gen."/compile_swf.txt");
$output = $compileSwfCmd;
$output = str_replace('${gen}',$gen,$output);
$output = str_replace('${AMXMLC}',AMXMLC,$output);
$output = str_replace('${FLEX_HOME}',FLEX_HOME,$output);
$output = str_replace('${debug}',$debug,$output);
execCmd($output,"编译游戏");

# 处理打包
$buildApkCmd = file_get_contents($gen."/build_apk.txt");
$output = $buildApkCmd;
$output = str_replace('${gen}',$gen,$output);
$output = str_replace('${KEYSTORE}',KEYSTORE,$output);
$output = str_replace('${ADT}',ADT,$output);
$output = str_replace('${icon}',$icon,$output);
$output = str_replace('${assets}',$assets,$output);
$output = str_replace('${debug}',$debug,$output);
execCmd($output,"打包apk");

# 打包百度广告extra
    echo( date("H:i:s")." 执行 打包百度广告extra <pre>");
    // 寻找apk
    $srcPath = findAPK($gen);
    // 路径
    $apkResultPath = $srcPath . "-result.apk";
    $extraApkPath = $srcPath.".extra.apk";

    $tmpDir = WORK_FOLDER."/tmp";
    $extraSrcPath = WORK_FOLDER ."/extra";

    if(file_exists($tmpDir))
    {dirDel($tmpDir);}
    mkdir($tmpDir);

    $zip = new ZipArchive();
    if($zip->open($srcPath) !==true)
    {
        die("Open apk failed\n");
    }
    $zip->extractTo($tmpDir);
    $zip->close();

    $filesInTmp = scandir($tmpDir);
    if(false !== array_search("extra",$filesInTmp))
    {
        dirDel($tmpDir);
        die("APK已经是extra的了，无需重打包签名\n");
    }

    dirDel($tmpDir."/META-INF/");

    # 压缩新apk
    $zip = new ZipArchive();
    if ($zip->open($extraApkPath, ZIPARCHIVE::CREATE)!==TRUE) {
        exit("无法创建 <$extraApkPath>\n");
    }

    ## 解压出的东西方如更目录
    $basicFiles = listdir($tmpDir);
    foreach ($basicFiles as $file) {
        $localFile =         str_replace("./","",
            str_replace("\\","/",
                str_replace($tmpDir."/","",$file)
            )
        );
        $zip->addFile($file,$localFile);
    //    echo($file . " > $localFile \n");
    }


    ## extra 方如根目录
    $files = listdir($extraSrcPath);
    foreach($files as $filePath)
    {
        $localFile = str_replace("./","",str_replace("\\","/",str_replace(WORK_FOLDER."/","",$filePath)));
        $zip->addFile($filePath,$localFile);
    //    echo($filePath . " > $localFile \n");
    }
    $zip->close();
    echo("嵌入extra完毕，下面开始签名\n");


    # sign
    $signedAPKPath = $extraApkPath.".signed";
    $cmd = sprintf("jarsigner -verbose -keystore %s -STOREPASS %s -signedjar %s %s %s -keypass %s -sigalg SHA1withRSA -digestalg SHA1 "
        ,KEYSTORE_PATH
        ,KEYSTORE_STOREPASS
        ,$signedAPKPath
        ,$extraApkPath
        ,KEYSTORE_ALIAS
        ,KEYSTORE_KEYPASS
    );
    echo "$cmd\n";
    $javaResult = exec($cmd);

    echo "签名完毕，下面开始对apk进行优化\n";
    $alignedAPKPath = $signedAPKPath.".aligned";
    echo exec(WORK_FOLDER."/bin/zipalign -v 4 $signedAPKPath $alignedAPKPath")."\n";
    echo "apk  优化完成\n";


    # clean tmp files
    dirDel($tmpDir);
    rename($alignedAPKPath,$apkResultPath);
    unlink($extraApkPath);
    unlink($signedAPKPath);
    unlink($srcPath);

    echo "Done.结果保存在     ".$apkResultPath."\n</pre>";

# 尝试安装到手机
    execCmd(APP_ROOT."/util/adb install -r ".$apkResultPath,"尝试安装到手机");

?>
</body>
</html>
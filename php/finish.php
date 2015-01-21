<?php
/**
 * 填写数据完毕
 * 替换内容，检测上传的内容是否完整，编译swf 让玩家开始打包
 * Created by PhpStorm.
 * User: rhett
 * Date: 15/1/21
 * Time: 12:08
 */
require_once dirname(__FILE__) . "/inc.php";

$appID=input('id');

$autoFillData=readSeedByAppID($appID);

    // 编译

$androidBuneleID = $autoFillData['androidBuneleID'];
$template=$autoFillData['template'];
$debug = 'false';

#gen Folder
$templ = TEMPLATES_ROOT."/".$template;
$gen = GENERATOED_ROOT."/app".$appID;
$icon = $gen."/icon";
new CopyFile($templ,$gen);

//  替换内容 replacelist.txt ，检测上传的内容 uploadlist.txt 是否完整

# 替换replacelist.txt 要求的内容
$replaceList = getTemplateReplaceList($template);
foreach ($replaceList as $eachReplaceFile)
{
    $output = file_get_contents($templ."/".$eachReplaceFile);
    // 遍历 从填入的配置 替换到文件
    foreach ($autoFillData as $autoFillKey => $autoFillVal)
    {
        $search = sprintf('${%s}',$autoFillKey);
        $output = str_replace($search,$autoFillVal,$output);
    }
    // 替换好的文本，存入gen下的路径
    file_put_contents($gen."/".$eachReplaceFile,$output);
}

# 处理编译
$compileSwfCmd = file_get_contents($gen."/compile_swf.txt");
$output = $compileSwfCmd;
$output = str_replace('${gen}',$gen,$output);
$output = str_replace('${AMXMLC}',AMXMLC,$output);
$output = str_replace('${FLEX_HOME}',FLEX_HOME,$output);
$output = str_replace('${debug}',$debug,$output);
?><!DOCTYPE html>
<html>
<head>
    <title>编译与发布</title>
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


<h1>4.编译与发布</h1>

<ul>
    <li><a href="build.php?id=<?php echo $appID; ?>">编译</a></li>
</ul>


<?php
execCmd($output);

?>


</body>
</html>